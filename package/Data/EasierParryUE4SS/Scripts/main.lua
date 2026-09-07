-- Easier Parry - UE4SS
-- The Blood of Dawnwalker, PC build 25129649 / executable CL-257186.
--
-- Updates the live FGameplayAttributeData on Coen's CharDevAttributeSet. The value is captured
-- from the running game, multiplied from that baseline, and kept applied when the player changes.

local MOD_NAME = "EasierParryUE4SS"
local INI_NAME = "EasierParryUE4SS.ini"
local DEFAULTS_NAME = "EasierParryUE4SS.defaults.ini"
local ATTRIBUTE_SET_FIELD = "CharDevAttributeSet"
local ATTRIBUTE_FIELD = "ParryWindowMultiplier"
local SCRIPT_SOURCE = debug.getinfo(1, "S").source

local config = {
    enabled = true,
    factor = 2.0,
    pollMilliseconds = 1000,
    debugLogging = false,
    dodgeInterruptsGuard = false, -- Legacy INI compatibility; native guard assets own this behavior.
}

local active = nil
local engine, gameplayStatics = nil, nil
local bootstrapAttempted = false
local pendingEngine = nil
local pending = false
local lastFailure = nil

local function Log(message, ...)
    local ok, rendered = pcall(string.format, message, ...)
    if not ok then rendered = tostring(message) end
    print(string.format("[%s] %s\n", MOD_NAME, rendered))
end

local function Debug(message, ...)
    if config.debugLogging then Log(message, ...) end
end

