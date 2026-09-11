-- MIT. Save-load configuration of the player's native dodge activation rule.
-- No input hooks, global ability scans, or recurring work. Defaults stay untouched.
local M = {}
local CLASS = '/Game/_Dawnwalker/Combat/Abilities/Dodge/GA_Dodge.GA_Dodge_C'
local GUARD = 'Player.Input.Block'
local FIELD = 'ActivationBlockedTags'
local function live(object)
    return object ~= nil and object:IsValid()
end
local function tags(object)
    local values = object[FIELD].GameplayTags
    assert(#values <= 64, 'Unexpected dodge activation tag count')
    local result, found = {}, false
    for i=1,#values do
        local name = values[i].TagName:ToString()
        assert(name:match('^[%w_%.]+$'), 'Unexpected gameplay tag name')
        result[#result+1] = name
        if name == GUARD then found = true end
    end
    return result, found
end
local function write(object, enabled)
    local names = tags(object)
    local target, parents, seen = {}, {}, {}
    for _, name in ipairs(names) do
        if name ~= GUARD then target[#target+1] = name end
    end
    if enabled then target[#target+1] = GUARD end
    local function serialize(values)
        local parts = {}
        for _, name in ipairs(values) do parts[#parts+1] = '(TagName="'..name..'")' end
        return '('..table.concat(parts, ',')..')'
    end
    for _, name in ipairs(target) do
        local parent = name:match('^(.*)%.')
        while parent do
            if not seen[parent] then parents[#parents+1]=parent; seen[parent]=true end
            parent = parent:match('^(.*)%.')
        end
    end
    local property = object:Reflection():GetProperty(FIELD)
    assert(live(property), 'Dodge activation tag property unavailable')
    property:ImportText('(GameplayTags='..serialize(target)..',ParentTags='..serialize(parents)..')',
        property:ContainerPtrToValuePtr(object), 0, object)
    local _, actual = tags(object)
    assert(actual == enabled, 'Dodge activation tag write did not stick')
end

function M.start(resolvePlayer, log, diagnostics)
    local componentClass, dodgeClass
    local ownerAddress, componentAddress, cursor = nil, nil, 1
    local pending, running, dirty, attempts, found = false, false, false, 0, false
    local lastFailure
    local run, schedule
    local function failure(message)
        if message ~= lastFailure then
            lastFailure = message
            log('Dodge while blocking setting: %s', message)
        end
    end
    local function patch(object, player)
        if not live(object) then return false end
        if object:HasAnyFlags(0x3630) then return false end -- defaults/archetypes or loading
        if object:GetClass():GetAddress() ~= dodgeClass:GetAddress() then return false end
        -- GA_Dodge is instanced per actor. Never alter shared class defaults or NPCs.
        assert(object.InstancingPolicy == 1, 'Unsupported dodge ability instancing policy')
        local avatar = object:GetAvatarActorFromActorInfo()
        if not live(avatar) or avatar:GetAddress() ~= player:GetAddress() then return false end
        local address = object:GetAddress()
        local name, classAddress = object:GetFullName(), dodgeClass:GetAddress()
        local function valid()
            if not live(object) or object:HasAnyFlags(0x18000) then return false end
            local class = object:GetClass()
            return live(class) and class:GetAddress() == classAddress and object:GetFullName() == name
        end
        Session.change('dodge-block:'..tostring(address), function()
            if not valid() then return nil, false end
            local _, hasGuard = tags(object)
            return hasGuard
        end, function(value)
            assert(valid(), 'Dodge ability was replaced')
            write(object, value)
            return true -- Yield after a native property restore.
        end, true)
        return true
    end
    local function slice()
        if not live(componentClass) then componentClass=StaticFindObject('/Script/GameplayAbilities.AbilitySystemComponent') end
        if not live(dodgeClass) then dodgeClass=StaticFindObject(CLASS) end
        if not live(componentClass) or not live(dodgeClass) then return 'waiting' end
        local player = resolvePlayer()
        if not live(player) then return 'waiting' end
        local component = player:GetComponentByClass(componentClass)
        if not live(component) then return 'waiting' end
        local pawnId, componentId = player:GetAddress(), component:GetAddress()
        if pawnId ~= ownerAddress or componentId ~= componentAddress then
            ownerAddress, componentAddress, cursor, found = pawnId, componentId, 1, false
        end
        -- Reacquire borrowed specs in every slice; keep only scalar cursors between frames.
        local items = component.ActivatableAbilities.Items
        assert(#items <= 512, 'Unexpected player ability count')
        local started = os.clock()
        for unit=1,8 do
            if cursor > #items then return found and 'done' or 'waiting' end
            local spec = items[cursor]
            cursor = cursor + 1
            local ability = spec.Ability
            if live(ability) and ability:GetClass():GetAddress() == dodgeClass:GetAddress() then
                assert(ability.InstancingPolicy == 1, 'Unsupported dodge ability instancing policy')
                for _, field in ipairs({'NonReplicatedInstances','ReplicatedInstances'}) do
                    local instances = spec[field]
                    assert(#instances <= 1, 'Unexpected per-actor dodge instance count')
                    for i=1,#instances do
                        if patch(instances[i], player) then found=true end
                    end
                end
                return 'more' -- At most one dodge spec is patched in a frame.
            end
            if os.clock()-started >= 0.0005 then return 'more' end
        end
        return 'more'
    end
    schedule = function(delay)
        if pending then return end
        pending = true
        ExecuteInGameThreadWithDelay(delay, run)
    end
    local measuredSlice = diagnostics.wrap('dodgeSetup', slice)
    run = function()
        pending = false
        local ok, outcome = pcall(measuredSlice)
        if not ok then
            running=false; failure(tostring(outcome)); return
        end
        if outcome == 'more' then schedule(16); return end
        if outcome == 'waiting' then
            attempts=attempts+1; cursor=1; found=false
            if attempts < 20 then schedule(100); return end
            running=false
            failure('Player dodge ability not ready; will retry on its next lifecycle event')
            return
        end
        if dirty then dirty=false; cursor=1; found=false; schedule(16); return end
        running=false; lastFailure=nil
        diagnostics.debug('Dodge while blocking disabled through native activation tags')
        diagnostics.flush(true)
    end
    local function wake()
        if running then dirty=true; return end
        running=true; dirty=false; attempts=0; cursor=1; found=false
        schedule(16)
    end
    -- Construction only schedules work. All reflection happens in registered game-thread callbacks.
    local ok, err=pcall(NotifyOnNewObject, CLASS, wake)
    if not ok then failure('Ability notifications unavailable: '..tostring(err)) end
    return wake
end
return M
