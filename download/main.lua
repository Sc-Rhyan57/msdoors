if _G.msdoors_isloading then
    print(" THE SCRIPT IS ALREADY LOADING!!! ")
    return
end

_G.msdoors_version = "01.11.25"

if shared.loaded then
    warn("[Msdoors] • Script is already loaded!")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Script already loaded!",
        Image = "rbxassetid://95869322194132",
        Text = "The script is already loaded!",
        Duration = 5
    })
    return
end

local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)

local CoreGui = cloneref(game:GetService("CoreGui"))

local function playRobloxSound(soundId, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. tostring(soundId)
    sound.Volume = volume or 3
    sound.Parent = CoreGui
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
    return sound
end

local RARE_SOUND_ID = 114029807919810
local MAIN_SOUND_ID = 8486683243
local RARE_CHANCE = 0.05

if math.random() < RARE_CHANCE then
    playRobloxSound(RARE_SOUND_ID, 3)
else
    playRobloxSound(MAIN_SOUND_ID, 3)
end

local Services = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    StarterGui = game:GetService("StarterGui"),
    Players = game:GetService("Players"),
    HttpService = game:GetService("HttpService")
}

local player = Services.Players.LocalPlayer
local placeId = game.PlaceId

local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    return success and result or nil
end

local SCRIPT_URL = "https://raw.msdoors.xyz/"
local FALLBACK_URL = "https://msdoors-content.vercel.app/"

local SUPPORTED_GAMES = {
    [6516141723] = "Doors-lobby",
    [107838858975205] = "Doors-lobby",
    [137519142947486] = "Doors-hotel",
    [92934548952604] = "Doors-hotel",
    [131351567799504] = "Doors-hotel",
    [74871629393921] = "Doors-lobby",
    [104289811284920] = "Doors-hotel",
    [6839171747] = "Doors-hotel",
    [2440500124] = "Doors-hotel",
    [87716067947993] = "Doors-hotel",
    [10549820578] = "Doors-hotel",
    [110258689672367] = "Doors-hotel",
    [189707] = "NaturalDisaster-game",
    [12137249458] = "Campos-FFA",
    [893973440] = "FTF"
}

local function notify(title, message)
    pcall(function()
        Services.StarterGui:SetCore("SendNotification", {
            Title = "Msdoors | " .. title,
            Image = "rbxassetid://95869322194132",
            Text = message,
            Duration = 5
        })
    end)
    print("[Msdoors] " .. title .. ": " .. message)
end

local function notifyError(errorMessage)
    warn("[Msdoors] Error: " .. errorMessage)

    local bindable = Instance.new("BindableFunction")
    bindable.OnInvoke = function(button)
        if button == "Copy error" then
            pcall(function()
                if setclipboard then
                    setclipboard(errorMessage)
                elseif toclipboard then
                    toclipboard(errorMessage)
                elseif Clipboard and Clipboard.set then
                    Clipboard.set(errorMessage)
                end
            end)
            pcall(function()
                Services.StarterGui:SetCore("SendNotification", {
                    Title = "Msdoors | Copied!",
                    Image = "rbxassetid://95869322194132",
                    Text = "Error copied to clipboard!",
                    Duration = 3
                })
            end)
        end
        bindable:Destroy()
    end

    pcall(function()
        Services.StarterGui:SetCore("SendNotification", {
            Title = "Msdoors | Error",
            Image = "rbxassetid://95869322194132",
            Text = string.sub(errorMessage, 1, 200),
            Duration = 50,
            Button1 = "Copy error",
            Button2 = "Ignore",
            Callback = bindable
        })
    end)
end

local function fetchUrl(url)
    local httpMethods = {
        function()
            return game:HttpGet(url)
        end,
        function()
            if typeof(http_request) == "function" then
                local res = http_request({ Url = url, Method = "GET" })
                return res.Body
            end
        end,
        function()
            if typeof(request) == "function" then
                local res = request({ Url = url, Method = "GET" })
                return res.Body
            end
        end,
        function()
            if typeof(syn) == "table" and typeof(syn.request) == "function" then
                local res = syn.request({ Url = url, Method = "GET" })
                return res.Body
            end
        end
    }

    local lastError = nil
    for _, method in pairs(httpMethods) do
        local success, result = pcall(method)
        if success and result then
            return result, nil
        elseif not success then
            lastError = tostring(result)
        end
    end
    return nil, lastError
end

local function loadScript(urls)
    local response = nil
    local lastError = nil
    local usedUrl = nil

    for _, url in ipairs(urls) do
        local body, err = fetchUrl(url)
        if body then
            response = body
            usedUrl = url
            break
        else
            lastError = err
            warn("[Msdoors] Failed to fetch from: " .. url .. (err and (" (" .. err .. ")") or ""))
        end
    end

    if not response then
        local errMsg = "Failed to download script from all sources:\n" .. table.concat(urls, "\n")
        if lastError then
            errMsg = errMsg .. "\nLast error: " .. lastError
        end
        notifyError(errMsg)
        return false
    end

    print("[Msdoors] Loaded from: " .. usedUrl)

    local func, loadErr = loadstring(response)
    if not func then
        notifyError("Failed to compile script:\n" .. tostring(loadErr))
        return false
    end

    local success, execErr = pcall(func)
    if not success then
        notifyError("Failed to execute script:\n" .. tostring(execErr))
        return false
    end

    return true
end

local function startMsdoors()
    local currentGame = game.PlaceId
    _G.msdoors_isloading = true

    local scriptName = SUPPORTED_GAMES[currentGame]
    if not scriptName then
        shared.loaded = false
        notify("WARN", "Game not supported")
        _G.msdoors_isloading = false
        return
    end

    local urls = {
        SCRIPT_URL .. scriptName,
        FALLBACK_URL .. scriptName
    }

    local success = loadScript(urls)

    if success then
        notify("Success", "Script executed successfully!")
    end

    _G.msdoors_isloading = false
end

startMsdoors()
