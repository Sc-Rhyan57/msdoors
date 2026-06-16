if _G.msdoors_isloading then
    print(" O SCRIPT JÁ ESTÁ CARREGANDO!!! ")
    return
end

_G.msdoors_version = "01.11.25"

if shared.loaded then
    warn("[Msdoors] • Script já está carregado!")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Script já carregado!",
        Image = "rbxassetid://95869322194132",
        Text = "o script já está carregado!",
        Duration = 5
    })
    return
end

local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)

local CoreGui = cloneref(game:GetService("CoreGui"))

local function GetGitAudioID(githubLink, soundName)
    local fileName = "customObject_Sound_" .. tostring(soundName) .. ".mp3"
    local success, audioData = pcall(function()
        return game:HttpGet(githubLink)
    end)
    if not success then
        warn("Falha ao baixar o áudio: " .. githubLink)
        return nil
    end
    writefile(fileName, audioData)
    return (getcustomasset or getsynasset)(fileName)
end

local function PlayGitSound(githubLink, soundName, volume)
    local soundId = GetGitAudioID(githubLink, soundName)
    if soundId then
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = volume or 0.5
        sound.Parent = CoreGui
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
            delfile("customObject_Sound_" .. tostring(soundName) .. ".mp3")
        end)
        return sound
    end
    
    return nil
end

PlayGitSound("https://github.com/Sc-Rhyan57/RandomStuff/raw/refs/heads/main/blue_lock_goal_score.mp3", "GOAAAAALLLL", 3)

--[[
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://8486683243"
sound.Volume = 3
sound.Parent = CoreGui
sound:Play()
sound.Ended:Connect(function()
    sound:Destroy()
end)
]]--

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
local SUPPORTED_GAMES = {
    [6516141723] = "Doors-lobby",
    [107838858975205] = "Doors-lobby", -- hardcore lobby
    [137519142947486] = "Doors-hotel", -- Hardcore
    [92934548952604] = "Doors-hotel", -- hardcore+
    [104289811284920] = "Doors-hotel", -- hardcore backup
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
    pcall(function()
        Services.StarterGui:SetCore("SendNotification", {
            Title = "Msdoors | Error",
            Image = "rbxassetid://95869322194132",
            Text = "An error occurred. Do you want to copy?\n" .. string.sub(errorMessage, 1, 100),
            Duration = 50,
            Button1 = "Copiar erro",
            Button2 = "Ignorar",
            Callback = Instance.new("BindableFunction")
        })
    end)

    local bindable = Instance.new("BindableFunction")
    bindable.OnInvoke = function(button)
        if button == "Copiar erro" then
            pcall(function()
                if setclipboard then
                    setclipboard(errorMessage)
                elseif toclipboard then
                    toclipboard(errorMessage)
                elseif Clipboard and Clipboard.set then
                    Clipboard.set(errorMessage)
                end
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
            Button1 = "Copiar erro",
            Button2 = "Ignorar",
            Callback = bindable
        })
    end)
end

local function loadScript(url)
    local httpMethods = {
        function() return game:HttpGet(url) end,
        function() 
            if typeof(http_request) == "function" then
                local response = http_request({Url = url, Method = "GET"})
                return response.Body
            end
        end,
        function() 
            if typeof(request) == "function" then
                local response = request({Url = url, Method = "GET"})
                return response.Body
            end
        end,
        function()
            if typeof(syn) == "table" and typeof(syn.request) == "function" then
                local response = syn.request({Url = url, Method = "GET"})
                return response.Body
            end
        end
    }
    
    local response = nil
    for _, method in pairs(httpMethods) do
        local success, result = pcall(method)
        if success and result then
            response = result
            break
        end
    end
    
    if not response then
        notifyError("Falha ao baixar o script da URL: " .. url)
        return false
    end
    
    local func, loadErr = loadstring(response)
    if not func then
        notifyError("Falha ao compilar o script:\n" .. tostring(loadErr))
        return false
    end

    local success, execErr = pcall(func)
    if not success then
        notifyError("Falha ao executar o script:\n" .. tostring(execErr))
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

    local success = loadScript(SCRIPT_URL .. scriptName)
    
    if success then
        notify("Sucess", "Script executed successfully!")
    end
    
    _G.msdoors_isloading = false
end

startMsdoors()
