local UI_BORDER_SPACING = 10
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

require "ISUI/ISScrollingListBox"
ISHTScrollingListBox = ISScrollingListBox:derive("ISHTScrollingListBox");

function ISHTScrollingListBox:new(x, y, width, height)
	local o = ISScrollingListBox.new(self, x, y, width, height)
	return o
end

function ISHTScrollingListBox:addColumn(columnName, attribute, size, converter)
	table.insert(self.columns, {name = columnName, attribute = attribute, size = size, converter = converter});
end

function ISHTScrollingListBox:doDrawItem(y, item, alt)
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

    local xoffset = 0;

    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)
    
	if #self.columns > 0 then
		local is_need_repaint = false
		for i = 1, #self.columns, 1 do
			local column = self.columns[i]
			local converter = tostring
			if column["converter"] ~= nil then
				converter = column["converter"]
			end
			local text = item.text
			if column.attribute ~= nil and item.item ~= nil and item.item[column.attribute] ~= nil then
				text = item.item[column.attribute]
			end
			local value = converter(text or "nil")
			local size = column.size
			if i < #self.columns then
				self:setStencilRect(xoffset, clipY, size, clipY2 - clipY)
				self:drawText(value, xoffset + UI_BORDER_SPACING, y + 3, 1, 1, 1, a, self.font);
				self:clearStencilRect()
				is_need_repaint = true
			else
				self:drawText(value, xoffset + UI_BORDER_SPACING, y + 3, 1, 1, 1, a, self.font);
			end
			xoffset = xoffset + size
		end
		if is_need_repaint then
			self:repaintStencilRect(0, clipY, self.width - 15, clipY2 - clipY)
		end
	else
		local converter = tostring
		local value = converter(item.text or "nil")
		self:drawText(value, xoffset + UI_BORDER_SPACING, y + 3, 1, 1, 1, a, self.font);
	end

    return y + self.itemheight;
end

function ISHTScrollingListBox:prerender()
	if self.items == nil then
		return;
	end

	local stencilX = 0
	local stencilY = 0
	local stencilX2 = self.width
	local stencilY2 = self.height

    self:drawRect(0, -self:getYScroll(), self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
	if self.drawBorder then
		self:drawRectBorder(0, -self:getYScroll(), self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
		stencilX = 1
		stencilY = 1
		stencilX2 = self.width - 1
		stencilY2 = self.height - 1
	end

	if self:isVScrollBarVisible() then
		stencilX2 = self.vscroll.x + 3 -- +3 because the scrollbar texture is narrower than the scrollbar width
	end

	-- This is to handle this listbox being inside a scrolling parent.
	if self.parent and self.parent:getScrollChildren() then
		stencilX = self.javaObject:clampToParentX(self:getAbsoluteX() + stencilX) - self:getAbsoluteX()
		stencilX2 = self.javaObject:clampToParentX(self:getAbsoluteX() + stencilX2) - self:getAbsoluteX()
		stencilY = self.javaObject:clampToParentY(self:getAbsoluteY() + stencilY) - self:getAbsoluteY()
		stencilY2 = self.javaObject:clampToParentY(self:getAbsoluteY() + stencilY2) - self:getAbsoluteY()
	end
	self:setStencilRect(stencilX, stencilY, stencilX2 - stencilX, stencilY2 - stencilY)

	local y = 0;
	local alt = false;

	if self.selected ~= -1 and self.selected > #self.items then
		self.selected = #self.items
	end

	local altBg = self.altBgColor

	self.listHeight = 0;
	 local i = 1;
	 for k, v in ipairs(self.items) do
		if not v.height then v.height = self.itemheight end -- compatibililty

		 if alt and altBg then
			self:drawRect(0, y, self:getWidth(), v.height-1, altBg.r, altBg.g, altBg.b, altBg.a);
		 else

		 end
		 v.index = i;
		 local y2 = self:doDrawItem(y, v, alt);
		if self.stopPrerender then
		    self.stopPrerender = false;
		    return;
		 end
		 self.listHeight = y2;
		 v.height = y2 - y
		 y = y2

		 alt = not alt;
		 i = i + 1;
		
	 end

	self:setScrollHeight((y));
	self:clearStencilRect();
	if self.doRepaintStencil then
		self:repaintStencilRect(stencilX, stencilY, stencilX2 - stencilX, stencilY2 - stencilY)
	end

	local mouseY = self:getMouseY()
	self:updateSmoothScrolling()
	if mouseY ~= self:getMouseY() and self:isMouseOver() then
		self:onMouseMove(0, self:getMouseY() - mouseY)
	end
	self:updateTooltip()
	
	if #self.columns > 0 then
--		print(self:getScrollHeight())
		self:drawRectBorderStatic(0, 0 - self.itemheight, self.width, self.itemheight, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b);
		self:drawRectStatic(0, 0 - self.itemheight, self.width, self.itemheight,self.listHeaderColor.a,self.listHeaderColor.r, self.listHeaderColor.g, self.listHeaderColor.b);
		local dyText = (self.itemheight - FONT_HGT_SMALL) / 2
		local xoffset = 0;
		for i,v in ipairs(self.columns) do
			local size = self.columns[i].size
			self:drawRectStatic(xoffset, 0 - self.itemheight, 1, self.itemheight + math.min(self.height, self.itemheight * #self.items - 1), 1, self.borderColor.r, self.borderColor.g, self.borderColor.b);
			if v.name then
				self:drawText(v.name, xoffset + UI_BORDER_SPACING, 0 - self.itemheight - 1 + dyText - self:getYScroll(), 1,1,1,1,UIFont.Small);
			end
			xoffset = xoffset + size
		end
	end
end