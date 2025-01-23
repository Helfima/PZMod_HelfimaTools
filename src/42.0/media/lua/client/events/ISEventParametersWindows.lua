local UI_BORDER_SPACING = 10
local BUTTON_HGT = getTextManager():getFontHeight(UIFont.Small) + 6

ISEventParametersWindows = ISCollapsableWindow:derive("ISEventParametersWindows");
ISEventParametersWindows.instance = nil
ISEventParametersWindows.largeFontHeight = getTextManager():getFontHeight(UIFont.Large)
ISEventParametersWindows.mediumFontHeight = getTextManager():getFontHeight(UIFont.Medium)
ISEventParametersWindows.smallFontHeight = getTextManager():getFontHeight(UIFont.Small)
ISEventParametersWindows.itemheight = getTextManager():getFontHeight(UIFont.Small)
ISEventParametersWindows.bottomInfoHeight = BUTTON_HGT
ISEventParametersWindows.qwertyConfiguration = true

ISEventParametersWindows.objectList = {}
ISEventParametersWindows.fieldListName = {}
ISEventParametersWindows.textManager = getTextManager()

function ISEventParametersWindows:initialise()
    ISCollapsableWindow.initialise(self);
end

function ISEventParametersWindows:close()
	ISCollapsableWindow.close(self)
end

function ISEventParametersWindows:prerender()
	ISCollapsableWindow.prerender(self)
end

function ISEventParametersWindows:render()
    ISCollapsableWindow.render(self);
end

function ISEventParametersWindows:new(x, y, width, height, character)
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
    o.title = getText("IGUI_EventParametersUI_Title");
    o.character = character;
    o.playerNum = character and character:getPlayerNum() or -1
    o:setResizable(false);
    o.lineH = 10;
    o.fgBar = {r=0, g=0.6, b=0, a=0.7 }
    o:setWantKeyEvents(true);
    return o;
end

function ISEventParametersWindows.openPanel(dataEvent)
    ISEventParametersWindows.OnInstanciatePanel()
    ISEventParametersWindows.dataEvent = dataEvent
    ISEventParametersWindows.instance:updateParameterListBox()
    ISEventParametersWindows.instance:updateParameterListBox()
end

function ISEventParametersWindows.OnInstanciatePanel()
    if ISEventParametersWindows.instance == nil then
        ISEventParametersWindows.instance = ISEventParametersWindows:new(0, 0, 1220, 275, getPlayer());
        ISEventParametersWindows.instance:initialise();
        ISEventParametersWindows.instance:addToUIManager();
        ISEventParametersWindows.instance:setVisible(true);
    else
        ISEventParametersWindows.instance:setVisible(true);
    end
end

function ISEventParametersWindows.OnMouseDownDataList(target, item)
    target:updateDataListBox()
end

function ISEventParametersWindows:createChildren()
    ISCollapsableWindow.createChildren(self)

    local listBoxHeight = 200
    local offset_y = 65
    local offset_x = UI_BORDER_SPACING
    local final_height = listBoxHeight + offset_y + UI_BORDER_SPACING
    self:setHeight(final_height)
    
    local childUI = ISHTScrollingListBox:new(offset_x, offset_y, 200, listBoxHeight)
    childUI:initialise()
    childUI:instantiate()
    childUI:setOnMouseDownFunction(self, self.OnMouseDownDataList)
    childUI.selected = 0
    childUI.joypadParent = self
    childUI.font = UIFont.NewSmall
    childUI.itemheight = self.textManager:getFontHeight(childUI.font)
    childUI.drawBorder = true
    childUI.target = self
    childUI.uiLabel = uiLabel
    childUI:addColumn("Parameter", "name", 250);
    self:addChild(childUI)
    self.parameterListBox = childUI
    local ui_width = 0
    for _, column in pairs(childUI.columns) do
        ui_width = ui_width + column.size
    end
    childUI:setWidth(ui_width)

    local offset_x = ui_width + 2 * UI_BORDER_SPACING

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
    childUI:addColumn("Name", "name", 200);
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
    self:setWidth(offset_x + ui_width + UI_BORDER_SPACING)
end

function ISEventParametersWindows:updateParameterListBox()
    print("ISEventParametersWindows:updateParameterListBox")
    self.parameterListBox:clear()
    if ISEventParametersWindows.dataEvent.parameters ~= nil then
        for key, parameter in pairs(ISEventParametersWindows.dataEvent.parameters) do
            self.parameterListBox:addItem(key, parameter)
        end
    end
end

function ISEventParametersWindows:updateDataListBox()
    print("ISEventParametersWindows:updateDataListBox")
    self.dataListBox:clear()
    local selected = self.parameterListBox.selected or 0
    local item = self.parameterListBox.items[selected]
    if item ~= nil then
        local isoObject = item.item
        local data = IsoHelper.getInfoClass(isoObject)
        
        local sorter = function(t,a,b) return t[b].name > t[a].name end
        for key, field in spairs(data.fields, sorter) do
            self.dataListBox:addItem(field.name, field)
        end
    end
end