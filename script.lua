--[[
    ==============================================================
    SUPERHERO EVOLUTION HUB - AUTO EDITION V2.0
    Game: +1 Superhero Evolution (PVP)
    Tecla 'K' para Minimizar / Abrir
    
    Automações Otimizadas:
       • ⚡ Auto Click (Zero FPS Drop - Otimização de Busca & Cliques Desacoplados)
       • 🔄 Auto Rebirth (Com Delay Slider & Estatísticas em Tempo Real)
       • 🏆 Auto Farm Win (Deslize Suave pelos Estágios, Espera 0.5s e Parada no Pad Alvo)
       • 🌀 Auto Endless (CO-OP Sem Fim, Auto Portal, Hold Seguro, Auto Hop)
       • 🛡️ Anti-AFK Silencioso
    ==============================================================
]]

local SCRIPT_VERSION_TIMESTAMP = 1791081104

-- Anti Multiple Instances Protection
local function destroyExistingHubs()
    for _, parent in ipairs({gethui and gethui(), (game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")), game:GetService("CoreGui")}) do
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

-- Cleanup ghost listeners
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

-- Roblox Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Game Remotes
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

-- Hub Configuration
local Config = {
    -- 1. Auto Click (Otimizado sem queda de FPS)
    FastClick = false,
    ClickCPS = 10,
    ClicksCount = 0,
    
    -- 2. Auto Rebirth
    AutoRebirth = false,
    RebirthDelay = 1.5,
    RebirthsCount = 0,
    
    -- 3. Auto Win (Progressão & Estágios - Padrão Mundo 10, Estágio 150, 0.5s de espera)
    SelectedProgWorld = "world10",
    SelectedProgStage = "Stage150",
    AutoWin = false,
    CombatTime = 0.5,
    WinGlideSpeed = 75,
    WinsCount = 0,
    
    -- 4. Auto Endless (CO-OP Sem Fim)
    AutoEndless = false,
    EndlessWorld = "current",
    AutoHopBlocked = false,
    
    -- Utilitários, Pop-ups & Recompensas
    AutoClosePopups = true, -- Auto fechar pop-ups de Robux / Reanimação e telas
    AutoClaimPlaytime = true, -- Auto resgatar recompensas de tempo de jogo
    AntiAfk = true,
    
    -- 5. Salvamento de Estado & Server Hop
    AutoSaveConfig = true,
}

getgenv().SuperHeroEvolutionHubConfig = Config

-- ══════════════════════════════════════════════════════════════
-- SISTEMA DE PERSISTÊNCIA DE CONFIGURAÇÕES & ESTADO
-- ══════════════════════════════════════════════════════════════
local CONFIG_FILE = "SuperHeroEvolution_Config.json"
local ConfigRestoredAfterHop = false

local function saveConfig()
    pcall(function()
        if Config.AutoSaveConfig == false then return end
        if not (writefile and HttpService) then return end
        local state = {
            FastClick = Config.FastClick,
            ClickCPS = Config.ClickCPS,
            AutoRebirth = Config.AutoRebirth,
            RebirthDelay = Config.RebirthDelay,
            SelectedProgWorld = Config.SelectedProgWorld,
            SelectedProgStage = Config.SelectedProgStage,
            AutoWin = Config.AutoWin,
            CombatTime = Config.CombatTime,
            WinGlideSpeed = Config.WinGlideSpeed,
            AutoEndless = Config.AutoEndless,
            EndlessWorld = Config.EndlessWorld,
            AutoHopBlocked = Config.AutoHopBlocked,
            AutoClosePopups = Config.AutoClosePopups,
            AutoClaimPlaytime = Config.AutoClaimPlaytime,
            AntiAfk = Config.AntiAfk,
            AutoSaveConfig = Config.AutoSaveConfig,
            SavedAt = os.time(),
        }
        writefile(CONFIG_FILE, HttpService:JSONEncode(state))
    end)
end

local function loadConfig()
    local ok = pcall(function()
        local data = nil
        -- 1. Verifica se veio do Server Hop na memória global (100% garantido sem depender de I/O de disco)
        if getgenv().SavedHopConfig and type(getgenv().SavedHopConfig) == "string" and #getgenv().SavedHopConfig > 5 then
            local s, d = pcall(function() return HttpService:JSONDecode(getgenv().SavedHopConfig) end)
            if s and type(d) == "table" then
                data = d
            end
        end
        
        -- 2. Se não veio da memória, carrega do arquivo salvo no disco
        if not data and readfile and isfile and isfile(CONFIG_FILE) and HttpService then
            local raw = readfile(CONFIG_FILE)
            if raw and #raw >= 5 then
                local s, d = pcall(function() return HttpService:JSONDecode(raw) end)
                if s and type(d) == "table" then
                    data = d
                end
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

-- Carrega o estado salvo imediatamente para reativar as funções ativas pós-Server Hop
loadConfig()

-- Tabelas de Mundos
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

local EndlessWorldsList = {
    {Id = "current", Name = "Mundo Atual / Mais Próximo"},
    {Id = "world10", Name = "Mundo 10"},
    {Id = "world9", Name = "Mundo 9"},
    {Id = "world8", Name = "Mundo 8"},
    {Id = "world7", Name = "Mundo 7"},
    {Id = "world6", Name = "Mundo 6"},
    {Id = "world5", Name = "Mundo 5"},
    {Id = "world4", Name = "Mundo 4"},
    {Id = "world3", Name = "Mundo 3"},
    {Id = "world2", Name = "Mundo 2"}
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

-- Threads & Connections Tracker
local ActiveThreads = {}
local ActiveConnections = {}

local function spawnThread(func)
    local thread = task.spawn(func)
    table.insert(ActiveThreads, thread)
    return thread
end

-- Teleport Helpers & Execução Automática Pós-Server Hop
local function queueScriptOnTeleport()
    pcall(function()
        saveConfig()
        local state = {
            FastClick = Config.FastClick,
            ClickCPS = Config.ClickCPS,
            AutoRebirth = Config.AutoRebirth,
            RebirthDelay = Config.RebirthDelay,
            SelectedProgWorld = Config.SelectedProgWorld,
            SelectedProgStage = Config.SelectedProgStage,
            AutoWin = Config.AutoWin,
            CombatTime = Config.CombatTime,
            WinGlideSpeed = Config.WinGlideSpeed,
            AutoEndless = Config.AutoEndless,
            EndlessWorld = Config.EndlessWorld,
            AutoHopBlocked = Config.AutoHopBlocked,
            AutoClosePopups = Config.AutoClosePopups,
            AutoClaimPlaytime = Config.AutoClaimPlaytime,
            AntiAfk = Config.AntiAfk,
            AutoSaveConfig = Config.AutoSaveConfig,
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
                        elseif readfile and isfile and isfile("hub.lua") then
                            loadstring(readfile("hub.lua"))()
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
    local tpConn = LocalPlayer.OnTeleport:Connect(function()
        saveConfig()
        queueScriptOnTeleport()
    end)
    table.insert(ActiveConnections, tpConn)
end)

pcall(function()
    local pConn = Players.PlayerRemoving:Connect(function(p)
        if p == LocalPlayer then
            saveConfig()
        end
    end)
    table.insert(ActiveConnections, pConn)
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

-- Auto Reconnect se desconectar
pcall(function()
    local guiService = game:GetService("GuiService")
    local reconnectConn = guiService.ErrorMessageChanged:Connect(function()
        task.wait(1.5)
        queueScriptOnTeleport()
        serverHop()
    end)
    table.insert(ActiveConnections, reconnectConn)
end)

-- Anti-AFK Silencioso
table.insert(ActiveConnections, LocalPlayer.Idled:Connect(function()
    if Config.AntiAfk then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
        end)
    end
end))

-- ══════════════════════════════════════════════════════════════
-- MOTOR DE BLOQUEIO E FECHAMENTO DE POP-UPS EM SEGUNDO PLANO
-- ══════════════════════════════════════════════════════════════
local MarketplaceService = game:GetService("MarketplaceService")

-- 1. Hook Preventivo: Bloqueia chamadas de compra de Robux antes que o pop-up sequer apareça na tela
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
        if MarketplaceService.PromptBundlePurchase then
            local oldPBP = MarketplaceService.PromptBundlePurchase
            hookfunction(MarketplaceService.PromptBundlePurchase, newcclosure(function(self, ...)
                if Config.AutoClosePopups then return end
                return oldPBP(self, ...)
            end))
        end
        if MarketplaceService.PromptPremiumPurchase then
            local oldPMP = MarketplaceService.PromptPremiumPurchase
            hookfunction(MarketplaceService.PromptPremiumPurchase, newcclosure(function(self, ...)
                if Config.AutoClosePopups then return end
                return oldPMP(self, ...)
            end))
        end
    end
end)

-- 2. Fechamento forçado e assíncrono de PurchasePrompt remanescente no CoreGui
local function closeRobloxPurchasePrompt()
    pcall(function()
        local coreGui = game:GetService("CoreGui")
        local vim = game:GetService("VirtualInputManager")
        
        local candidates = {}
        local ppa = coreGui:FindFirstChild("PurchasePromptApp")
        if ppa and ppa.Enabled then 
            table.insert(candidates, ppa) 
        end
        local pp = coreGui:FindFirstChild("PurchasePrompt")
        if pp and pp.Enabled then 
            table.insert(candidates, pp) 
        end
        local rbxGui = coreGui:FindFirstChild("RobloxGui")
        if rbxGui then
            local rbxPP = rbxGui:FindFirstChild("PurchasePrompt")
            if rbxPP and rbxPP.Enabled then 
                table.insert(candidates, rbxPP) 
            end
        end
        for _, ch in ipairs(coreGui:GetChildren()) do
            local chName = ch.Name:lower()
            if (chName:find("purchase") or chName:find("prompt")) and ch ~= ppa and ch ~= pp then
                if ch:IsA("ScreenGui") and ch.Enabled then
                    table.insert(candidates, ch)
                end
            end
        end
        
        local activePrompt = false
        local buttonsToClick = {}
        
        for _, container in ipairs(candidates) do
            for _, desc in ipairs(container:GetDescendants()) do
                if desc:IsA("GuiObject") and desc.Visible and desc.AbsoluteSize.X > 40 and desc.AbsoluteSize.Y > 40 then
                    activePrompt = true
                    
                    if desc:IsA("GuiButton") then
                        local name = desc.Name:lower()
                        local text = (desc:IsA("TextButton") and desc.Text:lower()) or ""
                        
                        -- NUNCA clica no botão de confirmação de compra de Robux!
                        local isConfirmBuy = name:find("buy") or name:find("purchase") or name:find("confirm")
                            or text:find("comprar") or text:find("buy") or text:find("purchase")
                            
                        if not isConfirmBuy then
                            local isClose = false
                            
                            -- 1. Nome ou texto típico de fechar / cancelar / 'X'
                            if name:find("close") or name:find("cancel") or name:find("dismiss") or name == "x" 
                                or text == "x" or text == "✕" or text == "×" or text:find("cancel") or text:find("fechar") then
                                isClose = true
                            end
                            
                            -- 2. ImageButton com ícone de fechar / cross
                            if not isClose and desc:IsA("ImageButton") then
                                local img = desc.Image:lower()
                                if img:find("close") or img:find("cancel") or img:find("cross") or img:find("x") then
                                    isClose = true
                                end
                            end
                            
                            -- 3. Botão no cabeçalho superior do modal (exatamente onde fica o 'X' na janela)
                            if not isClose then
                                local parentFrame = desc.Parent
                                if parentFrame and parentFrame:IsA("GuiObject") then
                                    local relY = math.abs(desc.AbsolutePosition.Y - parentFrame.AbsolutePosition.Y)
                                    if relY <= 70 and desc.AbsoluteSize.X <= 60 and desc.AbsoluteSize.Y <= 60 then
                                        isClose = true
                                    end
                                end
                            end
                            
                            if isClose then
                                table.insert(buttonsToClick, desc)
                            end
                        end
                    end
                end
            end
            
            -- Oculta o container imediatamente
            if activePrompt then
                pcall(function() container.Enabled = false end)
            end
        end
        
        -- Clica nos botões de fechar instantaneamente (firesignal) sem nenhum yield
        for _, btn in ipairs(buttonsToClick) do
            pcall(function()
                if firesignal then
                    firesignal(btn.Activated)
                    firesignal(btn.MouseButton1Click)
                end
            end)
            -- Simulação de mouse em thread assíncrona isolada em segundo plano
            pcall(function()
                local center = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
                task.spawn(function()
                    if vim then
                        vim:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
                        task.wait(0.03)
                        vim:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
                    elseif VirtualUser then
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(center)
                    end
                end)
            end)
        end
        
        -- Envia tecla Escape apenas se um prompt ativo foi realmente encontrado, em thread assíncrona
        if activePrompt and vim then
            task.spawn(function()
                vim:SendKeyEvent(true, Enum.KeyCode.Escape, false, game)
                task.wait(0.03)
                vim:SendKeyEvent(false, Enum.KeyCode.Escape, false, game)
            end)
        end
    end)
end

-- 3. Fechamento de Telas e Pop-ups In-Game (Revive, Ofertas, Promoções)
local function closeGamePopups()
    pcall(function()
        local pgui = LocalPlayer:FindFirstChild("PlayerGui")
        if not pgui then return end
        
        -- 1. Fecha Popup de Reanimação (Revive) nativo do jogo
        local screenGui = pgui:FindFirstChild("ScreenGui")
        if screenGui then
            local revive = screenGui:FindFirstChild("Revive")
            if revive and revive.Visible then
                revive.Visible = false
                local cancelBtn = revive:FindFirstChild("Cancel", true) 
                    or revive:FindFirstChild("No", true) 
                    or revive:FindFirstChild("Close", true)
                if cancelBtn and cancelBtn:IsA("GuiButton") then
                    pcall(function()
                        if firesignal then
                            firesignal(cancelBtn.Activated)
                            firesignal(cancelBtn.MouseButton1Click)
                        end
                    end)
                end
            end
        end
        
        -- 2. Fecha pop-ups de ofertas promocionais ou telas invasivas
        for _, gui in ipairs(pgui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and not gui.Name:match("^SuperHeroEvolutionHub") then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc:IsA("Frame") and desc.Visible and desc.AbsoluteSize.X > 150 and desc.AbsoluteSize.Y > 150 then
                        local fName = desc.Name:lower()
                        if (fName:find("offer") or fName:find("popup") or fName:find("prompt") 
                            or fName:find("special") or fName:find("pack")) and not (fName:find("playtime") or fName:find("gift")) then
                            for _, child in ipairs(desc:GetChildren()) do
                                if child:IsA("GuiButton") and child.Visible then
                                    local bName = child.Name:lower()
                                    local bText = (child:IsA("TextButton") and child.Text:lower()) or ""
                                    if bName:find("close") or bName:find("cancel") or bName:find("exit") or bName == "x"
                                        or bText == "x" or bText == "✕" or bText == "×" or bText:find("fechar") then
                                        pcall(function()
                                            if firesignal then
                                                firesignal(child.Activated)
                                                firesignal(child.MouseButton1Click)
                                            end
                                        end)
                                    end
                                end
                            end
                            desc.Visible = false
                        end
                    end
                end
            end
        end
    end)
end

-- 4. Motor em Segundo Plano (Totalmente Assíncrono e Não Bloqueante)
local isClosingBackground = false

local function runAutoClosePopups()
    if not Config.AutoClosePopups then return end
    if isClosingBackground then return end
    isClosingBackground = true
    
    -- Executa completamente em segundo plano via task.spawn para nunca travar ou atrasar outras threads
    task.spawn(function()
        pcall(closeRobloxPurchasePrompt)
        pcall(closeGamePopups)
        isClosingBackground = false
    end)
end

-- Daemon em segundo plano que roda continuamente
spawnThread(function()
    while true do
        if Config.AutoClosePopups then
            pcall(runAutoClosePopups)
        end
        task.wait(0.12) -- Intervalo ágil em segundo plano (8 verificações por segundo)
    end
end)

-- Gatilhos reativos em segundo plano por evento para fechamento instantâneo
pcall(function()
    local coreGui = game:GetService("CoreGui")
    local conn = coreGui.DescendantAdded:Connect(function(desc)
        if Config.AutoClosePopups then
            local p = desc.Parent
            local pName = (p and p.Name:lower()) or ""
            if pName:find("purchase") or pName:find("prompt") then
                task.spawn(runAutoClosePopups)
            end
        end
    end)
    table.insert(ActiveConnections, conn)
end)

pcall(function()
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    if pgui then
        local conn = pgui.DescendantAdded:Connect(function(desc)
            if Config.AutoClosePopups and (desc.Name == "Revive" or desc.Name:lower():find("offer")) then
                task.spawn(runAutoClosePopups)
            end
        end)
        table.insert(ActiveConnections, conn)
    end
end)

-- ══════════════════════════════════════════════════════════════
-- MOTOR DE AUTO RESGATE DE RECOMPENSAS DE TEMPO DE JOGO
-- ══════════════════════════════════════════════════════════════
local function claimPlaytimeRewards()
    if not Config.AutoClaimPlaytime then return end
    
    pcall(function()
        -- 1. Varredura e ativação nos botões da interface (PlayerGui)
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
                            
                            if isClaimable then
                                if firesignal then
                                    firesignal(desc.Activated)
                                    firesignal(desc.MouseButton1Click)
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- 2. Disparo de Remotes no ReplicatedStorage (Shared.Remotes e raiz)
        local candidateFolders = {}
        if Remotes then table.insert(candidateFolders, Remotes) end
        local sharedObj = ReplicatedStorage:FindFirstChild("Shared")
        if sharedObj then
            local sRems = sharedObj:FindFirstChild("Remotes") or sharedObj:FindFirstChild("Events")
            if sRems and sRems ~= Remotes then table.insert(candidateFolders, sRems) end
        end
        local rootRems = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Events")
        if rootRems and rootRems ~= Remotes then table.insert(candidateFolders, rootRems) end
        
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

-- Thread contínua para auto-resgatar recompensas de tempo a cada 3.0 segundos
spawnThread(function()
    while true do
        if Config.AutoClaimPlaytime then
            claimPlaytimeRewards()
        end
        task.wait(3.0)
    end
end)

-- Cache inteligente de mapa para eliminar quedas de FPS
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

-- ══════════════════════════════════════════════════════════════
-- ESTRUTURA DOS ESTÁGIOS (MUNDO 9 E OUTROS MUNDOS)
-- ══════════════════════════════════════════════════════════════

-- Encontra o Pad Livre (Free) do estágio conforme a hierarquia do jogo: Stage > Pad > Free
local function getStageFreePad(stageInstance)
    if not stageInstance then return nil end
    local padFolder = stageInstance:FindFirstChild("Pad")
    if not padFolder then return nil end
    
    -- 1. Busca direta dentro de Pad.Free (suporta Model e sub-hierarquias)
    local free = padFolder:FindFirstChild("Free")
    if free then
        if free:IsA("BasePart") then return free end
        local p = free:FindFirstChild("Pad", true) or free.PrimaryPart or free:FindFirstChildWhichIsA("BasePart", true)
        if p then return p end
    end
    
    -- 2. Busca direta por parte chamada Pad
    local direct = padFolder:FindFirstChild("Pad", true)
    if direct and direct:IsA("BasePart") then return direct end
    
    -- 3. Busca por qualquer filho com 'free' no nome
    for _, child in ipairs(padFolder:GetChildren()) do
        if child.Name:lower():find("free") then
            if child:IsA("BasePart") then return child end
            local p = child:FindFirstChildWhichIsA("BasePart", true)
            if p then return p end
        end
    end
    
    return padFolder:FindFirstChildWhichIsA("BasePart", true)
end

-- Encontra a posição exata da área de combate / monstros de cada estágio (Stage > EnemySpawns)
local function getStageCombatPosition(stageInstance)
    if not stageInstance then return nil end
    
    -- 1. Posição média do folder EnemySpawns (exatamente onde os monstros ficam)
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
            return (totalPos / count) + Vector3.new(0, 1.2, 0)
        end
    end
    
    -- 2. Ponto médio entre o Spawn do jogador e o Gate / Pad
    local spawnObj = stageInstance:FindFirstChild("Spawn")
    local spawnPos = spawnObj and (spawnObj:IsA("BasePart") and spawnObj.Position or (spawnObj:IsA("Model") and spawnObj:GetPivot().Position))
    local gateObj = stageInstance:FindFirstChild("Gate") or stageInstance:FindFirstChild("Barrier")
    local gatePos = gateObj and (gateObj:IsA("BasePart") and gateObj.Position or (gateObj:IsA("Model") and gateObj:GetPivot().Position))
    local pad = getStageFreePad(stageInstance)
    local padPos = pad and pad.Position
    
    local endPoint = gatePos or padPos
    if spawnPos and endPoint then
        return (spawnPos + endPoint) * 0.5 + Vector3.new(0, 1.2, 0)
    end
    
    if padPos then
        return padPos - Vector3.new(0, 0, 30)
    end
    
    return stageInstance:IsA("Model") and stageInstance:GetPivot().Position or nil
end

-- Encontra a saída / Gate do estágio para avançar sem tocar no Pad intermediário
local function getStageGatePosition(stageInstance)
    if not stageInstance then return nil end
    local gate = stageInstance:FindFirstChild("Gate") or stageInstance:FindFirstChild("Barrier")
    if gate then
        return gate:IsA("BasePart") and gate.Position or (gate:IsA("Model") and gate:GetPivot().Position)
    end
    local pad = getStageFreePad(stageInstance)
    if pad then return pad.Position end
    return nil
end

-- Detecção otimizada de sacos de pancada de treino
local cachedHitboxList = {}
local lastHitboxMapCheck = 0

local function isPaidOrRobuxZone(inst)
    if not inst then return false end
    local hb = inst:FindFirstChild("Hitbox")
    local bb = hb and hb:FindFirstChild("TrainingZoneBillboard")
    if bb then
        local gp = bb:FindFirstChild("GamepassRequirement")
        if gp and gp.Visible then return true end
    end
    if inst:GetAttribute("IsRobux") == true or inst:GetAttribute("GamepassId") then return true end
    return false
end

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
    for _, extra in ipairs({"Map", "MapTest"}) do
        local m = workspace:FindFirstChild(extra)
        if m and m ~= curMap then
            local tz = m:FindFirstChild("TrainingZone") or m:FindFirstChild("TrainingZones") or m:FindFirstChild("Zones")
            if tz then table.insert(containers, tz) end
            table.insert(containers, m)
        end
    end
    
    for _, container in ipairs(containers) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("Model") and not isPaidOrRobuxZone(child) then
                    local hb = child:FindFirstChild("Hitbox") or child:FindFirstChild("PunchingBag")
                    if hb and hb:IsA("BasePart") then
                        table.insert(cachedHitboxList, hb)
                    end
                elseif child:IsA("BasePart") and (child.Name == "Hitbox" or child.Name == "PunchingBag") then
                    if not isPaidOrRobuxZone(child) then
                        table.insert(cachedHitboxList, child)
                    end
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

-- UI Elements Globais
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
local EndlessReviveToggle = nil
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
-- 1. MOTOR DO AUTO CLICK OTIMIZADO (ZERO QUEDA DE FPS)
-- ══════════════════════════════════════════════════════════════
local currentTargetBag = nil
local currentTargetEnemy = nil

-- Thread 1: Rastreador de alvos desacoplado (roda a cada 0.6s, NUNCA dentro do loop rápido)
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
                
                -- 1. Verifica saco de pancada de treino próximo (< 35 studs)
                local bestBag = nil
                local hitboxes = getTrainingHitboxList()
                for _, hb in ipairs(hitboxes) do
                    if hb and hb.Parent and (hb.Position - pPos).Magnitude < 35 then
                        bestBag = hb
                        break
                    end
                end
                currentTargetBag = bestBag
                
                -- 2. Se não estiver perto de saco de treino, procura inimigo próximo
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

-- Thread 2: Disparo de Cliques Rápido e Ultra Leve (100% livre de varreduras pesadas de hierarchy)
spawnThread(function()
    local lastTouchInterest = 0
    local lastVirtualClick = 0
    local lastStatsUpdate = 0
    
    while true do
        if Config.FastClick then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if char and hum and hum.Health > 0 and hrp then
                local now = os.clock()
                
                -- Aciona saco de pancada se estiver presente
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
                
                -- Dispara remotes nativos do jogo
                if RemoteRequestAttack then RemoteRequestAttack:FireServer() end
                if RemotePlayerClick then RemotePlayerClick:FireServer() end
                
                -- Clique virtual desacoplado para animar sem sobrecarregar a fila de UI
                if now - lastVirtualClick >= 0.15 then
                    lastVirtualClick = now
                    pcall(function()
                        VirtualUser:ClickButton1(Vector2.new(100, 100))
                    end)
                end
                
                Config.ClicksCount = Config.ClicksCount + 1
                
                -- Atualização visual controlada
                if now - lastStatsUpdate >= 0.35 then
                    lastStatsUpdate = now
                    if ClickStatsCard and ClickStatsCard.Update then
                        ClickStatsCard.Update("Clicks: " .. Config.ClicksCount, Color3.fromRGB(56, 122, 255))
                    end
                end
            end
        end
        local cps = math.clamp(Config.ClickCPS or 10, 1, 50)
        task.wait(1 / cps)
    end
end)

-- ══════════════════════════════════════════════════════════════
-- 2. MOTOR DO AUTO REBIRTH
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
        task.wait(Config.RebirthDelay or 1.5)
    end
end)

-- ══════════════════════════════════════════════════════════════
-- 3. MOTOR DO AUTO WIN (DESLIZE, COMBATE E PARADA NO PAD ALVO)
-- ══════════════════════════════════════════════════════════════
local LockedPads = {}
local OriginalPadCFrames = {}

local function lockPadStationary(pad)
    if not pad or not pad:IsA("BasePart") or LockedPads[pad] then return end
    LockedPads[pad] = true
    local free = pad.Parent
    local basePart = free and (free:FindFirstChild("Part") or free:FindFirstChildWhichIsA("BasePart"))
    local groundY = (basePart and basePart:IsA("BasePart") and basePart ~= pad) and (basePart.Position.Y + 0.4) or pad.Position.Y
    local targetCF = pad.CFrame
    if basePart and pad.Position.Y > basePart.Position.Y + 1.0 then
        targetCF = CFrame.new(pad.Position.X, groundY, pad.Position.Z) * (pad.CFrame - pad.Position)
        pad.CFrame = targetCF
    end
    OriginalPadCFrames[pad] = targetCF
    pad.CanCollide = false
    pad.Anchored = true
    
    local conn = pad:GetPropertyChangedSignal("CFrame"):Connect(function()
        if pad and pad.Parent then
            local orig = OriginalPadCFrames[pad]
            if orig and (pad.CFrame.Position - orig.Position).Magnitude > 0.02 then
                pad.CFrame = orig
                pad.Velocity = Vector3.zero
                pad.RotVelocity = Vector3.zero
            end
        end
    end)
    table.insert(ActiveConnections, conn)
end

-- Deslize plano e fluido com no-clip contínuo (elimina stutter e colisões indesejadas)
local function glideToCFrame(targetCFrame, speed, attackWhileMoving)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end
    
    local activeSpeed = Config.WinGlideSpeed or speed or 75
    if hum then hum.WalkSpeed = activeSpeed end
    
    local targetPos = targetCFrame.Position
    local startPos = hrp.Position
    local totalDist = (targetPos - startPos).Magnitude
    if totalDist < 0.3 then
        hrp.CFrame = targetCFrame
        return true
    end
    
    local ncConn = RunService.Stepped:Connect(function()
        if char then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end)
    
    local lastAttackTick = 0
    local t0 = os.clock()
    local maxDuration = math.max((totalDist / activeSpeed) + 1.2, 0.35)
    local reached = false
    
    while Config.AutoWin and not Config.AutoEndless do
        local dt = RunService.Heartbeat:Wait()
        char = LocalPlayer.Character
        hum = char and char:FindFirstChildOfClass("Humanoid")
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not hum or hum.Health <= 0 then break end
        
        local currentPos = hrp.Position
        local toTarget = targetPos - currentPos
        local distRemaining = toTarget.Magnitude
        local step = activeSpeed * dt
        
        if attackWhileMoving and (os.clock() - lastAttackTick >= 0.05) then
            lastAttackTick = os.clock()
            if RemoteRequestAttack then RemoteRequestAttack:FireServer() end
            if RemotePlayerClick then RemotePlayerClick:FireServer() end
        end
        
        if distRemaining <= math.max(step * 1.15, 0.35) or (os.clock() - t0 >= maxDuration) then
            hrp.CFrame = targetCFrame
            reached = true
            break
        else
            local moveDir = toTarget.Unit
            local nextPos = currentPos + (moveDir * step)
            local flatDir = Vector3.new(moveDir.X, 0, moveDir.Z)
            if flatDir.Magnitude > 0.05 then
                local lookRot = CFrame.lookAt(nextPos, nextPos + flatDir)
                hrp.CFrame = hrp.CFrame:Lerp(lookRot, math.clamp(dt * 15, 0.08, 1.0))
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
        if oldChar then
            oldChar:BreakJoints()
        end
    end)
    local t0 = os.clock()
    while os.clock() - t0 < 10 do
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if c and h and h.Health > 0 and r and (c ~= oldChar or os.clock() - t0 > 3.0) then break end
        task.wait(0.15)
    end
    task.wait(0.8)
end

-- Executa o farm do estágio com tempo de espera configurável (0.5s padrão) e parada no Pad alvo
local function farmStage(stage, isFinalTargetStage, stagesList)
    if not stage or not Config.AutoWin or Config.AutoEndless then return false, "cancelled" end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false, "dead" end
    
    -- 1. Garante que o jogador está no mapa correspondente
    local stageMap = stage.Parent and stage.Parent.Parent
    if stageMap and stageMap.Name:match("^Map") then
        local curMap = getCurrentMap()
        if not curMap or curMap.Name ~= stageMap.Name then
            for _, w in ipairs(WorldsData) do
                if w.MapName == stageMap.Name and w.WorldNum and RemoteRequestWorldChange then
                    pcall(function() RemoteRequestWorldChange:InvokeServer(w.WorldNum) end)
                    task.wait(1.5)
                    break
                end
            end
        end
    end
    
    local stagePos = stage:IsA("Model") and stage:GetPivot().Position or (stage:FindFirstChildWhichIsA("BasePart", true) and stage:FindFirstChildWhichIsA("BasePart", true).Position)
    if stagePos and LocalPlayer.RequestStreamAroundAsync then
        pcall(function() LocalPlayer:RequestStreamAroundAsync(stagePos) end)
    end
    
    -- 2. Posição da área de combate (EnemySpawns)
    local combatPos = getStageCombatPosition(stage)
    if not combatPos then return false, "nopos" end
    
    char = LocalPlayer.Character
    hrp = char and char:FindFirstChild("HumanoidRootPart")
    hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false, "dead" end
    if hum then hum.WalkSpeed = Config.WinGlideSpeed or 75 end
    
    -- Desliza com velocidade configurada até a área de combate do estágio (sem teleporte brusco)
    local distToComb = (hrp.Position - combatPos).Magnitude
    if distToComb > 2.0 then
        local okGlide = glideToCFrame(CFrame.new(combatPos), nil, true)
        if not okGlide then return false, "dead" end
    end
    
    if not Config.AutoWin or Config.AutoEndless then return false, "cancelled" end
    
    -- 3. Para no estágio e luta durante o Tempo de Espera (0.5s padrão)
    -- "deixe com tempo de espera de 0,5 seg para cada estagio"
    -- "e no ultimo estagio faz parar no estagio antes de ir para o pad"
    local waitDuration = math.max(0.05, Config.CombatTime or 0.5)
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
    
    if not Config.AutoWin or Config.AutoEndless then return false, "cancelled" end
    
    -- 4. Tratamento do Pad
    -- Se for o ÚLTIMO estágio selecionado: agora sim desliza até o Pad (Free) e confirma a vitória!
    -- Se for estágio intermediário: avança para a saída/Gate sem tocar no Pad.
    if isFinalTargetStage then
        local targetPad = getStageFreePad(stage)
        if targetPad then
            lockPadStationary(targetPad)
            local padTargetCF = targetPad.CFrame + Vector3.new(0, 1.0, 0)
            local okPad = glideToCFrame(padTargetCF, nil, true)
            if not okPad then return false, "dead" end
            
            if firetouchinterest then
                firetouchinterest(hrp, targetPad, 0)
                task.wait(0.02)
                firetouchinterest(hrp, targetPad, 1)
                local foot = char:FindFirstChild("RightFoot") or char:FindFirstChild("Right Leg")
                if foot then
                    firetouchinterest(foot, targetPad, 0)
                    task.wait(0.02)
                    firetouchinterest(foot, targetPad, 1)
                end
            end
            
            local initialWinTime = lastWinCollectedTick
            local initialWinCount = totalWinsCollectedCount
            local initialLeaderWins = nil
            pcall(function()
                local ls = LocalPlayer:FindFirstChild("leaderstats")
                local w = ls and ls:FindFirstChild("Wins")
                if w then initialLeaderWins = w.Value end
            end)
            
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
                
                local currentLeaderWins = nil
                pcall(function()
                    local ls = LocalPlayer:FindFirstChild("leaderstats")
                    local w = ls and ls:FindFirstChild("Wins")
                    if w then currentLeaderWins = w.Value end
                end)
                
                if totalWinsCollectedCount > initialWinCount 
                    or lastWinCollectedTick > initialWinTime 
                    or (initialLeaderWins and currentLeaderWins and currentLeaderWins ~= initialLeaderWins)
                    or (hrp and (hrp.Position - targetPad.Position).Magnitude > 40) then
                    break
                end
                task.wait(0.05)
            end
        end
    else
        -- Estágio intermediário: desliza suavemente até o Gate para entrar no próximo estágio
        local gatePos = getStageGatePosition(stage)
        if gatePos then
            local distToGate = (hrp.Position - gatePos).Magnitude
            if distToGate > 1.5 and distToGate < 80 then
                glideToCFrame(CFrame.new(gatePos + Vector3.new(0, 1.2, 0)), nil, true)
            end
        end
    end
    
    return true, "ok"
end

local function ensurePlayerInWorld(worldNum, mapName)
    if not worldNum or not RemoteRequestWorldChange then return end
    pcall(function()
        local currentMap = getCurrentMap()
        if not currentMap or currentMap.Name ~= mapName then
            RemoteRequestWorldChange:InvokeServer(worldNum)
            task.wait(1.5)
        end
    end)
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
        task.wait(0.8)
        return
    end
    
    -- Começa no estágio mais próximo
    local startIndex = 1
    local minDist = math.huge
    for idx, item in ipairs(stagesList) do
        local cPos = getStageCombatPosition(item.Stage)
        if cPos then
            local d = (hrp.Position - cPos).Magnitude
            if d < minDist then
                minDist = d
                startIndex = idx
            end
        end
    end
    
    for i = startIndex, #stagesList do
        if cancelCheck and cancelCheck() then break end
        if not Config.AutoWin or Config.AutoEndless then break end
        
        char = LocalPlayer.Character
        hum = char and char:FindFirstChildOfClass("Humanoid")
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hum or hum.Health <= 0 or not hrp then
            waitForCharacterAlive()
            task.wait(0.8)
            break
        end
        
        local item = stagesList[i]
        local isSelectedStage = (i == #stagesList)
        local success, reason = farmStage(item.Stage, isSelectedStage, stagesList)
        
        char = LocalPlayer.Character
        hum = char and char:FindFirstChildOfClass("Humanoid")
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not success and (reason == "dead" or reason == "stalled") or not hum or hum.Health <= 0 or not hrp then
            waitForCharacterAlive()
            task.wait(0.8)
            break
        end
        
        if isSelectedStage then
            task.wait(0.3)
            local c = LocalPlayer.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            local pad = getStageFreePad(item.Stage)
            if r and pad and (r.Position - pad.Position).Magnitude < 35 then
                resetCharacterAndRecover()
            else
                task.wait(0.4)
            end
            break
        end
    end
end

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
                            ensurePlayerInWorld(wNum, wData.MapName)
                            local mapInstance = workspace:FindFirstChild(wData.MapName)
                            local stagesFolder = mapInstance and mapInstance:FindFirstChild("Stages")
                            farmStagesSequence(stagesFolder, Config.SelectedProgStage, function()
                                return not Config.AutoWin or Config.SelectedProgWorld ~= "all"
                            end)
                        end
                    end
                elseif chosenWorld ~= "current" then
                    local wData = nil
                    for _, w in ipairs(WorldsData) do
                        if w.Id == chosenWorld then wData = w; break end
                    end
                    if wData and wData.WorldNum and wData.MapName then
                        ensurePlayerInWorld(wData.WorldNum, wData.MapName)
                        local mapInstance = workspace:FindFirstChild(wData.MapName)
                        local stagesFolder = mapInstance and mapInstance:FindFirstChild("Stages")
                        farmStagesSequence(stagesFolder, Config.SelectedProgStage, function()
                            return not Config.AutoWin or Config.SelectedProgWorld ~= chosenWorld
                        end)
                    end
                else
                    local curMap = getCurrentMap()
                    local stagesFolder = curMap and curMap:FindFirstChild("Stages")
                    if stagesFolder then
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
local endlessDeathTick = 0
local isDeadWaiting = false
local wasInsideEndless = false
local lastJoinAttempt = 0
local outsideArenaStart = os.clock()
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
        if dist < 250 then
            return true
        end
    end
    return false
end

local function getEndlessArenaCenter()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil end
    
    local pPos = hrp.Position
    local targetWorld = nil
    if Config.EndlessWorld and Config.EndlessWorld ~= "current" then
        targetWorld = tonumber(string.match(tostring(Config.EndlessWorld), "%d+"))
    end
    
    if targetWorld and EndlessArenaCenters[targetWorld] then
        local c = EndlessArenaCenters[targetWorld]
        local d = (Vector3.new(pPos.X, 0, pPos.Z) - Vector3.new(c.X, 0, c.Z)).Magnitude
        if d < 350 then
            return c, targetWorld
        end
    end
    
    local closestCenter = nil
    local closestDist = math.huge
    local closestWorld = nil
    for wNum, c in pairs(EndlessArenaCenters) do
        local dist = (Vector3.new(pPos.X, 0, pPos.Z) - Vector3.new(c.X, 0, c.Z)).Magnitude
        if dist < closestDist then
            closestDist = dist
            closestCenter = c
            closestWorld = wNum
        end
    end
    
    if closestCenter and closestDist < 450 then
        return closestCenter, closestWorld
    end
    
    if targetWorld and EndlessArenaCenters[targetWorld] then
        return EndlessArenaCenters[targetWorld], targetWorld
    end
    return closestCenter, closestWorld
end

local function onCharacterLoadedForEndless(char)
    endlessEnteredCFrame = nil
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        local diedConn = hum.Died:Connect(function()
            if Config.AutoEndless then
                endlessDeathTick = os.clock()
                isDeadWaiting = true
                wasInsideEndless = false
                endlessEnteredCFrame = nil
            end
        end)
        table.insert(ActiveConnections, diedConn)
    end
end

if LocalPlayer.Character then onCharacterLoadedForEndless(LocalPlayer.Character) end
local endlessCharConn = LocalPlayer.CharacterAdded:Connect(function(char) onCharacterLoadedForEndless(char) end)
table.insert(ActiveConnections, endlessCharConn)

local function getPortalWorld(p)
    if not p then return nil end
    local attrW = p:GetAttribute("World")
    if type(attrW) == "number" then return attrW end
    local parent = p.Parent
    local map = parent and parent.Parent
    if map then
        if map.Name == "MapTest" then return 2 end
        local num = tonumber(string.match(map.Name, "%d+"))
        if num then return num end
    end
    return nil
end

local function getSelectedEndlessWorldNum()
    local targetWorld = nil
    if Config.EndlessWorld and Config.EndlessWorld ~= "current" then
        targetWorld = tonumber(string.match(tostring(Config.EndlessWorld), "%d+"))
    end
    
    if not targetWorld then
        local curMap = getCurrentMap()
        local curMapName = curMap and curMap.Name or "Map"
        if curMapName == "Map" then
            targetWorld = 2
        elseif curMapName == "MapTest" then
            targetWorld = 2
        else
            targetWorld = tonumber(string.match(curMapName, "%d+")) or 2
        end
    end
    
    if not targetWorld or targetWorld < 2 then targetWorld = 2 end
    if targetWorld > 10 then targetWorld = 10 end
    return targetWorld
end

local function getTargetEndlessPortal(targetWorldNum)
    if not targetWorldNum then targetWorldNum = getSelectedEndlessWorldNum() end
    local targetMapName = (targetWorldNum == 2 and "MapTest") or ("Map" .. tostring(targetWorldNum))
    
    local mapObj = workspace:FindFirstChild(targetMapName)
    local endlessFolder = mapObj and mapObj:FindFirstChild("Endless")
    local portal = endlessFolder and endlessFolder:FindFirstChild("Portal")
    if portal then
        return portal, targetWorldNum
    end
    
    local portals = CollectionService:GetTagged("EndlessPortal")
    for _, p in ipairs(portals) do
        if getPortalWorld(p) == targetWorldNum then
            return p, targetWorldNum
        end
    end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and #portals > 0 then
        local bestPortal = nil
        local minDist = math.huge
        for _, p in ipairs(portals) do
            local hb = p:FindFirstChild("Hitbox")
            if hb and hb:IsA("BasePart") then
                local dist = (hb.Position - hrp.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    bestPortal = p
                end
            end
        end
        if bestPortal then
            return bestPortal, getPortalWorld(bestPortal) or targetWorldNum
        end
    end
    
    return portals[1], targetWorldNum
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
    if Config.EndlessWorld and Config.EndlessWorld ~= "current" and curMapName ~= targetMapName then
        if RemoteRequestWorldChange then
            RemoteRequestWorldChange:InvokeServer(targetWorldNum)
            task.wait(1.5)
            local newChar, newHrp, newHum = waitForCharacterAlive(6)
            if not newHrp or not newHum or newHum.Health <= 0 then return false end
            char = newChar
            hrp = newHrp
            hum = newHum
        end
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

spawnThread(function()
    while true do
        if Config.AutoEndless then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                local reviveGui = pgui and pgui:FindFirstChild("ScreenGui") and pgui.ScreenGui:FindFirstChild("Revive")
                local isReviveActive = (reviveGui and reviveGui.Visible)
                local isDead = (not hum or hum.Health <= 0 or isReviveActive)
                
                if isReviveActive and reviveGui then
                    local cancelBtn = reviveGui:FindFirstChild("Cancel", true)
                    if cancelBtn and cancelBtn:IsA("GuiButton") then
                        pcall(function()
                            if firesignal then
                                firesignal(cancelBtn.Activated)
                                firesignal(cancelBtn.MouseButton1Click)
                            end
                        end)
                    end
                    reviveGui.Visible = false
                end
                runAutoClosePopups()
                
                if isInsideEndless() then
                    wasInsideEndless = true
                end
                
                -- Se morreu ou se a tela de revive do jogo apareceu
                if isDead and not isDeadWaiting then
                    endlessDeathTick = os.clock()
                    isDeadWaiting = true
                    wasInsideEndless = false
                    endlessEnteredCFrame = nil
                end
                
                -- Delay estrito de 14 segundos pós-morte no Endless
                if isDeadWaiting then
                    endlessEnteredCFrame = nil
                    outsideArenaStart = os.clock()
                    local elapsed = os.clock() - endlessDeathTick
                    local remaining = math.max(0, math.ceil(14.0 - elapsed))
                    
                    if elapsed < 14.0 then
                        if EndlessStatsCard and EndlessStatsCard.Update then
                            EndlessStatsCard.Update(string.format("Delay pós-morte: %ds...", remaining), Color3.fromRGB(255, 185, 55))
                        end
                        task.wait(0.25)
                        return
                    else
                        -- Já passaram 14 segundos! Espera o personagem estar 100% vivo e pronto
                        if hum and hum.Health > 0 and hrp and not isReviveActive and not isInsideEndless() then
                            isDeadWaiting = false
                            outsideArenaStart = os.clock()
                            if EndlessStatsCard and EndlessStatsCard.Update then
                                EndlessStatsCard.Update("Delay 14s concluído! Entrando...", Color3.fromRGB(56, 122, 255))
                            end
                        else
                            task.wait(0.25)
                            return
                        end
                    end
                end
                
                if hum and hum.Health > 0 and hrp then
                    if isInsideEndless() then
                        wasInsideEndless = true
                        outsideArenaStart = os.clock()
                        
                        if EndlessStatsCard and EndlessStatsCard.Update then
                            EndlessStatsCard.Update("Dentro da Arena (Seguro)", Color3.fromRGB(46, 204, 113))
                        end
                        
                        -- Focado 100% no Endless: segura a posição de entrada, zero velocidade, sem andar ou teleportar para boss/monstros
                        if not endlessEnteredCFrame then
                            local arenaCenter = getEndlessArenaCenter()
                            if arenaCenter then
                                endlessEnteredCFrame = CFrame.lookAt(hrp.Position, Vector3.new(arenaCenter.X, hrp.Position.Y, arenaCenter.Z))
                            else
                                endlessEnteredCFrame = hrp.CFrame
                            end
                            hrp.CFrame = endlessEnteredCFrame
                        end
                        
                        if endlessEnteredCFrame then
                            local currentPos = hrp.Position
                            local distFromEntry = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(endlessEnteredCFrame.Position.X, 0, endlessEnteredCFrame.Position.Z)).Magnitude
                            
                            if distFromEntry > 2 then
                                hrp.CFrame = endlessEnteredCFrame
                            end
                            
                            hum:Move(Vector3.zero, false)
                            hrp.Velocity = Vector3.zero
                            hrp.RotVelocity = Vector3.zero
                            if hrp.AssemblyLinearVelocity then hrp.AssemblyLinearVelocity = Vector3.zero end
                            if hrp.AssemblyAngularVelocity then hrp.AssemblyAngularVelocity = Vector3.zero end
                        else
                            hrp.Velocity = Vector3.zero
                            hrp.RotVelocity = Vector3.zero
                        end
                    else
                        endlessEnteredCFrame = nil
                        if EndlessStatsCard and EndlessStatsCard.Update then
                            EndlessStatsCard.Update("Entrando no Portal...", Color3.fromRGB(56, 122, 255))
                        end
                        if Config.AutoHopBlocked and (os.clock() - outsideArenaStart > 60) then
                            outsideArenaStart = os.clock()
                            serverHop()
                            return
                        end
                        if os.clock() - lastJoinAttempt > 2.0 then
                            lastJoinAttempt = os.clock()
                            enterEndlessPortal()
                        end
                    end
                end
            end)
        else
            isDeadWaiting = false
            endlessEnteredCFrame = nil
            outsideArenaStart = os.clock()
        end
        task.wait(0.15)
    end
end)

-- ══════════════════════════════════════════════════════════════
-- 5. DESIGN SYSTEM & INTERFACE VISUAL
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
    Background = Color3.fromRGB(15, 17, 24),
    Header = Color3.fromRGB(20, 23, 33),
    Sidebar = Color3.fromRGB(17, 20, 29),
    Card = Color3.fromRGB(24, 28, 40),
    CardBorder = Color3.fromRGB(42, 48, 70),
    Accent1 = Color3.fromRGB(135, 80, 255),
    Accent2 = Color3.fromRGB(56, 122, 255),
    Text = Color3.fromRGB(245, 245, 252),
    TextDim = Color3.fromRGB(150, 155, 175),
    Success = Color3.fromRGB(46, 204, 113),
    ToggleInactive = Color3.fromRGB(36, 42, 60),
    Warning = Color3.fromRGB(255, 185, 55),
    Error = Color3.fromRGB(255, 75, 75)
}

-- MiniBar
local MiniBar = Instance.new("Frame")
MiniBar.Name = "MiniBar"
MiniBar.Size = UDim2.new(0, 390, 0, 54)
MiniBar.Position = UDim2.new(0.5, -195, 0.04, 0)
MiniBar.BackgroundColor3 = Themes.Background
MiniBar.BorderSizePixel = 0
MiniBar.Visible = false
MiniBar.Active = true
MiniBar.Parent = ScreenGui

local MiniBarCorner = Instance.new("UICorner")
MiniBarCorner.CornerRadius = UDim.new(0, 27)
MiniBarCorner.Parent = MiniBar

local MiniBarStroke = Instance.new("UIStroke")
MiniBarStroke.Thickness = 1.5
MiniBarStroke.Color = Themes.Accent2
MiniBarStroke.Transparency = 0.2
MiniBarStroke.Parent = MiniBar

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Name = "Avatar"
AvatarImage.Size = UDim2.new(0, 42, 0, 42)
AvatarImage.Position = UDim2.new(0, 6, 0.5, -21)
AvatarImage.BackgroundColor3 = Themes.Card
AvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
AvatarImage.Parent = MiniBar

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = AvatarImage

local AvatarStroke = Instance.new("UIStroke")
AvatarStroke.Thickness = 1.5
AvatarStroke.Color = Themes.Accent2
AvatarStroke.Parent = AvatarImage

local MiniPlayerName = Instance.new("TextLabel")
MiniPlayerName.Name = "PlayerName"
MiniPlayerName.Size = UDim2.new(0, 160, 0, 16)
MiniPlayerName.Position = UDim2.new(0, 56, 0, 9)
MiniPlayerName.BackgroundTransparency = 1
MiniPlayerName.Text = LocalPlayer.DisplayName
MiniPlayerName.TextColor3 = Themes.Text
MiniPlayerName.TextSize = 13
MiniPlayerName.Font = Enum.Font.GothamBold
MiniPlayerName.TextXAlignment = Enum.TextXAlignment.Left
MiniPlayerName.TextTruncate = Enum.TextTruncate.AtEnd
MiniPlayerName.Parent = MiniBar

MiniStats = Instance.new("TextLabel")
MiniStats.Name = "StatsLabel"
MiniStats.Size = UDim2.new(0, 280, 0, 16)
MiniStats.Position = UDim2.new(0, 56, 0, 28)
MiniStats.BackgroundTransparency = 1
MiniStats.Text = "FPS: 60 • Ping: 35 ms • Rebirths: 0"
MiniStats.TextColor3 = Themes.TextDim
MiniStats.TextSize = 11
MiniStats.Font = Enum.Font.GothamMedium
MiniStats.TextXAlignment = Enum.TextXAlignment.Left
MiniStats.Parent = MiniBar

local MiniExpandBtn = Instance.new("TextButton")
MiniExpandBtn.Name = "ExpandBtn"
MiniExpandBtn.Size = UDim2.new(0, 36, 0, 36)
MiniExpandBtn.Position = UDim2.new(1, -44, 0.5, -18)
MiniExpandBtn.BackgroundColor3 = Themes.Card
MiniExpandBtn.Text = "[]"
MiniExpandBtn.TextColor3 = Themes.Text
MiniExpandBtn.TextSize = 13
MiniExpandBtn.Font = Enum.Font.GothamBold
MiniExpandBtn.AutoButtonColor = false
MiniExpandBtn.Active = true
MiniExpandBtn.Parent = MiniBar

local MiniExpandCorner = Instance.new("UICorner")
MiniExpandCorner.CornerRadius = UDim.new(0, 18)
MiniExpandCorner.Parent = MiniExpandBtn

local MiniExpandStroke = Instance.new("UIStroke")
MiniExpandStroke.Thickness = 1
MiniExpandStroke.Color = Themes.CardBorder
MiniExpandStroke.Parent = MiniExpandBtn

-- Janela Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 700, 0, 470)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -235)
MainFrame.BackgroundColor3 = Themes.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Themes.CardBorder
MainStroke.Parent = MainFrame

-- Topbar
local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Size = UDim2.new(1, 0, 0, 56)
Topbar.BackgroundColor3 = Themes.Header
Topbar.BorderSizePixel = 0
Topbar.Active = true
Topbar.Parent = MainFrame

local TopbarCorner = Instance.new("UICorner")
TopbarCorner.CornerRadius = UDim.new(0, 16)
TopbarCorner.Parent = Topbar

local TopbarLine = Instance.new("Frame")
TopbarLine.Size = UDim2.new(1, 0, 0, 1)
TopbarLine.Position = UDim2.new(0, 0, 1, -1)
TopbarLine.BackgroundColor3 = Themes.CardBorder
TopbarLine.BorderSizePixel = 0
TopbarLine.Parent = Topbar

local HeaderAvatar = Instance.new("ImageLabel")
HeaderAvatar.Name = "HeaderAvatar"
HeaderAvatar.Size = UDim2.new(0, 38, 0, 38)
HeaderAvatar.Position = UDim2.new(0, 14, 0.5, -19)
HeaderAvatar.BackgroundColor3 = Themes.Card
HeaderAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
HeaderAvatar.Parent = Topbar

local HeaderAvatarCorner = Instance.new("UICorner")
HeaderAvatarCorner.CornerRadius = UDim.new(1, 0)
HeaderAvatarCorner.Parent = HeaderAvatar

local HeaderAvatarStroke = Instance.new("UIStroke")
HeaderAvatarStroke.Thickness = 1.5
HeaderAvatarStroke.Color = Themes.Accent2
HeaderAvatarStroke.Parent = HeaderAvatar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(0, 240, 0, 20)
TitleLabel.Position = UDim2.new(0, 62, 0, 10)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ SUPERHERO EVOLUTION"
TitleLabel.TextColor3 = Themes.Text
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Topbar

local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Name = "Subtitle"
SubtitleLabel.Size = UDim2.new(0, 240, 0, 16)
SubtitleLabel.Position = UDim2.new(0, 62, 0, 30)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Text = "Auto Edition | " .. LocalPlayer.DisplayName
SubtitleLabel.TextColor3 = Themes.TextDim
SubtitleLabel.TextSize = 11
SubtitleLabel.Font = Enum.Font.GothamMedium
SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SubtitleLabel.Parent = Topbar

HeaderStats = Instance.new("TextLabel")
HeaderStats.Name = "HeaderStats"
HeaderStats.Size = UDim2.new(0, 240, 0, 26)
HeaderStats.Position = UDim2.new(1, -330, 0.5, -13)
HeaderStats.BackgroundColor3 = Themes.Card
HeaderStats.Text = "FPS: 60 • Ping: 30 ms • Rebirths: 0"
HeaderStats.TextColor3 = Themes.Accent2
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

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
MinimizeBtn.Position = UDim2.new(1, -76, 0.5, -16)
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
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -16)
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
        local tweenOut = TweenService:Create(MainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, 1.2, 0)
        })
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            if isMinimized then
                MainFrame.Visible = false
                MiniBar.Visible = true
                MiniBar.Position = UDim2.new(0.5, -195, -0.15, 0)
                TweenService:Create(MiniBar, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.5, -195, 0.04, 0)
                }):Play()
            end
        end)
    else
        local tweenBarOut = TweenService:Create(MiniBar, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -195, -0.15, 0)
        })
        tweenBarOut:Play()
        tweenBarOut.Completed:Connect(function()
            MiniBar.Visible = false
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, -350, 0.5, -235)
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

