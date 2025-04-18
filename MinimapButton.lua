MinimapButton = CreateFrame("Button", "Raidlist_MinimapButton", Minimap)

MinimapButton:SetSize(30, 30)
MinimapButton:SetPoint("CENTER")
MinimapButton:SetMovable(true)
MinimapButton:EnableMouse(true)

local icon = MinimapButton:CreateTexture("Raidlist_Icon", "BACKGROUND")
icon:SetTexture("Interface\\Icons\\Paladin_Protection.PNG")
icon:SetPoint("CENTER")
icon:SetSize(20,20)

local border = MinimapButton:CreateTexture("Raidlist_Border", "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetPoint("TOPLEFT")
border:SetSize(50,50)

local tooltip = CreateFrame("Frame", "Raidlist_Tooltip", MinimapButton)
tooltip:SetSize(50, 20)
tooltip:SetPoint("TOPLEFT")
tooltip:AdjustPointsOffset(-100, 10)
tooltip.Text = tooltip:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
tooltip.Text:SetPoint("TOPLEFT")
tooltip.Text:SetText("Raidlist Addon")

local background = tooltip:CreateTexture("Raidlist_Tolltip_Background", "BACKGROUND")
background:SetTexture("Interface\\Buttons\\UI-Slot-Background.PNG")
background:SetPoint("TOPLEFT")
background:AdjustPointsOffset(-10, 5)
background:SetSize(tooltip.Text:GetWidth() * 2,30)

tooltip:Hide()

MinimapButton:Show()

MinimapButton:SetScript("OnClick", HandleCommand)

MinimapButton:RegisterForDrag("LeftButton")
MinimapButton:SetScript("OnDragStart", function(self)
	self:StartMoving()
end)
MinimapButton:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

MinimapButton:SetScript("OnEnter", function(self)
	tooltip:Show()
end)

MinimapButton:SetScript("OnLeave", function(self)
	tooltip:Hide()
end)

