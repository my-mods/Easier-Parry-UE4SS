-- MIT. Convert saved timing multipliers to percentages without changing timing.
local M = {}
local backupSuffix = '.before-percentages'
local legacySchema = {
    {key='enabled', default=1, values={0,1}},
    {key='factor', default=2, min=0.1, max=50},
    {key='debugLogging', default=0, values={0,1}},
}
local function replace(store, path, original, updated)
    local backup, temporary = path..backupSuffix, path..backupSuffix..'.new'
    for _, name in ipairs({backup, temporary}) do
        local data, err, code = store.read(name)
        if data or code~=2 then return nil, 'Recover existing settings file: '..name..': '..tostring(err or '') end
    end
    local created, err = store.create(temporary, updated)
    if not created then return nil, err end
    if store.read(temporary)~=updated or store.read(path)~=original then
        os.remove(temporary); return nil, 'Settings changed during percentage conversion'
    end
    local saved, se = os.rename(path, backup)
    if not saved then os.remove(temporary); return nil, se end
    local installed, ie
    if store.read(backup)==original then installed, ie=os.rename(temporary,path)
    else ie='Settings changed before backup' end
    if not installed then
        local restored, re = os.rename(backup,path)
        if restored then os.remove(temporary) end
        return nil, tostring(ie)..(restored and '' or '; recover '..backup..': '..tostring(re))
    end
    if store.read(path)~=updated then return nil, 'Cannot verify settings; recover '..backup end
    return true
end
function M.load(directory, schema, seed)
    local Store = dofile(directory..'SettingsStore.lua')
    local path = Store.path(directory)
    local text, err, code = Store.read(path)
    if not text then
        if code~=2 then return nil, err end
        for _, suffix in ipairs({backupSuffix, backupSuffix..'.new'}) do
            local data, be, bc = Store.read(path..suffix)
            if data or bc~=2 then return nil, 'Recover '..path..suffix..': '..tostring(be or '') end
        end
        return Store.load(directory, schema, seed)
    end
    local values, parseError = Store.parse(text, schema)
    if values then return values end
    if parseError~='Missing setting: parryWindowPercent' then return nil, parseError end
    local legacy, legacyError = Store.parse(text, legacySchema)
    if not legacy then return nil, legacyError end
    local percent = string.format('%.17g', legacy.factor*100)
    local section, replacements = '', 0
    local updated = text:gsub('[^\r\n]+', function(line)
        local clean = line:gsub('^\239\187\191',''):gsub('[;#].*$','')
        local heading = clean:match('^%s*%[([^%]]+)%]%s*$')
        if heading then section=heading end
        if section=='Settings' and clean:match('^%s*factor%s*=') then
            replacements=replacements+1
            local indent, assignment = assert(line:match('^(%s*)factor(%s*=%s*)'))
            local trailing = line:match('(%s*[;#].*)$') or line:match('(%s*)$')
            return indent..'parryWindowPercent'..assignment..percent..trailing
        end
        return line
    end)
    if replacements~=1 then return nil, 'Expected exactly one legacy timing multiplier' end
    values, parseError=Store.parse(updated,schema)
    if not values then return nil, parseError end
    local ok, upgradeError=replace(Store,path,text,updated)
    if not ok then return nil, upgradeError end
    return values
end
return M