-- FPS, Ping e Rebirths na Topbar e MiniBar
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

-- Sidebar & Estrutura de Abas
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 160, 1, -56)
Sidebar.Position = UDim2.new(0, 0, 0, 56)
Sidebar.BackgroundColor3 = Themes.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Active = true
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 16)
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
PageContainer.Size = UDim2.new(1, -160, 1, -56)
PageContainer.Position = UDim2.new(0, 160, 0, 56)
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
    page.ScrollBarImageColor3 = Themes.Accent2
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
                    BackgroundColor3 = Themes.Card,
                    TextColor3 = Themes.Accent2
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
    frame.Name = "Header_" .. text:gsub("%W", "")
    frame.Size = UDim2.new(1, 0, 0, 24)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Position = UDim2.new(0, 2, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(text)
    lbl.TextColor3 = Themes.Accent2
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    return frame
end

local function createLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Name = "Label_" .. text:gsub("%W", "")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.Position = UDim2.new(0, 2, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(160, 168, 195)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function createInfoCard(parent, title, statusText, statusColor, forceColor)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 48)
    card.BackgroundColor3 = Themes.Card
    card.BorderSizePixel = 0
    card.Parent = parent
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Thickness = 1
    cardStroke.Color = Themes.CardBorder
    cardStroke.Parent = card
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.5, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 14, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Themes.Text
    titleLbl.TextSize = 12
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card
    
    local statusBadge = Instance.new("TextLabel")
    statusBadge.Size = UDim2.new(0, 200, 0, 30)
    statusBadge.Position = UDim2.new(1, -214, 0.5, -15)
    statusBadge.BackgroundColor3 = Themes.Header
    statusBadge.Text = statusText
    statusBadge.TextColor3 = forceColor or statusColor or Themes.Success
    statusBadge.TextSize = 11
    statusBadge.Font = Enum.Font.GothamBold
    statusBadge.Parent = card
    
    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 8)
    badgeCorner.Parent = statusBadge
    
    local badgeStroke = Instance.new("UIStroke")
    badgeStroke.Thickness = 1
    badgeStroke.Color = forceColor or statusColor or Themes.Success
    badgeStroke.Transparency = 0.5
    badgeStroke.Parent = statusBadge
    
    return {
        Update = function(newText, newColor)
            statusBadge.Text = newText
            local finalCol = forceColor or newColor or Themes.Success
            statusBadge.TextColor3 = finalCol
            badgeStroke.Color = finalCol
        end
    }
