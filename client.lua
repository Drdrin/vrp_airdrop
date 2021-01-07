
--STARTUP SETTINGS--
NpcSpawned = false
vrpMissionIgang = false
vrpTimer1 = 0
vrpEjerAfMission = false
TriggerServerEvent('vrpAirdrop:TjekStatus')

--TRÅDE--
Citizen.CreateThread(function()
    if NpcSpawned == false then
        RequestModel(GetHashKey('mp_s_m_armoured_01'))
            while not HasModelLoaded('mp_s_m_armoured_01') do
                Citizen.Wait(100)
            end
        QuestGiver = CreatePed(4, 0xCDEF5408, cfg.NpcCoord.x, cfg.NpcCoord.y, cfg.NpcCoord.z-1.0, cfg.NpcCoord.h, false, true)
        SetEntityHeading(QuestGiver, cfg.NpcCoord.h)
        FreezeEntityPosition(QuestGiver, true)
        SetEntityInvincible(QuestGiver, true)
        SetBlockingOfNonTemporaryEvents(QuestGiver, true)
        RequestAnimDict("amb@world_human_hang_out_street@male_c@base")
            while not HasAnimDictLoaded("amb@world_human_hang_out_street@male_c@base") do
                Citizen.Wait(100)
            end
        TaskPlayAnim(QuestGiver, "amb@world_human_hang_out_street@male_c@base", "base", 8.0, 8.0, -1, 1, 0, 0, 0, 0)
        NpcSpawned = true
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), cfg.NpcCoord.x, cfg.NpcCoord.y, cfg.NpcCoord.z, true ) < 1 then
            if vrpMissionIgang == false then
                DrawText3Ds(cfg.NpcCoord.x, cfg.NpcCoord.y, cfg.NpcCoord.z+0.4, "[~g~E~w~] Bestil Levering")
                if IsControlJustPressed(1, 38) then
                    TriggerServerEvent('vrpAirdrop:Startet')
                    Citizen.Wait(200)
                end
            else
                DrawText3Ds(cfg.NpcCoord.x, cfg.NpcCoord.y, cfg.NpcCoord.z+0.4, "~r~Optaget")
            end
        end
        if vrpEjerAfMission == true then
            if vrpTimer1 > 0 then
                ply_drawTxt("Pakken droppes om " .. vrpTimer1 .. " sekunder", 4, 1, 0.5, 0.90, 0.5, 255, 255, 255, 255)
            else
                ply_drawTxt("Pakken er blevet droppet", 4, 1, 0.5, 0.90, 0.5, 255, 255, 255, 255)
            end
        end
    end
end)


--
RegisterCommand('vrpTest', function()
TriggerServerEvent('vrpAirdrop:Startet')
end)
--

--Events--
RegisterNetEvent('vrpAirdrop:StatusUpdate')
RegisterNetEvent('vrpAirdrop:SpawnLevering')
RegisterNetEvent('vrpAirdrop:LeveringStartBuyer')

AddEventHandler('vrpAirdrop:SpawnLevering', function()
    vrpTimer2 = cfg.vrpTimer*60*30000/30
    Citizen.Wait(vrpTimer2)
    requiredModels = {"p_cargo_chute_s", "ex_prop_adv_case_sm", "prop_box_wood02a_pu", "ex_prop_adv_case_sm_flash"}
        for i = 1, # requiredModels do
            RequestModel(GetHashKey(requiredModels[i]))
            while not HasModelLoaded(GetHashKey(requiredModels[i])) do
                Citizen.Wait(1)
            end
        end
            RequestWeaponAsset(GetHashKey("weapon_flare"))
            while not HasWeaponAssetLoaded(GetHashKey("weapon_flare")) do
                Citizen.Wait(1)
            end
            local vrpCrate = CreateObject(GetHashKey("prop_box_wood02a_pu"), cfg.DropLocation.x, cfg.DropLocation.y, cfg.DropLocation.z, false, true, true)
            SetEntityLodDist(vrpCrate, 10000)
            SetEntityInvincible(vrpCrate, false)
            SetActivateObjectPhysicsAsSoonAsItIsUnfrozen(vrpCrate, true)
            ActivatePhysics(vrpCrate)
            SetDamping(vrpCrate, 2, 0.1)
            SetEntityVelocity(vrpCrate, 0.0, 0.0, -0.2)
            crateParachute = CreateObject(GetHashKey("p_cargo_chute_s"), cfg.DropLocation.x, cfg.DropLocation.y, cfg.DropLocation.z, false, true, true)
            SetEntityLodDist(crateParachute, 10000)
            SetActivateObjectPhysicsAsSoonAsItIsUnfrozen(crateParachute, true)
            SetEntityVelocity(crateParachute, 0.0, 0.0, -0.2)
            drugbox = CreateObject(GetHashKey("ex_prop_adv_case_sm_flash"), cfg.DropLocation.x, cfg.DropLocation.y, cfg.DropLocation.z, false, true, true)
            SetEntityInvincible(drugbox, true)
            SetActivateObjectPhysicsAsSoonAsItIsUnfrozen(drugbox, true)
            ActivatePhysics(drugbox)
            SetDisableBreaking(drugbox, false)
            SetDamping(drugbox, 2, 0.0245)
            SetEntityVelocity(drugbox, 0.0, 0.0, -0.2)
            local soundID = GetSoundId()
            PlaySoundFromEntity(soundID, "Crate_Beeps", drugbox, "MP_CRATE_DROP_SOUNDS", true, 0)
            AttachEntityToEntity(crateParachute, drugbox, 0, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            AttachEntityToEntity(drugbox, vrpCrate, 0, 0.0, 0.0, 0.3, 0.0, 0.0, false, false, true, false, 2, true)
            vrpDropped = true
            while HasObjectBeenBroken(vrpCrate) == false do
                Citizen.Wait(1)
            end
            local jx, jy, jz = table.unpack(GetEntityCoords(crateParachute))
            ShootSingleBulletBetweenCoords(jx, jy, jz, jx, jy + 0.0001, jz - 0.0001, 0, false, GetHashKey("weapon_flare"), 0, true, false, -1.0)
            DetachEntity(crateParachute, true, true)
            SetEntityCollision(crateParachute, false, true)
            DeleteEntity(crateParachute)
            DetachEntity(drugbox)
            SetBlipAlpha(blip, 255)
            while DoesEntityExist(drugbox) do
                Wait(0)
            end
            StopSound(soundID)
            ReleaseSoundId(soundID)
            for i = 1, #requiredModels do
                Wait(0)
                SetModelAsNoLongerNeeded(GetHashKey(requiredModels[i]))
            end
            RemoveWeaponAsset(GetHashKey("weapon_flare"))
        end)


AddEventHandler('vrpAirdrop:LeveringStartBuyer', function()
vrpEjerAfMission = true
SetNewWaypoint(cfg.DropLocation.x+0.0001, cfg.DropLocation.y+0.0001)
vrpTimer1 = cfg.vrpTimer*60
    while vrpMissionIgang == true do
        Citizen.Wait(1000)
        if vrpTimer1 > 0 then
            vrpTimer1 = vrpTimer1-1
        end
    end
end)

AddEventHandler('vrpAirdrop:StatusUpdate', function(ServerStatus)
vrpMissionIgang = ServerStatus
end)

AddEventHandler('vrpAirdrop:StatusUpdate', function (ServerStatus)
vrpEjerAfMission = false
end)

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

function ply_drawTxt(text,font,centre,x,y,scale,r,g,b,a)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(centre)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x , y)
end