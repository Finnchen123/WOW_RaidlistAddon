local CELL_WIDTH = 50
local CELL_WIDTH_NAME = 150
local CELL_HEIGHT = 20

-- adding a scrollframe (includes basic scrollbar thumb/buttons and functionality)
DisplayFrame.scrollFrame = CreateFrame("ScrollFrame", nil, DisplayFrame, "UIPanelScrollFrameTemplate")
DisplayFrame.scrollFrame:SetPoint("TOPLEFT", 12, -32)
DisplayFrame.scrollFrame:SetPoint("BOTTOMRIGHT", -34, 8)

-- creating a scrollChild to contain the content
DisplayFrame.scrollFrame.scrollChild = CreateFrame("Frame", nil, DisplayFrame.scrollFrame)
DisplayFrame.scrollFrame.scrollChild:SetSize(100, 100)
DisplayFrame.scrollFrame.scrollChild:SetPoint("TOPLEFT", 5, -5)
DisplayFrame.scrollFrame:SetScrollChild(DisplayFrame.scrollFrame.scrollChild)

-- adding content to the scrollChild
local content = DisplayFrame.scrollFrame.scrollChild
content.rows = {} -- each row of data is one wide button stored here

function calculateWidth(data)
    local longestString = 0
    for i = 1, #data, 1 do
        if string.len(data[i][1]) > longestString then
            longestString = string.len(data[i][1])
        end
    end
    CELL_WIDTH_NAME = longestString * 6
end

function UpdateList(data)
    calculateWidth(data)
    for i = 1, #data, 1 do
        -- create a row if not created yet (buttons[i] is a whole row; buttons[i].columns[j] are columns)
        if not content.rows[i] then
            local button = CreateFrame("Button", nil, content)
            button:SetSize(CELL_WIDTH * #Difficulties + CELL_WIDTH_NAME, CELL_HEIGHT)
            button:SetPoint("TOPLEFT", 0, -(i - 1) * CELL_HEIGHT)
            button.columns = {} -- creating columns for the row
            for j = 1, #Difficulties + 1, 1 do
                button.columns[j] = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
                if j == 1 then
                    button.columns[j]:SetPoint("LEFT", (j - 1) * CELL_WIDTH_NAME, 0)
                else
                    button.columns[j]:SetPoint("LEFT", (j - 1) * CELL_WIDTH + CELL_WIDTH_NAME, 0)
                end
            end
            content.rows[i] = button
        end
        -- now actually update the contents of the row
        for j = 1, #Difficulties + 1, 1 do
            if i == 1 then
                if j == 1 then
                    content.rows[i].columns[j]:SetText(data[i][j])
                else
                    content.rows[i].columns[j]:SetText(Difficulties[j-1].Names[UsedLanguage])
                end
            else
                content.rows[i].columns[j]:SetText(data[i][j])
            end
        end
        -- show the row that has data
        content.rows[i]:Show()
    end
    -- hide all extra rows (if list shrunk, hiding leftover)
    for i = #data + 1, #content.rows, 1 do
        content.rows[i]:Hide()
    end
end