end

local function createToggle(parent, title, defaultState, callback)
    local card = Instance.new("TextButton")
    card.Name = title .. "_Card"
    card.Size = UDim2.new(1, 0, 0, 44)
    card.BackgroundColor3 = Themes.Card
    card.BorderSizePixel = 0
    card.AutoButtonColor = false
    card.Text = ""
    card.Active = true
    card.Parent = parent
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Thickness = 1
    cardStroke.Color = Themes.CardBorder
    cardStroke.Parent = card
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -70, 1, 0)
    titleLbl.Position = UDim2.new(0, 14, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Themes.Text
    titleLbl.TextSize = 12
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card
    
    local toggleBtn = Instance.new("Frame")
    toggleBtn.Size = UDim2.new(0, 46, 0, 24)
    toggleBtn.Position = UDim2.new(1, -58, 0.5, -12)
    toggleBtn.BackgroundColor3 = defaultState and Themes.Success or Themes.ToggleInactive
    toggleBtn.Parent = card
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn
    
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 18, 0, 18)
    thumb.Position = defaultState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    thumb.BackgroundColor3 = Themes.Text
    thumb.BorderSizePixel = 0
    thumb.Parent = toggleBtn
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb
    
    local isEnabled = defaultState
    
    local function updateVisuals()
        local targetPos = isEnabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
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
            if not suppressCallback then
                callback(isEnabled)
            end
        end,
        Get = function() return isEnabled end
    }
