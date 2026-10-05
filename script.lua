--[[
    ==============================================================
    SUPERHERO EVOLUTION HUB - AUTO EDITION
    Jogo: +1 Superhero Evolution (PVP)
    Tecla 'K' para Minimizar / Abrir
    
    Abas e Automações:
       • ⚡ Auto Click (100% em Segundo Plano - Sem afetar Chat)
       • 🔄 Auto Rebirth (100% em Segundo Plano - Automático)
       • 🏆 Auto Win (Deslize Contínuo, Pad Alvo e Pausa Configurável)
       • 🌀 Auto Endless (Seleção de Mundos, Padrão Mundo 10, Fica Parado até Morrer)
       • ⚙️ Config (Salvar Estado, Anti-AFK, Auto Recompensas, Auto Fechar Pop-ups Robux)
    ==============================================================
]]

local SCRIPT_VERSION_TIMESTAMP = 1791169165

-- Destrói instâncias anteriores para evitar duplicatas
local function destroyExistingHubs()
    for _, parent in ipairs({
        gethui and gethui(),
        (game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")),
        game:GetService("CoreGui")
    }) do
        if parent then
            for _, c in ipairs(parent:GetChildren()) do
                if c.Name:match("^SuperHeroEvolutionHub") then
                    pcall(function() c:Destroy() end)
                end
            end
        end
    end
end
destroyExistingHubs()

if getgenv().SuperHeroEvolutionHubLoaded then
    if getgenv().SuperHeroEvolutionHubCleanup then
        pcall(getgenv().SuperHeroEvolutionHubCleanup)
    end
end
getgenv().SuperHeroEvolutionHubLoaded = true

-- Limpa conexões fantasmas de eventos Endless
pcall(function()
    if getconnections then
        local rep = game:GetService("ReplicatedStorage")
        local shared = rep:FindFirstChild("Shared")
        local rems = shared and shared:FindFirstChild("Remotes")
        if rems then
            local eu = rems:FindFirstChild("EndlessUpdate")
            if eu and eu:IsA("RemoteEvent") then
                for _, conn in ipairs(getconnections(eu.OnClientEvent)) do
                    pcall(function() conn:Disconnect() end)
                end
            end
            local ebs = rems:FindFirstChild("EndlessBattleState")
            if ebs and ebs:IsA("RemoteEvent") then
                for _, conn in ipairs(getconnections(ebs.OnClientEvent)) do
                    pcall(function() conn:Disconnect() end)
                end
            end
        end
    end
end)

-- Serviços do Roblox
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Remotes Oficiais do Jogo
local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local Remotes = Shared and Shared:WaitForChild("Remotes", 10)

local RemotePlayerClick = Remotes and Remotes:FindFirstChild("PlayerClick")
local RemoteRequestAttack = Remotes and Remotes:FindFirstChild("RequestAttack")
local RemoteRequestTrain = Remotes and Remotes:FindFirstChild("RequestTrain")
local RemoteRequestRebirth = Remotes and Remotes:FindFirstChild("RequestRebirth")
local RemoteRequestWorldChange = Remotes and Remotes:FindFirstChild("RequestWorldChange")
local RemoteEndlessJoinRequest = Remotes and Remotes:FindFirstChild("EndlessJoinRequest")
local RemoteEndlessStateRequest = Remotes and Remotes:FindFirstChild("EndlessStateRequest")
local RemoteEndlessBattleState = Remotes and Remotes:FindFirstChild("EndlessBattleState")
local RemoteEndlessUpdate = Remotes and Remotes:FindFirstChild("EndlessUpdate")
local RemotePlayVFX = Remotes and Remotes:FindFirstChild("PlayVFX")

-- ══════════════════════════════════════════════════════════════
-- CONFIGURAÇÕES & ESTADO
-- ══════════════════════════════════════════════════════════════
local Config = {
    -- 1. Auto Click (Em segundo plano, sem atrapalhar chat)
    FastClick = false,
    ClickDelay = 0.1, -- De 0.1s a 10.0s por clique
    ClicksCount = 0,
    
    -- 2. Auto Rebirth (Automático em segundo plano)
    AutoRebirth = false,
    RebirthDelay = 1.0,
    RebirthsCount = 0,
    
    -- 3. Auto Win (Deslize contínuo até o estágio alvo)
    SelectedProgWorld = "world10",
    SelectedProgStage = "Stage150",
    AutoWin = false,
    WinGlideSpeed = 110,
    PauseFromStage = "none", -- "none" = Não parar em nenhum estágio
    StageStopTime = 0.5, -- Tempo de parada (0.1s a 10.0s)
    ReturnToSpawnAfterWin = true,
    SpawnReturnMethod = "Teleport", -- "Teleport" ou "Reset"
    WinsCount = 0,
    
    -- 4. Auto Endless (CO-OP Sem Fim - Padrão inicial no Mundo 10)
    AutoEndless = false,
    EndlessWorld = "world10", -- Sempre padrão no melhor mundo (Mundo 10)
    
    -- 5. Configurações Gerais
    AutoSaveConfig = true,
    AntiAfk = true,
    AutoClaimPlaytime = true,
    AutoClosePopups = true, -- Auto fechar pop-ups de Robux clicando fora
}

getgenv().SuperHeroEvolutionHubConfig = Config

local CONFIG_FILE = "SuperHeroEvolution_Config.json"
local ConfigRestoredAfterHop = false

local function saveConfig()
    pcall(function()
        if Config.AutoSaveConfig == false then return end
        if not (writefile and HttpService) then return end
        local state = {
            FastClick = Config.FastClick,
            ClickDelay = Config.ClickDelay,
            AutoRebirth = Config.AutoRebirth,
            RebirthDelay = Config.RebirthDelay,
            SelectedProgWorld = Config.SelectedProgWorld,
            SelectedProgStage = Config.SelectedProgStage,
            AutoWin = Config.AutoWin,
            WinGlideSpeed = Config.WinGlideSpeed,
            PauseFromStage = Config.PauseFromStage,
            StageStopTime = Config.StageStopTime,
            ReturnToSpawnAfterWin = Config.ReturnToSpawnAfterWin,
            SpawnReturnMethod = Config.SpawnReturnMethod,
            AutoEndless = Config.AutoEndless,
            EndlessWorld = Config.EndlessWorld,
            AutoSaveConfig = Config.AutoSaveConfig,
            AntiAfk = Config.AntiAfk,
            AutoClaimPlaytime = Config.AutoClaimPlaytime,
            AutoClosePopups = Config.AutoClosePopups,
            SavedAt = os.time(),
        }
        writefile(CONFIG_FILE, HttpService:JSONEncode(state))
    end)
end

local function loadConfig()
    local ok = pcall(function()
        local data = nil
        if getgenv().SavedHopConfig and type(getgenv().SavedHopConfig) == "string" and #getgenv().SavedHopConfig > 5 then
            local s, d = pcall(function() return HttpService:JSONDecode(getgenv().SavedHopConfig) end)
            if s and type(d) == "table" then data = d end
        end
        
        if not data and readfile and isfile and isfile(CONFIG_FILE) and HttpService then
            local raw = readfile(CONFIG_FILE)
            if raw and #raw >= 5 then
                local s, d = pcall(function() return HttpService:JSONDecode(raw) end)
                if s and type(d) == "table" then data = d end
            end
        end
        
        if data and type(data) == "table" then
            for k, v in pairs(data) do
                if Config[k] ~= nil and k ~= "WinsCount" and k ~= "ClicksCount" and k ~= "RebirthsCount" then
                    Config[k] = v
                end
            end
            if Config.AutoEndless == true then
                Config.AutoWin = false
            end
            ConfigRestoredAfterHop = true
            return true
        end
    end)
    return ConfigRestoredAfterHop
end

loadConfig()

-- Dados dos Mundos do Jogo
local WorldsData = {
    {Id = "world1", Name = "Mundo 1", WorldNum = 1, MapName = "Map", Min = 1, Max = 15},
    {Id = "world2", Name = "Mundo 2", WorldNum = 2, MapName = "MapTest", Min = 16, Max = 30},
    {Id = "world3", Name = "Mundo 3", WorldNum = 3, MapName = "Map3", Min = 31, Max = 45},
    {Id = "world4", Name = "Mundo 4", WorldNum = 4, MapName = "Map4", Min = 46, Max = 60},
    {Id = "world5", Name = "Mundo 5", WorldNum = 5, MapName = "Map5", Min = 61, Max = 75},
    {Id = "world6", Name = "Mundo 6", WorldNum = 6, MapName = "Map6", Min = 76, Max = 90},
    {Id = "world7", Name = "Mundo 7", WorldNum = 7, MapName = "Map7", Min = 91, Max = 105},
    {Id = "world8", Name = "Mundo 8", WorldNum = 8, MapName = "Map8", Min = 106, Max = 120},
    {Id = "world9", Name = "Mundo 9", WorldNum = 9, MapName = "Map9", Min = 121, Max = 135},
    {Id = "world10", Name = "Mundo 10", WorldNum = 10, MapName = "Map10", Min = 136, Max = 150},
    {Id = "all", Name = "Todos os Mundos", WorldNum = nil, MapName = nil, Min = 1, Max = 150}
}

-- Lista de Mundos para Endless (Melhor Mundo / Mundo 10 primeiro por padrão)
local EndlessWorldsList = {
    {Id = "world10", Name = "Mundo 10 (Melhor Mundo)"},
    {Id = "world9", Name = "Mundo 9"},
    {Id = "world8", Name = "Mundo 8"},
    {Id = "world7", Name = "Mundo 7"},
    {Id = "world6", Name = "Mundo 6"},
    {Id = "world5", Name = "Mundo 5"},
    {Id = "world4", Name = "Mundo 4"},
    {Id = "world3", Name = "Mundo 3"},
    {Id = "world2", Name = "Mundo 2"},
    {Id = "best", Name = "Melhor Disponível (Auto)"}
}

local EndlessArenaCenters = {
    [2] = Vector3.new(764.57, 34.0, -1305.00),
    [3] = Vector3.new(1072.67, 34.0, -2569.20),
    [4] = Vector3.new(2293.47, 34.0, -1305.00),
    [5] = Vector3.new(3238.95, 34.0, -1305.00),
    [6] = Vector3.new(4009.25, 34.0, -1305.00),
    [7] = Vector3.new(4813.55, 34.0, -1305.00),
    [8] = Vector3.new(5663.95, 34.0, -1305.00),
    [9] = Vector3.new(6450.23, 34.0, -1305.00),
    [10] = Vector3.new(7219.63, 34.0, -1305.00),
}

-- Gerenciador de Threads e Conexões
local ActiveThreads = {}
local ActiveConnections = {}

local function spawnThread(func)
    local thread = task.spawn(func)
    table.insert(ActiveThreads, thread)
    return thread
end

-- Teleport Helpers & Server Hop
local function queueScriptOnTeleport()
    pcall(function()
        saveConfig()
        local state = {
            FastClick = Config.FastClick,
            ClickDelay = Config.ClickDelay,
            AutoRebirth = Config.AutoRebirth,
            RebirthDelay = Config.RebirthDelay,
            SelectedProgWorld = Config.SelectedProgWorld,
            SelectedProgStage = Config.SelectedProgStage,
            AutoWin = Config.AutoWin,
            WinGlideSpeed = Config.WinGlideSpeed,
            PauseFromStage = Config.PauseFromStage,
            StageStopTime = Config.StageStopTime,
            ReturnToSpawnAfterWin = Config.ReturnToSpawnAfterWin,
            SpawnReturnMethod = Config.SpawnReturnMethod,
            AutoEndless = Config.AutoEndless,
            EndlessWorld = Config.EndlessWorld,
            AutoSaveConfig = Config.AutoSaveConfig,
            AntiAfk = Config.AntiAfk,
            AutoClaimPlaytime = Config.AutoClaimPlaytime,
            AutoClosePopups = Config.AutoClosePopups,
            SavedAt = os.time(),
        }
        local jsonState = HttpService:JSONEncode(state)
        getgenv().SavedHopConfig = jsonState
        
        local queueTeleport = (syn and syn.queue_on_teleport) 
            or queue_on_teleport 
            or (fluxus and fluxus.queue_on_teleport)
            or (getgenv and getgenv().queue_on_teleport)
            
        if queueTeleport then
            local qCode = string.format([[
                task.spawn(function()
                    getgenv().SavedHopConfig = %q
                    repeat task.wait(0.5) until game:IsLoaded()
                    task.wait(1.5)
                    pcall(function()
                        if readfile and isfile and isfile("script.lua") then
                            loadstring(readfile("script.lua"))()
                        else
                            loadstring(game:HttpGet("https://raw.githubusercontent.com/miguelmarinho1420-hub/superhero-evolution/main/script.lua?t=" .. tostring(os.time())))()
                        end
                    end)
                end)
            ]], jsonState)
            queueTeleport(qCode)
        end
    end)
end
queueScriptOnTeleport()

pcall(function()
    table.insert(ActiveConnections, LocalPlayer.OnTeleport:Connect(function()
        saveConfig()
        queueScriptOnTeleport()
    end))
    table.insert(ActiveConnections, Players.PlayerRemoving:Connect(function(p)
        if p == LocalPlayer then saveConfig() end
    end))
end)

local function serverHop()
    queueScriptOnTeleport()
    local placeId = game.PlaceId
    local serversUrl = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", tostring(placeId))
    
    local success, body = pcall(function()
        if request then return request({Url = serversUrl, Method = "GET"}).Body
        elseif syn and syn.request then return syn.request({Url = serversUrl, Method = "GET"}).Body
        elseif http and http.request then return http.request({Url = serversUrl, Method = "GET"}).Body
        elseif http_request then return http_request({Url = serversUrl, Method = "GET"}).Body end
    end)
    
    if success and body then
        local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
        if ok and data and data.data then
            local validServers = {}
            for _, s in ipairs(data.data) do
                if s.playing and s.maxPlayers and s.playing < s.maxPlayers and s.id ~= game.JobId then
                    table.insert(validServers, s)
                end
            end
            table.sort(validServers, function(a, b) return a.playing < b.playing end)
            if #validServers > 0 then
                TeleportService:TeleportToPlaceInstance(placeId, validServers[1].id, LocalPlayer)
                return
            end
        end
    end
    TeleportService:Teleport(placeId, LocalPlayer)
end

-- ══════════════════════════════════════════════════════════════
-- ANTI-AFK SILENCIOSO
-- ══════════════════════════════════════════════════════════════
table.insert(ActiveConnections, LocalPlayer.Idled:Connect(function()
    if Config.AntiAfk then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
        end)
    end
end))

