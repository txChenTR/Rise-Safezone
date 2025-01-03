local Framework = nil
local FrameworkName = beqeend.DassakScriptiNeduu

if FrameworkName == "qb" then
    Framework = exports['qb-core']:GetCoreObject()
elseif FrameworkName == "qbx" then
    Framework = exports['qbx-core']:GetCoreObject()
elseif FrameworkName == "esx" then
    TriggerEvent('esx:getSharedObject', function(obj) Framework = obj end)
end

local isInSafeZone = {}
local safeZoneNotificationShown = false

function IsWhitelistedJob(job)
    for _, whitelistedJob in pairs(beqeend.Meslekler) do
        if job == whitelistedJob then
            return true
        end
    end
    return false
end

CreateThread(function()
    while true do
        local player = PlayerId()
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local newSafeZoneState = false 

        for index, v in pairs(beqeend.SafeAlanlari) do
            local distance = #(coords - v.coord)
            v.isInSafeZone = distance < v.radius
            isInSafeZone[index] = v.isInSafeZone

            if v.isInSafeZone then
                newSafeZoneState = true 

                if beqeend.DiriveBay then
                    SetPlayerCanDoDriveBy(player, false)
                end
                
                if beqeend.Vidiem then
                    Wait(0)
                    local vehList = GetGamePool('CVehicle')
                    for _, vehicle in pairs(vehList) do
                        SetEntityNoCollisionEntity(vehicle, ped, true)
                    end
                end

                local meslek = GetPlayerJob()
                if beqeend.Veapons and not IsWhitelistedJob(meslek) then
                    SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true) 
                end
            end
        end

        if newSafeZoneState ~= safeZoneNotificationShown then
            if newSafeZoneState then
                if beqeend.NotifyHangisiOlsunDayeeee == "ox" then
                    exports['ox_lib']:notify({
                        title = beqeend.SafeZoneTitle,
                        description = beqeend.SafeZoneGirisMesaji,
                        type = 'inform',
                        position = beqeend.OXNotifyYeri,
                        duration = beqeend.NotifySuresi
                    })
                elseif beqeend.NotifyHangisiOlsunDayeeee == "qb_notify" then
                    TriggerEvent('QBCore:Notify', beqeend.SafeZoneGirisMesaji, 'success', beqeend.NotifySuresi)
                elseif beqeend.NotifyHangisiOlsunDayeeee == "esx" then
                    ESX.ShowNotification(beqeend.SafeZoneGirisMesaji)
                end
            else
                if beqeend.NotifyHangisiOlsunDayeeee == "ox" then
                    exports['ox_lib']:notify({
                        title = beqeend.SafeZoneCikisTitle,
                        description = beqeend.SafeZoneCikisMesaji,
                        type = 'warning',
                        position = beqeend.OXNotifyYeri,
                        duration = beqeend.NotifySuresi
                    })
                elseif beqeend.NotifyHangisiOlsunDayeeee == "qb_notify" then
                    TriggerEvent('QBCore:Notify', beqeend.SafeZoneCikisMesaji, 'error', beqeend.NotifySuresi)
                elseif beqeend.NotifyHangisiOlsunDayeeee == "esx" then
                    ESX.ShowNotification(beqeend.SafeZoneCikisMesaji)
                end
            end
            safeZoneNotificationShown = newSafeZoneState
        end

        Wait(500)
    end
end)

CreateThread(function()
    while true do
        local isInAnySafeZone = false

        for _, v in pairs(isInSafeZone) do
            if v then
                isInAnySafeZone = true
                break
            end
        end

        local meslek = GetPlayerJob()
        if isInAnySafeZone and not IsWhitelistedJob(meslek) then
            if beqeend.YumrukkAmisina then
                DisableControlAction(0, 140, true)
                DisableControlAction(0, 141, true)
                DisableControlAction(0, 142, true)
            end

            if beqeend.FiriiAyim then
                DisableControlAction(0, 25, true)
            end

            if beqeend.Sooting then
                DisablePlayerFiring(PlayerId(), true)
            end
        end

        Wait(0)
    end
end)

for _, v in pairs(beqeend.SafeAlanlari) do
    local blip = AddBlipForRadius(v.coord.x, v.coord.y, v.coord.z, v.radius)
    SetBlipHighDetail(blip, true)
    SetBlipColour(blip, 2)
    SetBlipAlpha(blip, 128)
end

function GetPlayerJob()
    if FrameworkName == "qb" or FrameworkName == "qbx" then
        if Framework and Framework.Functions then
            local playerData = Framework.Functions.GetPlayerData()
            if playerData and playerData.job then
                return playerData.job.name
            end
        end
    elseif FrameworkName == "esx" then
        if Framework and ESX then
            local xPlayer = ESX.GetPlayerData()
            if xPlayer and xPlayer.job then
                return xPlayer.job.name
            end
        end
    end
    return nil
end