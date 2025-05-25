
-- Variables
-- Table to store the last shooting timestamp for each player to apply shooting cooldown.
local playerShootingCooldowns = {}
-- Flag to prevent multiple instances of shooting processing at the same time.
local processingShot = false

-- Local function to log messages to the client console if debug mode is enabled.
local function Log(message)
    if Config.Debug then
        print("[SmartAlert-Client] " .. tostring(message))
    end
end

-- Local function to log error messages to the client console.
local function LogError(message)
    print("[SmartAlert-Client] ERROR: " .. tostring(message))
end

-- Local function to determine the player's gender based on the model.
local function GetPlayerGender()
    local playerPed = PlayerPedId()
    local model = GetEntityModel(playerPed)

    if model == GetHashKey("mp_m_freemode_01") then
        return "Male"
    elseif model == GetHashKey("mp_f_freemode_01") then
        return "Female"
    end
    return "Unknown"
end

-- Local function to check if the player is wearing a mask.
local function IsPlayerMasked()
    local playerPed = PlayerPedId()
    local maskDrawable = GetPedDrawableVariation(playerPed, 1)

    -- Simple check - this may need to be customized based on the server's clothing system
    if maskDrawable > 0 then
        Log("Mask detected: drawable=" .. maskDrawable)
        return true
    end

    Log("No mask detected: drawable=" .. maskDrawable)
    return false
end

-- Local function to get the street name where the player is located.
local function GetStreetLocation()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local mainStreet = GetStreetNameFromHashKey(streetHash)

    if crossingHash ~= 0 then
        local crossStreet = GetStreetNameFromHashKey(crossingHash)
        return mainStreet .. " & " .. crossStreet
    end

    return mainStreet
end

-- Local function to capture a mugshot of the player using the MugShotBase64 resource.
local function CaptureMugshot()
    Log("Attempting to capture mugshot")

    local success, result = pcall(function()
        return exports["MugShotBase64"]:GetMugShotBase64(PlayerPedId(), false)
    end)

    if not success then
        LogError("Failed to capture mugshot: " .. tostring(result))
        return nil
    end

    if not result or result == "" then
        LogError("Mugshot function returned nil or empty result")
        return nil
    end

    Log("Mugshot captured successfully (" .. string.len(result) .. " characters)")
    return result
end
-- Local function to check if two entities have a clear line of sight.
local function HasClearSight(ped1, ped2, maxDistance)
    if not DoesEntityExist(ped1) or not DoesEntityExist(ped2) then return false end

    local pos1 = GetEntityCoords(ped1)
    local pos2 = GetEntityCoords(ped2)

    local distance = #(pos1 - pos2)
    print(string.format("📏 Distance: %.2f", distance))

    if distance > maxDistance then
        return false
    end

    local hasSight = HasEntityClearLosToEntity(ped1, ped2, 17)
    print("👀 Clear line of sight:", hasSight)
    return hasSight
end

local function IsAnyNearbyPedSeeingPlayer()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local peds = GetGamePool("CPed")
    local closestDist = Config.PedDetectionRadius + 0.01
    local closestPed = nil

    for _, ped in ipairs(peds) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) and not IsEntityDead(ped) then
            local pedCoords = GetEntityCoords(ped)
            local dist = #(pedCoords - playerCoords)
            if dist < closestDist then
                if HasClearSight(ped, playerPed, Config.PedDetectionRadius) then
                    closestDist = dist
                    closestPed = ped
                end
            end
        end
    end

    if closestPed then
        print("NPC has clear line of sight to player.")
        return true
    else
        print("No visible NPC nearby.")
        return false
    end
end

-- Local function that handles the player shooting logic.
local function HandlePlayerShooting()
    local playerPed = PlayerPedId()
    local playerID = GetPlayerServerId(PlayerId())
    local currentTime = GetGameTimer()

    -- Prevent the function from running concurrently.
    if processingShot then
        return
    end

    -- Apply player-wide shooting cooldown.
    if playerShootingCooldowns[playerID] and (currentTime - playerShootingCooldowns[playerID]) < (Config.ShootingCooldown * 1000) then
        return
    end

    -- Prevent the function from running concurrently.
    if processingShot then
        return
    end

    -- Check if the player is shooting.
    if IsPedShooting(playerPed) then
        -- Check if there are any NPCs that can see the player.
        if not IsAnyNearbyPedSeeingPlayer() then
            Log("Shooting detected but no NPC witnesses in sight. Alert not triggered.")
            return
        end

        processingShot = true
        Log("Shooting detected, processing alert")

        -- Apply the player-wide shooting cooldown.
        playerShootingCooldowns[playerID] = currentTime

        -- Check if the player is masked.
        local masked = IsPlayerMasked()

        -- Introduce a chance for no alert to be sent.
        local randomChance = math.random(1, 100)
        if randomChance > Config.AlertChance then
            Log("Alert suppressed: Random chance (" .. (100 - Config.AlertChance) .. "%) prevented alert.")
            processingShot = false
            return
        end

        -- If the player is not masked, capture and send the mugshot to the server.
        if not masked then
            Log("Player is unmasked, preparing facial recognition data for server.")
            local mugshot = CaptureMugshot()
            if mugshot then
                -- Trigger the server event to process the image and send the face description.
                TriggerServerEvent('shootingAlert:processImage', mugshot, GetPlayerServerId(PlayerId()))
            else
                LogError("Failed to capture mugshot, continuing without face description.")
            end
        end

        -- Reset the processing flag after a short delay.
        Citizen.SetTimeout(500, function()
            processingShot = false
        end)
    end
end

-- Event Handlers & Initialization
-- Main thread to continuously handle player shooting.
Citizen.CreateThread(function()
    Log("Shooting alert system initialized")
    while true do
        HandlePlayerShooting()
        Citizen.Wait(200)
    end
end)

-- Registered Net Event: Handles the face description received from the server
RegisterNetEvent('Client:ReceivedFaceDescription', function(data)
    -- Get the player's current street and prepares the dispatch data.
    local coords = GetEntityCoords(PlayerPedId())
    local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
    local dispatchData = {
        message = 'Shooting Alert',
        codeName = 'smart-alert',
        code = '10-35',
        gender = GetPlayerGender(),
        icon = 'fas fa-car-burst',
        coords = coords,
        street = street,
        information = data,
        jobs = { 'leo' }
    }
    -- Triggers the ps-dispatch:server:notify event on the server to dispatch the alert.
    Wait(5000) -- Wait for 10 seconds before sending the alert for more realism.
    TriggerServerEvent('ps-dispatch:server:notify', dispatchData)
end)


-- dev tool for test only 
-- RegisterCommand("spawnped", function(source, args)
--     local modelName = args[1] or "a_m_m_skater_01" -- default ped model
--     local playerPed = PlayerPedId()
--     local coords = GetEntityCoords(playerPed)

--     RequestModel(modelName)
--     while not HasModelLoaded(modelName) do
--         Wait(100)
--     end

--     local spawnedPed = CreatePed(4, modelName, coords.x, coords.y, coords.z, GetEntityHeading(playerPed), true, false)

--     SetEntityAsMissionEntity(spawnedPed, true, true)
--     SetPedCanRagdoll(spawnedPed, true)

--     print("✅ Spawned ped: " .. modelName)
-- end)