end

local function createSlider(parent, title, minVal, maxVal, defaultVal, suffix, isFloat, callback)
    local card = Instance.new("Frame")
    card.Name = title .. "_Slider"
    card.Size = UDim2.new(1, 0, 0, 56)
    card.BackgroundColor3 = Themes.Card
    card.BorderSizePixel = 0
    card.Active = true
    card.Parent = parent
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Thickness = 1
    cardStroke.Color = Themes.CardBorder
    cardStroke.Parent = card
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -90, 0, 24)
    titleLbl.Position = UDim2.new(0, 14, 0, 6)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Themes.Text
    titleLbl.TextSize = 12
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card
    
    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 70, 0, 24)
    valLbl.Position = UDim2.new(1, -84, 0, 6)
    valLbl.BackgroundTransparency = 1
    valLbl.TextColor3 = Themes.Accent2
    valLbl.TextSize = 13
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = card
    
    local track = Instance.new("TextButton")
    track.Name = "SliderTrack"
    track.Size = UDim2.new(1, -28, 0, 6)
    track.Position = UDim2.new(0, 14, 0, 38)
    track.BackgroundColor3 = Color3.fromRGB(30, 36, 52)
    track.BorderSizePixel = 0
    track.Text = ""
    track.AutoButtonColor = false
    track.Parent = card
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Name = "SliderFill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Themes.Accent2
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill
    
    local currentVal = defaultVal
    
    local function updateValue(val, trigger)
        if isFloat then
            currentVal = math.clamp(math.floor(val * 10 + 0.5) / 10, minVal, maxVal)
            valLbl.Text = string.format("%.1f%s", currentVal, suffix or "")
        else
            currentVal = math.clamp(math.floor(val + 0.5), minVal, maxVal)
            valLbl.Text = tostring(currentVal) .. (suffix or "")
        end
        local pct = math.clamp((currentVal - minVal) / (maxVal - minVal), 0, 1)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        if trigger ~= false and callback then
            callback(currentVal)
        end
    end
    
    updateValue(defaultVal, false)
    
    local dragging = false
    local function processInput(input)
        local trackPos = track.AbsolutePosition.X
        local trackWidth = track.AbsoluteSize.X
        if trackWidth <= 0 then return end
        local inputX = input.Position.X
        local pct = math.clamp((inputX - trackPos) / trackWidth, 0, 1)
        local rawVal = minVal + pct * (maxVal - minVal)
        updateValue(rawVal, true)
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            processInput(input)
        end
    end)
    
    local endedConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    table.insert(ActiveConnections, endedConn)
    
    local changedConn = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            processInput(input)
        end
    end)
    table.insert(ActiveConnections, changedConn)
    
    return {
        SetValue = function(v) updateValue(v, true) end,
        GetValue = function() return currentVal end
    }