-- ══════════════════════════════════════════════════════════════
-- AUTO FECHAR POP-UPS DE ROBUX (CLICANDO FORA DO POP-UP)
-- ══════════════════════════════════════════════════════════════
local MarketplaceService = game:GetService("MarketplaceService")

-- 1. Hook preventivo para bloquear chamadas de compras de Robux
pcall(function()
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if Config.AutoClosePopups and (self == MarketplaceService or (typeof(self) == "Instance" and self.ClassName == "MarketplaceService")) then
                if method == "PromptProductPurchase" or method == "PromptPurchase" 
                    or method == "PromptGamePassPurchase" or method == "PromptRobloxPurchase"
                    or method == "PromptBundlePurchase" or method == "PromptPremiumPurchase" then
                    return
                end
            end
            return oldNamecall(self, ...)
        end))
    end
end)

pcall(function()
    if hookfunction and MarketplaceService then
        local oldPPP = MarketplaceService.PromptProductPurchase
        hookfunction(MarketplaceService.PromptProductPurchase, newcclosure(function(self, ...)
            if Config.AutoClosePopups then return end
            return oldPPP(self, ...)
        end))
        local oldPP = MarketplaceService.PromptPurchase
        hookfunction(MarketplaceService.PromptPurchase, newcclosure(function(self, ...)
            if Config.AutoClosePopups then return end
            return oldPP(self, ...)
        end))
        local oldPGP = MarketplaceService.PromptGamePassPurchase
        hookfunction(MarketplaceService.PromptGamePassPurchase, newcclosure(function(self, ...)
            if Config.AutoClosePopups then return end
            return oldPGP(self, ...)
        end))
    end
end)

-- 2. Detecção e fechamento clicando várias vezes FORA do pop-up
local function dismissPopupsByClickingOutside()
    if not Config.AutoClosePopups then return end
    
    pcall(function()
        local vp = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
        -- Pontos seguros nos cantos extremos da tela (backdrop escuro, bem fora de qualquer popup central)
        local outsidePoints = {
            Vector2.new(30, 30),
            Vector2.new(vp.X - 30, 30),
            Vector2.new(30, vp.Y - 30),
            Vector2.new(vp.X - 30, vp.Y - 30),
            Vector2.new(45, 45)
        }
        
        local activePromptFound = false
        
        -- A) Verifica prompts do CoreGui (ex: Compra de Robux / Reanimação Sem Fim)
        for _, name in ipairs({"PurchasePromptApp", "PurchasePrompt", "RobloxGui"}) do
            local container = CoreGui:FindFirstChild(name)
            if container and container.Enabled then
                for _, desc in ipairs(container:GetDescendants()) do
                    if desc:IsA("GuiObject") and desc.Visible and desc.AbsoluteSize.X > 60 and desc.AbsoluteSize.Y > 60 then
                        local dName = desc.Name:lower()
                        if dName:find("prompt") or dName:find("purchase") or dName:find("dialog") or dName:find("modal") or dName:find("alert") then
                            activePromptFound = true
                            break
                        end
                    end
                end
                if activePromptFound then
                    pcall(function() container.Enabled = false end)
                    break
                end
            end
        end
        
        -- B) Verifica popups in-game no PlayerGui (Revive, Ofertas de Robux, Reanimação Sem Fim)
        local pgui = LocalPlayer:FindFirstChild("PlayerGui")
        if pgui then
            local screenGui = pgui:FindFirstChild("ScreenGui")
            if screenGui then
                local revive = screenGui:FindFirstChild("Revive")
                if revive and revive.Visible then
                    activePromptFound = true
                    revive.Visible = false
                    local cancelBtn = revive:FindFirstChild("Cancel", true) or revive:FindFirstChild("Close", true) or revive:FindFirstChild("No", true)
                    if cancelBtn and cancelBtn:IsA("GuiButton") and firesignal then
                        firesignal(cancelBtn.Activated)
                        firesignal(cancelBtn.MouseButton1Click)
                    end
                end
            end
            
            for _, gui in ipairs(pgui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Enabled and not gui.Name:match("^SuperHeroEvolutionHub") then
                    for _, desc in ipairs(gui:GetDescendants()) do
                        if desc:IsA("Frame") and desc.Visible and desc.AbsoluteSize.X > 150 and desc.AbsoluteSize.Y > 150 then
                            local fName = desc.Name:lower()
                            if (fName:find("offer") or fName:find("popup") or fName:find("purchase") or fName:find("revive") or fName:find("special")) 
                                and not (fName:find("playtime") or fName:find("gift")) then
                                activePromptFound = true
                                desc.Visible = false
                                for _, b in ipairs(desc:GetChildren()) do
                                    if b:IsA("GuiButton") and b.Visible then
                                        local bName = b.Name:lower()
                                        if bName:find("close") or bName:find("cancel") or bName:find("x") then
                                            if firesignal then
                                                firesignal(b.Activated)
                                                firesignal(b.MouseButton1Click)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- C) Se um popup de Robux/compra foi detectado, clica algumas vezes FORA do popup no backdrop
        if activePromptFound then
            for i = 1, 3 do
                local pt = outsidePoints[math.random(1, #outsidePoints)]
                if VirtualInputManager then
                    VirtualInputManager:SendMouseButtonEvent(pt.X, pt.Y, 0, true, game, 0)
                    task.wait(0.03)
                    VirtualInputManager:SendMouseButtonEvent(pt.X, pt.Y, 0, false, game, 0)
                elseif VirtualUser then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(pt)
                end
                task.wait(0.04)
            end
            
            -- Envia Escape por segurança em thread separada
            if VirtualInputManager then
                task.spawn(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Escape, false, game)
                    task.wait(0.03)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Escape, false, game)
                end)
            end
        end
    end)
end

-- Daemon de verificação contínua em segundo plano
spawnThread(function()
    while true do
        if Config.AutoClosePopups then
            pcall(dismissPopupsByClickingOutside)
        end
        task.wait(0.15)
    end
end)

-- Gatilhos reativos em segundo plano para fechamento instantâneo
pcall(function()
    table.insert(ActiveConnections, CoreGui.DescendantAdded:Connect(function(desc)
        if Config.AutoClosePopups then
            local pName = (desc.Parent and desc.Parent.Name:lower()) or ""
            if pName:find("purchase") or pName:find("prompt") then
                task.spawn(dismissPopupsByClickingOutside)
            end
        end
    end))
    
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    if pgui then
        table.insert(ActiveConnections, pgui.DescendantAdded:Connect(function(desc)
            if Config.AutoClosePopups and (desc.Name == "Revive" or desc.Name:lower():find("offer")) then
                task.spawn(dismissPopupsByClickingOutside)
            end
        end))
    end
end)

-- ══════════════════════════════════════════════════════════════
-- AUTO RESGATE DE RECOMPENSAS DE TEMPO DE JOGO
-- ══════════════════════════════════════════════════════════════
local function claimPlaytimeRewards()
    if not Config.AutoClaimPlaytime then return end
    
    pcall(function()
        -- 1. Varre e ativa os 12 botões de Recompensa de Tempo na UI (PlayerGui)
        local pgui = LocalPlayer:FindFirstChild("PlayerGui")
        if pgui then
            for _, gui in ipairs(pgui:GetChildren()) do
                if gui:IsA("ScreenGui") and not gui.Name:match("^SuperHeroEvolutionHub") then
                    for _, desc in ipairs(gui:GetDescendants()) do
                        if desc:IsA("GuiButton") then
                            local text = (desc:IsA("TextButton") and desc.Text:lower()) or ""
                            if text == "" then
                                for _, c in ipairs(desc:GetChildren()) do
                                    if c:IsA("TextLabel") and c.Visible then
                                        text = c.Text:lower()
                                        break
                                    end
                                end
                            end
                            
                            local isClaimed = text:find("reivindicado") or text:find("claimed") or text:find("resgatado")
                            local isClaimable = (text:find("reivindica") or text:find("claim") or text:find("resgatar") or text:find("coletar") or text:find("pegar")) and not isClaimed
                            
                            if isClaimable and firesignal then
                                firesignal(desc.Activated)
                                firesignal(desc.MouseButton1Click)
                            end
                        end
                    end
                end
            end
        end
        
        -- 2. Dispara remotes de Playtime/Gift do jogo (1 a 12)
        local candidateFolders = {}
        if Remotes then table.insert(candidateFolders, Remotes) end
        local sharedObj = ReplicatedStorage:FindFirstChild("Shared")
        if sharedObj then
            local sRems = sharedObj:FindFirstChild("Remotes") or sharedObj:FindFirstChild("Events")
            if sRems and sRems ~= Remotes then table.insert(candidateFolders, sRems) end
        end
        
        for _, f in ipairs(candidateFolders) do
            for _, rem in ipairs(f:GetChildren()) do
                local rName = rem.Name:lower()
                if rName:find("gift") or rName:find("playtime") or rName:find("timereward") or (rName:find("claim") and (rName:find("reward") or rName:find("time") or rName:find("gift"))) then
                    if rem:IsA("RemoteEvent") then
                        for i = 1, 12 do
                            pcall(function() rem:FireServer(i) end)
                            pcall(function() rem:FireServer(tostring(i)) end)
                        end
                        pcall(function() rem:FireServer() end)
                    elseif rem:IsA("RemoteFunction") then
                        for i = 1, 12 do
                            pcall(function() rem:InvokeServer(i) end)
                            pcall(function() rem:InvokeServer(tostring(i)) end)
                        end
                        pcall(function() rem:InvokeServer() end)
                    end
                end
            end
        end
    end)
end

spawnThread(function()
    while true do
        if Config.AutoClaimPlaytime then
            claimPlaytimeRewards()
        end
        task.wait(3.0)
    end
end)

-- ══════════════════════════════════════════════════════════════
-- DETECÇÃO DE MAPA, CHÃO E ESTÁGIOS
-- ══════════════════════════════════════════════════════════════
local cachedCurrentMap = nil
local lastMapCheck = 0

local function getCurrentMap()
    local now = os.clock()
    if cachedCurrentMap and (now - lastMapCheck < 1.0) then
        return cachedCurrentMap
    end
    lastMapCheck = now
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        cachedCurrentMap = workspace:FindFirstChild("Map")
        return cachedCurrentMap
    end
    
    local myPos = hrp.Position
    local bestMap = nil
    local minDist = math.huge
    for _, child in ipairs(workspace:GetChildren()) do
        if child.Name:match("^Map") then
            local bp = child:FindFirstChildWhichIsA("BasePart", true)
            if bp then
                local dist = (bp.Position - myPos).Magnitude
                if dist < minDist then
                    minDist = dist
                    bestMap = child
                end
            end
        end
    end
    cachedCurrentMap = bestMap or workspace:FindFirstChild("Map")
    return cachedCurrentMap
end

local function isGroundPart(hitPart)
    if not hitPart or not hitPart:IsA("BasePart") then return false end
    if not hitPart.CanCollide and hitPart.Transparency >= 0.95 then return false end
    local p = hitPart.Parent
    if p and (p:FindFirstChildOfClass("Humanoid") or (p.Parent and p.Parent:FindFirstChildOfClass("Humanoid"))) then
        return false
    end
    return true
end

local function getHumanoidFloorOffset(char)
    char = char or LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hip = (hum and hum.HipHeight and hum.HipHeight > 0) and hum.HipHeight or 2.1
    local halfHrp = (hrp and hrp.Size.Y > 0) and (hrp.Size.Y * 0.5) or 1.0
    return hip + halfHrp + 0.15
end

local function getFloorHeightAt(x, z, referenceY, char)
    char = char or LocalPlayer.Character
    local refY = referenceY
    if not refY then
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        refY = hrp and hrp.Position.Y or 20
    end
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local filterList = {}
    if char then table.insert(filterList, char) end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then table.insert(filterList, plr.Character) end
    end
    params.FilterDescendantsInstances = filterList
    params.IgnoreWater = true
    
    local origin = Vector3.new(x, refY + 15, z)
    local hit = workspace:Raycast(origin, Vector3.new(0, -50, 0), params)
    if hit and hit.Instance and isGroundPart(hit.Instance) then
        return hit.Position.Y
    end
    
    local highOrigin = Vector3.new(x, refY + 45, z)
    local highHit = workspace:Raycast(highOrigin, Vector3.new(0, -100, 0), params)
    if highHit and highHit.Instance and isGroundPart(highHit.Instance) then
        return highHit.Position.Y
    end
    
    return nil
end

local function getStageFreePad(stageInstance)
    if not stageInstance then return nil end
    local padFolder = stageInstance:FindFirstChild("Pad")
    if not padFolder then return nil end
    
    local free = padFolder:FindFirstChild("Free")
    if free then
        if free:IsA("BasePart") then return free end
        local p = free:FindFirstChild("Pad", true) or free.PrimaryPart or free:FindFirstChildWhichIsA("BasePart", true)
        if p then return p end
    end
    
    local direct = padFolder:FindFirstChild("Pad", true)
    if direct and direct:IsA("BasePart") then return direct end
    
    for _, child in ipairs(padFolder:GetChildren()) do
        if child.Name:lower():find("free") then
            if child:IsA("BasePart") then return child end
            local p = child:FindFirstChildWhichIsA("BasePart", true)
            if p then return p end
        end
    end
    
    return padFolder:FindFirstChildWhichIsA("BasePart", true)
end

