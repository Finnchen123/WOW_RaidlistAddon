local _, Raidlist = ...

local UI = Raidlist.UI

if not UI then
    error(
        "Raidlist UI must be initialized before RaidList.lua."
    )
end


-- ============================================================
-- Layout
-- ============================================================

local HEADER_HEIGHT = 32
local ROW_HEIGHT = 30

local RAID_COLUMN_WIDTH = 250
local DIFFICULTY_COLUMN_WIDTH = 63

local TABLE_WIDTH =
    RAID_COLUMN_WIDTH
    + (#Raidlist.Difficulties
        * DIFFICULTY_COLUMN_WIDTH)


-- ============================================================
-- Header
-- ============================================================

local header = CreateFrame(
    "Frame",
    nil,
    UI.Content,
    "BackdropTemplate"
)

UI.ListHeader = header

header:SetPoint(
    "TOPLEFT",
    0,
    0
)

header:SetPoint(
    "TOPRIGHT",
    -18,
    0
)

header:SetHeight(
    HEADER_HEIGHT
)

header:SetBackdrop({
    bgFile =
        "Interface\\Buttons\\WHITE8x8"
})

header:SetBackdropColor(
    0.075,
    0.085,
    0.10,
    1
)


local raidHeader =
    header:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

UI.RaidHeader = raidHeader

raidHeader:SetPoint(
    "LEFT",
    12,
    0
)

raidHeader:SetWidth(
    RAID_COLUMN_WIDTH - 12
)

raidHeader:SetJustifyH("LEFT")


UI.DifficultyHeaders = {}

for index, difficulty in ipairs(
    Raidlist.Difficulties
) do
    local fontString =
        header:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormalSmall"
        )

    fontString:SetWidth(
        DIFFICULTY_COLUMN_WIDTH
    )

    fontString:SetPoint(
        "LEFT",
        header,
        "LEFT",
        RAID_COLUMN_WIDTH
            + ((index - 1)
                * DIFFICULTY_COLUMN_WIDTH),
        0
    )

    fontString:SetJustifyH(
        "CENTER"
    )

    UI.DifficultyHeaders[index] =
        fontString
end


-- Bottom separator

local headerSeparator =
    header:CreateTexture(
        nil,
        "ARTWORK"
    )

headerSeparator:SetPoint(
    "BOTTOMLEFT",
    0,
    0
)

headerSeparator:SetPoint(
    "BOTTOMRIGHT",
    0,
    0
)

headerSeparator:SetHeight(1)

headerSeparator:SetColorTexture(
    0.25,
    0.28,
    0.33,
    1
)


-- ============================================================
-- Scroll frame
-- ============================================================

local scrollFrame =
    CreateFrame(
        "ScrollFrame",
        nil,
        UI.Content,
        "ScrollFrameTemplate"
    )

UI.ScrollFrame = scrollFrame

scrollFrame:SetPoint(
    "TOPLEFT",
    header,
    "BOTTOMLEFT",
    0,
    -4
)

scrollFrame:SetPoint(
    "BOTTOMRIGHT",
    UI.Content,
    "BOTTOMRIGHT",
    0,
    0
)


local scrollChild =
    CreateFrame(
        "Frame",
        nil,
        scrollFrame
    )

UI.ScrollChild =
    scrollChild

scrollChild:SetPoint(
    "TOPLEFT",
    0,
    0
)

scrollChild:SetWidth(
    TABLE_WIDTH
)

scrollChild:SetHeight(1)

scrollFrame:SetScrollChild(
    scrollChild
)


-- ============================================================
-- Status appearance
-- ============================================================

local statusAppearance = {
    finished = {
        Symbol = "●",
        Color = {
            0.25,
            0.90,
            0.40
        }
    },

    available = {
        Symbol = "●",
        Color = {
            0.95,
            0.30,
            0.30
        }
    },

    blocked = {
        Symbol = "●",
        Color = {
            0.25,
            0.60,
            1.00
        }
    },

    unavailable = {
        Symbol = "–",
        Color = {
            0.45,
            0.48,
            0.52
        }
    }
}


-- ============================================================
-- Rows
-- ============================================================

UI.Rows = {}