end

local function createDropdown(parent, title, options, defaultId, onSelected)
    local hasTitle = (title and title ~= "")
    local closedHeight = hasTitle and 68 or 38
    local openHeight = hasTitle and 218 or 188
    
    local container = Instance.new("Frame")
    container.Name = (hasTitle and title or "Dropdown") .. "_Dropdown"
    container.Size = UDim2.new(1, 0, 0, closedHeight)
    container.BackgroundColor3 = Themes.Card
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.Active = true
    container.Parent = parent
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 10)
    containerCorner.Parent = container
    
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Thickness = 1
    containerStroke.Color = Themes.CardBorder
    containerStroke.Parent = container
    
    if hasTitle then
        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -24, 0, 16)
        titleLbl.Position = UDim2.new(0, 14, 0, 6)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = title
        titleLbl.TextColor3 = Themes.TextDim
        titleLbl.TextSize = 11
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Parent = container
    end
    
    local selectBtn = Instance.new("TextButton")
    selectBtn.Size = hasTitle and UDim2.new(1, -28, 0, 34) or UDim2.new(1, 0, 1, 0)
    selectBtn.Position = hasTitle and UDim2.new(0, 14, 0, 26) or UDim2.new(0, 0, 0, 0)
    selectBtn.BackgroundColor3 = hasTitle and Themes.Header or Themes.Card
    selectBtn.Text = ""
    selectBtn.AutoButtonColor = false
    selectBtn.Active = true
    selectBtn.Parent = container
    
    local selectCorner = Instance.new("UICorner")
    selectCorner.CornerRadius = UDim.new(0, 8)
    selectCorner.Parent = selectBtn
    
    local selectedText = Instance.new("TextLabel")
    selectedText.Size = UDim2.new(1, -34, 1, 0)
    selectedText.Position = UDim2.new(0, 14, 0, 0)
    selectedText.BackgroundTransparency = 1
    selectedText.TextColor3 = Themes.Text
    selectedText.TextSize = 12
    selectedText.Font = Enum.Font.GothamMedium
    selectedText.TextXAlignment = Enum.TextXAlignment.Left
    selectedText.TextTruncate = Enum.TextTruncate.AtEnd
    selectedText.Parent = selectBtn
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 24, 1, 0)
    arrow.Position = UDim2.new(1, -30, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▾"
    arrow.TextColor3 = Themes.Accent2
    arrow.TextSize = 12
    arrow.Font = Enum.Font.GothamBold
    arrow.Parent = selectBtn
    
    local listScroll = Instance.new("ScrollingFrame")
    listScroll.Name = "ListScroll"
    listScroll.Size = hasTitle and UDim2.new(1, -28, 0, 140) or UDim2.new(1, -12, 0, 140)
    listScroll.Position = hasTitle and UDim2.new(0, 14, 0, 68) or UDim2.new(0, 6, 0, 42)
    listScroll.BackgroundColor3 = Themes.Background
    listScroll.BorderSizePixel = 0
    listScroll.ScrollBarThickness = 4
    listScroll.ScrollBarImageColor3 = Themes.Accent2
    listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listScroll.Parent = container
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = listScroll
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = listScroll
    
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 6)
    listPadding.PaddingBottom = UDim.new(0, 6)
    listPadding.PaddingLeft = UDim.new(0, 6)
    listPadding.PaddingRight = UDim.new(0, 6)
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
            itemBtn.Size = UDim2.new(1, 0, 0, 30)
            itemBtn.BackgroundColor3 = (opt.Id == currentSelected) and Themes.Card or Themes.Header
            itemBtn.Text = "  " .. opt.Name
            itemBtn.TextColor3 = (opt.Id == currentSelected) and Themes.Accent2 or Themes.Text
            itemBtn.TextSize = 12
            itemBtn.Font = Enum.Font.GothamMedium
            itemBtn.TextXAlignment = Enum.TextXAlignment.Left
            itemBtn.TextTruncate = Enum.TextTruncate.AtEnd
            itemBtn.AutoButtonColor = false
            itemBtn.Active = true
            itemBtn.Parent = listScroll
            
            local itemCorner = Instance.new("UICorner")
            itemCorner.CornerRadius = UDim.new(0, 6)
            itemCorner.Parent = itemBtn
            
            itemBtn.MouseEnter:Connect(function()
                TweenService:Create(itemBtn, TweenInfo.new(0.15), {BackgroundColor3 = Themes.CardBorder}):Play()
            end)
            itemBtn.MouseLeave:Connect(function()
                local c = (opt.Id == currentSelected) and Themes.Card or Themes.Header
                TweenService:Create(itemBtn, TweenInfo.new(0.15), {BackgroundColor3 = c}):Play()
            end)
            
            itemBtn.Activated:Connect(function()
                currentSelected = opt.Id
                selectedText.Text = opt.Name
                isOpen = false
                arrow.Text = "▾"
                TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, closedHeight)
                }):Play()
                if onSelected then onSelected(opt.Id, opt.Name) end
            end)
        end
    end
    
    renderItems()
    
    selectBtn.Activated:Connect(function()
        isOpen = not isOpen
        if isOpen then
            arrow.Text = "▴"
            TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, openHeight)
            }):Play()
        else
            arrow.Text = "▾"
            TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, closedHeight)
            }):Play()
        end
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
            else
                local found = false
                for _, opt in ipairs(options) do
                    if opt.Id == currentSelected then
                        found = true
                        selectedText.Text = opt.Name
                        break
                    end
                end
                if not found and #options > 0 then
                    currentSelected = options[1].Id
                    selectedText.Text = options[1].Name
                end
            end
            renderItems()
        end
    }