local function getStageCombatPosition(stageInstance)
    if not stageInstance then return nil end
    local char = LocalPlayer.Character
    local offset = getHumanoidFloorOffset(char)
    
    local enemySpawns = stageInstance:FindFirstChild("EnemySpawns")
    if enemySpawns then
        local totalPos = Vector3.zero
        local count = 0
        for _, p in ipairs(enemySpawns:GetChildren()) do
            if p:IsA("BasePart") then
                totalPos = totalPos + p.Position
                count = count + 1
            elseif p:IsA("Model") then
                totalPos = totalPos + p:GetPivot().Position
                count = count + 1
            end
        end
        if count > 0 then
            local avg = totalPos / count
            local gY = getFloorHeightAt(avg.X, avg.Z, avg.Y, char)
            local finalY = (gY and (gY + offset)) or avg.Y
            return Vector3.new(avg.X, finalY, avg.Z)
        end
    end
    
    local spawnObj = stageInstance:FindFirstChild("Spawn")
    local spawnPos = spawnObj and (spawnObj:IsA("BasePart") and spawnObj.Position or (spawnObj:IsA("Model") and spawnObj:GetPivot().Position))
    local gateObj = stageInstance:FindFirstChild("Gate") or stageInstance:FindFirstChild("Barrier")
    local gatePos = gateObj and (gateObj:IsA("BasePart") and gateObj.Position or (gateObj:IsA("Model") and gateObj:GetPivot().Position))
    local pad = getStageFreePad(stageInstance)
    local padPos = pad and pad.Position
    
    local endPoint = gatePos or padPos
    if spawnPos and endPoint then
        local mid = (spawnPos + endPoint) * 0.5
        local gY = getFloorHeightAt(mid.X, mid.Z, mid.Y, char)
        local finalY = (gY and (gY + offset)) or mid.Y
        return Vector3.new(mid.X, finalY, mid.Z)
    end
    
    if padPos then
        local pt = padPos - Vector3.new(0, 0, 30)
        local gY = getFloorHeightAt(pt.X, pt.Z, pt.Y, char)
        local finalY = (gY and (gY + offset)) or pt.Y
        return Vector3.new(pt.X, finalY, pt.Z)
    end
    
    local raw = stageInstance:IsA("Model") and stageInstance:GetPivot().Position or nil
    if raw then
        local gY = getFloorHeightAt(raw.X, raw.Z, raw.Y, char)
        local finalY = (gY and (gY + offset)) or raw.Y
        return Vector3.new(raw.X, finalY, raw.Z)
    end
    return nil
end

local function getStageGatePosition(stageInstance)
    if not stageInstance then return nil end
    local char = LocalPlayer.Character
    local offset = getHumanoidFloorOffset(char)
    local gate = stageInstance:FindFirstChild("Gate") or stageInstance:FindFirstChild("Barrier")
    if gate then
        local pos = gate:IsA("BasePart") and gate.Position or (gate:IsA("Model") and gate:GetPivot().Position)
        if pos then
            local gY = getFloorHeightAt(pos.X, pos.Z, pos.Y, char)
            local finalY = (gY and (gY + offset)) or pos.Y
            return Vector3.new(pos.X, finalY, pos.Z)
        end
    end
    local pad = getStageFreePad(stageInstance)
    if pad then
        local pos = pad.Position
        local gY = getFloorHeightAt(pos.X, pos.Z, pos.Y, char)
        local finalY = (gY and (gY + offset)) or pos.Y
        return Vector3.new(pos.X, finalY, pos.Z)
    end
    return nil
end

local function getStagesOptionsForWorld(worldId)
    local list = {}
    local wInfo = nil
    for _, w in ipairs(WorldsData) do
        if w.Id == worldId then wInfo = w; break end
    end
    if wInfo and wInfo.Min and wInfo.Max then
        for i = wInfo.Min, wInfo.Max do
            table.insert(list, {Id = "Stage" .. i, Name = "Estágio " .. i})
        end
        return list
    end
    if worldId == "all" then
        for i = 1, 150 do table.insert(list, {Id = "Stage" .. i, Name = "Estágio " .. i}) end
        return list
    end
    for i = 1, 15 do table.insert(list, {Id = "Stage" .. i, Name = "Estágio " .. i}) end
    return list
end

local function getPauseStageOptionsForWorld(worldId)
    local list = {
        {Id = "none", Name = "Não parar em nenhum estágio"}
    }
    local stages = getStagesOptionsForWorld(worldId)
    for _, opt in ipairs(stages) do
        table.insert(list, opt)
    end
    return list
end

-- Detecção de sacos de pancada de treino
local cachedHitboxList = {}
local lastHitboxMapCheck = 0

local function getTrainingHitboxList()
    local now = os.clock()
    if #cachedHitboxList > 0 and (now - lastHitboxMapCheck < 3.0) then
        return cachedHitboxList
    end
    lastHitboxMapCheck = now
    cachedHitboxList = {}
    
    local curMap = getCurrentMap()
    local containers = {}
    if curMap then
        local tz = curMap:FindFirstChild("TrainingZone") or curMap:FindFirstChild("TrainingZones") or curMap:FindFirstChild("Zones")
        if tz then table.insert(containers, tz) end
        table.insert(containers, curMap)
    end
    
    for _, container in ipairs(containers) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("Model") then
                    local hb = child:FindFirstChild("Hitbox") or child:FindFirstChild("PunchingBag")
                    if hb and hb:IsA("BasePart") then
                        table.insert(cachedHitboxList, hb)
                    end
                elseif child:IsA("BasePart") and (child.Name == "Hitbox" or child.Name == "PunchingBag") then
                    table.insert(cachedHitboxList, child)
                end
            end
            if #cachedHitboxList > 0 then break end
        end
    end
    return cachedHitboxList
end

-- Estatísticas em Tempo Real
local SessionRebirths = 0
local initialLeaderRebirths = nil
local totalWinsCollectedCount = 0
local lastWinCollectedTick = 0

local ClickStatsCard = nil
local RebirthStatsCard = nil
local WinStatsCard = nil
local EndlessStatsCard = nil
local HeaderStats = nil
local MiniStats = nil

local ClickToggle = nil
local RebirthToggle = nil
local WinToggle = nil
local EndlessToggle = nil
local AntiAfkToggle = nil
local AutoClosePopupsToggle = nil
local PlaytimeToggle = nil

pcall(function()
    local ls = LocalPlayer:WaitForChild("leaderstats", 5)
    local r = ls and ls:WaitForChild("Rebirths", 5)
    if r then
        initialLeaderRebirths = tonumber(r.Value) or 0
        local rConn = r.Changed:Connect(function(current)
            if initialLeaderRebirths ~= nil then
                local diff = current - initialLeaderRebirths
                if diff >= 0 then
                    SessionRebirths = diff
                    Config.RebirthsCount = SessionRebirths
                    if RebirthStatsCard and RebirthStatsCard.Update then
                        RebirthStatsCard.Update(string.format("Sessão: %d | Total: %d", SessionRebirths, current), Color3.fromRGB(56, 122, 255))
                    end
                end
            end
        end)
        table.insert(ActiveConnections, rConn)
    end
end)

if RemotePlayVFX then
    local winVfxConn = RemotePlayVFX.OnClientEvent:Connect(function(vfxName, _, targetPlr)
        if vfxName == "WinPadTouch" and targetPlr == LocalPlayer then
            lastWinCollectedTick = os.clock()
            totalWinsCollectedCount = totalWinsCollectedCount + 1
            Config.WinsCount = totalWinsCollectedCount
            if WinStatsCard and WinStatsCard.Update then
                WinStatsCard.Update("Vitórias: " .. totalWinsCollectedCount, Color3.fromRGB(46, 204, 113))
            end
        end
    end)
    table.insert(ActiveConnections, winVfxConn)
end

pcall(function()
    local ls = LocalPlayer:WaitForChild("leaderstats", 5)
    local winsStat = ls and ls:WaitForChild("Wins", 5)
    if winsStat then
        local wConn = winsStat.Changed:Connect(function()
            lastWinCollectedTick = os.clock()
            totalWinsCollectedCount = totalWinsCollectedCount + 1
            Config.WinsCount = totalWinsCollectedCount
            if WinStatsCard and WinStatsCard.Update then
                WinStatsCard.Update("Vitórias: " .. totalWinsCollectedCount, Color3.fromRGB(46, 204, 113))
            end
        end)
        table.insert(ActiveConnections, wConn)
    end
end)

-- ══════════════════════════════════════════════════════════════
-- 1. MOTOR DO AUTO CLICK (100% EM SEGUNDO PLANO - ZERO CHAT INTERRUPT)
-- ══════════════════════════════════════════════════════════════
local currentTargetBag = nil
local currentTargetEnemy = nil

-- Thread 1: Rastreador de alvos desacoplado (roda a cada 0.6s)
spawnThread(function()
    while true do
        if Config.FastClick then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then
                    currentTargetBag = nil
                    currentTargetEnemy = nil
                    return
                end
                
                local pPos = hrp.Position
                local bestBag = nil
                local hitboxes = getTrainingHitboxList()
                for _, hb in ipairs(hitboxes) do
                    if hb and hb.Parent and (hb.Position - pPos).Magnitude < 35 then
                        bestBag = hb
                        break
                    end
                end
                currentTargetBag = bestBag
                
                if not bestBag then
                    local bestEnemy = nil
                    local bestDist = 45
                    local curMap = getCurrentMap()
                    local searchFolders = {}
                    if curMap then
                        local st = curMap:FindFirstChild("Stages")
                        if st then table.insert(searchFolders, st) end
                        local en = curMap:FindFirstChild("Enemies") or curMap:FindFirstChild("Mobs")
                        if en then table.insert(searchFolders, en) end
                    end
                    for _, fName in ipairs({"Enemies", "enemynew"}) do
                        local f = workspace:FindFirstChild(fName)
                        if f then table.insert(searchFolders, f) end
                    end
                    
                    for _, folder in ipairs(searchFolders) do
                        for _, child in ipairs(folder:GetChildren()) do
                            if child:IsA("Model") and not Players:GetPlayerFromCharacter(child) then
                                local hum = child:FindFirstChildOfClass("Humanoid")
                                local root = child:FindFirstChild("HumanoidRootPart") or child.PrimaryPart
                                if hum and hum.Health > 0 and root then
                                    local d = (root.Position - pPos).Magnitude
                                    if d < bestDist then
                                        bestDist = d
                                        bestEnemy = child
                                    end
                                end
                            end
                        end
                        if bestEnemy then break end
                    end
                    currentTargetEnemy = bestEnemy
                else
                    currentTargetEnemy = nil
                end
            end)
        else
            currentTargetBag = nil
            currentTargetEnemy = nil
        end
        task.wait(0.6)
    end
end)

-- Thread 2: Disparo de cliques puramente via Remotes (SEM clicar na tela, chat 100% livre)
spawnThread(function()
    local lastTouchInterest = 0
    local lastStatsUpdate = 0
    
    while true do
        if Config.FastClick then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if char and hum and hum.Health > 0 and hrp then
                local now = os.clock()
                
                -- Se houver saco de treino próximo, ativa hitbox e treino
                if currentTargetBag and currentTargetBag.Parent then
                    if now - lastTouchInterest >= 1.5 then
                        lastTouchInterest = now
                        if firetouchinterest then
                            firetouchinterest(hrp, currentTargetBag, 0)
                            firetouchinterest(hrp, currentTargetBag, 1)
                        end
                    end
                    if RemoteRequestTrain then RemoteRequestTrain:FireServer() end
                elseif currentTargetEnemy and currentTargetEnemy.Parent then
                    local eRoot = currentTargetEnemy:FindFirstChild("HumanoidRootPart") or currentTargetEnemy.PrimaryPart
                    if eRoot and hum.MoveDirection.Magnitude <= 0.05 then
                        hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(eRoot.Position.X, hrp.Position.Y, eRoot.Position.Z))
                    end
                end
                
                -- Dispara Remotes nativos em segundo plano (não rouba foco do mouse/teclado nem atrapalha o chat)
                if RemoteRequestAttack then RemoteRequestAttack:FireServer() end
                if RemotePlayerClick then RemotePlayerClick:FireServer() end
                
                Config.ClicksCount = Config.ClicksCount + 1
                
                if now - lastStatsUpdate >= 0.35 then
                    lastStatsUpdate = now
                    if ClickStatsCard and ClickStatsCard.Update then
                        ClickStatsCard.Update("Clicks: " .. Config.ClicksCount, Color3.fromRGB(56, 122, 255))
                    end
                end
            end
        end
        
        -- Intervalo configurável pelo usuário: de 0.1s até 10.0s
        local delayVal = math.clamp(Config.ClickDelay or 0.1, 0.1, 10.0)
        task.wait(delayVal)
    end
end)

-- ══════════════════════════════════════════════════════════════
-- 2. MOTOR DO AUTO REBIRTH (AUTOMÁTICO EM SEGUNDO PLANO)
-- ══════════════════════════════════════════════════════════════
spawnThread(function()
    while true do
        if Config.AutoRebirth then
            pcall(function()
                if RemoteRequestRebirth then
                    local s, res = pcall(function() return RemoteRequestRebirth:InvokeServer() end)
                    if s and res == true then
                        if initialLeaderRebirths == nil then
                            SessionRebirths = SessionRebirths + 1
                            Config.RebirthsCount = SessionRebirths
                        end
                        if RebirthStatsCard and RebirthStatsCard.Update then
                            local total = 0
                            pcall(function()
                                local ls = LocalPlayer:FindFirstChild("leaderstats")
                                local r = ls and ls:FindFirstChild("Rebirths")
                                if r then total = tonumber(r.Value) or 0 end
                            end)
                            RebirthStatsCard.Update(string.format("Sessão: %d | Total: %d", SessionRebirths, total), Color3.fromRGB(56, 122, 255))
                        end
                    end
                end
            end)
        end
        task.wait(Config.RebirthDelay or 1.0)
    end
end)

-- ══════════════════════════════════════════════════════════════
-- 3. MOTOR DO AUTO WIN (DESLIZE, COMBATE E PARADA NO PAD ALVO)
-- ══════════════════════════════════════════════════════════════
local StabilizedPads = {}

