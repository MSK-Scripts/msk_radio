----------------------------------------------------------------
-- Register all Items
----------------------------------------------------------------
if Config.Item.enable then
    ESX.RegisterUsableItem(Config.Item.item, function(source)
        TriggerClientEvent('msk_radio:openRadio', source)
    end)
end

----------------------------------------------------------------
-- Register Events
----------------------------------------------------------------
RegisterNetEvent('msk_radio:addPlayerToRadio', function(channel)
    local playerId = source

    addPlayerToRadio(playerId, channel)
end)

RegisterNetEvent('msk_radio:removePlayerToRadio', function(channel)
    local playerId = source
    
    removePlayerFromRadio(playerId, channel)
end)

----------------------------------------------------------------
-- Register Callbacks
----------------------------------------------------------------
MSK.Register('msk_radio:getChannelMembers', function(source, channel)
    return getChannelMembers(channel, source) -- source only for tokovoip
end)

MSK.Register('msk_radio:hasChannelPassword', function(source, channel)
    return hasChannelPassword(channel)
end)

MSK.Register('msk_radio:checkChannelPassword', function(source, channel, password)
    return checkChannelPassword(channel, password)
end)

MSK.Register('msk_radio:isFirstInChannel', function(source, channel)
    return isFirstInChannel(channel, source) -- source only for tokovoip
end)