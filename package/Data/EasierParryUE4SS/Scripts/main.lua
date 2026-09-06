-- Easier Parry - UE4SS
-- The Blood of Dawnwalker, PC build 25129649 / executable CL-257186.
--
-- Updates the live FGameplayAttributeData on Coen's CharDevAttributeSet. The value is captured
-- from the running game, multiplied from that baseline, and kept applied when the player changes.

local MOD_NAME = "EasierParryUE4SS"
local INI_NAME = "EasierParryUE4SS.ini"
local PLAYER_CLASS = "DawnwalkerPlayerCharacter"
local ATTRIBUTE_SET_FIELD = "CharDevAttributeSet"
local ATTRIBUTE_FIELD = "ParryWindowMultiplier"
local SCRIPT_SOURCE = debug.getinfo(1, "S").source

local config = {
    enabled = true,
    factor = 2.0,
    pollMilliseconds = 1000,
    debugLogging = false,
    dodgeInterruptsGuard = false,
}

local active = nil
local cachedPlayer = nil
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

local function IniPath()
    local source = (SCRIPT_SOURCE or ""):gsub("^@", "")
    local directory = string.match(source, "^(.*)[/\\][^/\\]*$")
    if directory ~= nil and directory ~= "" then return directory .. "/" .. INI_NAME end
    return "ue4ss/Mods/" .. MOD_NAME .. "/Scripts/" .. INI_NAME
end

local function LoadConfig()
    local path = IniPath()
    local file = io.open(path, "r")
    if file == nil then
        Log("WARNING: cannot open %s; keeping factor=%.3f, enabled=%s", path, config.factor, tostring(config.enabled))
        return false
    end
    local contents = file:read("*a")
    file:close()
    if contents == nil then
        Log("WARNING: cannot read %s; keeping current settings", path)
        return false
    end

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
                        Log("WARNING: invalid %s in %s; keeping its default", key, path)
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

local function SaveConfig(saveDodge)
    local path = IniPath()
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
    contents = SetIniValue(contents, "factor", string.format("%.17g", config.factor))
    contents = SetIniValue(contents, "enabled", tostring(config.enabled))
    if saveDodge then contents = SetIniValue(contents, "dodgeinterruptsguard", tostring(config.dodgeInterruptsGuard)) end
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
    Log("Saved factor=%.3f, enabled=%s to %s", config.factor, tostring(config.enabled), path)
    return true
end

local function IsLive(object)
    if object == nil then return false end
    local ok, valid = pcall(function() return object:IsValid() end)
    return ok and valid == true
end

local function Unwrap(value)
    if value == nil then return nil end
    local ok, unwrapped = pcall(function() return value:get() end)
    if ok and unwrapped ~= nil then return unwrapped end
    return value
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

-- GA_Input_CombatDodge calls this reflected native function before GA_Dodge
-- performs its usual activation/state/cost checks. No input keys are hardcoded.
local dodgeHookInstalled = false
local dodgeHookIds = nil
local function EnsureDodgeHook()
    if dodgeHookInstalled then return true end
    if not config.dodgeInterruptsGuard then return false end
    if RegisterHook == nil then
        Log("WARNING: dodge guard interruption unavailable: RegisterHook is missing")
        return false
    end
    local ok, reason = pcall(function()
        local preId, postId = RegisterHook("/Script/DogwoodCombat.CombatComponentBase:TryActivateDodgeAbility", function(context)
            if not config.enabled or not config.dodgeInterruptsGuard then return end
            local released, failure = pcall(function()
                local combat = Unwrap(context)
                if not IsLive(combat) or IsDefaultObject(combat) then return end
                local player = Unwrap(combat:GetCharacter())
                -- Resolve possession on every dodge request. Never retain player objects
                -- across loads, death, or possession changes; never alter an NPC's guard.
                if not IsLive(player) or IsDefaultObject(player)
                    or not player:IsPlayerControlled() or not player:IsLocallyControlled() then return end
                if combat:IsBlocking() and combat:WantsToBlock() then
                    combat:SetDesiredBlockState(false)
                    Debug("Released guard for the player's dodge attempt")
                end
            end)
            if not released then Log("WARNING: dodge guard interruption failed: %s", tostring(failure)) end
            -- Leave the native return value and all normal dodge eligibility checks intact.
        end)
        dodgeHookIds = {preId, postId}
    end)
    if not ok then
        Log("WARNING: could not register dodge guard interruption: %s", tostring(reason))
        return false
    end
    dodgeHookInstalled = true
    Log("Dodge guard interruption hook ready")
    return true
end

local function NearlyEqual(left, right)
    return type(left) == "number" and type(right) == "number"
        and math.abs(left - right) <= 0.0001
end