local function stabilizePadPart(part)
    if not part or not part:IsA("BasePart") or StabilizedPads[part] then return end
    StabilizedPads[part] = true
    
    local origCF = part.CFrame
    local origTrans = part.Transparency
    
    pcall(function()
        part.Anchored = true
        part.CanCollide = false
        part.AssemblyLinearVelocity = Vector3.zero
        part.AssemblyAngularVelocity = Vector3.zero
    end)
    
    local cConn = part:GetPropertyChangedSignal("CFrame"):Connect(function()
        if part and part.Parent then
            if (part.CFrame.Position - origCF.Position).Magnitude > 0.01 then
                pcall(function()
                    part.CFrame = origCF
                    part.AssemblyLinearVelocity = Vector3.zero
                    part.AssemblyAngularVelocity = Vector3.zero
                end)
            end
        end
    end)
    table.insert(ActiveConnections, cConn)
    
    local tConn = part:GetPropertyChangedSignal("Transparency"):Connect(function()
        if part and part.Parent and part.Transparency > origTrans then
            pcall(function() part.Transparency = origTrans end)
        end
    end)
    table.insert(ActiveConnections, tConn)
end

local function stabilizePad(pad)
    if not pad then return end
    if pad:IsA("BasePart") then stabilizePadPart(pad) end
    local parent = pad.Parent
    if parent and (parent:IsA("Model") or parent:IsA("Folder")) then
        for _, desc in ipairs(parent:GetDescendants()) do
            if desc:IsA("BasePart") then stabilizePadPart(desc) end
        end
    end
end

-- Deslize contínuo suave na altura do chão com no-clip
local function glideToCFrame(targetCFrame, speed, attackWhileMoving, exactTargetY)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end
    
    local activeSpeed = Config.WinGlideSpeed or speed or 110
    if hum then hum.WalkSpeed = activeSpeed end
    
    local targetPos = targetCFrame.Position
    local startPos = hrp.Position
    local offset = getHumanoidFloorOffset(char)
    
    if not exactTargetY then
        local targetFloorY = getFloorHeightAt(targetPos.X, targetPos.Z, targetPos.Y, char)
        if targetFloorY then
            targetPos = Vector3.new(targetPos.X, targetFloorY + offset, targetPos.Z)
        end
    end
    
    local horizDistInit = (Vector3.new(targetPos.X - startPos.X, 0, targetPos.Z - startPos.Z)).Magnitude
    if horizDistInit < 0.3 then
        local finalY = exactTargetY and targetPos.Y or ((getFloorHeightAt(targetPos.X, targetPos.Z, hrp.Position.Y, char) and (getFloorHeightAt(targetPos.X, targetPos.Z, hrp.Position.Y, char) + offset)) or targetPos.Y)
        local flatDir = Vector3.new(targetCFrame.LookVector.X, 0, targetCFrame.LookVector.Z)
        if flatDir.Magnitude > 0.01 then
            hrp.CFrame = CFrame.lookAt(Vector3.new(targetPos.X, finalY, targetPos.Z), Vector3.new(targetPos.X, finalY, targetPos.Z) + flatDir)
        else
            hrp.CFrame = CFrame.new(targetPos.X, finalY, targetPos.Z)
        end
        return true
    end
    
    local ncConn = RunService.Stepped:Connect(function()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end)
    
    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    end)
    
    local lastAttackTick = 0
    local reached = false
    local t0 = os.clock()
    local maxDuration = math.max((horizDistInit / math.max(activeSpeed, 20)) + 3.0, 1.2)
    
    while Config.AutoWin and not Config.AutoEndless do
        local dt = RunService.Heartbeat:Wait()
        char = LocalPlayer.Character
        hum = char and char:FindFirstChildOfClass("Humanoid")
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not hum or hum.Health <= 0 then break end
        
        activeSpeed = Config.WinGlideSpeed or speed or 110
        if hum then hum.WalkSpeed = activeSpeed end
        
        local currentPos = hrp.Position
        local horizDiff = Vector3.new(targetPos.X - currentPos.X, 0, targetPos.Z - currentPos.Z)
        local horizDist = horizDiff.Magnitude
        local step = activeSpeed * dt
        
        if attackWhileMoving and (os.clock() - lastAttackTick >= 0.05) then
            lastAttackTick = os.clock()
            if RemoteRequestAttack then RemoteRequestAttack:FireServer() end
            if RemotePlayerClick then RemotePlayerClick:FireServer() end
        end
        
        if horizDist <= math.max(step * 0.95, 0.4) or (os.clock() - t0 >= maxDuration) then
            local finalY = exactTargetY and targetPos.Y or ((getFloorHeightAt(targetPos.X, targetPos.Z, currentPos.Y, char) and (getFloorHeightAt(targetPos.X, targetPos.Z, currentPos.Y, char) + offset)) or currentPos.Y)
            local flatDir = Vector3.new(horizDiff.X, 0, horizDiff.Z)
            if flatDir.Magnitude > 0.01 then
                hrp.CFrame = CFrame.lookAt(Vector3.new(targetPos.X, finalY, targetPos.Z), Vector3.new(targetPos.X, finalY, targetPos.Z) + flatDir)
            else
                hrp.CFrame = CFrame.new(targetPos.X, finalY, targetPos.Z) * (targetCFrame - targetCFrame.Position)
            end
            reached = true
            break
        else
            local moveDir = horizDiff.Unit
            local moveDist = math.min(step, horizDist)
            local nextHoriz = currentPos + (moveDir * moveDist)
            
            local targetY
            if exactTargetY then
                local progress = 1.0 - math.clamp(horizDist / math.max(horizDistInit, 1), 0, 1)
                local floorY = getFloorHeightAt(nextHoriz.X, nextHoriz.Z, currentPos.Y, char)
                local baseGroundY = (floorY and (floorY + offset)) or currentPos.Y
                targetY = baseGroundY + (targetPos.Y - baseGroundY) * math.clamp(progress * 1.5, 0, 1)
            else
                local floorY = getFloorHeightAt(nextHoriz.X, nextHoriz.Z, currentPos.Y, char)
                targetY = (floorY and (floorY + offset)) or currentPos.Y
            end
            
            local nextY = currentPos.Y + (targetY - currentPos.Y) * math.clamp(dt * 20, 0.18, 1.0)
            local nextPos = Vector3.new(nextHoriz.X, nextY, nextHoriz.Z)
            
            local flatDir = Vector3.new(moveDir.X, 0, moveDir.Z)
            if flatDir.Magnitude > 0.01 then
                local targetRot = CFrame.lookAt(nextPos, nextPos + flatDir)
                hrp.CFrame = hrp.CFrame:Lerp(targetRot, math.clamp(dt * 15, 0.1, 1.0))
            else
                hrp.CFrame = CFrame.new(nextPos) * (targetCFrame - targetCFrame.Position)
            end
        end
    end
    
    pcall(function() ncConn:Disconnect() end)
    if hrp and hum and hum.Health > 0 then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hum.WalkSpeed = 50
        return reached
    end
    return false
end

local function waitForCharacterAlive(timeout)
    timeout = timeout or 10
    local t0 = os.clock()
    while os.clock() - t0 < timeout do
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if char and hum and hum.Health > 0 and hrp and hrp.Parent == char then
            return char, hrp, hum
        end
        task.wait(0.15)
    end
    local char = LocalPlayer.Character
    return char, char and char:FindFirstChild("HumanoidRootPart"), char and char:FindFirstChildOfClass("Humanoid")
end

local function resetCharacterAndRecover()
    local oldChar = LocalPlayer.Character
    local oldHum = oldChar and oldChar:FindFirstChildOfClass("Humanoid")
    pcall(function()
        if oldHum and oldHum.Health > 0 then
            oldHum.Health = 0
            oldHum:ChangeState(Enum.HumanoidStateType.Dead)
        end
        if oldChar then oldChar:BreakJoints() end
    end)
    local t0 = os.clock()
    while os.clock() - t0 < 10 do
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if c and h and h.Health > 0 and r and (c ~= oldChar or os.clock() - t0 > 3.0) then break end
        task.wait(0.15)
    end
    task.wait(0.5)
end

local function getMapSpawnCFrame(curMap, stagesList)
    curMap = curMap or getCurrentMap()
    if not curMap then return nil end
    
    local sp = curMap:FindFirstChildWhichIsA("SpawnLocation", true)
    if sp then return sp.CFrame + Vector3.new(0, 3.5, 0) end
    
    for _, name in ipairs({"SpawnLocation", "PlayerSpawn", "SpawnPoint", "LobbySpawn", "Spawn"}) do
        local found = curMap:FindFirstChild(name, true)
        if found then
            local pName = found.Parent and found.Parent.Name or ""
            if not pName:match("^Stage[2-9]") and not pName:match("^Stage%d%d") then
                if found:IsA("BasePart") then
                    return found.CFrame + Vector3.new(0, 3.5, 0)
                elseif found:IsA("Model") then
                    return found:GetPivot() + Vector3.new(0, 3.5, 0)
                end
            end
        end
    end
    
    local stage1 = (stagesList and stagesList[1] and stagesList[1].Stage)
    if stage1 then
        local stgSpawn = stage1:FindFirstChild("Spawn") or stage1:FindFirstChild("SpawnLocation")
        if stgSpawn then
            local p = stgSpawn:IsA("BasePart") and stgSpawn.Position or (stgSpawn:IsA("Model") and stgSpawn:GetPivot().Position)
            if p then return CFrame.new(p + Vector3.new(0, 3.5, 0)) end
        end
    end
    return nil
end

local function returnToSpawn(curMap, worldNum, stagesList)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then
        waitForCharacterAlive()
        return
    end
    
    local method = Config.SpawnReturnMethod or "Teleport"
    if method == "Reset" then
        resetCharacterAndRecover()
        return
    end
    
    local spawnCF = getMapSpawnCFrame(curMap, stagesList)
    if worldNum and RemoteRequestWorldChange then
        pcall(function() RemoteRequestWorldChange:InvokeServer(worldNum) end)
    end
    
    if spawnCF then
        char = LocalPlayer.Character
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = spawnCF
            task.wait(0.08)
            hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = spawnCF
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end
    
    task.wait(0.2)
    char = LocalPlayer.Character
    hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and spawnCF then
        local distToSpawn = (hrp.Position - spawnCF.Position).Magnitude
        if distToSpawn > 150 then resetCharacterAndRecover() end
    elseif not spawnCF then
        resetCharacterAndRecover()
    end
end

local function getStageReferencePosition(stageInst)
    if not stageInst then return nil end
    local gate = stageInst:FindFirstChild("Gate") or stageInst:FindFirstChild("Barrier") or stageInst:FindFirstChild("Exit")
    if gate then
        return gate:IsA("BasePart") and gate.Position or (gate:IsA("Model") and gate:GetPivot().Position)
    end
    local pad = getStageFreePad(stageInst)
    if pad then return pad.Position end
    local sp = stageInst:FindFirstChild("Spawn")
    if sp then
        return sp:IsA("BasePart") and sp.Position or (sp:IsA("Model") and sp:GetPivot().Position)
    end
    if stageInst:IsA("Model") then return stageInst:GetPivot().Position end
    local bp = stageInst:FindFirstChildWhichIsA("BasePart", true)
    return bp and bp.Position
end

