-- append icon in the left menu
require "ISUI/ISEquippedItem"

ISEquippedItem.super_new = ISEquippedItem.new
function ISEquippedItem:new (x, y, width, height, chr)
    local o = ISEquippedItem.super_new(self, x, y, width, height, chr)
    o.iconEventTable=getTexture("media/textures/EventReceiverTable_64x.png")
    return o
end

ISEquippedItem.super_initialise = ISEquippedItem.initialise
function ISEquippedItem:initialise()
    ISEquippedItem.super_initialise(self)
    local xMax = self.instance.x-5
    local yMax = self.instance:getBottom()+5

---@type Texture
    local texture = self.iconEventTable
    local size = 32
    self.htButtonEventTable = ISButton:new(xMax, yMax, size, size, "", self, self.OnHtButtonEventTableClick)
    self.htButtonEventTable:forceImageSize(size, size)
    self.htButtonEventTable:setImage(texture)
    self.htButtonEventTable:setDisplayBackground(false)
    self.htButtonEventTable.borderColor = {r=1, g=1, b=1, a=0.1}

    self.instance:addChild(self.htButtonEventTable)

    self.instance:setHeight(self.instance:getHeight() + self.htButtonEventTable:getHeight() + 5)
end

function ISEquippedItem:OnHtButtonEventTableClick(button, x, y)
    ISEventsWindow.openPanel()
end