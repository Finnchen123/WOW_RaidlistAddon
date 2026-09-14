local addonName, Vendor = ...

local BUTTON_WIDTH = 180
local BUTTON_HEIGHT = 24

local BUTTON_TEXT_SELL =
    "Items verkaufen"

local BUTTON_TEXT_EMPTY =
    "Keine Items"

local BUTTON_TEXT_SELLING =
    "Verkaufe..."

local vendorButton =
    CreateFrame(
        "Button",
        addonName .. "VendorButton",
        MerchantFrame,
        "UIPanelButtonTemplate"
    )

Vendor.VendorButton =
    vendorButton

vendorButton:Hide()

vendorButton:SetSize(
    BUTTON_WIDTH,
    BUTTON_HEIGHT
)

vendorButton:SetPoint(
    "TOPLEFT",
    MerchantFrame,
    "TOPRIGHT",
    6,
    -40
)

vendorButton:RegisterForClicks(
    "LeftButtonUp"
)

vendorButton:SetScript(
    "OnEnter",
    function(self)
        GameTooltip:SetOwner(
            self,
            "ANCHOR_TOP"
        )

        GameTooltip:SetText(
            "Items verkaufen"
        )

        local count =
            Vendor:GetSellableItemCount()

        if count > 0 then
            GameTooltip:AddLine(
                count
                .. " passende Gegenstände werden verkauft.",
                1,
                1,
                1,
                true
            )

            local totalValue =
                Vendor:GetSellableItemsValue()

            if totalValue > 0 then
                GameTooltip:AddLine(" ")

                GameTooltip:AddLine(
                    "Händlerwert: "
                    .. GetMoneyString(
                        totalValue,
                        true
                    ),
                    0.75,
                    0.75,
                    0.75,
                    true
                )
            end
        else
            GameTooltip:AddLine(
                "Es wurden keine passenden Gegenstände gefunden.",
                0.75,
                0.75,
                0.75,
                true
            )
        end

        GameTooltip:Show()
    end
)

vendorButton:SetScript(
    "OnLeave",
    function()
        GameTooltip:Hide()
    end
)

function Vendor:UpdateVendorButton()
    if not MerchantFrame:IsShown() then
        vendorButton:Hide()
        return
    end

    if not RaidlistDB
        or not RaidlistDB.showVendorButton
    then
        vendorButton:Hide()
        return
    end

    vendorButton:Show()

    if self.IsSellingItems then
        vendorButton:Disable()

        vendorButton:SetText(
            BUTTON_TEXT_SELLING
        )

        return
    end

    local count =
        self:GetSellableItemCount()

    if count > 0 then
        vendorButton:Enable()

        vendorButton:SetText(
            BUTTON_TEXT_SELL
            .. " ("
            .. count
            .. ")"
        )
    else
        vendorButton:Disable()

        vendorButton:SetText(
            BUTTON_TEXT_EMPTY
        )
    end
end

vendorButton:SetScript(
    "OnClick",
    function(_, button)
        if button ~= "LeftButton" then
            return
        end

        if Vendor.IsSellingItems then
            return
        end

        if Vendor:GetSellableItemCount()
            <= 0
        then
            return
        end

        Vendor:SellItems()

        Vendor:UpdateVendorButton()
    end
)

local eventFrame =
    CreateFrame("Frame")

eventFrame:RegisterEvent(
    "MERCHANT_SHOW"
)

eventFrame:RegisterEvent(
    "MERCHANT_CLOSED"
)

eventFrame:RegisterEvent(
    "BAG_UPDATE_DELAYED"
)

eventFrame:SetScript(
    "OnEvent",
    function(_, event)
        if event == "MERCHANT_SHOW" then
            Vendor:UpdateVendorButton()

            return
        end

        if event == "MERCHANT_CLOSED" then
            GameTooltip:Hide()

            return
        end

        if event == "BAG_UPDATE_DELAYED" then
            if MerchantFrame:IsShown()
                and not Vendor.IsSellingItems
            then
                Vendor:UpdateVendorButton()
            end

            return
        end
    end
)