local function getTrackForwardDirection(stagesList)
    if not stagesList or #stagesList < 2 then
        return Vector3.new(0, 0, -1)
    end
    local firstPos = getStageReferencePosition(stagesList[1].Stage)
    local lastPos = getStageReferencePosition(stagesList[#stagesList].Stage)
    if firstPos and lastPos then
        local flat = Vector3.new(lastPos.X - firstPos.X, 0, lastPos.Z - firstPos.Z)
        if flat.Magnitude > 5 then
            return flat.Unit
        end
    end
    for i = 1, #stagesList - 1 do
        local pA = getStageReferencePosition(stagesList[i].Stage)
        local pB = getStageReferencePosition(stagesList[i + 1].Stage)
        if pA and pB then
            local flat = Vector3.new(pB.X - pA.X, 0, pB.Z - pA.Z)
            if flat.Magnitude > 2 then
                return flat.Unit
            end
        end
    end
    return Vector3.new(0, 0, -1)
end

-- Farm individual de cada estágio (Apenas movimento para frente)
local function farmStage(stage, stageNum, isFinalTargetStage, stagesList, trackDir)
    if not stage or not Config.AutoWin or Config.AutoEndless then return false, "cancelled" end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false, "dead" end
    
    trackDir = trackDir or Vector3.new(0, 0, -1)
    
    -- Pausa configurável: se 'none', não para em nenhum estágio; se for um estágio, para a partir dele
    local shouldPauseAtThisStage = false
    if Config.PauseFromStage and Config.PauseFromStage ~= "none" then
        local pauseNum = tonumber(string.match(tostring(Config.PauseFromStage), "%d+"))
        if pauseNum and stageNum >= pauseNum then
            shouldPauseAtThisStage = true
        end
    end
    local waitDuration = shouldPauseAtThisStage and math.clamp(Config.StageStopTime or 0.5, 0.1, 10.0) or 0.0
    
    -- 1. Se DEVE pausar para lutar neste estágio
    if waitDuration > 0 then
        local combatPos = getStageCombatPosition(stage)
        if combatPos then
            char = LocalPlayer.Character
            hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local toCombat = Vector3.new(combatPos.X - hrp.Position.X, 0, combatPos.Z - hrp.Position.Z)
                -- Só anda até a área de combate se ela estiver À FRENTE (nunca volta para trás!)
                if toCombat:Dot(trackDir) > 0.5 and toCombat.Magnitude > 1.2 then
                    local okGlide = glideToCFrame(CFrame.new(combatPos), nil, true)
                    if not okGlide then return false, "dead" end
                end
            end
        end
        
        if not Config.AutoWin or Config.AutoEndless then return false, "cancelled" end
        
        -- Luta no estágio durante o tempo configurado
        local fightStart = os.clock()
        while Config.AutoWin and not Config.AutoEndless and (os.clock() - fightStart < waitDuration) do
            char = LocalPlayer.Character
            hrp = char and char:FindFirstChild("HumanoidRootPart")
            hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then return false, "dead" end
            
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            
            if RemoteRequestAttack then RemoteRequestAttack:FireServer() end
            if RemotePlayerClick then RemotePlayerClick:FireServer() end
            task.wait(0.04)
        end
    end
    
    if not Config.AutoWin or Config.AutoEndless then return false, "cancelled" end
    
    -- 2. Movimento para frente
    if isFinalTargetStage then
        -- Apenas no estágio final selecionado (ex: 145) ele vai para o Pad!
        local targetPad = getStageFreePad(stage)
        if targetPad then
            stabilizePad(targetPad)
            local padOffset = getHumanoidFloorOffset(char)
            local padTopY = targetPad.Position.Y + (targetPad.Size.Y * 0.5)
            local padTargetCF = CFrame.new(targetPad.Position.X, padTopY + padOffset, targetPad.Position.Z)
            
            local okPad = glideToCFrame(padTargetCF, nil, true, true)
            if not okPad then return false, "dead" end
            
            if firetouchinterest then
                firetouchinterest(hrp, targetPad, 0)
                task.wait(0.02)
                firetouchinterest(hrp, targetPad, 1)
            end
            
            local initialWinCount = totalWinsCollectedCount
            local padTouchStart = os.clock()
            while Config.AutoWin and not Config.AutoEndless and (os.clock() - padTouchStart < 1.0) do
                char = LocalPlayer.Character
                hrp = char and char:FindFirstChild("HumanoidRootPart")
                hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum or hum.Health <= 0 then return false, "dead" end
                
                hrp.CFrame = padTargetCF
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                
                if firetouchinterest then
                    firetouchinterest(hrp, targetPad, 0)
                    task.wait(0.02)
                    firetouchinterest(hrp, targetPad, 1)
                end
                
                if totalWinsCollectedCount > initialWinCount then break end
                task.wait(0.05)
            end
            task.wait(0.15)
        end
    else
        -- Estágio intermediário: desliza SEMPRE PARA FRENTE até a saída/gate
        local gatePos = getStageGatePosition(stage)
        if gatePos then
            char = LocalPlayer.Character
            hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local toGate = Vector3.new(gatePos.X - hrp.Position.X, 0, gatePos.Z - hrp.Position.Z)
                -- Só desliza se o gate estiver À FRENTE no percurso (nunca anda para trás)
                if toGate:Dot(trackDir) > 0.5 and toGate.Magnitude > 1.2 then
                    glideToCFrame(CFrame.new(gatePos), nil, true)
                end
            end
        end
    end
    
    return true, "ok"
end

local function getStagesToFarm(stagesFolder, selectedStage)
    if not stagesFolder then return {} end
    local targetNum = nil
    if selectedStage and selectedStage ~= "all" then
        targetNum = tonumber(string.match(selectedStage, "%d+"))
    end
    local stagesList = {}
    for _, stg in ipairs(stagesFolder:GetChildren()) do
        local num = tonumber(string.match(stg.Name, "%d+")) or 0
        if targetNum == nil or num <= targetNum then
            table.insert(stagesList, {Stage = stg, Num = num})
        end
    end
    table.sort(stagesList, function(a, b) return a.Num < b.Num end)
    return stagesList
end

local function farmStagesSequence(stagesFolder, selectedStage, cancelCheck)
    if not stagesFolder then return end
    local stagesList = getStagesToFarm(stagesFolder, selectedStage)
    if #stagesList == 0 then return end
    if cancelCheck and cancelCheck() then return end
    if not Config.AutoWin or Config.AutoEndless then return end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hum or hum.Health <= 0 or not hrp then
        waitForCharacterAlive()
        task.wait(0.5)
        return
    end
    
    -- Calcula vetor de direção da pista (sempre para frente)
    local trackDir = getTrackForwardDirection(stagesList)
    
    -- Encontra o estágio mais próximo sem voltar para trás
    local startIndex = 1
    local minDist = math.huge
    for idx, item in ipairs(stagesList) do
        local refPos = getStageReferencePosition(item.Stage) or getStageCombatPosition(item.Stage)
        if refPos then
            local d = (Vector3.new(hrp.Position.X - refPos.X, 0, hrp.Position.Z - refPos.Z)).Magnitude
            if d < minDist then
                minDist = d
                startIndex = idx
            end
        end
    end
    if minDist > 250 then startIndex = 1 end
    
    -- Se o estágio de início estiver para trás do jogador, avança para não andar para trás
    while startIndex < #stagesList do
        local curRef = getStageReferencePosition(stagesList[startIndex].Stage)
        if curRef then
            local toCur = Vector3.new(curRef.X - hrp.Position.X, 0, curRef.Z - hrp.Position.Z)
            if toCur:Dot(trackDir) < -2.0 then
                startIndex = startIndex + 1
            else
                break
            end
        else
            break
        end
    end
    
    -- Desliza pelos estágios em ordem ESTRITAMENTE PARA FRENTE até o estágio alvo
    for i = startIndex, #stagesList do
        if cancelCheck and cancelCheck() then break end
        if not Config.AutoWin or Config.AutoEndless then break end
        
        char = LocalPlayer.Character
        hum = char and char:FindFirstChildOfClass("Humanoid")
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hum or hum.Health <= 0 or not hrp then
            waitForCharacterAlive()
            task.wait(0.5)
            break
        end
        
        local item = stagesList[i]
        local isSelectedStage = (i == #stagesList)
        local success, reason = farmStage(item.Stage, item.Num, isSelectedStage, stagesList, trackDir)
        
        char = LocalPlayer.Character
        hum = char and char:FindFirstChildOfClass("Humanoid")
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not success and (reason == "dead" or reason == "stalled") or not hum or hum.Health <= 0 or not hrp then
            waitForCharacterAlive()
            task.wait(0.5)
            break
        end
        
        if isSelectedStage then
            if cancelCheck and cancelCheck() then break end
            if not Config.AutoWin or Config.AutoEndless then break end
            
            task.wait(0.15)
            if Config.ReturnToSpawnAfterWin then
                local mapInst = (stagesFolder and stagesFolder.Parent) or getCurrentMap()
                local wNum = nil
                if mapInst then
                    for _, w in ipairs(WorldsData) do
                        if w.MapName == mapInst.Name then
                            wNum = w.WorldNum
                            break
                        end
                    end
                end
                returnToSpawn(mapInst, wNum, stagesList)
            end
            task.wait(0.15)
            break
        end
    end
end

-- Thread Principal do Auto Win
spawnThread(function()
    while true do
        if Config.AutoWin and not Config.AutoEndless then
            pcall(function()
                local myChar, myHrp, myHum = waitForCharacterAlive(6)
                if not myHrp or not myHum or myHum.Health <= 0 then task.wait(0.5); return end
                if myHrp.Position.Z < -800 then return end
                
                local chosenWorld = Config.SelectedProgWorld
                if chosenWorld == "all" then
                    for wNum = 1, 10 do
                        if not Config.AutoWin or Config.SelectedProgWorld ~= "all" then break end
                        local wData = WorldsData[wNum]
                        if wData and wData.MapName then
                            if RemoteRequestWorldChange then RemoteRequestWorldChange:InvokeServer(wNum) end
                            local mapInstance = workspace:FindFirstChild(wData.MapName)
                            local stagesFolder = mapInstance and mapInstance:FindFirstChild("Stages")
                            farmStagesSequence(stagesFolder, Config.SelectedProgStage, function()
                                return not Config.AutoWin or Config.SelectedProgWorld ~= "all"
                            end)
                        end
                    end
                else
                    local wData = nil
                    for _, w in ipairs(WorldsData) do
                        if w.Id == chosenWorld then wData = w; break end
                    end
                    if wData and wData.WorldNum and wData.MapName then
                        local curMap = getCurrentMap()
                        if not curMap or curMap.Name ~= wData.MapName then
                            if RemoteRequestWorldChange then
                                RemoteRequestWorldChange:InvokeServer(wData.WorldNum)
                                task.wait(1.5)
                            end
                        end
                        local mapInstance = workspace:FindFirstChild(wData.MapName)
                        local stagesFolder = mapInstance and mapInstance:FindFirstChild("Stages")
                        farmStagesSequence(stagesFolder, Config.SelectedProgStage, function()
                            return not Config.AutoWin or Config.SelectedProgWorld ~= chosenWorld
                        end)
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- ══════════════════════════════════════════════════════════════
-- 4. MOTOR DO AUTO ENDLESS (CO-OP SEM FIM)
-- ══════════════════════════════════════════════════════════════
local isDeadWaiting = false
local endlessEnteredCFrame = nil

local function isInsideEndless()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    local em = pgui and pgui:FindFirstChild("ScreenGui") and pgui.ScreenGui:FindFirstChild("Top") and pgui.ScreenGui.Top:FindFirstChild("EndlessMode")
    if em and em.Visible then return true end
    
    local pPos = hrp.Position
    for _, center in pairs(EndlessArenaCenters) do
        local dist = (Vector3.new(pPos.X, 0, pPos.Z) - Vector3.new(center.X, 0, center.Z)).Magnitude
        if dist < 250 then return true end
    end
    return false
end

local function getSelectedEndlessWorldNum()
    if Config.EndlessWorld == "best" then return 10 end
    local num = tonumber(string.match(tostring(Config.EndlessWorld or "10"), "%d+"))
    return num or 10
end

local function getTargetEndlessPortal(targetWorldNum)
    targetWorldNum = targetWorldNum or getSelectedEndlessWorldNum()
    local targetMapName = (targetWorldNum == 2 and "MapTest") or ("Map" .. tostring(targetWorldNum))
    
    local mapObj = workspace:FindFirstChild(targetMapName)
    local endlessFolder = mapObj and mapObj:FindFirstChild("Endless")
    local portal = endlessFolder and endlessFolder:FindFirstChild("Portal")
    if portal then return portal, targetWorldNum end
    
    local portals = CollectionService:GetTagged("EndlessPortal")
    for _, p in ipairs(portals) do
        local hb = p:FindFirstChild("Hitbox")
        if hb and hb:IsA("BasePart") then return p, targetWorldNum end
    end
    return nil, targetWorldNum
end

local function enterEndlessPortal()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end
    if isInsideEndless() then return true end
    
    local targetWorldNum = getSelectedEndlessWorldNum()
    local targetMapName = (targetWorldNum == 2 and "MapTest") or ("Map" .. tostring(targetWorldNum))
    
    local curMap = getCurrentMap()
    local curMapName = curMap and curMap.Name or "Map"
    if curMapName ~= targetMapName and RemoteRequestWorldChange then
        RemoteRequestWorldChange:InvokeServer(targetWorldNum)
        task.wait(1.5)
        local newChar, newHrp, newHum = waitForCharacterAlive(6)
        if not newHrp or not newHum or newHum.Health <= 0 then return false end
        char = newChar
        hrp = newHrp
        hum = newHum
    end
    
    local portal, worldNum = getTargetEndlessPortal(targetWorldNum)
    if not portal then return false end
    local hitbox = portal:FindFirstChild("Hitbox")
    if not hitbox or not hitbox:IsA("BasePart") then return false end
    
    hrp.CFrame = hitbox.CFrame + Vector3.new(0, 1.5, 0)
    task.wait(0.2)
    if firetouchinterest then
        firetouchinterest(hrp, hitbox, 0)
        task.wait(0.05)
        firetouchinterest(hrp, hitbox, 1)
    end
    task.wait(0.2)
    if RemoteEndlessStateRequest then pcall(function() RemoteEndlessStateRequest:InvokeServer(worldNum) end) end
    task.wait(0.2)
    if RemoteEndlessJoinRequest then RemoteEndlessJoinRequest:FireServer(worldNum) end
    task.wait(0.3)
    
    pcall(function()
        local pgui = LocalPlayer:FindFirstChild("PlayerGui")
        local screenGui = pgui and pgui:FindFirstChild("ScreenGui")
        local menus = screenGui and screenGui:FindFirstChild("Menus")
        local ej = menus and menus:FindFirstChild("EndlessJoin")
        if ej then
            local main = ej:FindFirstChild("Container") and ej.Container:FindFirstChild("Main")
            local joinBtn = main and main:FindFirstChild("Join")
            if joinBtn and joinBtn:IsA("GuiButton") and firesignal then
                firesignal(joinBtn.Activated)
                firesignal(joinBtn.MouseButton1Click)
            end
            task.wait(0.15)
            ej.Visible = false
        end
    end)
    return isInsideEndless()
end

-- Thread Principal do Auto Endless
spawnThread(function()
    local lastJoinAttempt = 0
    
    while true do
        if Config.AutoEndless then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local isDead = (not hum or hum.Health <= 0)
                
                -- Se morreu dentro ou fora do Endless
                if isDead then
                    if not isDeadWaiting then
                        isDeadWaiting = true
                        endlessEnteredCFrame = nil
                        if EndlessStatsCard and EndlessStatsCard.Update then
                            EndlessStatsCard.Update("Personagem morreu. Aguardando Respawn...", Color3.fromRGB(255, 185, 55))
                        end
                    end
                    task.wait(0.5)
                    return
                end
                
                -- Personagem vivo e pronto
                if isDeadWaiting then
                    task.wait(1.0)
                    isDeadWaiting = false
                end
                
                if isInsideEndless() then
                    -- Dentro da Arena: FICA TOTALMENTE PARADO ATACANDO ATÉ MORRER
                    if EndlessStatsCard and EndlessStatsCard.Update then
                        EndlessStatsCard.Update("Dentro do Endless (Parado e Atacando)", Color3.fromRGB(46, 204, 113))
                    end
                    
                    if not endlessEnteredCFrame then
                        local wNum = getSelectedEndlessWorldNum()
                        local c = EndlessArenaCenters[wNum]
                        if c then
                            endlessEnteredCFrame = CFrame.lookAt(hrp.Position, Vector3.new(c.X, hrp.Position.Y, c.Z))
                        else
                            endlessEnteredCFrame = hrp.CFrame
                        end
                        hrp.CFrame = endlessEnteredCFrame
                    end
                    
                    -- Trava a posição para ficar parado
                    if endlessEnteredCFrame then
                        local dist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(endlessEnteredCFrame.Position.X, 0, endlessEnteredCFrame.Position.Z)).Magnitude
                        if dist > 2 then
                            hrp.CFrame = endlessEnteredCFrame
                        end
                    end
                    
                    hum:Move(Vector3.zero, false)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    
                    -- Fica batendo continuamente em segundo plano
                    if RemoteRequestAttack then RemoteRequestAttack:FireServer() end
                    if RemotePlayerClick then RemotePlayerClick:FireServer() end
                else
                    endlessEnteredCFrame = nil
                    if EndlessStatsCard and EndlessStatsCard.Update then
                        EndlessStatsCard.Update("Entrando no Portal do Endless...", Color3.fromRGB(56, 122, 255))
                    end
                    
                    if os.clock() - lastJoinAttempt > 2.0 then
                        lastJoinAttempt = os.clock()
                        enterEndlessPortal()
                    end
                end
            end)
        else
            isDeadWaiting = false
            endlessEnteredCFrame = nil
        end
        task.wait(0.12)
    end
end)

-- ══════════════════════════════════════════════════════════════
-- 5. INTERFACE VISUAL (EXATAMENTE COMO NAS IMAGENS)
-- ══════════════════════════════════════════════════════════════
local ScreenParent
if gethui then
    ScreenParent = gethui()
elseif CoreGui:FindFirstChild("RobloxGui") then
    ScreenParent = CoreGui
else
    ScreenParent = LocalPlayer:WaitForChild("PlayerGui")
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SuperHeroEvolutionHub_" .. math.random(1000, 9999)
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = ScreenParent

local Themes = {
    Background = Color3.fromRGB(15, 18, 28),
    Header = Color3.fromRGB(20, 24, 36),
    Sidebar = Color3.fromRGB(17, 20, 31),
    Card = Color3.fromRGB(24, 29, 44),
    CardBorder = Color3.fromRGB(38, 46, 68),
    AccentBlue = Color3.fromRGB(56, 122, 255),
    AccentBlueBg = Color3.fromRGB(25, 42, 75),
    Text = Color3.fromRGB(245, 247, 255),
    TextDim = Color3.fromRGB(150, 158, 180),
    Success = Color3.fromRGB(46, 204, 113),
    ToggleInactive = Color3.fromRGB(36, 42, 60),
    Warning = Color3.fromRGB(255, 185, 55),
    Error = Color3.fromRGB(255, 75, 75)
}

-- MiniBar quando minimizado
local MiniBar = Instance.new("Frame")
MiniBar.Name = "MiniBar"
MiniBar.Size = UDim2.new(0, 380, 0, 50)
MiniBar.Position = UDim2.new(0.5, -190, 0.04, 0)
MiniBar.BackgroundColor3 = Themes.Background
MiniBar.BorderSizePixel = 0
MiniBar.Visible = false
MiniBar.Active = true
MiniBar.Parent = ScreenGui

local MiniBarCorner = Instance.new("UICorner")
MiniBarCorner.CornerRadius = UDim.new(0, 25)
MiniBarCorner.Parent = MiniBar

local MiniBarStroke = Instance.new("UIStroke")
MiniBarStroke.Thickness = 1.5
MiniBarStroke.Color = Themes.AccentBlue
MiniBarStroke.Transparency = 0.2
MiniBarStroke.Parent = MiniBar

local AvatarMini = Instance.new("ImageLabel")
AvatarMini.Name = "Avatar"
AvatarMini.Size = UDim2.new(0, 38, 0, 38)
AvatarMini.Position = UDim2.new(0, 6, 0.5, -19)
AvatarMini.BackgroundColor3 = Themes.Card
AvatarMini.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
AvatarMini.Parent = MiniBar

local AvatarMiniCorner = Instance.new("UICorner")
AvatarMiniCorner.CornerRadius = UDim.new(1, 0)
AvatarMiniCorner.Parent = AvatarMini

local MiniPlayerName = Instance.new("TextLabel")
MiniPlayerName.Size = UDim2.new(0, 150, 0, 16)
MiniPlayerName.Position = UDim2.new(0, 52, 0, 8)
MiniPlayerName.BackgroundTransparency = 1
MiniPlayerName.Text = "Marinho"
MiniPlayerName.TextColor3 = Themes.Text
MiniPlayerName.TextSize = 12
MiniPlayerName.Font = Enum.Font.GothamBold
MiniPlayerName.TextXAlignment = Enum.TextXAlignment.Left
MiniPlayerName.Parent = MiniBar

MiniStats = Instance.new("TextLabel")
MiniStats.Size = UDim2.new(0, 240, 0, 16)
MiniStats.Position = UDim2.new(0, 52, 0, 26)
MiniStats.BackgroundTransparency = 1
MiniStats.Text = "FPS: 60 • Ping: 30 ms • Rebirths: 0"
MiniStats.TextColor3 = Themes.TextDim
MiniStats.TextSize = 10
MiniStats.Font = Enum.Font.GothamMedium
MiniStats.TextXAlignment = Enum.TextXAlignment.Left
MiniStats.Parent = MiniBar

local MiniExpandBtn = Instance.new("TextButton")
MiniExpandBtn.Size = UDim2.new(0, 32, 0, 32)
MiniExpandBtn.Position = UDim2.new(1, -40, 0.5, -16)
MiniExpandBtn.BackgroundColor3 = Themes.Card
MiniExpandBtn.Text = "□"
MiniExpandBtn.TextColor3 = Themes.Text
MiniExpandBtn.TextSize = 13
MiniExpandBtn.Font = Enum.Font.GothamBold
MiniExpandBtn.AutoButtonColor = false
MiniExpandBtn.Active = true
MiniExpandBtn.Parent = MiniBar

local MiniExpandCorner = Instance.new("UICorner")
MiniExpandCorner.CornerRadius = UDim.new(0, 16)
MiniExpandCorner.Parent = MiniExpandBtn

-- Janela Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 680, 0, 450)
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -225)
MainFrame.BackgroundColor3 = Themes.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Themes.CardBorder
MainStroke.Parent = MainFrame

-- Topbar
local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Size = UDim2.new(1, 0, 0, 54)
Topbar.BackgroundColor3 = Themes.Header
Topbar.BorderSizePixel = 0
Topbar.Active = true
Topbar.Parent = MainFrame

local TopbarCorner = Instance.new("UICorner")
TopbarCorner.CornerRadius = UDim.new(0, 14)
TopbarCorner.Parent = Topbar

local TopbarLine = Instance.new("Frame")
TopbarLine.Size = UDim2.new(1, 0, 0, 1)
TopbarLine.Position = UDim2.new(0, 0, 1, -1)
TopbarLine.BackgroundColor3 = Themes.CardBorder
TopbarLine.BorderSizePixel = 0
TopbarLine.Parent = Topbar

-- Avatar do Jogador com Borda Azul Circular
local HeaderAvatar = Instance.new("ImageLabel")
HeaderAvatar.Name = "HeaderAvatar"
HeaderAvatar.Size = UDim2.new(0, 36, 0, 36)
HeaderAvatar.Position = UDim2.new(0, 14, 0.5, -18)
HeaderAvatar.BackgroundColor3 = Themes.Card
HeaderAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
HeaderAvatar.Parent = Topbar

local HeaderAvatarCorner = Instance.new("UICorner")
HeaderAvatarCorner.CornerRadius = UDim.new(1, 0)
HeaderAvatarCorner.Parent = HeaderAvatar

local HeaderAvatarStroke = Instance.new("UIStroke")
HeaderAvatarStroke.Thickness = 1.5
HeaderAvatarStroke.Color = Themes.AccentBlue
HeaderAvatarStroke.Parent = HeaderAvatar

-- Títulos Exatamente Conforme Imagem
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(0, 240, 0, 18)
TitleLabel.Position = UDim2.new(0, 58, 0, 10)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ SUPERHERO EVOLUTION"
TitleLabel.TextColor3 = Themes.Text
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Topbar

local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Name = "Subtitle"
SubtitleLabel.Size = UDim2.new(0, 240, 0, 16)
SubtitleLabel.Position = UDim2.new(0, 58, 0, 28)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Text = "Auto Edition | Marinho"
SubtitleLabel.TextColor3 = Themes.TextDim
SubtitleLabel.TextSize = 11
SubtitleLabel.Font = Enum.Font.GothamMedium
SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SubtitleLabel.Parent = Topbar

-- Pílula de Stats no Topbar
HeaderStats = Instance.new("TextLabel")
HeaderStats.Name = "HeaderStats"
HeaderStats.Size = UDim2.new(0, 230, 0, 26)
HeaderStats.Position = UDim2.new(1, -320, 0.5, -13)
HeaderStats.BackgroundColor3 = Themes.Card
HeaderStats.Text = "FPS: 60 • Ping: 30 ms • Rebirths: 0"
HeaderStats.TextColor3 = Themes.AccentBlue
HeaderStats.TextSize = 10
HeaderStats.Font = Enum.Font.GothamBold
HeaderStats.Parent = Topbar

local HeaderStatsCorner = Instance.new("UICorner")
HeaderStatsCorner.CornerRadius = UDim.new(0, 13)
HeaderStatsCorner.Parent = HeaderStats

local HeaderStatsStroke = Instance.new("UIStroke")
HeaderStatsStroke.Thickness = 1
HeaderStatsStroke.Color = Themes.CardBorder
HeaderStatsStroke.Parent = HeaderStats

-- Botões Minimizar e Fechar
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -72, 0.5, -15)
MinimizeBtn.BackgroundColor3 = Themes.Card
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Themes.Text
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Active = true
MinimizeBtn.Parent = Topbar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -15)
CloseBtn.BackgroundColor3 = Themes.Card
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Themes.Text
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Active = true
CloseBtn.Parent = Topbar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- Minimizar & Restaurar Janela
local isMinimized = false

