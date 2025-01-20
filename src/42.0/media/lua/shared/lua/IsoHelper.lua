IsoHelper = {}
IsoHelper.readFunction = false

IsoHelper.funcNames = {
    ["IsoDeadBody"] = function(object) return object:getOutfitName() or tostring(object:getObjectID()) end,
    ["IsoPlayer"] = function(object) return object:getUsername(true) end,
    ["IsoZombie"] = function(object) return object:getOutfitName() end,
    ["BaseVehicle"] = function(object) return object:getScript():getName() end,
    ["IsoObject"] = function(object) return object:getSprite():getName() end,
}

IsoHelper.getInfoName = function(isoObject)
    local typeName = tostring(isoObject:getClass())
    local name = nil
    for funcType, funcName in pairs(IsoHelper.funcNames) do
        if instanceof(isoObject, funcType) then
            typeName = funcType
            name = funcName(isoObject)
            break
        end
    end
    local name = name or isoObject:getName() or tostring(isoObject)
    return tostring(typeName or "nil") .. ": " .. tostring(name or "nil")
end

IsoHelper.getInfoClass = function(isoObject)
    local data = {fields={},methods={}}
    local numField = getNumClassFields(isoObject)
    for i = 0, numField - 1 do
        local classField = getClassField(isoObject, i)
        if classField ~= nil then
            local value = getClassFieldVal(isoObject, classField)
            local field = {
                name = classField:getName(),
                type = classField:getType():getName(),
                value = value
            }
            table.insert(data.fields, field)
        end
    end
    if IsoHelper.readFunction then
        local numMethod = getNumClassFunctions(isoObject)
        for i = 0, numMethod - 1 do
            local classMethod = getClassFunction(isoObject, i)
            if classMethod ~= nil then
                local numParameter = getMethodParameterCount(classMethod)
                local value = "?"
                if numParameter == 0 then
                    pcall(function() 
                        value = classMethod:invoke(isoObject)
                    end )
                end
                local method = {
                    name = classMethod:getName(),
                    type = classMethod:getReturnType():getName(),
                    value = value
                }
                table.insert(data.methods, method)
            end
        end
    end
    return data
end