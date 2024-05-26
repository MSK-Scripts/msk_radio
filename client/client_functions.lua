isRadioOpen = false
radioProp = nil
tokoVoipRadioVolume = 100

openRadio = function()
    if isRadioOpen then return end
    isRadioOpen = true

    SendNUIMessage({
        action = "openUI", 
        showMemberList = Config.showMemberListButton,
        isInChannel = getRadioChannel(),
        volume = getRadioVolume() or 10,
        voiceSystem = Config.VoiceSystem,
        locales = Translation[Config.Locale]
    })
    SetNuiFocus(true, true)

    playRadioInHand()
end
exports('openRadio', openRadio)
RegisterNetEvent('msk_radio:openRadio', openRadio)

isRadioOpen = function()
    return isRadioOpen
end
exports('isRadioOpen', isRadioOpen)

hasChannelPassword = function(channel)
    return MSK.Trigger('msk_radio:hasChannelPassword', channel)
end
exports('hasChannelPassword', hasChannelPassword)

checkChannelPassword = function(channel, password)
    return MSK.Trigger('msk_radio:checkChannelPassword', channel, password)
end
exports('checkChannelPassword', checkChannelPassword)

isEncryptedChannel = function(channel)
    if Config.EncryptedChannels[tonumber(channel)] then
        return true
    end
    return false
end
exports('isEncryptedChannel', isEncryptedChannel)

setChannelPassword = function(channel, password)
    TriggerServerEvent('msk_radio:registerChannelPassword', channel, password)
end
exports('setChannelPassword', setChannelPassword)

getRadioChannel = function()
    local channel

    if Config.VoiceSystem == 'saltychat' then
        channel = exports.saltychat:GetRadioChannel(true)
    elseif Config.VoiceSystem == 'pma' then
        channel = Player(GetPlayerServerId(PlayerId())).state.radioChannel
    elseif Config.VoiceSystem == 'tokovoip' then
        channel = exports["tokovoip_script"]:getPlayerData(GetPlayerServerId(PlayerId()), 'radio:channel')
    end

    return channel
end
exports('getRadioChannel', getRadioChannel)

getRadioVolume = function()
    local volume

    if Config.VoiceSystem == 'saltychat' then
        volume = Round(exports.saltychat:GetRadioVolume() * 100)
    elseif Config.VoiceSystem == 'pma' then
        volume = Player(GetPlayerServerId(PlayerId())).state.radioVolume
    elseif Config.VoiceSystem == 'tokovoip' then
        volume = tokoVoipRadioVolume
    end

    return volume
end
exports('getRadioVolume', getRadioVolume)

isFirstInChannel = function(channel)
    return MSK.Trigger('msk_radio:isFirstInChannel', channel)
end
exports('isFirstInChannel', isFirstInChannel)

setRadioChannel = function(channel)
    if Config.VoiceSystem == 'saltychat' then
        exports["saltychat"]:SetRadioChannel(channel, true)
    elseif Config.VoiceSystem == 'pma' then
        exports["pma-voice"]:setVoiceProperty('radioEnabled', true)
        exports["pma-voice"]:SetRadioChannel(channel)
    elseif Config.VoiceSystem == 'tokovoip' then
        exports["tokovoip_script"]:addPlayerToRadio(channel)
    end

    TriggerServerEvent('msk_radio:addPlayerToRadio', channel)
end
exports('setRadioChannel', setRadioChannel)

removeRadioChannel = function(channel)
    if Config.VoiceSystem == 'saltychat' then
        exports["saltychat"]:SetRadioChannel(nil, true)
    elseif Config.VoiceSystem == 'pma' then
        exports["pma-voice"]:setVoiceProperty('radioEnabled', false)
        exports["pma-voice"]:SetRadioChannel(0)
    elseif Config.VoiceSystem == 'tokovoip' then
        exports["tokovoip_script"]:removePlayerFromRadio(channel or getRadioChannel())
    end

    TriggerServerEvent('msk_radio:removePlayerToRadio', channel or getRadioChannel())
end
exports('removeRadioChannel', removeRadioChannel)

setRadioVolume = function(volume)
    if Config.VoiceSystem == 'saltychat' then
        volume = volume / 100
        exports["saltychat"]:SetRadioVolume(volume)
    elseif Config.VoiceSystem == 'pma' then
        exports["pma-voice"]:setRadioVolume(volume)
    elseif Config.VoiceSystem == 'tokovoip' then
        tokoVoipRadioVolume = volume
        exports["tokovoip_script"]:setRadioVolume(volume)
    end
end
exports('setRadioVolume', setRadioVolume)

setRadioSpeaker = function(active)
    if Config.VoiceSystem == 'saltychat' then
        exports["saltychat"]:SetRadioSpeaker(active)
    elseif Config.VoiceSystem == 'pma' then
        -- I don't know the export for that
    elseif Config.VoiceSystem == 'tokovoip' then
        -- I don't know the export for that
    end
end
exports('setRadioSpeaker', setRadioSpeaker)

----------------------------------------------------------------
-- Props and Animations
----------------------------------------------------------------
loadAnimDict = function(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)

        while not HasAnimDictLoaded(dict) do
            Wait(1)
        end
    end
end

loadModel = function(modelHash)
    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
    
        while not HasModelLoaded(modelHash) do
            Wait(1)
        end
    end
end

playRadioInHand = function()
    local playerPed = PlayerPedId()

    loadAnimDict("cellphone@")
    TaskPlayAnim(playerPed, "cellphone@", "cellphone_text_read_base", 3.0, -3.0, -1, 49, 0, 0, 0, 0)

    loadModel(`prop_cs_hand_radio`)
    radioProp = CreateObject(`prop_cs_hand_radio`, 1.0, 1.0, 1.0, 1, 1, 0)
    AttachEntityToEntity(radioProp, playerPed, GetPedBoneIndex(playerPed, 57005), 0.14, 0.01, -0.02, 110.0, 120.0, -15.0, 1, 0, 0, 0, 2, 1)
end

removeRadioObject = function()
    local playerPed = PlayerPedId()

    StopAnimTask(playerPed, "cellphone@", "cellphone_text_read_base", 3.0)
    ClearPedTasks(playerPed)
    DeleteObject(radioProp)
    radioProp = nil
end

playAnimationRadioTalking = function()
    loadAnimDict("random@arrests")
    TaskPlayAnim(PlayerPedId(), "random@arrests", "generic_radio_chatter", 8.0, -8.0, -1, 49, 0, 0, 0, 0)
end

stopAnimationRadioTalking = function()
    local playerPed = PlayerPedId()

    StopAnimTask(playerPed, "random@arrests", "generic_radio_chatter", 8.0)
    ClearPedTasks(playerPed)
end