local function setMinimized(state)
    isMinimized = state
    if isMinimized then
        local tweenOut = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, 1.2, 0)
        })
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            if isMinimized then
                MainFrame.Visible = false
                MiniBar.Visible = true
                MiniBar.Position = UDim2.new(0.5, -190, -0.15, 0)
                TweenService:Create(MiniBar, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.5, -190, 0.04, 0)
                }):Play()
            end
        end)
    else
        local tweenBarOut = TweenService:Create(MiniBar, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -190, -0.15, 0)
        })
        tweenBarOut:Play()
        tweenBarOut.Completed:Connect(function()
            MiniBar.Visible = false
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, -340, 0.5, -225)
            }):Play()
        end)
    end
end

local function toggleMinimize() setMinimized(not isMinimized) end

MinimizeBtn.Activated:Connect(function() setMinimized(true) end)
MinimizeBtn.MouseButton1Click:Connect(function() setMinimized(true) end)
MiniExpandBtn.Activated:Connect(function() setMinimized(false) end)
MiniExpandBtn.MouseButton1Click:Connect(function() setMinimized(false) end)

CloseBtn.Activated:Connect(function()
    if getgenv().SuperHeroEvolutionHubCleanup then getgenv().SuperHeroEvolutionHubCleanup() end
end)
CloseBtn.MouseButton1Click:Connect(function()
    if getgenv().SuperHeroEvolutionHubCleanup then getgenv().SuperHeroEvolutionHubCleanup() end
end)

local keyKConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
        toggleMinimize()
    end
end)
table.insert(ActiveConnections, keyKConn)

-- Janela Arrastável
local function makeDraggable(targetFrame, dragHandle)
    local dragging = false
    local dragInput, dragStart, startPos
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    
    local dragConn = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(targetFrame, TweenInfo.new(0.06, Enum.EasingStyle.Sine), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
    table.insert(ActiveConnections, dragConn)
end

makeDraggable(MainFrame, Topbar)
makeDraggable(MiniBar, MiniBar)

-- FPS, Ping e Rebirths em Tempo Real
local fpsCount = 0
local lastTime = tick()

table.insert(ActiveConnections, RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    local now = tick()
    if now - lastTime >= 1 then
        local fps = fpsCount
        fpsCount = 0
        lastTime = now
        
        local ping = 0
        pcall(function()
            local item = Stats.Network.ServerStatsItem:FindFirstChild("Data Ping")
            if item then ping = math.floor(item:GetValue()) end
        end)
        
        local formatted = string.format("FPS: %d • Ping: %d ms • Rebirths: %d", fps, ping, SessionRebirths)
        HeaderStats.Text = formatted
        MiniStats.Text = formatted
    end
end))

-- Sidebar & Estrutura das 5 Abas
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 160, 1, -54)
Sidebar.Position = UDim2.new(0, 0, 0, 54)
Sidebar.BackgroundColor3 = Themes.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Active = true
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 14)
SidebarCorner.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 12)
SidebarPadding.PaddingLeft = UDim.new(0, 8)
SidebarPadding.PaddingRight = UDim.new(0, 8)
SidebarPadding.Parent = Sidebar

local PageContainer = Instance.new("Frame")
PageContainer.Name = "PageContainer"
PageContainer.Size = UDim2.new(1, -160, 1, -54)
PageContainer.Position = UDim2.new(0, 160, 0, 54)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = MainFrame

local Tabs = {}
local TabButtons = {}

