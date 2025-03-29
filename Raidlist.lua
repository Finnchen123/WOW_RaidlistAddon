FinishedRaids = {}

SLASH_RAIDLIST1 = "/raidlist"
UsedLanguage = "en"

Color_Red = CreateColorFromHexString("FFFF0000")
Color_Green = CreateColorFromHexString("FF00FF00")
Color_Blue = CreateColorFromHexString("FF2386C9")

function HandleCommand()
    if DisplayFrame:IsShown() then
        DisplayFrame:Hide()
    else
        UpdateData()
        DisplayFrame:Show()
    end
end

function UpdateData()
    local data = {}
    local finishedDifficulties
    local blockedDifficulties

    -- Iterate over all raids
    for i = 1, #AllRaids, 1 do
        data[i] = {}
        data[i][1] = AllRaids[i].Names[UsedLanguage]
        finishedDifficulties = {}
        blockedDifficulties = {}

        -- Is raid finished? YES: #raidIndices > 0, Add all difficulties to finishedDifficulties
        local raidIndices = GetRaidByID(AllRaids[i].InstanceID, FinishedRaids)
        for j = 1, #raidIndices, 1 do
            finishedDifficulties[#finishedDifficulties+1] = FinishedRaids[raidIndices[j]].difficulty
        end

        -- Check if raid is blocked due to being finished
        for j = 1, #finishedDifficulties, 1 do
            local difficultyIndex = GetDifficultyByID(finishedDifficulties[j], Difficulties)
            for k = 1, #Difficulties[difficultyIndex].Blocking, 1 do
                if not IsInList(Difficulties[difficultyIndex].Blocking[k], blockedDifficulties) then
                    blockedDifficulties[#blockedDifficulties+1] = Difficulties[difficultyIndex].Blocking[k]
                end
            end
        end

        --Display different things depending on results
        for j = 1, #finishedDifficulties, 1 do
            data[i][GetDifficultyByID(finishedDifficulties[j], Difficulties)+1] = Color_Green:WrapTextInColorCode("Y")
            print(data[i][1] .. GetDifficultyByID(finishedDifficulties[j], Difficulties)+1)
        end

        for j = 1, #blockedDifficulties, 1 do
            data[i][GetDifficultyByID(blockedDifficulties[j], Difficulties)+1] = Color_Blue:WrapTextInColorCode("B")
        end

        for j = 1, #Difficulties, 1 do
            if not data[i][j+1] then
                if IsInList(Difficulties[j].ID, AllRaids[i].Difficulties) then
                    data[i][j+1] = Color_Red:WrapTextInColorCode("N")
                else
                    data[i][j+1] = "-"
                end
            else
                if not IsInList(Difficulties[j].ID, AllRaids[i].Difficulties) then
                    data[i][j+1] = "-"
                end
            end
        end

        UpdateList(data)
    end
end

function GetDifficultyByID(id, list)
    local index = -1
    for i = 1, #list, 1 do
        if id == list[i].ID then
            index = i
            break
        end
    end
    return index
end

function GetRaidByID(id, list)
    local indices = {}
    for i = 1, #list, 1 do
        if id == list[i].InstanceID then
            indices[#indices+1] = i
        end
    end
    return indices
end

function IsInList(id, list)
    local result = false
    for i = 1, #list, 1 do
        if id == list[i] then
            result = true
            break
        end
    end
    return result
end

SlashCmdList["RAIDLIST"] = HandleCommand