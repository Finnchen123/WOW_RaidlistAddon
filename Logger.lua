RaidlistLogger = {}

local PREFIX = "|cff2386c9[Raidlist]|r"

function RaidlistLogger:Error(message)
    if not message then
        return
    end

    if RaidlistSettings and RaidlistSettings.showErrorsInChat then
        DEFAULT_CHAT_FRAME:AddMessage(
            PREFIX .. " |cffff4040Error:|r " .. tostring(message)
        )
    end
end

function RaidlistLogger:Warning(message)
    if not message then
        return
    end

    if RaidlistSettings and RaidlistSettings.showErrorsInChat then
        DEFAULT_CHAT_FRAME:AddMessage(
            PREFIX .. " |cffffcc00Warning:|r " .. tostring(message)
        )
    end
end

function RaidlistLogger:Info(message)
    if not message then
        return
    end
    
    DEFAULT_CHAT_FRAME:AddMessage(
        PREFIX .. " " .. tostring(message)
    )
end