local function CreateRow(index)
    local row =
        CreateFrame(
            "Button",
            nil,
            scrollChild
        )

    row:SetHeight(
        ROW_HEIGHT
    )

    row:SetWidth(
        TABLE_WIDTH
    )

    row:SetPoint(
        "TOPLEFT",
        0,
        -((index - 1) * ROW_HEIGHT)
    )


    -- --------------------------------------------------------
    -- Alternating background
    -- --------------------------------------------------------

    local background =
        row:CreateTexture(
            nil,
            "BACKGROUND"
        )

    background:SetAllPoints()

    if index % 2 == 0 then
        background:SetColorTexture(
            1,
            1,
            1,
            0.025
        )
    else
        background:SetColorTexture(
            1,
            1,
            1,
            0.00
        )
    end

    row.Background =
        background


    -- --------------------------------------------------------
    -- Hover
    -- --------------------------------------------------------

    local highlight =
        row:CreateTexture(
            nil,
            "BACKGROUND",
            nil,
            1
        )

    highlight:SetAllPoints()

    highlight:SetColorTexture(
        1,
        1,
        1,
        0.055
    )

    highlight:Hide()

    row.Highlight =
        highlight


    row:SetScript(
        "OnEnter",
        function(self)
            self.Highlight:Show()

            if self.Data then
                GameTooltip:SetOwner(
                    self,
                    "ANCHOR_RIGHT"
                )

                GameTooltip:SetText(
                    self.Data.raidName
                )

                GameTooltip:AddLine(
                    "Instance ID: "
                    .. tostring(
                        self.Data.instanceID
                    ),
                    0.65,
                    0.68,
                    0.72
                )

                GameTooltip:Show()
            end
        end
    )


    row:SetScript(
        "OnLeave",
        function(self)
            self.Highlight:Hide()
            GameTooltip:Hide()
        end
    )


    -- --------------------------------------------------------
    -- Raid name
    -- --------------------------------------------------------

    local raidName =
        row:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlight"
        )

    raidName:SetPoint(
        "LEFT",
        12,
        0
    )

    raidName:SetWidth(
        RAID_COLUMN_WIDTH - 20
    )

    raidName:SetJustifyH(
        "LEFT"
    )

    raidName:SetWordWrap(false)

    row.RaidName =
        raidName


    -- --------------------------------------------------------
    -- Difficulty columns
    -- --------------------------------------------------------

    row.DifficultyCells = {}

    for difficultyIndex = 1,
        #Raidlist.Difficulties
    do
        local cell =
            row:CreateFontString(
                nil,
                "OVERLAY",
                "GameFontNormalLarge"
            )

        cell:SetWidth(
            DIFFICULTY_COLUMN_WIDTH
        )

        cell:SetPoint(
            "LEFT",
            row,
            "LEFT",
            RAID_COLUMN_WIDTH
                + ((difficultyIndex - 1)
                    * DIFFICULTY_COLUMN_WIDTH),
            0
        )

        cell:SetJustifyH(
            "CENTER"
        )

        row.DifficultyCells[
            difficultyIndex
        ] = cell
    end


    UI.Rows[index] = row

    return row
end


-- ============================================================
-- Header localization
-- ============================================================

function UI:RefreshHeaders()
    local language =
        Raidlist:GetLanguage()

    self.RaidHeader:SetText(
        Raidlist:GetText("raid")
    )

    for index, difficulty in ipairs(
        Raidlist.Difficulties
    ) do
        local name

        if difficulty.ShortNames then
            name =
                difficulty.ShortNames[language]
        end

        name =
            name
            or difficulty.Names[language]
            or difficulty.Names.en
            or tostring(difficulty.ID)

        self.DifficultyHeaders[
            index
        ]:SetText(name)
    end
end


-- ============================================================
-- Data rendering
-- ============================================================

function UI:RefreshRaidList(data)
    for index, raidData in ipairs(data) do
        local row =
            self.Rows[index]
            or CreateRow(index)

        row.Data =
            raidData

        row.RaidName:SetText(
            raidData.raidName
        )

        for difficultyIndex,
            difficulty in ipairs(
                Raidlist.Difficulties
            )
        do
            local status =
                raidData.statuses[
                    difficulty.ID
                ]

            local appearance =
                statusAppearance[status]
                or statusAppearance.unavailable

            local cell =
                row.DifficultyCells[
                    difficultyIndex
                ]

            cell:SetText(
                appearance.Symbol
            )

            cell:SetTextColor(
                appearance.Color[1],
                appearance.Color[2],
                appearance.Color[3]
            )
        end

        row:Show()
    end


    -- Hide old rows if the raid list became shorter.
    for index =
        #data + 1,
        #self.Rows
    do
        self.Rows[index]:Hide()
    end


    scrollChild:SetHeight(
        math.max(
            #data * ROW_HEIGHT,
            1
        )
    )
end