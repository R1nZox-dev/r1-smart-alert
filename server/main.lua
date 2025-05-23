-- !! IMPORTANT !! Replace 'YOUR_DISCORD_WEBHOOK_URL_HERE' with your actual Discord webhook URL
local AIKey = "YOUR_GEMINI_API_KEY" -- YOUR ACTUAL GEMINI API KEY
local aiRequestCounter = 0
RegisterNetEvent('shootingAlert:processImage')
AddEventHandler('shootingAlert:processImage', function(imageBase64)
    local playerServerId = source
    if not imageBase64 then
        return
    end

    local _, _, mimeTypePrefix, base64PureData = string.find(imageBase64, "^(data:[%w/+%-]+;base64,)(.*)")

    if not base64PureData then
        return
    end

    local mime_type = "image/png"
    if mimeTypePrefix then
        local foundMime = string.match(mimeTypePrefix, "data:([^;]+);base64,")
        if foundMime then
            mime_type = foundMime
        end
    end

    -- Increment the request counter before sending the AI request
    aiRequestCounter = aiRequestCounter + 1

    local requestData = {
        contents = {
            {
                role = "user",
                parts = {
                    { text = Config.AIPrompts[Config.PlayerSelectedLanguage] or Config.AIPrompts["english"] },
                    {
                        inline_data = {
                            mime_type = mime_type,
                            data = base64PureData
                        }
                    }
                }
            }
        }
    }

    -- Use AIKey if you've moved your API key into the Config table
    local AIEndpointFull = Config.AIEndpoint .. AIKey
    local requestBody = json.encode(requestData)

    PerformHttpRequest(AIEndpointFull, function(statusCode, responseText, headers)
        local faceDescription = "N/A"
        local successMessage = "AI Request Processed"
        local embedColor = 0x00FF00 -- Green for success

        local currentTime = os.date("%Y-%m-%d %H:%M:%S")
        local playerIdentifier = GetPlayerIdentifiers(playerServerId)[1] or "Unknown" -- Get a unique player identifier

        -- Build common fields for the embed
        local fields = {
            { name = "Request Number", value = tostring(aiRequestCounter), inline = true },
            { name = "Player ID", value = tostring(playerServerId), inline = true },
            { name = "Identifier", value = playerIdentifier, inline = true },
        }

        if statusCode ~= 200 then
            successMessage = "AI Request Failed"
            embedColor = 0xFF0000 -- Red for error
            faceDescription = responseText or "No response text."
            table.insert(fields, { name = "Status Code", value = tostring(statusCode), inline = true })
            table.insert(fields, { name = "Error Response", value = faceDescription, inline = false })
        else
            local success, response = pcall(json.decode, responseText)
            if not success then
                successMessage = "AI Request Failed (JSON Error)"
                embedColor = 0xFFA500 -- Orange for warning
                faceDescription = responseText or "JSON decode failed."
                table.insert(fields, { name = "Error Details", value = faceDescription, inline = false })
            else
                if response and response.candidates and response.candidates[1] and
                   response.candidates[1].content and response.candidates[1].content.parts and
                   response.candidates[1].content.parts[1] and response.candidates[1].content.parts[1].text then
                    faceDescription = response.candidates[1].content.parts[1].text
                    TriggerClientEvent('Client:ReceivedFaceDescription', playerServerId, faceDescription)
                    table.insert(fields, { name = "Description", value = faceDescription, inline = false })
                else
                    successMessage = "AI Request Failed (Invalid Format)"
                    embedColor = 0xFFA500 -- Orange for warning
                    faceDescription = responseText or "AI response format invalid."
                    table.insert(fields, { name = "Raw Response", value = faceDescription, inline = false })
                end
            end
        end

        local contentMessage = ""
        -- Check if it's time to tag @everyone
        if aiRequestCounter >= Config.TagEveryoneThreshold then
            contentMessage = "@everyone - AI Request Threshold Almost Reached!"
            -- Reset counter after tagging if desired, otherwise comment this line
            aiRequestCounter = 0
        end

        -- Construct the embed payload
        local embedPayload = {
            username = "AI Request Logger", -- Name that appears for the webhook
            avatar_url = "https://media.discordapp.net/attachments/1234292894500913162/1234538226237046929/r1.jpg?ex=6831f051&is=68309ed1&hm=ed335155aae508dc76981aecda75e4e52576be18e7faa9a5a6e54c21736a25f2&=&format=webp", -- Optional: URL to an avatar for the webhook user
            content = contentMessage, -- The message content above the embed (optional, used for @everyone)
            embeds = {
                {
                    title = successMessage,
                    description = string.format("Details for AI image processing request."),
                    color = embedColor, -- Decimal representation of hex color (e.g., 0x00FF00 is 65280)
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"), -- ISO 8601 format for Discord timestamp
                    footer = {
                        text = "AI Request Log",
                        icon_url = "https://media.discordapp.net/attachments/1234292894500913162/1234538226237046929/r1.jpg?ex=6831f051&is=68309ed1&hm=ed335155aae508dc76981aecda75e4e52576be18e7faa9a5a6e54c21736a25f2&=&format=webp" -- Optional footer icon
                    },
                    fields = fields
                }
            }
        }

        -- Send the embed to Discord via webhook
        if Config.DiscordWebhookURL ~= 'YOUR_DISCORD_WEBHOOK_URL_HERE' then
            PerformHttpRequest(Config.DiscordWebhookURL, function(webhookStatusCode, webhookResponseText, webhookHeaders)
                if webhookStatusCode ~= 204 then -- 204 No Content is success for Discord webhooks
                    print(string.format("Failed to send Discord webhook. Status: %d, Response: %s", webhookStatusCode, webhookResponseText))
                end
            end, 'POST', json.encode(embedPayload), {
                ['Content-Type'] = 'application/json'
            })
        else
            print("WARNING: DiscordWebhookURL is not set in script. Logging to console only.")
        end

    end, 'POST', requestBody, {
        ['Content-Type'] = 'application/json'
    })
end)