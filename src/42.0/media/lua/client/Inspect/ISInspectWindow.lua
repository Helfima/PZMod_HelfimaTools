require "ISUI/ISCollapsableWindow"

local UI_BORDER_SPACING = 10
local BUTTON_HGT = getTextManager():getFontHeight(UIFont.Small) + 6

ISInspectWindow = ISCollapsableWindow:derive("ISInspectWindow");
ISInspectWindow.instance = nil
ISInspectWindow.largeFontHeight = getTextManager():getFontHeight(UIFont.Large)
ISInspectWindow.mediumFontHeight = getTextManager():getFontHeight(UIFont.Medium)
ISInspectWindow.smallFontHeight = getTextManager():getFontHeight(UIFont.Small)
ISInspectWindow.itemheight = getTextManager():getFontHeight(UIFont.Small)
ISInspectWindow.bottomInfoHeight = BUTTON_HGT
ISInspectWindow.qwertyConfiguration = true

ISInspectWindow.objectList = {}
ISInspectWindow.fieldListName = {}
ISInspectWindow.textManager = getTextManager()

function ISInspectWindow:initialise()
    ISCollapsableWindow.initialise(self);
end

function ISInspectWindow:close()
	ISCollapsableWindow.close(self)
end

function ISInspectWindow:prerender()
	ISCollapsableWindow.prerender(self)
end

function ISInspectWindow:render()
    ISCollapsableWindow.render(self);
end

function ISInspectWindow:new(x, y, width, height, character)
    local o = {};
    if x == 0 and y == 0 then
       x = (getCore():getScreenWidth() / 2) - (width / 2);
       y = (getCore():getScreenHeight() / 2) - (height / 2);
    end
    o = ISCollapsableWindow:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    o.anchorLeft = false;
    o.moveWithMouse = true;
    o.LabelDash = "-"
    o.LabelDashWidth = getTextManager():MeasureStringX(UIFont.Small, o.LabelDash)
    o.minimumWidth = width
    o.minimumHeight = height
    o.title = getText("IGUI_InspectUI_Title");
    o.character = character;
    o.playerNum = character and character:getPlayerNum() or -1
    o:setResizable(false);
    o.lineH = 10;
    o.fgBar = {r=0, g=0.6, b=0, a=0.7 }
    o:setWantKeyEvents(true);
    return o;
end

function ISInspectWindow.OnOpenPanel(object, name)
    local selected = 0
    if object ~= nil then
        local objectKey = tostring(object)
        ISInspectWindow.objectList[objectKey] = object
    end
    ISInspectWindow.OnInstanciatePanel()
end

function ISInspectWindow.OnInstanciatePanel()
    if ISInspectWindow.instance == nil then
        ISInspectWindow.instance = ISInspectWindow:new(0,0,600,200,getPlayer());
        ISInspectWindow.instance:initialise();
        ISInspectWindow.instance:addToUIManager();
        ISInspectWindow.instance:setVisible(true);
    else
        ISInspectWindow.instance:setVisible(true);
    end

    ISInspectWindow.instance:updateObjectListBox()
    ISInspectWindow.instance:updateDataListBox()
end

function ISInspectWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local listBoxHeight = 600
    local offset_y = 65
    local offset_x = UI_BORDER_SPACING
    local final_height = listBoxHeight + offset_y + UI_BORDER_SPACING
    self:setHeight(final_height)

    local childUI = ISHTScrollingListBox:new(offset_x, offset_y, 200, listBoxHeight)
    childUI:initialise()
    childUI:instantiate()
    childUI:setOnMouseDownFunction(self, self.onObjectListMouseDown)
    childUI.selected = 0
    childUI.joypadParent = self
    childUI.font = UIFont.NewSmall
    childUI.itemheight = self.textManager:getFontHeight(childUI.font)
    childUI.drawBorder = true
    childUI.target = self
    childUI.uiLabel = uiLabel
    childUI:addColumn("Object", "name", 250);
    self:addChild(childUI)
    self.objectListBox = childUI
    local ui_width = 0
    for _, column in pairs(childUI.columns) do
        ui_width = ui_width + column.size
    end
    childUI:setWidth(ui_width)

    offset_x = offset_x + ui_width + UI_BORDER_SPACING

    childUI = ISHTScrollingListBox:new(offset_x, offset_y, 200, listBoxHeight)
    childUI:initialise()
    childUI:instantiate()
    childUI.selected = 0
    childUI.joypadParent = self
    childUI.font = UIFont.NewSmall
    childUI.itemheight = self.textManager:getFontHeight(childUI.font)
    childUI.drawBorder = true
    childUI.target = self
    childUI.uiLabel = uiLabel
    childUI:addColumn("Field", "name", 200);
    --childUI:addColumn("Modifier", "modifier", 150);
    childUI:addColumn("Type", "type", 250);
    childUI:addColumn("Value", "value", 600);
    self:addChild(childUI)
    self.dataListBox = childUI

    local ui_width = 0
    for _, column in pairs(childUI.columns) do
        ui_width = ui_width + column.size
    end
    childUI:setWidth(ui_width)

    offset_x = offset_x + ui_width + UI_BORDER_SPACING

    childUI = ISHTScrollingListBox:new(offset_x, offset_y, 200, listBoxHeight)
    childUI:initialise()
    childUI:instantiate()
    childUI.selected = 0
    childUI.joypadParent = self
    childUI.font = UIFont.NewSmall
    childUI.itemheight = self.textManager:getFontHeight(childUI.font)
    childUI.drawBorder = true
    childUI.target = self
    childUI.uiLabel = uiLabel
    childUI:addColumn("Data", "name", 400);
    self:addChild(childUI)
    self.dataModBox = childUI

    local ui_width = 0
    for _, column in pairs(childUI.columns) do
        ui_width = ui_width + column.size
    end
    childUI:setWidth(ui_width)

    self:setWidth(offset_x + ui_width + UI_BORDER_SPACING)
end

function ISInspectWindow:onObjectListMouseDown(target, item)
    self:updateDataListBox()
end

function ISInspectWindow:updateObjectListBox()
    self.objectListBox:clear()
    for key, object in pairs(self.objectList) do
        local displayName = IsoHelper.getInfoName(object)
        self.objectListBox:addItem(displayName, object)
    end
end

function ISInspectWindow:updateDataListBox()
    local selected = self.objectListBox.selected or 1
    local item = self.objectListBox.items[selected]
    local isoObject = item.item
    local data = IsoHelper.getInfoClass(isoObject)

    self.dataListBox:clear()
    for key, field in pairs(data.fields) do
        self.dataListBox:addItem(field.name, field)
    end

    self.dataModBox:clear()
    self:parseModData(isoObject)
end

function ISInspectWindow:parseModData(obj)
    local modDataWidth = 150
    local modData = obj and obj.getModData and obj:getModData()
    if modData then
        modDataWidth = self:recursiveTableParse(modData)
    else
        self.dataModBox:addItem("No modData found.", nil)
    end
    return modDataWidth
end


function ISInspectWindow:recursiveTableParse(_t, _ident)
    _ident = _ident or ""
    local tM = getTextManager()
    local stringWidth = 150
    local s
    for k,v in pairs(_t) do
        if type(v)=="table" then
            s = tostring(_ident).."["..tostring(k).."]  =  "
            self.dataModBox:addItem(s, nil)
            self:recursiveTableParse(v, _ident.."    ")
        else
            s = tostring(_ident).."["..tostring(k).."]  =  "..tostring(v)
            self.dataModBox:addItem(s, nil)
        end
        if s then stringWidth = math.max(stringWidth, tM:MeasureStringX(self.dataModBox.font, s)+30) end
    end
    return stringWidth
end