local addonName, Vendor = ...

Vendor.Name = addonName

local EQUIPMENT_CLASSES = {
    [Enum.ItemClass.Weapon] = true,
    [Enum.ItemClass.Armor] = true
}

Vendor.IsSellingItems = false
Vendor.SellQueue = nil
Vendor.SellQueueIndex = 0

function Vendor:GetSelectedExpansionID()
    if not RaidlistDB then
        return nil
    end

    return tonumber(
        RaidlistDB.sellableExpansionID
    )
end

function Vendor:GetItemData(itemID)
    local itemName,
          itemLink,
          itemQuality,
          itemLevel,
          itemMinLevel,
          itemType,
          itemSubType,
          itemStackCount,
          itemEquipLoc,
          itemTexture,
          sellPrice,
          classID,
          subclassID,
          bindType,
          expansionID =
        C_Item.GetItemInfo(itemID)

    if not itemName then
        return nil
    end

    return {
        itemName = itemName,
        itemLink = itemLink,
        itemQuality = itemQuality,
        sellPrice = sellPrice or 0,
        classID = classID,
        expansionID = expansionID
    }
end

function Vendor:IsSellableItem(
    bagID,
    slotID
)
    local containerItem =
        C_Container.GetContainerItemInfo(
            bagID,
            slotID
        )

    if not containerItem
        or not containerItem.itemID
    then
        return false
    end

    if containerItem.isLocked then
        return false
    end

    local itemData =
        self:GetItemData(
            containerItem.itemID
        )

    if not itemData then
        return false
    end

    if not EQUIPMENT_CLASSES[
        itemData.classID
    ] then
        return false
    end

    local selectedExpansionID =
        self:GetSelectedExpansionID()

    if selectedExpansionID == nil then
        return false
    end

    if itemData.expansionID
        ~= selectedExpansionID
    then
        return false
    end

    if itemData.sellPrice <= 0 then
        return false
    end

    return true
end

function Vendor:GetSellableItems()
    local items = {}

    for bagID =
        BACKPACK_CONTAINER,
        NUM_TOTAL_EQUIPPED_BAG_SLOTS
    do
        local slotCount =
            C_Container.GetContainerNumSlots(
                bagID
            )

        for slotID = 1, slotCount do
            if self:IsSellableItem(
                bagID,
                slotID
            ) then
                local containerItem =
                    C_Container.GetContainerItemInfo(
                        bagID,
                        slotID
                    )

                local itemData =
                    self:GetItemData(
                        containerItem.itemID
                    )

                items[#items + 1] = {
                    bagID = bagID,
                    slotID = slotID,
                    itemID =
                        containerItem.itemID,
                    itemLink =
                        containerItem.hyperlink,
                    stackCount =
                        containerItem.stackCount
                        or 1,
                    sellPrice =
                        itemData.sellPrice,
                    expansionID =
                        itemData.expansionID
                }
            end
        end
    end

    return items
end

function Vendor:GetSellableItemCount()
    return #self:GetSellableItems()
end

function Vendor:GetSellableItemsValue()
    local totalValue = 0

    for _, item in ipairs(
        self:GetSellableItems()
    ) do
        totalValue =
            totalValue
            + (
                item.sellPrice
                * item.stackCount
            )
    end

    return totalValue
end

function Vendor:StopSelling()
    self.IsSellingItems = false
    self.SellQueue = nil
    self.SellQueueIndex = 0

    if CursorHasItem() then
        ClearCursor()
    end

    if self.UpdateVendorButton then
        self:UpdateVendorButton()
    end
end

function Vendor:SellNextItem()
    if not self.IsSellingItems then
        return
    end

    if not MerchantFrame
        or not MerchantFrame:IsShown()
    then
        self:StopSelling()
        return
    end

    if not self.SellQueue then
        self:StopSelling()
        return
    end

    self.SellQueueIndex =
        self.SellQueueIndex + 1

    local item =
        self.SellQueue[
            self.SellQueueIndex
        ]

    if not item then
        self:StopSelling()
        return
    end

    local currentItem =
        C_Container.GetContainerItemInfo(
            item.bagID,
            item.slotID
        )

    if not currentItem
        or currentItem.itemID
            ~= item.itemID
        or currentItem.isLocked
        or not self:IsSellableItem(
            item.bagID,
            item.slotID
        )
    then
        C_Timer.After(
            0.05,
            function()
                Vendor:SellNextItem()
            end
        )

        return
    end

    C_Container.UseContainerItem(
        item.bagID,
        item.slotID
    )

    C_Timer.After(
        0.05,
        function()
            if Vendor.IsSellingItems
                and not CursorHasItem()
            then
                Vendor:SellNextItem()
            end
        end
    )
end

function Vendor:SellItems()
    if self.IsSellingItems then
        return
    end

    if not MerchantFrame
        or not MerchantFrame:IsShown()
    then
        return
    end

    local items =
        self:GetSellableItems()

    if #items == 0 then
        return
    end

    self.SellQueue = items
    self.SellQueueIndex = 0
    self.IsSellingItems = true

    self:SellNextItem()
end

local function InstallTradeTimerBypass()
    local popup =
        StaticPopupDialogs[
            "CONFIRM_MERCHANT_TRADE_TIMER_REMOVAL"
        ]

    if not popup then
        return
    end

    if popup.RaidlistVendorHooked then
        return
    end

    popup.RaidlistVendorHooked = true

    local originalOnShow =
        popup.OnShow

    popup.OnShow =
        function(self, ...)
            if originalOnShow then
                originalOnShow(
                    self,
                    ...
                )
            end

            if not Vendor.IsSellingItems then
                return
            end

            StaticPopup_Hide(
                "CONFIRM_MERCHANT_TRADE_TIMER_REMOVAL"
            )

            if CursorHasItem() then
                SellCursorItem()
            end

            C_Timer.After(
                0.05,
                function()
                    if Vendor.IsSellingItems then
                        Vendor:SellNextItem()
                    end
                end
            )
        end
end

local eventFrame =
    CreateFrame("Frame")

eventFrame:RegisterEvent(
    "PLAYER_LOGIN"
)

eventFrame:RegisterEvent(
    "MERCHANT_CLOSED"
)

eventFrame:SetScript(
    "OnEvent",
    function(_, event)
        if event == "PLAYER_LOGIN" then
            InstallTradeTimerBypass()
            return
        end

        if event == "MERCHANT_CLOSED" then
            if Vendor.IsSellingItems then
                Vendor:StopSelling()
            end
        end
    end
)