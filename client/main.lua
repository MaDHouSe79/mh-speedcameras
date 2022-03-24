local QBCore = exports['qb-core']:GetCoreObject()
local LoadedPropList = {}
local coyottestate = false
local PlayerData = {}
local Blips = {}
local highspeed = 0
local numberPlate = ""
local model = ""
local street1 = ""

local speedMultiplier = Config.UseMPH and 2.23694 or 3.6

local displaymph = Config.UseMPH and "MPH" or "KM"

local hasFlits =  false

local function round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

-- create radar props
local function LoadRadarProps()
	local propName = 'prop_cctv_pole_01a'
	RequestModel(propName)
	while not HasModelLoaded(propName) do
		Citizen.Wait(100)
	end
	for k, v in pairs(Config.Radars) do
		local radar = CreateObject(GetHashKey(propName), v.coords.x, v.coords.y, v.coords.z - 7, true, true, true)
		SetObjectTargettable(radar, true)
		SetEntityHeading(radar, v.coords.w - 115)
		SetEntityAsMissionEntity(radar, true, true)
		FreezeEntityPosition(radar, true)
		LoadedPropList[#LoadedPropList + 1] = radar
	end
	TriggerEvent('qb-speedcameras:ShowRadarBlip')
end

local -- Determines if player is close enough to trigger cam
function HandlespeedCam(kmhSpeed, maxSpeed, Plate, vehicleModel, radarStreet)
	local fine = 0
	local TooMuchSpeed = tonumber(kmhSpeed) - tonumber(maxSpeed)
	if TooMuchSpeed >= 25 and TooMuchSpeed <= 50 then
		fine = 500 + (TooMuchSpeed * Config.KmhFine)
	elseif TooMuchSpeed > 50 and TooMuchSpeed <= 100 then
		fine = 750 + (TooMuchSpeed * Config.KmhFine)
	elseif TooMuchSpeed > 100 and TooMuchSpeed <= 125 then
		fine = 1000 + (TooMuchSpeed * Config.KmhFine)
	elseif TooMuchSpeed > 125 and TooMuchSpeed <= 150 then
		fine = 1250 + (TooMuchSpeed * Config.KmhFine)
	elseif TooMuchSpeed > 150 and TooMuchSpeed <= 175 then
		fine = 1500 + (TooMuchSpeed * Config.KmhFine)
	elseif TooMuchSpeed > 175 then
		fine = 1750 + (TooMuchSpeed * Config.KmhFine)
	end
	if TooMuchSpeed >= 25 then

		local PlayerData = QBCore.Functions.GetPlayerData()

		local driver = PlayerData.charinfo.firstname ..' '.. PlayerData.charinfo.lastname
		local citizenid = PlayerData.citizenid
		TriggerServerEvent('qb-speedcameras:PayFine', GetPlayerServerId(PlayerId()), Plate, kmhSpeed, maxSpeed, fine, vehicleModel, radarStreet, displaymph, driver, citizenid)
	end
end

local function UnloadRadarProps()
	for k, v in pairs(LoadedPropList) do
		DeleteEntity(v)
	end
end

local function Flits()
	if not hasFlits then
		hasFlits = true
		SetNuiFocus(false,false)
		SendNUIMessage({type = 'openSpeedcamera'})
		Citizen.Wait(50)
		SendNUIMessage({type = 'closeSpeedcamera'})
		SendNUIMessage({playsong = 'true', songname= "speedcamera"})
		QBCore.Functions.Notify(Lang:t('notify.flashed'), "error", 5000)
	end
	
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    UnloadRadarProps()
	Wait(10)
	LoadRadarProps()
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		UnloadRadarProps()
	end
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		LoadRadarProps()
	end
end)

RegisterNetEvent('qb-speedcameras:ShowRadarBlip', function()
	coyottestate = true
	if Config.ShowBlips then 
		for k,v in pairs (Config.Radars) do
			local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
			SetBlipSprite  (blip, 184)
			SetBlipDisplay (blip, 4)
			SetBlipScale   (blip, 1.0)
			SetBlipCategory(blip, 3)
			SetBlipColour  (blip, 0)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			if Config.MergBlips then 
				AddTextComponentString(Lang:t('blip.title1'))
			else
				AddTextComponentString(Lang:t('blip.title2',{maxspeed = v.maxSpeed}))
			end
			EndTextCommandSetBlipName(blip)
			Blips[#Blips + 1] = blip
		end
	end
end)

RegisterNetEvent('qb-speedcameras:ShowRadarProp', function()
	LoadRadarProps()
end)

RegisterNetEvent('qb-speedcameras:RemoveRadarBlip', function()
	coyottestate = false
	for i=1, #Blips, 1 do
		RemoveBlip(Blips[i])
		Blips[i] = nil
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		for k,v in pairs (Config.Radars) do
			local myPed = GetPlayerPed(-1)
			local vehicle = GetVehiclePedIsIn(myPed, false)
			if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == myPed then
				if QBCore.Functions.GetPlayerData().job.name == 'police' or QBCore.Functions.GetPlayerData().job.name == 'ambulance' and QBCore.Functions.GetPlayerData().job.onduty then
					return
				end
				local coords = GetEntityCoords(myPed)
				local distance = GetDistanceBetweenCoords(v.coords.x, v.coords.y, v.coords.z,coords, true)
				local kmhSpeed = math.ceil(GetEntitySpeed(vehicle) * speedMultiplier)
				if distance < Config.SpeedCamRange then
					while GetDistanceBetweenCoords(v.coords.x, v.coords.y, v.coords.z, GetEntityCoords(myPed), true) < Config.SpeedCamRange do
						if GetVehicleClass(vehicle) ~= 18 then
							local kmhSpeed =  math.ceil(GetEntitySpeed(vehicle) * speedMultiplier)
							numberPlate = GetVehicleNumberPlateText(vehicle)
							local s1, s2 = Citizen.InvokeNative( 0x2EB41072B4C1E4C0,v.coords.x, v.coords.y, v.coords.z, Citizen.PointerValueInt(), Citizen.PointerValueInt() )
							street1 = GetStreetNameFromHashKey(s1)
							model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
							if (tonumber(kmhSpeed) > tonumber(v.maxSpeed)) and (tonumber( highspeed) < tonumber(kmhSpeed)) then
								highspeed = kmhSpeed
								Flits()
							end
						end
						Citizen.Wait(100)
					end
					if highspeed ~= 0 then
						HandlespeedCam(highspeed, v.maxSpeed, numberPlate, model, street1)
						Citizen.Wait(500)
					end
					highspeed = 0
					Citizen.Wait(500)
					hasFlits = false
				end
			end
		end
	end
end)
