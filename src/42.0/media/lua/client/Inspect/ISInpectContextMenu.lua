local ISInpectContextMenu = {}
ISInpectContextMenu.displayName="Inspect 2"
ISInpectContextMenu.iconPath="media/textures/Search_16x.png"
ISInpectContextMenu.iconTexture=getTexture(ISInpectContextMenu.iconPath)

function ISInpectContextMenu.openInspectView(object, name)
    ISInspectWindow.OnOpenPanel(object, name)
end

--- a context menu for an inventory item
---@param playerNum integer
---@param context ISContextMenu
---@param items {[integer] : InventoryItem} | {[integer] : ContextMenuItemStack}
function ISInpectContextMenu.InventoryObject(playerNum, context, items)
    for i,v in ipairs(items) do
		local item = v
        if not instanceof(v, "InventoryItem") then item = v.items[1] end
        local option = context:addOptionOnTop(ISInpectContextMenu.displayName, item, ISInpectContextMenu.openInspectView, item:getType())
        option.iconTexture = ISInpectContextMenu.iconTexture
        break
	end
end

function ISInpectContextMenu.addContextMenuIsoObjects(contextMenu, isoObjects)
    for i=0,isoObjects:size()-1 do
        local isoObject = isoObjects:get(i)
        local displayName = IsoHelper.getInfoName(isoObject)
        contextMenu:addOption(displayName, isoObject, ISInpectContextMenu.openInspectView, isoObject:getType())
    end
end

--- a world context menu
---@param playerNum integer
---@param context ISContextMenu
---@param worldObjects {[integer] : IsoObject}
---@param test boolean
function ISInpectContextMenu.WorldObject(playerNum, context, worldObjects, test)
    local mainMenu = context:addOptionOnTop(ISInpectContextMenu.displayName, worldObjects, nil)
    mainMenu.iconTexture = ISInpectContextMenu.iconTexture
    local subMenu = ISContextMenu:getNew(context)
    context:addSubMenu(mainMenu, subMenu)

    local square = nil
    for i,object in ipairs(worldObjects) do
        if square == nil then square = object:getSquare() end
        local objectSprite = object:getSprite()
        local props = objectSprite and objectSprite:getProperties()

        local customName = props and props:Is("CustomName") and props:Val("CustomName")
        if customName then
            if props:Is("GroupName") then customName = props:Val("GroupName").." "..customName end
            customName = ": "..customName
        else
            local spriteName = objectSprite and objectSprite:getName()
            customName = ": ".. (spriteName or tostring(object:getClass()))
        end

        local displayName = "IsoObject"..(customName or "")
        subMenu:addOption(displayName, object, ISInpectContextMenu.openInspectView, object:getType())
    end

    if square ~= nil then
        for x=square:getX()-1, square:getX()+1 do
            for y=square:getY()-1, square:getY()+1 do
                local cellSquare = getCell():getGridSquare(x, y, square:getZ())
                if cellSquare then
                    local staticMovingObjects = cellSquare:getStaticMovingObjects()
                    ISInpectContextMenu.addContextMenuIsoObjects(subMenu, staticMovingObjects)

                    local movingObjects = cellSquare:getMovingObjects()
                    ISInpectContextMenu.addContextMenuIsoObjects(subMenu, movingObjects)
                end
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(ISInpectContextMenu.WorldObject)
Events.OnFillInventoryObjectContextMenu.Add(ISInpectContextMenu.InventoryObject)