local function createTab(name, icon, layoutOrder)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "TabBtn"
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Themes.Card
    btn.BackgroundTransparency = 1
    btn.Text = (icon and #icon > 0) and (icon .. "  " .. name) or name
    btn.TextColor3 = Themes.TextDim
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamSemibold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = layoutOrder
    btn.AutoButtonColor = false
    btn.Active = true
    btn.Parent = Sidebar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local btnPadding = Instance.new("UIPadding")
    btnPadding.PaddingLeft = UDim.new(0, 10)
    btnPadding.Parent = btn
    
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Themes.AccentBlue
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Parent = PageContainer
    
    local pageLayout = Instance.new("UIListLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 8)
    pageLayout.Parent = page
    
    local pagePadding = Instance.new("UIPadding")
    pagePadding.PaddingTop = UDim.new(0, 14)
    pagePadding.PaddingLeft = UDim.new(0, 16)
    pagePadding.PaddingRight = UDim.new(0, 16)
    pagePadding.PaddingBottom = UDim.new(0, 20)
    pagePadding.Parent = page
    
    Tabs[name] = page
    TabButtons[name] = btn
    
    local function onTabSelect()
        for tabName, p in pairs(Tabs) do
            p.Visible = (tabName == name)
            local b = TabButtons[tabName]
            if tabName == name then
                TweenService:Create(b, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0,
                    BackgroundColor3 = Themes.AccentBlueBg,
                    TextColor3 = Themes.AccentBlue
                }):Play()
            else
                TweenService:Create(b, TweenInfo.new(0.2), {
                    BackgroundTransparency = 1,
                    TextColor3 = Themes.TextDim
                }):Play()
            end
        end
    end

    btn.Activated:Connect(onTabSelect)
    btn.MouseButton1Click:Connect(onTabSelect)
    return page
end

-- Componentes Visuais Reutilizáveis
local function createSectionHeader(parent, text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 22)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Position = UDim2.new(0, 2, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(text)
    lbl.TextColor3 = Themes.AccentBlue
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    return frame
end

local function createLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.Position = UDim2.new(0, 2, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Themes.TextDim
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function createInfoCard(parent, title, statusText, statusColor)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 44)
    card.BackgroundColor3 = Themes.Card
    card.BorderSizePixel = 0
    card.Parent = parent
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Thickness = 1
    cardStroke.Color = Themes.CardBorder
    cardStroke.Parent = card
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.5, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Themes.Text
    titleLbl.TextSize = 12
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card
    
    local statusBadge = Instance.new("TextLabel")
    statusBadge.Size = UDim2.new(0, 190, 0, 26)
    statusBadge.Position = UDim2.new(1, -202, 0.5, -13)
    statusBadge.BackgroundColor3 = Themes.Header
    statusBadge.Text = statusText
    statusBadge.TextColor3 = statusColor or Themes.Success
    statusBadge.TextSize = 11
    statusBadge.Font = Enum.Font.GothamBold
    statusBadge.Parent = card
    
    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 6)
    badgeCorner.Parent = statusBadge
    
    local badgeStroke = Instance.new("UIStroke")
    badgeStroke.Thickness = 1
    badgeStroke.Color = statusColor or Themes.Success
    badgeStroke.Transparency = 0.5
    badgeStroke.Parent = statusBadge
    
    return {
        Update = function(newText, newColor)
            statusBadge.Text = newText
            local finalCol = newColor or Themes.Success
            statusBadge.TextColor3 = finalCol
            badgeStroke.Color = finalCol
        end
    }
end

local function createToggle(parent, title, defaultState, callback)
    local card = Instance.new("TextButton")
    card.Size = UDim2.new(1, 0, 0, 42)
    card.BackgroundColor3 = Themes.Card
    card.BorderSizePixel = 0
    card.AutoButtonColor = false
    card.Text = ""
    card.Active = true
    card.Parent = parent
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Thickness = 1
    cardStroke.Color = Themes.CardBorder
    cardStroke.Parent = card
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -70, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Themes.Text
    titleLbl.TextSize = 12
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card
    
    local toggleBtn = Instance.new("Frame")
    toggleBtn.Size = UDim2.new(0, 44, 0, 22)
    toggleBtn.Position = UDim2.new(1, -54, 0.5, -11)
    toggleBtn.BackgroundColor3 = defaultState and Themes.Success or Themes.ToggleInactive
    toggleBtn.Parent = card
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn
    
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = defaultState and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    thumb.BackgroundColor3 = Themes.Text
    thumb.BorderSizePixel = 0
    thumb.Parent = toggleBtn
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb
    
    local isEnabled = defaultState
    
    local function updateVisuals()
        local targetPos = isEnabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local targetColor = isEnabled and Themes.Success or Themes.ToggleInactive
        TweenService:Create(thumb, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Position = targetPos}):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
    end
    
    local lastToggle = 0
    local function onToggle()
        local now = tick()
        if now - lastToggle < 0.15 then return end
        lastToggle = now
        isEnabled = not isEnabled
        updateVisuals()
        callback(isEnabled)
    end
    
    card.Activated:Connect(onToggle)
    card.MouseButton1Click:Connect(onToggle)
    return {
        Set = function(val, suppressCallback)
            isEnabled = val
            updateVisuals()
            if not suppressCallback then callback(isEnabled) end
        end,
        Get = function() return isEnabled end
    }
end

local function createSlider(parent, title, minVal, maxVal, defaultVal, unit, isFloat, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 56)
    card.BackgroundColor3 = Themes.Card
    card.BorderSizePixel = 0
    card.Parent = parent
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Thickness = 1
    cardStroke.Color = Themes.CardBorder
    cardStroke.Parent = card
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.6, 0, 0, 20)
    titleLbl.Position = UDim2.new(0, 12, 0, 6)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Themes.Text
    titleLbl.TextSize = 12
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card
    
    local valueLbl = Instance.new("TextLabel")
    valueLbl.Size = UDim2.new(0.35, 0, 0, 20)
    valueLbl.Position = UDim2.new(0.65, -12, 0, 6)
    valueLbl.BackgroundTransparency = 1
    local initialText = isFloat and string.format("%.1f", defaultVal) or tostring(math.floor(defaultVal))
    valueLbl.Text = initialText .. unit
    valueLbl.TextColor3 = Themes.AccentBlue
    valueLbl.TextSize = 12
    valueLbl.Font = Enum.Font.GothamBold
    valueLbl.TextXAlignment = Enum.TextXAlignment.Right
    valueLbl.Parent = card
    
    local track = Instance.new("TextButton")
    track.Size = UDim2.new(1, -24, 0, 8)
    track.Position = UDim2.new(0, 12, 0, 36)
    track.BackgroundColor3 = Themes.ToggleInactive
    track.BorderSizePixel = 0
    track.Text = ""
    track.AutoButtonColor = false
    track.Active = true
    track.Parent = card
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    local ratio = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    fill.BackgroundColor3 = Themes.AccentBlue
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 14, 0, 14)
    thumb.Position = UDim2.new(1, -7, 0.5, -7)
    thumb.BackgroundColor3 = Themes.Text
    thumb.BorderSizePixel = 0
    thumb.Parent = fill
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb
    
    local isSliding = false
    local currentValue = defaultVal
    
    local function updateValue(inputX)
        local trackAbsPos = track.AbsolutePosition.X
        local trackAbsSize = track.AbsoluteSize.X
        local rawRatio = math.clamp((inputX - trackAbsPos) / trackAbsSize, 0, 1)
        
        local val = minVal + (maxVal - minVal) * rawRatio
        if not isFloat then
            val = math.floor(val + 0.5)
        else
            val = math.floor(val * 10 + 0.5) / 10
        end
        currentValue = val
        
        fill.Size = UDim2.new(rawRatio, 0, 1, 0)
        local txt = isFloat and string.format("%.1f", val) or tostring(val)
        valueLbl.Text = txt .. unit
        callback(val)
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
            updateValue(input.Position.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input.Position.X)
        end
    end)
    
    return {
        Set = function(val)
            currentValue = val
            local r = math.clamp((val - minVal) / (maxVal - minVal), 0, 1)
            fill.Size = UDim2.new(r, 0, 1, 0)
            local txt = isFloat and string.format("%.1f", val) or tostring(val)
            valueLbl.Text = txt .. unit
            callback(val)
        end,
        Get = function() return currentValue end
    }
end

local function createDropdown(parent, title, options, defaultId, onSelected)
    local hasTitle = (title and #title > 0)
    local closedHeight = hasTitle and 64 or 38
    local openHeight = hasTitle and 210 or 180
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, closedHeight)
    container.BackgroundColor3 = hasTitle and Themes.Card or Color3.fromRGB(0, 0, 0)
    container.BackgroundTransparency = hasTitle and 0 or 1
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.Parent = parent
    
    if hasTitle then
        local contCorner = Instance.new("UICorner")
        contCorner.CornerRadius = UDim.new(0, 8)
        contCorner.Parent = container
        
        local contStroke = Instance.new("UIStroke")
        contStroke.Thickness = 1
        contStroke.Color = Themes.CardBorder
        contStroke.Parent = container
        
        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -24, 0, 16)
        titleLbl.Position = UDim2.new(0, 12, 0, 6)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = title
        titleLbl.TextColor3 = Themes.TextDim
        titleLbl.TextSize = 11
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Parent = container
    end
    
    local selectBtn = Instance.new("TextButton")
    selectBtn.Size = hasTitle and UDim2.new(1, -24, 0, 32) or UDim2.new(1, 0, 1, 0)
    selectBtn.Position = hasTitle and UDim2.new(0, 12, 0, 24) or UDim2.new(0, 0, 0, 0)
    selectBtn.BackgroundColor3 = hasTitle and Themes.Header or Themes.Card
    selectBtn.Text = ""
    selectBtn.AutoButtonColor = false
    selectBtn.Active = true
    selectBtn.Parent = container
    
    local selectCorner = Instance.new("UICorner")
    selectCorner.CornerRadius = UDim.new(0, 6)
    selectCorner.Parent = selectBtn
    
    local selectedText = Instance.new("TextLabel")
    selectedText.Size = UDim2.new(1, -30, 1, 0)
    selectedText.Position = UDim2.new(0, 10, 0, 0)
    selectedText.BackgroundTransparency = 1
    selectedText.TextColor3 = Themes.Text
    selectedText.TextSize = 12
    selectedText.Font = Enum.Font.GothamMedium
    selectedText.TextXAlignment = Enum.TextXAlignment.Left
    selectedText.TextTruncate = Enum.TextTruncate.AtEnd
    selectedText.Parent = selectBtn
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 24, 1, 0)
    arrow.Position = UDim2.new(1, -28, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▾"
    arrow.TextColor3 = Themes.AccentBlue
    arrow.TextSize = 12
    arrow.Font = Enum.Font.GothamBold
    arrow.Parent = selectBtn
    
    local listScroll = Instance.new("ScrollingFrame")
    listScroll.Size = hasTitle and UDim2.new(1, -24, 0, 136) or UDim2.new(1, -12, 0, 136)
    listScroll.Position = hasTitle and UDim2.new(0, 12, 0, 62) or UDim2.new(0, 6, 0, 40)
    listScroll.BackgroundColor3 = Themes.Background
    listScroll.BorderSizePixel = 0
    listScroll.ScrollBarThickness = 4
    listScroll.ScrollBarImageColor3 = Themes.AccentBlue
    listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listScroll.Parent = container
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = listScroll
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = listScroll
    
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 4)
    listPadding.PaddingBottom = UDim.new(0, 4)
    listPadding.PaddingLeft = UDim.new(0, 4)
    listPadding.PaddingRight = UDim.new(0, 4)
    listPadding.Parent = listScroll
    
    local currentSelected = defaultId
    local isOpen = false
    
    for _, opt in ipairs(options) do
        if opt.Id == defaultId then
            selectedText.Text = opt.Name
            break
        end
    end
    if selectedText.Text == "" and #options > 0 then
        selectedText.Text = options[1].Name
        currentSelected = options[1].Id
    end
    
    local function renderItems()
        for _, child in ipairs(listScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        for _, opt in ipairs(options) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, 0, 0, 28)
            itemBtn.BackgroundColor3 = (opt.Id == currentSelected) and Themes.Card or Themes.Header
            itemBtn.Text = "  " .. opt.Name
            itemBtn.TextColor3 = (opt.Id == currentSelected) and Themes.AccentBlue or Themes.Text
            itemBtn.TextSize = 11
            itemBtn.Font = Enum.Font.GothamMedium
            itemBtn.TextXAlignment = Enum.TextXAlignment.Left
            itemBtn.TextTruncate = Enum.TextTruncate.AtEnd
            itemBtn.AutoButtonColor = false
            itemBtn.Active = true
            itemBtn.Parent = listScroll
            
            local itemCorner = Instance.new("UICorner")
            itemCorner.CornerRadius = UDim.new(0, 6)
            itemCorner.Parent = itemBtn
            
            itemBtn.Activated:Connect(function()
                currentSelected = opt.Id
                selectedText.Text = opt.Name
                isOpen = false
                arrow.Text = "▾"
                TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, closedHeight)
                }):Play()
                if onSelected then onSelected(opt.Id, opt.Name) end
            end)
        end
    end
    
    renderItems()
    
    selectBtn.Activated:Connect(function()
        isOpen = not isOpen
        arrow.Text = isOpen and "▴" or "▾"
        local targetH = isOpen and openHeight or closedHeight
        TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, targetH)
        }):Play()
    end)
    
    return {
        GetSelected = function() return currentSelected end,
        SetSelected = function(id, name)
            currentSelected = id
            selectedText.Text = name or tostring(id)
            if onSelected then onSelected(id, name or tostring(id)) end
            renderItems()
        end,
        UpdateOptions = function(newOptions, newDefaultId)
            options = newOptions
            if newDefaultId then
                currentSelected = newDefaultId
                for _, opt in ipairs(options) do
                    if opt.Id == newDefaultId then
                        selectedText.Text = opt.Name
                        break
                    end
                end
            end
            renderItems()
        end
    }
end

