
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

vrpMissionIgangServer = false

RegisterServerEvent('vrpAirdrop:TjekStatus')
RegisterServerEvent('vrpAirdrop:Startet')

AddEventHandler('vrpAirdrop:TjekStatus', function()
local source = source
TriggerClientEvent('vrpAirdrop:StatusUpdate', source, vrpMissionIgangServer)
end)

AddEventHandler('vrpAirdrop:Startet', function()
local source = source
local user_id = vRP.getUserId({source})
vrpMissionIgangServer = true
TriggerClientEvent('vrpAirdrop:StatusUpdate', -1, vrpMissionIgangServer)
    vRP.request({source, "Vil du købe leveringen for " .. cfg.leveringspris .. "kr?",8,function(source,ok)
        if ok then
            if vRP.tryFullPayment({user_id,cfg.leveringspris}) then
                TriggerClientEvent('vrpAirdrop:SpawnLevering', -1)
                TriggerClientEvent('vrpAirdrop:LeveringStartBuyer', source)
                vrpTimz = 0
                MaxTime = (cfg.vrpTimer+15)*60
                while vrpMissionIgangServer == true do
                    Citizen.Wait(1000)
                    if vrpTimz < MaxTime then
                        vrpTimz = vrpTimz+1
                    else
                        
                    end
                end
            else
                vrpMissionIgangServer = false
                TriggerClientEvent('vrpAirdrop:StatusUpdate', -1, vrpMissionIgangServer)
            end
        else
            vrpMissionIgangServer = false
            TriggerClientEvent('vrpAirdrop:StatusUpdate', -1, vrpMissionIgangServer)
        end
    end})
end)

RegisterServerEvent("coke:GiveItem")
AddEventHandler("coke:GiveItem", function()
	local _source = source
	local user_id = vRP.getUserId({_source})
	vRP.giveInventoryItem({user_id,"kokain",50})
end)