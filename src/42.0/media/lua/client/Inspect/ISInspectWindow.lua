require "ISUI/ISCollapsableWindow"

local UI_BORDER_SPACING = 10
local BUTTON_HGT = getTextManager():getFontHeight(UIFont.Small) + 6

ISInspectWindow = ISCollapsableWindow:derive("ISInspectWindow");
ISScrollingListBox.stopPrerender = false
ISInspectWindow.path = "PZMod_HelfimaTools/42.0/media/lua/client/Inspect/ISInspectWindow.lua"
ISInspectWindow.instance = nil
ISInspectWindow.largeFontHeight = getTextManager():getFontHeight(UIFont.Large)
ISInspectWindow.mediumFontHeight = getTextManager():getFontHeight(UIFont.Medium)
ISInspectWindow.smallFontHeight = getTextManager():getFontHeight(UIFont.Small)
ISInspectWindow.bottomInfoHeight = BUTTON_HGT
ISInspectWindow.qwertyConfiguration = true
ISInspectWindow.bottomTextSpace = "     "

ISInspectWindow.objectList = {}
ISInspectWindow.fieldListName = {}
ISInspectWindow.textManager = getTextManager()
ISInspectWindow.itemheight = 25
ISInspectWindow.columns = {
    {name="column1", size=100},
    {name="column2", size=100},
    {name="column2", size=100}
}

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
    -- add that length to the extra width that's guaranteed
    --local rightSide = UI_BORDER_SPACING*3 + 42 + recipeWidth + 2
    -- the recipe list on the left side is 3/10 of the total width, so divide the right side width by 7, and multiply by 3 to get the left side width
    --local leftSide = (rightSide / 7) * 3
    -- now take the max length between the above width, and the width of the text at the bottom of the window
    --o.minimumWidth = math.max(getTextManager():MeasureStringX(UIFont.Small, o.bottomInfoText1)+UI_BORDER_SPACING*2+2, leftSide+rightSide+1)
    o.minimumWidth = width
    o:setWidth(o.minimumWidth)
    o.minimumHeight = 600+(getCore():getOptionFontSizeReal()-1)*60
    o.title = getText("IGUI_InspectUI_Title");
    o.character = character;
    o.playerNum = character and character:getPlayerNum() or -1
    o:setResizable(true);
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
        ISInspectWindow.instance = ISInspectWindow:new(0,0,1200,600,getPlayer());
        ISInspectWindow.instance:initialise();
        ISInspectWindow.instance:addToUIManager();
        ISInspectWindow.instance:setVisible(true);
    else
        ISInspectWindow.instance:setVisible(true);
    end

    ISInspectWindow.instance:updateObjectListBox()
    ISInspectWindow.instance:updateDataListBox()
end

function ISInspectWindow:drawItemList(y, item, alt)
    local a = 0.9
    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15)
    end
    self:drawText( item.text, 10, y + 2, 1, 1, 1, a, self.font)
    return y + self.itemheight
end

function ISInspectWindow:addColumn(columnName, attribute, size)
	table.insert(self.columns, {name = columnName, attribute = attribute, size = size});
end

function ISInspectWindow:drawColumnList(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end
    
    local a = 0.9;

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15);
    end

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.6, 0.5, 0.5);
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    local xoffset = UI_BORDER_SPACING;

    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)
    
    local is_need_repaint = false
    for i = 1, #self.columns, 1 do
        local value = tostring(item.item[self.columns[i].attribute] or "nil")
        local clipX = self.columns[i].size
        if i < #self.columns then
            local clipX2 = self.columns[i + 1].size
            self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
            self:drawText(value, clipX + xoffset, y + 3, 1, 1, 1, a, self.font);
            self:clearStencilRect()
            is_need_repaint = true
        else
            self:drawText(value, clipX + xoffset, y + 3, 1, 1, 1, a, self.font);
        end
    end
    if is_need_repaint then
        self:repaintStencilRect(0, clipY, self.width - 10, clipY2 - clipY)
    end

    return y + self.itemheight;
end

function ISInspectWindow:createScrollingListBox(x, y, width, height, title)
    local uiLabel = ISLabel:new(x, y, 22, title, 1, 1, 1, 1, UIFont.Small, true);
    self:addChild(uiLabel);

    local childUI = ISScrollingListBox:new(x, y + 60, width, height)
    childUI:initialise()
    childUI:instantiate()
    childUI.selected = 0
    childUI.joypadParent = self
    childUI.font = UIFont.NewSmall
    childUI.itemheight = self.textManager:getFontHeight(childUI.font)
    childUI.drawBorder = true
    childUI.target = self
    childUI.uiLabel = uiLabel
    self:addChild(childUI)
    return childUI
end

function ISInspectWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local listBoxHeight = self.height - 100
    
    self.objectListBox = self:createScrollingListBox(10, 65, 150, listBoxHeight, "Objects")
    self.objectListBox.doDrawItem = self.drawItemList
    self.objectListBox:setOnMouseDownFunction(self, self.onObjectListMouseDown)
    self.objectListBox.addColumn = self.addColumn
    self.objectListBox:addColumn("Name", "name", 0);
    
    self.dataListBox = self:createScrollingListBox(220, 65, 150, listBoxHeight, "Data")
    self.dataListBox.doDrawItem = self.drawColumnList
    self.dataListBox.addColumn = self.addColumn
    self.dataListBox:addColumn("Name", "name", 0);
    self.dataListBox:addColumn("Type", "type", 200 + (getCore():getOptionFontSizeReal()*20));
    self.dataListBox:addColumn("Value", "value", 400 + (getCore():getOptionFontSizeReal()*20));
end

function ISInspectWindow:onObjectListMouseDown(target, item)
    self:updateDataListBox()
end

function ISInspectWindow:updateObjectListBox()
    local objectListWidth = 150
    self.objectListBox:clear()
    for key, object in pairs(self.objectList) do
        local displayName = IsoHelper.getInfoName(object)
        self.objectListBox:addItem(displayName, object)
        objectListWidth = math.max(objectListWidth, self.textManager:MeasureStringX(self.objectListBox.font, displayName) + 65)
    end
    self.objectListBox.selected = #self.objectListBox.items
    self.objectListBox:setWidth(objectListWidth)

    self.dataListBox:setX(objectListWidth + 15)
    self.dataListBox.uiLabel:setX(objectListWidth + 15)
end

function ISInspectWindow:updateDataListBox()
    local selected = self.objectListBox.selected
    local item = self.objectListBox.items[selected]
    local isoObject = item.item
    local data = IsoHelper.getInfoClass(isoObject)

    local dataListWidth = 150
    self.dataListBox:clear()
    for key, field in pairs(data.fields) do
        self.dataListBox:addItem(field.name, field)
        local width1 = self.textManager:MeasureStringX(self.dataListBox.font, tostring(field.name))
        local width2 = self.textManager:MeasureStringX(self.dataListBox.font, tostring(field.type))
        local width3 = self.textManager:MeasureStringX(self.dataListBox.font, tostring(field.value))
        dataListWidth = math.max(dataListWidth, width1 + width2 + width3 + 65)
    end

    self.dataListBox:setWidth(600)
end
