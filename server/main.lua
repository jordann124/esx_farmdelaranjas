ESX 						   = nil
local CopsConnected       	   = 0
local PlayersHarvestingKoda    = {}
local PlayersTransformingKoda  = {}
local PlayersSellingKoda       = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function CountCops()
	local xPlayers = ESX.GetPlayers()

	CopsConnected = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			CopsConnected = CopsConnected + 1
		end
	end

	SetTimeout(120 * 1000, CountCops)
end

CountCops()

--kodeina
local function HarvestKoda(source)

	SetTimeout(Config.TimeToFarm, function()
		if PlayersHarvestingKoda[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local koda = xPlayer.getInventoryItem('laranja')

			if koda.limit ~= -1 and koda.count >= koda.limit then
				TriggerClientEvent('esx:showNotification', source, _U('mochila_full'))
			else
				xPlayer.addInventoryItem('laranja', 1)
				HarvestKoda(source)
			end
		end
	end)
end

RegisterServerEvent('esx_farmdelaranjas:startHarvestKoda')
AddEventHandler('esx_farmdelaranjas:startHarvestKoda', function()
	local _source = source

	if not PlayersHarvestingKoda[_source] then
		PlayersHarvestingKoda[_source] = true

		TriggerClientEvent('esx:showNotification', _source, _U('pegar_laranjas'))
		HarvestKoda(_source)
	else
		print(('esx_farmdelaranjas: %s attempted to exploit the marker!'):format(GetPlayerIdentifiers(_source)[1]))
	end
end)

RegisterServerEvent('esx_farmdelaranjas:stopHarvestKoda')
AddEventHandler('esx_farmdelaranjas:stopHarvestKoda', function()
	local _source = source

	PlayersHarvestingKoda[_source] = false
end)

local function TransformKoda(source)

	SetTimeout(Config.TimeToProcess, function()
		if PlayersTransformingKoda[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local kodaQuantity = xPlayer.getInventoryItem('laranja').count
			local pooch = xPlayer.getInventoryItem('sumo_de_laranja')

			if pooch.limit ~= -1 and pooch.count >= pooch.limit then
				TriggerClientEvent('esx:showNotification', source, _U('nao_tens_laranjas_suficientes'))
			elseif kodaQuantity < 5 then
				TriggerClientEvent('esx:showNotification', source, _U('nao_tens_mais_laranjas'))
			else
				xPlayer.removeInventoryItem('laranja', 5)
				xPlayer.addInventoryItem('sumo_de_laranja', 1)

				TransformKoda(source)
			end
		end
	end)
end

RegisterServerEvent('esx_farmdelaranjas:startTransformKoda')
AddEventHandler('esx_farmdelaranjas:startTransformKoda', function()
	local _source = source

	if not PlayersTransformingKoda[_source] then
		PlayersTransformingKoda[_source] = true

		TriggerClientEvent('esx:showNotification', _source, _U('transformar_sumo_de_laranja'))
		TransformKoda(_source)
	else
		print(('esx_farmdelaranjas: %s attempted to exploit the marker!'):format(GetPlayerIdentifiers(_source)[1]))
	end
end)

RegisterServerEvent('esx_farmdelaranjas:stopTransformKoda')
AddEventHandler('esx_farmdelaranjas:stopTransformKoda', function()
	local _source = source

	PlayersTransformingKoda[_source] = false
end)

local function SellKoda(source)

	SetTimeout(Config.TimeToSell, function()
		if PlayersSellingKoda[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local poochQuantity = xPlayer.getInventoryItem('sumo_de_laranja').count

			if poochQuantity == 0 then
				TriggerClientEvent('esx:showNotification', source, _U('nao_tens_sumo_de_laranja'))
			else
				xPlayer.removeInventoryItem('sumo_de_laranja', 1)
				if CopsConnected == 0 then
					xPlayer.addAccountMoney('bank', 10)
					TriggerClientEvent('esx:showNotification', source, _U('vendeste_sumo'))
				elseif CopsConnected == 1 then
					xPlayer.addAccountMoney('bank', 10)
					TriggerClientEvent('esx:showNotification', source, _U('vendeste_sumo'))
				elseif CopsConnected == 2 then
					xPlayer.addAccountMoney('bank', 10)
					TriggerClientEvent('esx:showNotification', source, _U('vendeste_sumo'))
				elseif CopsConnected == 3 then
					xPlayer.addAccountMoney('bank', 10)
					TriggerClientEvent('esx:showNotification', source, _U('vendeste_sumo'))
				elseif CopsConnected == 4 then
					xPlayer.addAccountMoney('bank', 10)
					TriggerClientEvent('esx:showNotification', source, _U('vendeste_sumo'))
				elseif CopsConnected >= 5 then
					xPlayer.addAccountMoney('bank', 10)
					TriggerClientEvent('esx:showNotification', source, _U('vendeste_sumo'))
				end

				SellKoda(source)
			end
		end
	end)
end

RegisterServerEvent('esx_farmdelaranjas:startSellKoda')
AddEventHandler('esx_farmdelaranjas:startSellKoda', function()
	local _source = source

	if not PlayersSellingKoda[_source] then
		PlayersSellingKoda[_source] = true

		TriggerClientEvent('esx:showNotification', _source, _U('venda_do_sumo'))
		SellKoda(_source)
	else
		print(('esx_farmdelaranjas: %s attempted to exploit the marker!'):format(GetPlayerIdentifiers(_source)[1]))
	end
end)

RegisterServerEvent('esx_farmdelaranjas:stopSellKoda')
AddEventHandler('esx_farmdelaranjas:stopSellKoda', function()
	local _source = source

	PlayersSellingKoda[_source] = false
end)

RegisterServerEvent('esx_farmdelaranjas:GetUserInventory')
AddEventHandler('esx_farmdelaranjas:GetUserInventory', function(currentZone)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	TriggerClientEvent('esx_farmdelaranjas:ReturnInventory',
		_source,
		xPlayer.getInventoryItem('laranja').count,
		xPlayer.getInventoryItem('sumo_de_laranja').count,
		xPlayer.job.name,
		currentZone
	)
end)

ESX.RegisterUsableItem('laranja', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeInventoryItem('laranja', 1)

	TriggerClientEvent('esx_farmdelaranjas:onPot', _source)
	TriggerClientEvent('esx:showNotification', _source, _U('used_one_koda'))
end)
