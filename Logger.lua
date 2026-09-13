local addonName, Raidlist = ...

local Logger = {}

Raidlist.Logger = Logger


local PREFIX =
    "|cff4ea1ff[Raidlist]|r"


function Logger:Error(message)
    if not RaidlistDB
        or not RaidlistDB.showErrorsInChat
    then
        return
    end

    if not DEFAULT_CHAT_FRAME then
        return
    end

    DEFAULT_CHAT_FRAME:AddMessage(
        PREFIX
        .. " |cffff5555Error:|r "
        .. tostring(message)
    )
end


function Logger:Warning(message)
    if not RaidlistDB
        or not RaidlistDB.showErrorsInChat
    then
        return
    end

    if not DEFAULT_CHAT_FRAME then
        return
    end

    DEFAULT_CHAT_FRAME:AddMessage(
        PREFIX
        .. " |cffffcc55Warning:|r "
        .. tostring(message)
    )
end


function Logger:Info(message)
    if not DEFAULT_CHAT_FRAME then
        return
    end

    DEFAULT_CHAT_FRAME:AddMessage(
        PREFIX .. " " .. tostring(message)
    )
end


function Logger:InstallErrorHandler()
    if self.errorHandlerInstalled then
        return
    end

    self.errorHandlerInstalled = true

    local previousHandler =
        geterrorhandler()

    local addonPath =
        "Interface/AddOns/" .. addonName .. "/"

    seterrorhandler(function(message)
        -- Preserve Blizzard/BugSack/etc. behavior.
        if previousHandler then
            previousHandler(message)
        end

        if not RaidlistDB
            or not RaidlistDB.showErrorsInChat
        then
            return
        end

        local text = tostring(message)

        -- Only display errors originating from this addon.
        local belongsToRaidlist =
            text:find(addonPath, 1, true)
            or text:find(addonName, 1, true)

        if not belongsToRaidlist then
            return
        end

        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage(
                PREFIX
                .. " |cffff5555Lua Error:|r "
                .. text
            )
        end
    end)
end