end

local function createButton(parent, text, isBlueAccent, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = isBlueAccent and Themes.Accent2 or Themes.Card
    btn.Text = text
    btn.TextColor3 = Themes.Text
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Active = true
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Thickness = 1
    btnStroke.Color = isBlueAccent and Themes.Accent2 or Themes.CardBorder
    btnStroke.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    
    local lastClick = 0
    local function onClick()
        local now = tick()
        if now - lastClick < 0.15 then return end
        lastClick = now
        callback()
    end
    btn.Activated:Connect(onClick)
    btn.MouseButton1Click:Connect(onClick)
    return btn
end

-- ══════════════════════════════════════════════════════════════
-- 6. CRIAÇÃO DAS 4 ABAS SOLICITADAS (+ CONFIG)
-- ══════════════════════════════════════════════════════════════
local ClickTab = createTab("Auto Click", "⚡", 1)
local RebirthTab = createTab("Auto Rebirth", "🔄", 2)
local WinTab = createTab("Auto Win", "🏆", 3)
local EndlessTab = createTab("Auto Endless", "🌀", 4)
local ConfigTab = createTab("Config", "⚙️", 5)

-- ── ABA 1: AUTO CLICK ──────────────────────────────────────────
createSectionHeader(ClickTab, "⚡ AUTO CLICK (OTIMIZADO - ZERO LAG)")

ClickStatsCard = createInfoCard(ClickTab, "📊 Cliques Efetuados", "Clicks: 0", Themes.Accent2)

ClickToggle = createToggle(ClickTab, "Ativar Auto Click", Config.FastClick, function(val)
    Config.FastClick = val
    saveConfig()
end)

createSlider(ClickTab, "Velocidade de Cliques (CPS)", 1, 50, Config.ClickCPS, " CPS", false, function(val)
    Config.ClickCPS = val
    saveConfig()
end)

-- ── ABA 2: AUTO REBIRTH ────────────────────────────────────────
createSectionHeader(RebirthTab, "🔄 AUTO REBIRTH")

RebirthStatsCard = createInfoCard(RebirthTab, "📊 Estatísticas de Rebirth", "Sessão: 0 | Total: 0", Themes.Accent2)

RebirthToggle = createToggle(RebirthTab, "Ativar Auto Rebirth", Config.AutoRebirth, function(val)
    Config.AutoRebirth = val
    saveConfig()
end)

createSlider(RebirthTab, "Intervalo de Rebirth", 0.5, 5.0, Config.RebirthDelay, "s", true, function(val)
    Config.RebirthDelay = val
    saveConfig()
end)

-- ── ABA 3: AUTO WIN ────────────────────────────────────────────
createSectionHeader(WinTab, "🏆 PROGRESSÃO & ESTÁGIOS")

WinStatsCard = createInfoCard(WinTab, "📊 Vitórias Coletadas", "Vitórias: 0", Themes.Accent2)

createLabel(WinTab, "1. Selecione o Mundo:")

local stageProgDropdown = nil

local worldProgDropdown = createDropdown(WinTab, "", WorldsData, Config.SelectedProgWorld, function(worldId)
    Config.SelectedProgWorld = worldId
    if stageProgDropdown and stageProgDropdown.UpdateOptions then
        local opts = getStagesOptionsForWorld(worldId)
        local def = (opts[#opts] and opts[#opts].Id) or "Stage1"
        stageProgDropdown.UpdateOptions(opts, def)
        Config.SelectedProgStage = def
    end
    saveConfig()
end)

createLabel(WinTab, "2. Até qual Estágio Progredir / Vencer:")

stageProgDropdown = createDropdown(WinTab, "", getStagesOptionsForWorld(Config.SelectedProgWorld), Config.SelectedProgStage, function(stageId)
    Config.SelectedProgStage = stageId
    saveConfig()
end)

WinToggle = createToggle(WinTab, "Auto Progressão Completa (Auto Win)", Config.AutoWin, function(val)
    Config.AutoWin = val
    if val then
        Config.AutoEndless = false
        if EndlessToggle and EndlessToggle.Set then EndlessToggle.Set(false, true) end
    end
    saveConfig()
end)

createSlider(WinTab, "Tempo de Espera por Estágio", 0.05, 3.0, Config.CombatTime, "s", true, function(val)
    Config.CombatTime = val
    saveConfig()
end)

createSlider(WinTab, "Velocidade de Deslize (Glide)", 40, 300, Config.WinGlideSpeed, " Speed", false, function(val)
    Config.WinGlideSpeed = val
    saveConfig()
end)

-- ── ABA 4: AUTO ENDLESS ────────────────────────────────────────
createSectionHeader(EndlessTab, "🌀 CO-OP SEM FIM (ENDLESS)")

EndlessStatsCard = createInfoCard(EndlessTab, "📊 Status do CO-OP", "Fora da Arena", Themes.Accent2)

createLabel(EndlessTab, "Selecione o Mundo do CO-OP:")

createDropdown(EndlessTab, "", EndlessWorldsList, Config.EndlessWorld, function(worldId)
    Config.EndlessWorld = worldId
    saveConfig()
end)

EndlessToggle = createToggle(EndlessTab, "Auto CO-OP Sem Fim", Config.AutoEndless, function(val)
    Config.AutoEndless = val
    if val then
        Config.AutoWin = false
        if WinToggle and WinToggle.Set then WinToggle.Set(false, true) end
    end
    saveConfig()
end)

createToggle(EndlessTab, "Auto Hop se Bloqueado (+1 min)", Config.AutoHopBlocked, function(val)
    Config.AutoHopBlocked = val
    saveConfig()
end)

EndlessReviveToggle = createToggle(EndlessTab, "Auto Fechar Reanimação (Segundo Plano)", Config.AutoClosePopups, function(val)
    Config.AutoClosePopups = val
    if AutoClosePopupsToggle and AutoClosePopupsToggle.Set then
        AutoClosePopupsToggle.Set(val, true)
    end
    saveConfig()
end)

createSectionHeader(ConfigTab, "⚙️ CONFIGURAÇÕES GERAIS")

AntiAfkToggle = createToggle(ConfigTab, "Anti-AFK Silencioso", Config.AntiAfk, function(val)
    Config.AntiAfk = val
    saveConfig()
end)

AutoClosePopupsToggle = createToggle(ConfigTab, "Auto Fechar Pop-ups (Segundo Plano)", Config.AutoClosePopups, function(val)
    Config.AutoClosePopups = val
    if EndlessReviveToggle and EndlessReviveToggle.Set then
        EndlessReviveToggle.Set(val, true)
    end
    saveConfig()
end)

PlaytimeToggle = createToggle(ConfigTab, "Auto Resgatar Recompensas de Tempo", Config.AutoClaimPlaytime, function(val)
    Config.AutoClaimPlaytime = val
    saveConfig()
end)

createButton(ConfigTab, "🎁 Resgatar Recompensas de Tempo Agora", false, function()
    claimPlaytimeRewards()
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🎁 Recompensas de Tempo",
            Text = "Verificando e resgatando recompensas disponíveis...",
            Duration = 3
        })
    end)
end)

