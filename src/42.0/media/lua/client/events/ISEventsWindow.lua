local UI_BORDER_SPACING = 10
local BUTTON_HGT = getTextManager():getFontHeight(UIFont.Small) + 6

ISEventsWindow = ISCollapsableWindow:derive("ISEventsWindow");
ISEventsWindow.instance = nil
ISEventsWindow.largeFontHeight = getTextManager():getFontHeight(UIFont.Large)
ISEventsWindow.mediumFontHeight = getTextManager():getFontHeight(UIFont.Medium)
ISEventsWindow.smallFontHeight = getTextManager():getFontHeight(UIFont.Small)
ISEventsWindow.itemheight = getTextManager():getFontHeight(UIFont.Small)
ISEventsWindow.bottomInfoHeight = BUTTON_HGT
ISEventsWindow.qwertyConfiguration = true

ISEventsWindow.objectList = {}
ISEventsWindow.fieldListName = {}
ISEventsWindow.textManager = getTextManager()

function ISEventsWindow:initialise()
    ISCollapsableWindow.initialise(self);

    HTEventsController.Attach(function() ISEventsWindow.instance:updateDataListBox() end)
end

function ISEventsWindow:close()
	ISCollapsableWindow.close(self)
end

function ISEventsWindow:prerender()
	ISCollapsableWindow.prerender(self)
end

function ISEventsWindow:render()
    ISCollapsableWindow.render(self);
end

function ISEventsWindow:new(x, y, width, height, character)
    local o = {};
    if x == 0 and y == 0 then
       x = (getCore():getScreenWidth() / 4);
       y = (getCore():getScreenHeight() / 4);
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
    o.title = getText("IGUI_EventsUI_Title");
    o.character = character;
    o.playerNum = character and character:getPlayerNum() or -1
    o:setResizable(false);
    o.lineH = 10;
    o.fgBar = {r=0, g=0.6, b=0, a=0.7 }
    o:setWantKeyEvents(true);
    return o;
end

function ISEventsWindow.openPanel()
    ISEventsWindow.OnInstanciatePanel()
    ISEventsWindow.instance:updateDataListBox()
end

function ISEventsWindow.OnInstanciatePanel()
    if ISEventsWindow.instance == nil then
        ISEventsWindow.instance = ISEventsWindow:new(0, 0, 1220, 275, getPlayer());
        ISEventsWindow.instance:initialise();
        ISEventsWindow.instance:addToUIManager();
        ISEventsWindow.instance:setVisible(true);
    else
        ISEventsWindow.instance:setVisible(true);
    end
end

function ISEventsWindow.OnMouseDownDataList(target, dataEvent)
    ISEventParametersWindows.openPanel(dataEvent)
end

function ISEventsWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local listBoxHeight = 200
    local offset_y = 65
    local final_height = listBoxHeight + offset_y + UI_BORDER_SPACING
    self:setHeight(final_height)
    
    local childUI = ISHTScrollingListBox:new(UI_BORDER_SPACING, offset_y, 1200, listBoxHeight)
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
    --childUI:addColumn("Time", "time", 200);
    childUI:addColumn("DispayTime", "time", 200, function(time) return os.date('%Y-%m-%d %H:%M:%S', time) end);
    childUI:addColumn("Event", "name", 250);
    childUI:addColumn("Description", "description", 750);
    self:addChild(childUI)
    self.dataListBox = childUI

    local ui_width = 0
    for _, column in pairs(childUI.columns) do
        ui_width = ui_width + column.size
    end
    childUI:setWidth(ui_width)
    self:setWidth(ui_width + 2 * UI_BORDER_SPACING)
end

function ISEventsWindow:updateDataListBox()
    print("ISEventsWindow:updateDataListBox")
    self.dataListBox:clear()
    print("ISEventsWindow:updateDataListBox", "#dataEvents=", #HTEventsController.dataEvents)
    for i = #HTEventsController.dataEvents, 1, -1 do
        local dataEvent = HTEventsController.dataEvents[i]
        self.dataListBox:addItem(dataEvent.name, dataEvent)
    end
end