local function createButton(parent, text, isBlueAccent, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = isBlueAccent and Themes.AccentBlue or Themes.Card
    btn.Text = text
    btn.TextColor3 = Themes.Text
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Active = true
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Thickness = 1
    btnStroke.Color = isBlueAccent and Themes.AccentBlue or Themes.CardBorder
    btnStroke.Parent = btn
    
    local lastClick = 0
    local function onClick()
        local now = tick()
        if now - lastClick < 0.2 then return end
        lastClick = now
        callback()
    end
    btn.Activated:Connect(onClick)
    btn.MouseButton1Click:Connect(onClick)
    return btn
end

-- ══════════════════════════════════════════════════════════════
-- CRIAÇÃO DAS 5 ABAS SOLICITADAS
-- ══════════════════════════════════════════════════════════════
local ClickTab = createTab("Auto Click", "⚡", 1)
local RebirthTab = createTab("Auto Rebirth", "🔄", 2)
local WinTab = createTab("Auto Win", "🏆", 3)
local EndlessTab = createTab("Auto Endless", "🌀", 4)
local ConfigTab = createTab("Config", "⚙️", 5)

-- ── ABA 1: AUTO CLICK ──────────────────────────────────────────
createSectionHeader(ClickTab, "⚡ AUTO CLICK (SEGUNDO PLANO - ZERO CHAT INTERRUPT)")

ClickStatsCard = createInfoCard(ClickTab, "📊 Cliques Efetuados", "Clicks: 0", Themes.AccentBlue)

ClickToggle = createToggle(ClickTab, "Ativar Auto Click", Config.FastClick, function(val)
    Config.FastClick = val
    saveConfig()
end)

createSlider(ClickTab, "Velocidade / Intervalo por Clique", 0.1, 10.0, Config.ClickDelay, "s por clique", true, function(val)
    Config.ClickDelay = val
    saveConfig()
end)

-- ── ABA 2: AUTO REBIRTH ────────────────────────────────────────
createSectionHeader(RebirthTab, "🔄 AUTO REBIRTH")

RebirthStatsCard = createInfoCard(RebirthTab, "📊 Estatísticas de Rebirth", "Sessão: 0 | Total: 0", Themes.AccentBlue)

RebirthToggle = createToggle(RebirthTab, "Ativar Auto Rebirth Automático", Config.AutoRebirth, function(val)
    Config.AutoRebirth = val
    saveConfig()
end)

-- ── ABA 3: AUTO WIN ────────────────────────────────────────────
createSectionHeader(WinTab, "🏆 PROGRESSÃO & ESTÁGIOS (AUTO WIN)")

WinStatsCard = createInfoCard(WinTab, "📊 Vitórias Coletadas", "Vitórias: 0", Themes.AccentBlue)

createLabel(WinTab, "1. Selecione o Mundo:")
local stageProgDropdown = nil
local pauseStageDropdown = nil

local worldProgDropdown = createDropdown(WinTab, "", WorldsData, Config.SelectedProgWorld, function(worldId)
    Config.SelectedProgWorld = worldId
    if stageProgDropdown and stageProgDropdown.UpdateOptions then
        local opts = getStagesOptionsForWorld(worldId)
        local def = (opts[#opts] and opts[#opts].Id) or "Stage1"
        stageProgDropdown.UpdateOptions(opts, def)
        Config.SelectedProgStage = def
    end
    if pauseStageDropdown and pauseStageDropdown.UpdateOptions then
        local pauseOpts = getPauseStageOptionsForWorld(worldId)
        pauseStageDropdown.UpdateOptions(pauseOpts, Config.PauseFromStage or "none")
    end
    saveConfig()
end)

createLabel(WinTab, "2. Estágio Alvo (Parar no Pad e Pegar Vitória):")
stageProgDropdown = createDropdown(WinTab, "", getStagesOptionsForWorld(Config.SelectedProgWorld), Config.SelectedProgStage, function(stageId)
    Config.SelectedProgStage = stageId
    saveConfig()
end)

WinToggle = createToggle(WinTab, "Ativar Auto Win (Deslizar até Estágio Alvo)", Config.AutoWin, function(val)
    Config.AutoWin = val
    if val then
        Config.AutoEndless = false
        if EndlessToggle and EndlessToggle.Set then EndlessToggle.Set(false, true) end
    end
    saveConfig()
end)

createSlider(WinTab, "Velocidade de Deslize do Personagem", 40, 350, Config.WinGlideSpeed, " Speed", false, function(val)
    Config.WinGlideSpeed = val
    saveConfig()
end)

createLabel(WinTab, "3. Pausar para Lutar a partir do Estágio:")
pauseStageDropdown = createDropdown(WinTab, "", getPauseStageOptionsForWorld(Config.SelectedProgWorld), Config.PauseFromStage or "none", function(stageId)
    Config.PauseFromStage = stageId
    saveConfig()
end)

createSlider(WinTab, "Tempo de Parada em Cada Estágio", 0.1, 10.0, Config.StageStopTime, "s", true, function(val)
    Config.StageStopTime = val
    saveConfig()
end)

createToggle(WinTab, "Voltar ao Spawn Após Pegar o Pad", Config.ReturnToSpawnAfterWin, function(val)
    Config.ReturnToSpawnAfterWin = val
    saveConfig()
end)

createDropdown(WinTab, "", {
    {Id = "Teleport", Name = "Modo Retorno: Teleporte Instantâneo"},
    {Id = "Reset", Name = "Modo Retorno: Reset do Personagem"}
}, Config.SpawnReturnMethod, function(methodId)
    Config.SpawnReturnMethod = methodId
    saveConfig()
end)

-- ── ABA 4: AUTO ENDLESS ────────────────────────────────────────
createSectionHeader(EndlessTab, "🌀 CO-OP SEM FIM (ENDLESS)")

EndlessStatsCard = createInfoCard(EndlessTab, "📊 Status do Endless", "Fora da Arena", Themes.AccentBlue)

createLabel(EndlessTab, "Selecione o Mundo do Endless:")
createDropdown(EndlessTab, "", EndlessWorldsList, Config.EndlessWorld, function(worldId)
    Config.EndlessWorld = worldId
    saveConfig()
end)

EndlessToggle = createToggle(EndlessTab, "Ativar Auto Endless (Ficar Parado até Morrer)", Config.AutoEndless, function(val)
    Config.AutoEndless = val
    if val then
        Config.AutoWin = false
        if WinToggle and WinToggle.Set then WinToggle.Set(false, true) end
    end
    saveConfig()
end)

-- ── ABA 5: CONFIG ──────────────────────────────────────────────
createSectionHeader(ConfigTab, "⚙️ UTILITÁRIOS & SEGUNDO PLANO")

AntiAfkToggle = createToggle(ConfigTab, "Anti-AFK Silencioso", Config.AntiAfk, function(val)
    Config.AntiAfk = val
    saveConfig()
end)

AutoClosePopupsToggle = createToggle(ConfigTab, "Auto Fechar Pop-ups de Robux (Clicando Fora)", Config.AutoClosePopups, function(val)
    Config.AutoClosePopups = val
    saveConfig()
end)

PlaytimeToggle = createToggle(ConfigTab, "Auto Resgatar Recompensas de Tempo de Jogo", Config.AutoClaimPlaytime, function(val)
    Config.AutoClaimPlaytime = val
    saveConfig()
end)

createButton(ConfigTab, "🎁 Resgatar Recompensas de Tempo Agora", false, function()
    claimPlaytimeRewards()
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🎁 Recompensas",
            Text = "Verificando e resgatando recompensas de tempo...",
            Duration = 3
        })
    end)
end)

createSectionHeader(ConfigTab, "💾 PERSISTÊNCIA & CONFIGURAÇÃO")

createToggle(ConfigTab, "Salvar Configurações Usadas no Script", Config.AutoSaveConfig, function(val)
    Config.AutoSaveConfig = val
    saveConfig()
end)

createButton(ConfigTab, "💾 Salvar Configurações Agora", true, function()
    saveConfig()
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "💾 Salvo com Sucesso",
            Text = "Configurações salvas no arquivo!",
            Duration = 3
        })
    end)
end)

createButton(ConfigTab, "🔄 Recarregar Configurações Salvas", false, function()
    if loadConfig() then
        if ClickToggle and ClickToggle.Set then ClickToggle.Set(Config.FastClick == true, true) end
        if RebirthToggle and RebirthToggle.Set then RebirthToggle.Set(Config.AutoRebirth == true, true) end
        if WinToggle and WinToggle.Set then WinToggle.Set(Config.AutoWin == true, true) end
        if EndlessToggle and EndlessToggle.Set then EndlessToggle.Set(Config.AutoEndless == true, true) end
        if AntiAfkToggle and AntiAfkToggle.Set then AntiAfkToggle.Set(Config.AntiAfk == true, true) end
        if AutoClosePopupsToggle and AutoClosePopupsToggle.Set then AutoClosePopupsToggle.Set(Config.AutoClosePopups == true, true) end
        if PlaytimeToggle and PlaytimeToggle.Set then PlaytimeToggle.Set(Config.AutoClaimPlaytime == true, true) end
        if pauseStageDropdown and pauseStageDropdown.SetSelected then
            local pName = (Config.PauseFromStage == "none") and "Não parar em nenhum estágio" or tostring(Config.PauseFromStage)
            pauseStageDropdown.SetSelected(Config.PauseFromStage or "none", pName)
        end
        if stageProgDropdown and stageProgDropdown.SetSelected then
            stageProgDropdown.SetSelected(Config.SelectedProgStage, tostring(Config.SelectedProgStage))
        end
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "🔄 Configurações Restauradas",
                Text = "Configurações recarregadas com sucesso!",
                Duration = 3
            })
        end)
    end
end)

createButton(ConfigTab, "🌐 Trocar de Servidor (Server Hop)", false, function()
    saveConfig()
    serverHop()
end)

createInfoCard(ConfigTab, "⌨️ Tecla de Atalho", "Pressione 'K' para Minimizar / Abrir", Themes.TextDim)

createButton(ConfigTab, "❌ Fechar / Descarregar Script", false, function()
    if getgenv().SuperHeroEvolutionHubCleanup then
        getgenv().SuperHeroEvolutionHubCleanup()
    end
end)

-- Aplica estados carregados
local function applyLoadedConfig()
    pcall(function()
        if ClickToggle and ClickToggle.Set then ClickToggle.Set(Config.FastClick == true, true) end
        if RebirthToggle and RebirthToggle.Set then RebirthToggle.Set(Config.AutoRebirth == true, true) end
        if WinToggle and WinToggle.Set then WinToggle.Set(Config.AutoWin == true, true) end
        if EndlessToggle and EndlessToggle.Set then EndlessToggle.Set(Config.AutoEndless == true, true) end
        if AntiAfkToggle and AntiAfkToggle.Set then AntiAfkToggle.Set(Config.AntiAfk == true, true) end
        if AutoClosePopupsToggle and AutoClosePopupsToggle.Set then AutoClosePopupsToggle.Set(Config.AutoClosePopups == true, true) end
        if PlaytimeToggle and PlaytimeToggle.Set then PlaytimeToggle.Set(Config.AutoClaimPlaytime == true, true) end
        if pauseStageDropdown and pauseStageDropdown.SetSelected then
            local pName = (Config.PauseFromStage == "none") and "Não parar em nenhum estágio" or tostring(Config.PauseFromStage)
            pauseStageDropdown.SetSelected(Config.PauseFromStage or "none", pName)
        end
        if stageProgDropdown and stageProgDropdown.SetSelected then
            stageProgDropdown.SetSelected(Config.SelectedProgStage, tostring(Config.SelectedProgStage))
        end
    end)
end
applyLoadedConfig()

-- ══════════════════════════════════════════════════════════════
-- 6. CLEANUP & AUTO-UPDATE
-- ══════════════════════════════════════════════════════════════
getgenv().SuperHeroEvolutionHubCleanup = function()
    for k, _ in pairs(Config) do
        if type(Config[k]) == "boolean" then
            Config[k] = false
        end
    end
    
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
        for _, part in ipairs(char and char:GetDescendants() or {}) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end)
    
    for _, t in ipairs(ActiveThreads) do pcall(task.cancel, t) end
    for _, c in ipairs(ActiveConnections) do pcall(function() c:Disconnect() end) end
    table.clear(ActiveThreads)
    table.clear(ActiveConnections)
    
    if ScreenGui and ScreenGui.Parent then pcall(function() ScreenGui:Destroy() end) end
    destroyExistingHubs()
    
    getgenv().SuperHeroEvolutionHubLoaded = nil
    getgenv().SuperHeroEvolutionHubCleanup = nil
    getgenv().SuperHeroEvolutionHubConfig = nil
    
    print("[SUPERHERO EVOLUTION] Script descarregado completamente com sucesso.")
end

-- Auto Update
spawnThread(function()
    local isAutoUpdating = false
    while true do
        task.wait(6)
        if not isAutoUpdating then
            pcall(function()
                local verUrl = "https://raw.githubusercontent.com/miguelmarinho1420-hub/superhero-evolution/main/version.json?t=" .. os.time()
                local raw = game:HttpGet(verUrl)
                if raw and #raw > 5 then
                    local data = HttpService:JSONDecode(raw)
                    if data and data.timestamp and tonumber(data.timestamp) > SCRIPT_VERSION_TIMESTAMP then
                        isAutoUpdating = true
                        pcall(function()
                            if getgenv().SuperHeroEvolutionHubCleanup then
                                getgenv().SuperHeroEvolutionHubCleanup()
                            end
                        end)
                        task.wait(0.5)
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/miguelmarinho1420-hub/superhero-evolution/main/script.lua?t=" .. os.time()))()
                    end
                end
            end)
        end
    end
end)

-- Seleciona a primeira aba inicialmente
if TabButtons["Auto Win"] then
    TabButtons["Auto Win"].BackgroundTransparency = 0
    TabButtons["Auto Win"].BackgroundColor3 = Themes.AccentBlueBg
    TabButtons["Auto Win"].TextColor3 = Themes.AccentBlue
    Tabs["Auto Win"].Visible = true
end

print("══════════════════════════════════════════════════════")
print("[SUPERHERO EVOLUTION HUB] Carregado com Sucesso!")
print("Recursos: Auto Click (0.1s a 10s), Auto Rebirth, Auto Win com Pad Alvo e Pausa, Auto Endless (Mundo 10 padrão, parado até morrer), Config (Salvar, Anti-AFK, Auto Recompensas, Auto Fechar Pop-ups Robux clicando fora).")
print("Pressione 'K' para Minimizar / Abrir a interface.")
print("══════════════════════════════════════════════════════")