createSectionHeader(ConfigTab, "💾 SALVAMENTO DE ESTADO & SERVER HOP")

createInfoCard(ConfigTab, "📁 Arquivo de Configuração", "SuperHeroEvolution_Config.json", Themes.Success)

createToggle(ConfigTab, "Salvar Estado Automaticamente", Config.AutoSaveConfig, function(val)
    Config.AutoSaveConfig = val
    saveConfig()
end)

createButton(ConfigTab, "💾 Salvar Configurações Agora", true, function()
    saveConfig()
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "💾 Salvo com Sucesso!",
            Text = "Estado atual das funções salvo no arquivo!",
            Duration = 3
        })
    end)
end)

createButton(ConfigTab, "🔄 Recarregar Configurações do Arquivo", false, function()
    if loadConfig() then
        if ClickToggle and ClickToggle.Set then ClickToggle.Set(Config.FastClick == true, true) end
        if RebirthToggle and RebirthToggle.Set then RebirthToggle.Set(Config.AutoRebirth == true, true) end
        if WinToggle and WinToggle.Set then WinToggle.Set(Config.AutoWin == true, true) end
        if EndlessToggle and EndlessToggle.Set then EndlessToggle.Set(Config.AutoEndless == true, true) end
        if AntiAfkToggle and AntiAfkToggle.Set then AntiAfkToggle.Set(Config.AntiAfk == true, true) end
        if AutoClosePopupsToggle and AutoClosePopupsToggle.Set then AutoClosePopupsToggle.Set(Config.AutoClosePopups == true, true) end
        if EndlessReviveToggle and EndlessReviveToggle.Set then EndlessReviveToggle.Set(Config.AutoClosePopups == true, true) end
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "🔄 Configurações Recarregadas!",
                Text = "Funções e parâmetros restaurados do arquivo!",
                Duration = 3
            })
        end)
    end