local function Trim(value)
    return (tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function ParseBoolean(value)
    local lower = string.lower(Trim(value))
    if lower == "true" or lower == "yes" or lower == "on" or lower == "1" then return true end
    if lower == "false" or lower == "no" or lower == "off" or lower == "0" then return false end
    return nil
end

local function ScriptIniPath(name)
    local source = (SCRIPT_SOURCE or ""):gsub("^@", "")
    local directory = string.match(source, "^(.*)[/\\][^/\\]*$")
    if directory ~= nil and directory ~= "" then return directory .. "/" .. name end
    return "ue4ss/Mods/" .. MOD_NAME .. "/Scripts/" .. name
end

local function IniPath()
    local directory = os.getenv("LOCALAPPDATA")
    if not directory or not (directory:match("^%a:[/\\]") or directory:match("^\\\\")) then return nil end
    return directory:gsub("[/\\]+$", "") .. "/Dawnwalker/Saved/Config/" .. INI_NAME
end

local function ReadIni(path)
    local file, err, code = io.open(path, "rb")
    if not file then return nil, err, code end
    local contents, readError = file:read("*a")
    file:close()
    return contents, readError
end

-- Windows rename refuses an existing destination, including a file created
-- after the initial read. Startup must never replace personal settings.
local function CreateUserIni(path, contents)
    if package.config:sub(1, 1) ~= "\\" then return nil, "Windows is required" end
    local ok, token = pcall(os.tmpname)
    if not ok then return nil, token end
    os.remove(token)
    local basename = token:match("([^/\\]+)$")
    if not basename then return nil, "Invalid temporary filename" end
    local temporary = path .. "." .. basename .. ".tmp"
    local file, err = io.open(temporary, "a+b")
    if not file then return nil, err end
    if file:seek("end") ~= 0 then
        file:close()
        return nil, "Temporary file already occupied"
    end
    local written, writeError = file:write(contents)
    local closed, closeError = file:close()
    if not written or not closed then
        os.remove(temporary)
        return nil, writeError or closeError
    end
    local renamed, renameError = os.rename(temporary, path)
    if not renamed then
        os.remove(temporary)
        local existing, existingError = ReadIni(path)
        return existing, existingError or renameError
    end
    return contents
end

local function ApplyIni(contents, path)
    -- Editors may save a UTF-8 BOM before the first section header.
    contents = contents:gsub("^\239\187\191", "")
    local section = ""
    for line in contents:gmatch("[^\r\n]+") do
        local clean = Trim((line:gsub("[;#].*$", "")))
        local sectionName = string.match(clean, "^%[([^%]]+)%]$")
        if sectionName ~= nil then
            section = string.lower(Trim(sectionName))
        elseif section == "general" and clean ~= "" then
            local key, value = string.match(clean, "^([%w_]+)%s*=%s*(.-)%s*$")
            if key ~= nil then
                key = string.lower(key)
                if key == "enabled" or key == "debuglogging" or key == "dodgeinterruptsguard" then
                    local parsed = ParseBoolean(value)
                    if parsed ~= nil then
                        local field = ({enabled="enabled", debuglogging="debugLogging", dodgeinterruptsguard="dodgeInterruptsGuard"})[key]
                        config[field] = parsed
                    end
                elseif key == "factor" or key == "pollmilliseconds" then
                    local parsed = tonumber(value)
                    if parsed == nil or parsed ~= parsed or math.abs(parsed) == math.huge then
                        Log("WARNING: invalid %s in %s; keeping the inherited value", key, path)
                    elseif key == "factor" then
                        config.factor = math.max(0.1, math.min(50.0, parsed))
                    else
                        config.pollMilliseconds = math.floor(math.max(100, math.min(5000, parsed)))
                    end
                end
            end
        end
    end
    Log("Loaded configuration from %s (factor=%.3f, enabled=%s)", path, config.factor, tostring(config.enabled))
    return true
end

local function LoadConfig()
    local defaultsPath = ScriptIniPath(DEFAULTS_NAME)
    local defaults, defaultsError = ReadIni(defaultsPath)
    if defaults == nil then
        Log("WARNING: cannot read shipped defaults %s: %s", defaultsPath, tostring(defaultsError))
        return false
    end
    ApplyIni(defaults, defaultsPath)
    local path = IniPath()
    if path == nil then
        Log("WARNING: LOCALAPPDATA unavailable; personal settings cannot be located")
        return false
    end
    local personal, err, code = ReadIni(path)
    if personal == nil and code == 2 then
        local legacy, legacyError, legacyCode = ReadIni(ScriptIniPath(INI_NAME))
        if legacy == nil and legacyCode ~= 2 then
            Log("WARNING: cannot read legacy INI for migration: %s", tostring(legacyError))
            return false
        end
        local initial = legacy or table.concat({
            "; Personal Easier Parry settings - preserved across mod updates.",
            "; Only uncomment settings you want to override, then restart the game.",
            "; Omitted settings inherit EasierParryUE4SS.defaults.ini from the mod.",
            "; Console commands update only the settings they change in this file.",
            "", "[General]", "; enabled = true", "; factor = 2.0",
            "; pollMilliseconds = 1000", "; debugLogging = false",
            "; Guard recovery is native and always active; the old dodge option is ignored.", "",
        }, "\n")
        personal, err = CreateUserIni(path, initial)
        if personal ~= nil then Log("Personal INI ready at %s", path) end
    end
    if personal == nil then
        Log("WARNING: cannot read/create personal INI %s: %s. Ensure Saved/Config exists, then restart; personal settings were not replaced.", path, tostring(err))
        return false
    end
    ApplyIni(personal, path)
    return true
end

-- Patch only the selected setting in [General], retaining comments and other keys.
local function SetIniValue(contents, key, value)
    local section, found, hasGeneral = "", false, false
    local newline = contents:find("\r\n", 1, true) and "\r\n" or "\n"
    local function Header(line)
        local clean = Trim((line:gsub("^\239\187\191", ""):gsub("[;#].*$", "")))
        local name = clean:match("^%[([^%]]+)%]$")
        return name and string.lower(Trim(name))
    end
    contents = contents:gsub("[^\r\n]+", function(line)
        local header = Header(line)
        if header then
            section = header
            if header == "general" then hasGeneral = true end
        elseif section == "general" then
            local prefix, name = line:match("^(%s*([%w_]+)%s*=%s*)")
            if name and string.lower(name) == key then
                found = true
                local suffix = line:match("([ \t]*[;#].*)$") or line:match("([ \t]*)$") or ""
                return prefix .. value .. suffix
            end
        end
        return line
    end)
    if found then return contents end
    if not hasGeneral then
        if contents ~= "" and not contents:match("[\r\n]$") then contents = contents .. newline end
        return contents .. "[General]" .. newline .. key .. " = " .. value .. newline
    end
    local inserted = false
    return (contents:gsub("[^\r\n]+", function(line)
        if not inserted and Header(line) == "general" then
            inserted = true
            return line .. newline .. key .. " = " .. value
        end
        return line
    end))
end

local function SaveConfig(keys)
    local path = IniPath()
    if not path then Log("WARNING: personal INI path unavailable; settings remain active for this session"); return false end
    -- Read only to preserve unrelated edits; these bytes never replace session settings.
    local file, _, code = io.open(path, "rb")
    local contents = ""
    if file then
        contents = file:read("*a")
        file:close()
    elseif code ~= 2 then
        contents = nil
    end
    if contents == nil then
        Log("WARNING: could not read %s for saving; settings remain active for this session", path)
        return false
    end
    for _, key in ipairs(keys) do
        local value = key == "factor" and string.format("%.17g", config[key]) or tostring(config[key])
        contents = SetIniValue(contents, string.lower(key), value)
    end
    file = io.open(path, "wb")
    if file == nil then
        Log("WARNING: could not save %s; settings remain active for this session", path)
        return false
    end
    local written = file:write(contents)
    local closed = file:close()
    if not written or not closed then
        Log("WARNING: saving %s failed; settings remain active for this session", path)
        return false
    end
    Log("Saved %s to %s", table.concat(keys, ", "), path)
    return true
end

local function IsLive(object)
    if object == nil then return false end
    local ok, valid = pcall(function() return object:IsValid() end)
    return ok and valid == true
end

local function SafeName(object)
    if object == nil then return "<nil>" end
    local ok, name = pcall(function() return object:GetFullName() end)
    if ok and name ~= nil then return tostring(name) end
    return tostring(object)
end

local function IsDefaultObject(object)
    return string.find(SafeName(object), "Default__", 1, true) ~= nil
end

-- Guard input and dodge suspension are handled by the native ability assets.
-- This script only maintains the configurable parry timing attribute.

local function NearlyEqual(left, right)
    return type(left) == "number" and type(right) == "number"
        and math.abs(left - right) <= 0.0001
end

local function ReadAttribute(attributeSet)
    if not IsLive(attributeSet) then return nil, nil, nil, "attribute owner is not live" end
    local ok, raw = pcall(function() return attributeSet[ATTRIBUTE_FIELD] end)
    if not ok or raw == nil then return nil, nil, nil, "attribute property was not readable" end

    if type(raw) == "number" then return raw, raw, "number", nil end

    -- FGameplayAttributeData is already a struct view, not a parameter wrapper.
    -- Keep it local to this read so no struct view survives a player replacement.
    local okBase, base = pcall(function() return raw.BaseValue end)
    local okCurrent, current = pcall(function() return raw.CurrentValue end)
    if okBase and okCurrent and type(base) == "number" and type(current) == "number" then
        return base, current, "struct", nil
    end

    return nil, nil, nil, "FGameplayAttributeData values were not readable"
end

local function NumberText(value)
    return string.format("%.9g", value)
end

local function WriteWithReflection(attributeSet, base, current, kind)
    return pcall(function()
        local property = attributeSet:Reflection():GetProperty(ATTRIBUTE_FIELD)
        if property == nil or not property:IsValid() then error("property reflection failed") end

        local valueText = NumberText(current)
        if kind == "struct" then
            valueText = string.format("(BaseValue=%s,CurrentValue=%s)", NumberText(base), NumberText(current))
        end

        property:ImportText(
            valueText,
            property:ContainerPtrToValuePtr(attributeSet),
            0,
            attributeSet
        )
    end)
end

local function WriteDirect(attributeSet, base, current, kind)
    return pcall(function()
        if kind == "number" then
            attributeSet[ATTRIBUTE_FIELD] = current
            return
        end

        local raw = attributeSet[ATTRIBUTE_FIELD]
        raw.BaseValue = base
        raw.CurrentValue = current
    end)
end

local function WriteAttribute(attributeSet, base, current, kind)
    if not IsLive(attributeSet) then return false, "attribute owner is not live" end
    local ok = WriteWithReflection(attributeSet, base, current, kind)
    if not ok then ok = WriteDirect(attributeSet, base, current, kind) end
    if not ok then return false, "both reflection and direct writes failed" end

    local actualBase, actualCurrent = ReadAttribute(attributeSet)
    if not NearlyEqual(actualBase, base) or not NearlyEqual(actualCurrent, current) then
        return false, string.format(
            "write did not stick (wanted %.4f/%.4f, read %s/%s)",
            base,
            current,
            tostring(actualBase),
            tostring(actualCurrent)
        )
    end
    return true, nil
end

local function FindPlayerAttributeSet()
    -- Engine/CDO discovery happens once per startup (or explicit 'on'), never
    -- once per missing player. Construction callbacks only hand off a reference.
    if pendingEngine ~= nil then
        if IsLive(pendingEngine) and not IsDefaultObject(pendingEngine) then
            engine = pendingEngine
        end
        pendingEngine = nil
    end
    if not bootstrapAttempted then
        bootstrapAttempted = true
        local ok = pcall(function()
            if not IsLive(engine) then engine = FindFirstOf("Engine") end
            gameplayStatics = StaticFindObject("/Script/Engine.Default__GameplayStatics")
        end)
        if not ok or not IsLive(engine) or not IsLive(gameplayStatics) then
            Log("WARNING: player resolver unavailable; use easierparry on to retry after loading")
        end
    end
    if not IsLive(engine) or not IsLive(gameplayStatics) then
        return nil, nil, "waiting for the game engine"
    end
    -- The viewport follows the current world. A cached pawn/controller can
    -- remain valid AND locally controlled in the world left by a save load.
    -- Index zero resolves one local player, without a global UObject scan.
    local viewport = engine.GameViewport
    if not IsLive(viewport) then return nil, nil, "waiting for the game viewport" end
    local player = gameplayStatics:GetPlayerPawn(viewport, 0)
    if not IsLive(player) or not player:IsPlayerControlled() or not player:IsLocallyControlled() then
        return nil, nil, "waiting for the local player's possessed pawn"
    end
    local attributeSet = player[ATTRIBUTE_SET_FIELD]
    if not IsLive(attributeSet) then
        return player, nil, "waiting for the player's CharDevAttributeSet"
    end
    return player, attributeSet, nil
end

local function SameObject(left, right)
    -- UE4SS may return a new Lua wrapper for the same native object.
    return IsLive(left) and IsLive(right) and left:GetAddress() == right:GetAddress()
end

local function RestoreBaseline()
    if active == nil or not IsLive(active.attributeSet) then
        active = nil
        return
    end

    -- Do not overwrite a value recalculated by the game while we were detached.
    local base, current = ReadAttribute(active.attributeSet)
    if base == nil then active = nil; return end
    local restoredBase = NearlyEqual(base, active.targetBase) and active.baselineBase or base
    local restoredCurrent = NearlyEqual(current, active.targetCurrent) and active.baselineCurrent or current
    if NearlyEqual(base, restoredBase) and NearlyEqual(current, restoredCurrent) then
        active = nil
        return
    end
    local ok, reason = WriteAttribute(
        active.attributeSet,
        restoredBase,
        restoredCurrent,
        active.kind
    )
    if ok then
        Log("Released timing override %.4f / %.4f", restoredBase, restoredCurrent)
    else
        Log("WARNING: could not restore the baseline: %s", tostring(reason))
    end
    active = nil
end

local function Attach(player, attributeSet)
    local base, current, kind, reason = ReadAttribute(attributeSet)
    if base == nil then return false, reason end

    active = {
        attributeSet = attributeSet,
        player = player,
        baselineBase = base,
        baselineCurrent = current,
        targetBase = base * config.factor,
        targetCurrent = current * config.factor,
        kind = kind,
    }

    local ok, writeReason = WriteAttribute(
        attributeSet,
        active.targetBase,
        active.targetCurrent,
        kind
    )
    if not ok then
        -- A write can fail after changing only one field. Retain its baseline
        -- and target so the next tick repairs it instead of multiplying again.
        return false, writeReason
    end

    Log(
        "Applied x%.3f: ParryWindowMultiplier %.4f/%.4f -> %.4f/%.4f",
        config.factor,
        base,
        current,
        base * config.factor,
        current * config.factor
    )
    return true, nil
end

local function RecordFailure(reason)
    if reason ~= lastFailure then
        Debug("%s", tostring(reason))
        lastFailure = reason
    end
end

local function Poll()
    if not config.enabled then return "disabled" end

    local player, attributeSet, reason = FindPlayerAttributeSet()
    if attributeSet == nil then
        -- Keep the numeric baseline during temporary unpossession, but never
        -- repair a detached set. Repossession of that same set must not compound.
        RecordFailure(reason)
        return "waiting"
    end
    if active == nil or not SameObject(active.attributeSet, attributeSet) then
        -- Release only our unchanged value before handing over. This also avoids
        -- compounding if a later possession returns to the previous live set.
        RestoreBaseline()
        local attached, attachReason = Attach(player, attributeSet)
        if not attached then RecordFailure(attachReason); return "error" end
        lastFailure = nil
        return "attach"
    end

    active.player = player

    local attributeSet = active.attributeSet
    local base, current, _, reason = ReadAttribute(attributeSet)
    if base == nil then
        RecordFailure(reason)
        return "error"
    end
    if not NearlyEqual(base, active.targetBase) or not NearlyEqual(current, active.targetCurrent) then
        local repaired, repairReason = WriteAttribute(
            attributeSet,
            active.targetBase,
            active.targetCurrent,
            active.kind
        )
        if repaired then
            Debug("Reapplied the runtime value after the game recalculated it")
            lastFailure = nil
            return "repair"
        else
            RecordFailure(repairReason)
            return "error"
        end
    end
end

-- Debug-only wall-time sampling around the timing worker, including native calls.
-- Windows CRT os.clock has millisecond granularity: zero is not proof of zero cost.
-- No profiler timers, object lookups, or retained samples; only fixed-size counters.
local perf, queuedAt = nil, nil
local PERF_REPORT_LIMIT = 120
local function PerfClock()
    local ok, value = pcall(os.clock)
    if ok and type(value) == "number" and value >= 0 and value < math.huge then return value end
    return nil
end
local function NewPerf(now)
    return {count=0, total=0, max=0, queueMax=0, slow=0, errors=0,
        attach=0, repair=0, waiting=0, reports=0, lastReport=now,
        worstPhase="none", lastError="none"}
end
local function PerfReport(label, now, automatic)
    if not perf then Log("PERF %s: no timing samples collected", label); return end
    if automatic and perf.reports >= PERF_REPORT_LIMIT then return end
    if automatic then perf.reports = perf.reports + 1 end
    perf.lastReport = now
    Log("PERF %s: samples=%d avg=%.3fms max=%.3fms worst=%s slow(>=5ms)=%d queueMax=%.3fms attach=%d repair=%d wait=%d errors=%d lastError=%s; worker only, excludes summary logging; os.clock ms granularity",
        label, perf.count, perf.total / math.max(1, perf.count), perf.max,
        perf.worstPhase, perf.slow, perf.queueMax, perf.attach, perf.repair,
        perf.waiting, perf.errors, perf.lastError)
    if automatic and perf.reports == PERF_REPORT_LIMIT then
        Log("PERF automatic output limit reached; use easierparry debug status for totals or debug on to start a new capture")
    end
end

local function Tick()
    pending = false
    local start = config.debugLogging and PerfClock() or nil
    local queued = queuedAt
    queuedAt = nil
    local bootstrapping = not bootstrapAttempted
    local ok, outcome = pcall(Poll)
    if not ok then RecordFailure("runtime error: " .. tostring(outcome)) end
    if not config.debugLogging then return end
    local finish = PerfClock()
    if not start or not finish or finish < start then
        if not perf or not perf.clockFailed then
            Log("PERF clock unavailable or moved backwards; sample discarded")
        end
        perf = perf or NewPerf(0)
        perf.clockFailed = true
        return
    end
    perf = perf or NewPerf(start)
    perf.clockFailed = false
    local elapsed = math.floor((finish - start) * 1000 + 0.5)
    local phase = bootstrapping and "bootstrap" or (ok and (outcome or "steady") or "error")
    perf.count = perf.count + 1
    perf.total = perf.total + elapsed
    if elapsed >= perf.max then perf.max = elapsed; perf.worstPhase = phase end
    if queued and queued <= start then perf.queueMax = math.max(perf.queueMax, math.floor((start-queued)*1000 + 0.5)) end
    if elapsed >= 5 then perf.slow = perf.slow + 1 end
    if outcome == "attach" then perf.attach = perf.attach + 1 end
    if outcome == "repair" then perf.repair = perf.repair + 1 end
    if outcome == "waiting" then perf.waiting = perf.waiting + 1 end
    if not ok or outcome == "error" then
        perf.errors = perf.errors + 1
        perf.lastError = tostring(lastFailure or outcome):sub(1,240):gsub("[\r\n]", " ")
    end
    -- First sample includes bootstrap. Afterwards at most one line per five
    -- seconds during slow work, otherwise one per thirty seconds. Totals persist.
    if perf.count == 1 or finish-perf.lastReport >= 30
        or (elapsed >= 5 and finish-perf.lastReport >= 5) then
        PerfReport("summary", finish, true)
    end
end

if not LoadConfig() then return end
-- No reflected reads in the construction callback; the next maintenance tick
-- observes readiness on the game thread. Missing notifications never cause scans.
local notified, notifyError = pcall(function()
    NotifyOnNewObject("/Script/Engine.Engine", function(object)
        pendingEngine = object
    end)
end)
if not notified then
    Log("WARNING: engine replacement notification unavailable: %s", tostring(notifyError))
end
-- One diagnostics switch controls both timing summaries and guard tracing.
local guardTraceControl
local function SetGuardTracing(enabled)
    if not enabled and not guardTraceControl then return end
    local ok, err = pcall(function()
        if guardTraceControl then
            guardTraceControl(enabled)
        elseif enabled then
            guardTraceControl = dofile(ScriptIniPath("GuardTrace.lua"))(Log)
        end
    end)
    if not ok then Log("GuardTrace failed: %s", tostring(err)) end
end
SetGuardTracing(config.debugLogging)

local function HandleCommand(command, argument)
    if command == "debug" then
        if argument == "on" then
            config.debugLogging = true
            SetGuardTracing(true)
            perf, queuedAt = nil, nil
            Log("Debug logging enabled for this session; PERF captures worker time and queue delay, not whole-game frame time")
        elseif argument == "off" then
            if config.debugLogging then PerfReport("final", PerfClock() or 0, false) end
            config.debugLogging = false
            SetGuardTracing(false)
            perf, queuedAt = nil, nil
            Log("Debug logging disabled for this session")
        else
            Log("Debug logging enabled=%s; commands: easierparry debug on | off | status", tostring(config.debugLogging))
            if config.debugLogging then PerfReport("status", PerfClock() or 0, false) end
        end
        return true
    end

    if command == "dodge" then
        Log("Guard recovery now uses native game abilities and is always active while this mod is installed. The old dodge toggle is retired; your personal INI is preserved.")
        return true
    end

    if command == "status" then
        Log("Native held-guard fixes are supplied by the installed game assets; enabled controls the timing multiplier only.")
        if active ~= nil then
            Log(
                "enabled=%s factor=%.3f baseline=%.4f/%.4f target=%.4f/%.4f",
                tostring(config.enabled),
                config.factor,
                active.baselineBase,
                active.baselineCurrent,
                active.targetBase,
                active.targetCurrent
            )
        else
            Log("enabled=%s factor=%.3f; waiting for a player", tostring(config.enabled), config.factor)
        end
        return true
    end

    if command == "off" then
        config.enabled = false
        RestoreBaseline()
        Log("Parry timing disabled; native guard fixes remain active.")
        SaveConfig({"enabled"})
        return true
    end

    if command == "on" then
        bootstrapAttempted = false
        config.enabled = true
        Log("Parry timing enabled; native guard fixes remain active.")
        SaveConfig({"enabled"})
        return true
    end

    if command == "reload" then
        Log("Settings are loaded once at startup. Use easierparry <factor>, on or off to change and save them.")
        return true
    end

    local runtimeFactor = tonumber(command)
    if runtimeFactor ~= nil and runtimeFactor == runtimeFactor and math.abs(runtimeFactor) ~= math.huge then
        RestoreBaseline()
        config.factor = math.max(0.1, math.min(50.0, runtimeFactor))
        config.enabled = true
        Log("Using factor %.3f", config.factor)
        SaveConfig({"factor", "enabled"})
        return true
    end

    Log("Commands: easierparry status | on | off | <factor> | debug on/off/status")
    return true
end

if RegisterConsoleCommandHandler ~= nil then
    RegisterConsoleCommandHandler("easierparry", function(fullCommand, parameters, ar)
        -- Copy only owned text into the deferred callback, never callback parameters.
        local command = string.lower(tostring(parameters[1] or "status"))
        local argument = string.lower(tostring(parameters[2] or "status"))
        ExecuteInGameThread(function() HandleCommand(command, argument) end)
        return true
    end)
end

LoopAsync(config.pollMilliseconds, function()
    if config.enabled and not pending then
        pending = true
        queuedAt = config.debugLogging and PerfClock() or nil
        ExecuteInGameThread(Tick)
    end
    return false
end)

Log(
    "Loaded (enabled=%s, factor=%.3f, poll=%d ms, debug=%s). Load a save, then check UE4SS.log for 'Applied'.",
    tostring(config.enabled),
    config.factor,
    config.pollMilliseconds,
    tostring(config.debugLogging)
)
