local QBCore = exports['qb-core']:GetCoreObject()

local UseWebHook = false
local Webhook = "" --webhook 

local function sendToDiscord(title, message, color)
	if UseWebHook then
		if Webhook == "" then
			print("you have no webhook, create one on discord [https://discord.com/developers/applications] and place this in the config.lua (Config.Webhook)")
		else
			if message == nil or message == '' then return end
			LogArray = {
				{
					["color"] = color,
					["title"] = title,
					["description"] = "Time: **"..os.date('%Y-%m-%d %H:%M:%S').."**",
					["fields"] = {
						{
							["name"] = Lang:t('discord.vehicle'),
							["value"] = message
						}
					},
					["footer"] = {
						["text"] = "qb-speedcameras re-edit by MaDHouSe",
						["icon_url"] = "https://icons.iconarchive.com/icons/iconarchive/red-orb-alphabet/128/Letter-M-icon.png",
					}
				}
			}
			PerformHttpRequest(Config.Webhook , function(err, text, headers) end, 'POST', json.encode({username = "SpeedCam", embeds = LogArray}), { ['Content-Type'] = 'application/json' })
		end
	end
end

RegisterServerEvent('qb-speedcameras:PayFine')
AddEventHandler('qb-speedcameras:PayFine', function(source, plate, kmhSpeed, maxSpeed, amount, vehicleModel, radarStreet, displaymph, data)
	local platePrefix = string.upper(string.sub(plate, 0, 4))
	local _source = source
	local color = Config.orange
	local title = "Speed Cam"
	local speed = kmhSpeed - maxSpeed
	local Player = QBCore.Functions.GetPlayer(_source)
	local driver = Player.PlayerData.charinfo.firstname ..' '.. Player.PlayerData.charinfo.lastname
	local citizenid = Player.PlayerData.citizenid
    if Player.Functions.RemoveMoney("cash", amount, "pay-fine") then
		TriggerClientEvent('QBCore:Notify', _source, Lang:t('notify.payfine'), "success")
    else
		if Player.Functions.RemoveMoney("bank", amount, "pay-fine") then
			TriggerClientEvent('QBCore:Notify', _source, Lang:t('notify.payfine'), "success")
		end
	end
	sendToDiscord(Lang:t('discord.title',{title=title}),Lang:t('discord.driver', {driver = driver}) ..'\n'..Lang:t('discord.model', {model = vehicleModel}) ..'\n'..Lang:t('discord.plate', {plate = plate})..'\n'..Lang:t('discord.speed', {speed = kmhSpeed, displaymph=displaymph}).. '\n'..Lang:t('discord.maxspeed', {maxspeed = maxSpeed})..'\n'..Lang:t('discord.radar', {street = radarStreet})..'\n'..Lang:t('discord.fine', {fine = amount}), color)
end)