end)

createButton(ConfigTab, "🌐 Forçar Server Hop (Trocar Servidor)", false, function()
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🌐 Server Hop",
            Text = "Salvando estado e conectando a novo servidor...",
            Duration = 3
        })
    end)
    saveConfig()
    serverHop()
end)

createInfoCard(ConfigTab, "⌨️ Tecla de Atalho", "Pressione 'K' para Minimizar / Abrir", Themes.TextDim)

createButton(ConfigTab, "❌ Descarregar / Fechar Script", false, function()
    if getgenv().SuperHeroEvolutionHubCleanup then
        getgenv().SuperHeroEvolutionHubCleanup()
    end
end)

-- Aplica visualmente os estados carregados a todos os botões e toggles
local function applyLoadedConfig()
    pcall(function()
        if ClickToggle and ClickToggle.Set then ClickToggle.Set(Config.FastClick == true, true) end
        if RebirthToggle and RebirthToggle.Set then RebirthToggle.Set(Config.AutoRebirth == true, true) end
        if WinToggle and WinToggle.Set then WinToggle.Set(Config.AutoWin == true, true) end
        if EndlessToggle and EndlessToggle.Set then EndlessToggle.Set(Config.AutoEndless == true, true) end
        if AntiAfkToggle and AntiAfkToggle.Set then AntiAfkToggle.Set(Config.AntiAfk == true, true) end
        if AutoClosePopupsToggle and AutoClosePopupsToggle.Set then AutoClosePopupsToggle.Set(Config.AutoClosePopups == true, true) end
        if EndlessReviveToggle and EndlessReviveToggle.Set then EndlessReviveToggle.Set(Config.AutoClosePopups == true, true) end
        if PlaytimeToggle and PlaytimeToggle.Set then PlaytimeToggle.Set(Config.AutoClaimPlaytime == true, true) end
    end)
end
applyLoadedConfig()

-- Notificação se tiver restaurado após Server Hop
if ConfigRestoredAfterHop then
    task.spawn(function()
        task.wait(2.0)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "💾 Estado Restaurado!",
                Text = "Funções ativas recarregadas automaticamente pós-Server Hop!",
                Duration = 6
            })
        end)
    end)
end

-- ══════════════════════════════════════════════════════════════
-- 7. CLEANUP FUNCTION & AUTO-UPDATE
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
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end)
    
    for _, t in ipairs(ActiveThreads) do pcall(task.cancel, t) end
    for _, c in ipairs(ActiveConnections) do pcall(function() c:Disconnect() end) end
    table.clear(ActiveThreads)
    table.clear(ActiveConnections)
    
    if ScreenGui and ScreenGui.Parent then pcall(function() ScreenGui:Destroy() end) end
    destroyExistingHubs()
    
    SessionRebirths = 0
    totalWinsCollectedCount = 0
    Config.RebirthsCount = 0
    Config.ClicksCount = 0
    Config.WinsCount = 0
    
    getgenv().SuperHeroEvolutionHubLoaded = nil
    getgenv().SuperHeroEvolutionHubCleanup = nil
    getgenv().SuperHeroEvolutionHubConfig = nil
    
    print("[Hub] Script descarregado completamente com sucesso.")
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
                        print(string.format("[Auto Update] Nova versão detectada (%s: %s)! Recarregando script automaticamente...", tostring(data.commit), tostring(data.message or "Atualização")))
                        
                        pcall(function()
                            game:GetService("StarterGui"):SetCore("SendNotification", {
                                Title = "🚀 Hub Atualizado!",
                                Text = "Nova versão (" .. tostring(data.commit) .. ") carregada automaticamente!",
                                Duration = 5
                            })
                        end)
                        
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
    TabButtons["Auto Win"].BackgroundColor3 = Themes.Card
    TabButtons["Auto Win"].TextColor3 = Themes.Accent2
    Tabs["Auto Win"].Visible = true
end

print("══════════════════════════════════════════════════════")
print("[SUPERHERO EVOLUTION HUB - AUTO EDITION V2.0] Carregado com Sucesso!")
print("Recursos: Auto Click Otimizado, Auto Rebirth, Auto Farm Win e Auto Endless.")
print("Pressione 'K' para Minimizar / Abrir a interface.")
print("══════════════════════════════════════════════════════")
