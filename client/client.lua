if Config.Command.enable then
    RegisterCommand(Config.Command.command, function()
        if Config.Command.checkItem then
            local hasItem = MSK.HasItem(Config.Item.item)
            if not hasItem or hasItem and hasItem.count == 0 then return end
        end

        openRadio()
    end)
    TriggerEvent('chat:addSuggestion', '/' .. Config.Command.command, 'Open the Radio', {})

    if Config.Hotkey.enable then
        RegisterKeyMapping(Config.Command.command, 'Radio', 'keyboard', Config.Hotkey.hotkey)
    end
end

----------------------------------------------------------------
-- Register Events
----------------------------------------------------------------
RegisterNetEvent('esx:removeInventoryItem', function(itemName, itemCount)
    if not Config.DisconnectOnItemRemove then return end
    if itemName ~= Config.Item.item then return end
    if itemCount > 0 then return end

    removeRadioChannel()
end)

AddEventHandler('SaltyChat_RadioTrafficStateChanged', function(primaryReceive, primaryTransmit, secondaryReceive, secondaryTransmit)
    if primaryTransmit then
        playAnimationRadioTalking()
    elseif not primaryTransmit then
        stopAnimationRadioTalking()
    end
end)

----------------------------------------------------------------
-- Register Callbacks
----------------------------------------------------------------
MSK.Register('msk_radio:getTokovoipPlayers', function(source, players, channel)
    local channelMembers = {}

    for k, playerId in pairs(players) do
        local isInChannel = exports["tokovoip_script"]:isPlayerInChannel(channel)

        if isInChannel then
            channelMembers[#channelMembers + 1] = playerId
        end
    end

    return channelMembers
end)

----------------------------------------------------------------
-- Register NUI Callbacks
----------------------------------------------------------------
RegisterNUICallback("enter-channel", function(data, cb)
    if not data.frequence or data.frequence == '' then return end
    local isEncryptedChannel = isEncryptedChannel(data.frequence)

    if not isEncryptedChannel and hasChannelPassword(data.frequence) then
        return cb('input') -- NUI Callback opens Passwort Input
    elseif not isEncryptedChannel and isFirstInChannel(data.frequence) then
        return cb('input') -- NUI Callback opens Passwort Input
    end

    if isEncryptedChannel and not MSK.TableContains(Config.EncryptedChannels[tonumber(data.frequence)], ESX.PlayerData.job.name) then
        cb('denied')
        return Config.Notification(nil, Translation[Config.Locale]['channel_encrypted'], 'error')
    end

    setRadioChannel(data.frequence)

    SendNUIMessage({
        action = "refreshVolume", 
        volume = getRadioVolume()
    })

    cb('OK')
end)

RegisterNUICallback("popup-action", function(data, cb)
    if not hasChannelPassword(data.frequence) then
        if data.password and data.password ~= '' then
            setChannelPassword(data.frequence, data.password)
        end
        setRadioChannel(data.frequence)
    else
        local isPasswordCorrect = checkChannelPassword(data.frequence, data.password)

        if not isPasswordCorrect then
            cb('failed') -- NUI Callback password is wrong
            return Config.Notification(nil, Translation[Config.Locale]['password_invalid'], 'error')
        end

        setRadioChannel(data.frequence)
    end

    cb('OK')
end)

RegisterNUICallback("refresh-member", function(data, cb)
    logging('debug', 'Refresh Members in channel: ' .. data.frequence)
    if not Config.showMemberListButton then return end
    local channelMember = MSK.Trigger('msk_radio:getChannelMembers', getRadioChannel())

    cb(channelMember) -- NUI Callback refresh Channelmembers
end)

RegisterNUICallback("leave-channel", function(data)
    removeRadioChannel(data.frequence)
end)

RegisterNUICallback("change-volume", function(data)
    setRadioVolume(data.volume)
end)

RegisterNUICallback("radio-speaker", function(data)
    setRadioSpeaker(data.activate)
end)

RegisterNUICallback("closeUI", function()
    isRadioOpen = false
    SetNuiFocus(false, false)
    removeRadioObject()
end)

logging = function(code, ...)
    if not Config.Debug then return end
    MSK.Logging(code, ...)
end

AddEventHandler('onResourceStop', function(resource)
	if GetCurrentResourceName() ~= resource then return end
    removeRadioObject()
end)