local function ReadAttribute(attributeSet)
    local ok, raw = pcall(function() return attributeSet[ATTRIBUTE_FIELD] end)
    if not ok or raw == nil then return nil, nil, nil, "attribute property was not readable" end

    raw = Unwrap(raw)
    if type(raw) == "number" then return raw, raw, "number", nil end

    local okBase, base = pcall(function() return Unwrap(raw.BaseValue) end)
    local okCurrent, current = pcall(function() return Unwrap(raw.CurrentValue) end)
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

        local raw = Unwrap(attributeSet[ATTRIBUTE_FIELD])
        raw.BaseValue = base
        raw.CurrentValue = current
    end)
end

local function WriteAttribute(attributeSet, base, current, kind)
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
    local player = cachedPlayer
    if not IsLive(player) then
        local ok
        ok, player = pcall(FindFirstOf, PLAYER_CLASS)
        if not ok or not IsLive(player) or IsDefaultObject(player) then
            player = nil
            local foundAll, players = pcall(FindAllOf, PLAYER_CLASS)
            if foundAll and players ~= nil then
                for _, candidate in pairs(players) do
                    if IsLive(candidate) and not IsDefaultObject(candidate) then
                        player = candidate
                        break
                    end
                end
            end
        end
        cachedPlayer = player
    end
    if not IsLive(player) then
        return nil, nil, "waiting for a live player"
    end

    local gotSet, attributeSet = pcall(function() return Unwrap(player[ATTRIBUTE_SET_FIELD]) end)
    if not gotSet or not IsLive(attributeSet) then
        return player, nil, "waiting for the player's CharDevAttributeSet"
    end
    return player, attributeSet, nil
end

local function RestoreBaseline()
    if active == nil or not IsLive(active.attributeSet) then
        active = nil
        return
    end

    local ok, reason = WriteAttribute(
        active.attributeSet,
        active.baselineBase,
        active.baselineCurrent,
        active.kind
    )
    if ok then
        Log("Restored baseline %.4f / %.4f", active.baselineBase, active.baselineCurrent)
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
        active = nil
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
    if not config.enabled then return end

    -- Global object discovery is only needed when the cache is absent or stale.
    -- Healthy ticks validate the cached objects and read the value; no name lookups,
    -- player resolution, reflection writes, or object-array scans are performed.
    if active == nil or not IsLive(active.attributeSet) or not IsLive(active.player) then
        -- A player can disappear while its attribute set is still live. Restore it
        -- before forgetting the baseline, in case the next player shares that set.
        RestoreBaseline()
        local player, attributeSet, reason = FindPlayerAttributeSet()
        if attributeSet == nil then
            RecordFailure(reason)
            return
        end
        local attached, attachReason = Attach(player, attributeSet)
        if not attached then RecordFailure(attachReason) else lastFailure = nil end
        return
    end

    local attributeSet = active.attributeSet
    local base, current = ReadAttribute(attributeSet)
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
        else
            RecordFailure(repairReason)
        end
    end
end

local function Tick()
    pending = false
    local ok, reason = pcall(Poll)
    if not ok then RecordFailure("runtime error: " .. tostring(reason)) end
end

LoadConfig()
if config.enabled and config.dodgeInterruptsGuard then EnsureDodgeHook() end

if RegisterConsoleCommandHandler ~= nil then
    RegisterConsoleCommandHandler("easierparry", function(fullCommand, parameters, ar)
        local command = string.lower(tostring(parameters[1] or "status"))

        if command == "dodge" then
            local value = ParseBoolean(parameters[2])
            if value == nil then
                Log("Use easierparry dodge on | off (current=%s)", tostring(config.dodgeInterruptsGuard))
                return true
            end
            local previous = config.dodgeInterruptsGuard
            config.dodgeInterruptsGuard = value
            if value and not EnsureDodgeHook() then
                config.dodgeInterruptsGuard = previous
                return true
            end
            SaveConfig(true)
            Log("dodgeInterruptsGuard=%s (mod enabled=%s)", tostring(value), tostring(config.enabled))
            return true
        end

        if command == "status" then
            Log("dodgeInterruptsGuard=%s hookReady=%s", tostring(config.dodgeInterruptsGuard), tostring(dodgeHookInstalled))
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
            RestoreBaseline()
            config.enabled = false
            Log("Disabled")
            SaveConfig()
            return true
        end

        if command == "on" then
            config.enabled = true
            if config.dodgeInterruptsGuard then EnsureDodgeHook() end
            Log("Enabled")
            SaveConfig()
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
            if config.dodgeInterruptsGuard then EnsureDodgeHook() end
            Log("Using factor %.3f", config.factor)
            SaveConfig()
            return true
        end

        Log("Commands: easierparry status | on | off | <factor> | dodge on | dodge off")
        return true
    end)
end

LoopAsync(config.pollMilliseconds, function()
    if not pending then
        pending = true
        ExecuteInGameThread(Tick)
    end
    return false
end)

Log(
    "Loaded (enabled=%s, factor=%.3f, poll=%d ms). Load a save, then check UE4SS.log for 'Applied'.",
    tostring(config.enabled),
    config.factor,
    config.pollMilliseconds
)
