--[[
    ==============================================================
    SUPERHERO EVOLUTION HUB - V5.0 MASTER EDITION
    Game: +1 Superhero Evolution (PVP)
    Tecla 'K' para Minimizar / Abrir
    Estatísticas de Rebirth em Tempo Real na MiniBar!
    Sistema Completo de Títulos Automáticos por Modo (Boss, Treino, PvP, Vitória, CO-OP)
    Sistema Completo de Eventos:
       • Boss de Arena (Thanos / Doom / Tung Sahur / Kong) + Dodge + Levitação Anti-Chão
       • Invasão & Raid (com Travessia Inteligente de Obby & Auto Ataque)
       • Desafio de Sobrevivência (Dodge de Meteoros & Shockwaves)
       • Memória & Retorno Automático à Atividade Anterior
       • Status dos Eventos em Tempo Real
    Clique & Treino Inteligente (Mundos 1 a 8) + CPS Slider + Colado na PunchingBag
    Progressão Completa & Estágios (Mundos 1 a 9) + Slider Tempo de Combate
    CO-OP Sem Fim com Auto Hop se Bloqueado (+1 min fora da arena)
    Ovos & Pets: Auto Open 2x Múltiplos, Pular Animação Instantâneo
    Proteção de Tela & Auto Fechar Pop-ups (Eventos, Diários & Robux)
    Movimento & Física: Anti-AFK Silencioso, Speed Walk Slider, Infinite Jump, Noclip, Invisibilidade
    Voo Suave (Fly) com Slider de Velocidade de Voo
    Teleporte de Mundos (1 a 9) & Server Hop Vazio
    Salvar & Restaurar Automações Automaticamente em JSON
    ==============================================================
]]

local SCRIPT_VERSION_TIMESTAMP = 1790884533

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

RemotePlayerClick = Remotes and Remotes:FindFirstChild("PlayerClick")
RemoteRequestAttack = Remotes and Remotes:FindFirstChild("RequestAttack")
RemoteRequestTrain = Remotes and Remotes:FindFirstChild("RequestTrain")
RemoteRequestRebirth = Remotes and Remotes:FindFirstChild("RequestRebirth")
RemoteHatchEgg = Remotes and Remotes:FindFirstChild("HatchEgg")
RemoteTryPurchaseEgg = Remotes and Remotes:FindFirstChild("TryPurchaseEgg")
RemoteAutoHatch = Remotes and Remotes:FindFirstChild("AutoHatch")
RemotePlayHatchVisuals = Remotes and Remotes:FindFirstChild("PlayHatchVisuals")
RemoteClaimDailyReward = Remotes and Remotes:FindFirstChild("ClaimDailyReward")
RemoteGetDailyRewardState = Remotes and Remotes:FindFirstChild("GetDailyRewardState")
RemoteClaimGroupReward = Remotes and Remotes:FindFirstChild("ClaimGroupReward")
RemoteClaimPlaytimeReward = Remotes and Remotes:FindFirstChild("ClaimPlaytimeReward")
RemoteGetPlaytimeRewardsState = Remotes and Remotes:FindFirstChild("GetPlaytimeRewardsState")
RemoteRaidJoinRequest = Remotes and Remotes:FindFirstChild("RaidJoinRequest")
RemoteRaidReviveRequest = Remotes and Remotes:FindFirstChild("RaidReviveRequest")
RemoteBossEventResponse = Remotes and Remotes:FindFirstChild("BossEventResponse")
RemoteBossEventPrompt = Remotes and Remotes:FindFirstChild("BossEventPrompt")
RemoteBossEventUpdate = Remotes and Remotes:FindFirstChild("BossEventUpdate")
RemoteBossEventCountdown = Remotes and Remotes:FindFirstChild("BossEventCountdown")
RemoteBossEventReward = Remotes and Remotes:FindFirstChild("BossEventReward")
RemoteRequestWorldChange = Remotes and Remotes:FindFirstChild("RequestWorldChange")
RemoteGetData = Remotes and Remotes:FindFirstChild("GetData")
RemoteEndlessJoinRequest = Remotes and Remotes:FindFirstChild("EndlessJoinRequest")
RemoteEndlessStateRequest = Remotes and Remotes:FindFirstChild("EndlessStateRequest")
RemoteEndlessBattleState = Remotes and Remotes:FindFirstChild("EndlessBattleState")
RemoteEndlessUpdate = Remotes and Remotes:FindFirstChild("EndlessUpdate")
RemotePlayVFX = Remotes and Remotes:FindFirstChild("PlayVFX")
RemotePromptEventRsvp = Remotes and Remotes:FindFirstChild("PromptEventRsvp")
RemoteEquipTitle = Remotes and Remotes:FindFirstChild("EquipTitle")
RemoteGetTitlesState = Remotes and Remotes:FindFirstChild("GetTitlesState")

-- Hub Configuration (Default: Tudo desativado exceto Anti-AFK e Resgatar Recompensas AFK)
local Config = {
    -- 1. Clique & Treino Inteligente
    FastClick = false,
    ClickCPS = 5,
    SelectedTrainWorld = "auto",
    TrainZoneFilter = "free",
    SelectedTrainZone = "auto",
    TrainPositioning = "melee",
    TrainDistanceOffset = 5.0,
    AutoTrain = false,
    AutoRebirth = false,
    RebirthDelay = 1.5,
    
    -- 2. Progressão & Estágios
    SelectedProgWorld = "world9",
    SelectedProgStage = "Stage134",
    AutoWin = false,
    CombatTime = 0.5,
    WinGlideSpeed = 75,
    
    -- 3. CO-OP Sem Fim
    AutoEndless = false,
    EndlessWorld = "current",
    AutoHopBlocked = false,
    
    -- 4. Ovos & Pets
    SelectedEgg = "goldensteampunk_egg",
    AutoHatch = false,
    AutoHatchMultiple = false,
    FastHatch = false,
    SkipEggAnimation = false,
    HatchSpeed = 0.08,
    
    -- 5. Proteção de Tela & Popups
    AutoClosePopups = false,
    
    -- 6. Movimento & Física
    AntiAfk = true,
    WalkSpeedEnabled = false,
    WalkSpeed = 60,
    InfiniteJump = false,
    Noclip = false,
    Invisibility = false,
    FlyEnabled = false,
    FlySpeed = 50,
    
    -- 7. Teleporte de Mundos & Conexão
    SelectedTeleportWorld = 1,
    AutoReconnect = false,
    AutoSaveSettings = false,
    
    -- 8. Títulos Automáticos por Modo (Título certo para cada atividade)
    TitleTrainEnabled = false,
    TitleTrain = "apocalypse",
    TitleWinEnabled = false,
    TitleWin = "hall_of_famer",
    TitleCoopEnabled = false,
    TitleCoop = "eternity",
    TitleBossEnabled = false,
    TitleBoss = "the_immortal",
    TitleRaidEnabled = false,
    TitleRaid = "warbringer",
    TitlePvpEnabled = false,
    TitlePvp = "the_immortal",
    TitleEggEnabled = false,
    TitleEgg = "beast_god",
    
    -- 9. Eventos Especiais
    AutoEnterBoss = false,
    BossDodge = false,
    BossAutoAttack = false,
    BossLowHover = false,
    AutoEnterRaid = false,
    RaidObbySmart = false,
    RaidAutoAttack = false,
    EventReturnMemory = false,
    
    -- 10. PvP
    PvpKillAura = false,
    PvpStickToTarget = false,
    PvpAuraRange = 25,
    
    -- Playtime & Daily Rewards
    AutoDailyRewards = false,
    AutoPlaytimeRewards = true,
    
    -- Estatísticas
    ClicksCount = 0,
    RebirthsCount = 0,
    EggsHatched = 0
}

getgenv().SuperHeroEvolutionHubConfig = Config

local ActiveThreads = {}
local ActiveConnections = {}
local SessionRebirths = 0
local initialLeaderRebirths = nil

pcall(function()
    local ls = LocalPlayer:WaitForChild("leaderstats", 5)
    local r = ls and ls:WaitForChild("Rebirths", 5)
    if r then
        initialLeaderRebirths = tonumber(r.Value) or 0
        local rConn = r.Changed:Connect(function(newVal)
            if initialLeaderRebirths ~= nil then
                local current = tonumber(newVal) or 0
                local diff = current - initialLeaderRebirths
                if diff >= 0 then
                    SessionRebirths = diff
                    Config.RebirthsCount = SessionRebirths
                    if MainStatsCard then
                        MainStatsCard.Update("Clicks: " .. Config.ClicksCount .. " | Rebirths: " .. SessionRebirths, (Themes and Themes.Accent2) or Color3.fromRGB(0, 210, 255))
                    end
                end
            end
        end)
        table.insert(ActiveConnections, rConn)
    end
end)

-- Forward declarations (Globals para liberar registradores locais do Luau)
checkAndAcceptBossInvite = nil
finishBossAndResetCharacter = nil
isHandlingBossFinish = false
applySkipAnimation = nil
applyInvisibility = nil
startFly = nil
stopFly = nil
saveConfig = nil
loadConfig = nil
serverHop = nil
equipTitle = nil
updateTitleCardVisual = nil
autoSyncActiveTitle = nil
MainStatsCard = nil
EventStatusCard = nil
MiniBar = nil
MainFrame = nil
HeaderStats = nil
MiniStats = nil
Sidebar = nil
PageContainer = nil
Tabs = {}
TabButtons = {}
createTab = nil

local function spawnThread(func)
    local thread = task.spawn(func)
    table.insert(ActiveThreads, thread)
    return thread
end

-- ══════════════════════════════════════════════════════════════
--  CENTROS DAS ARENAS DE CO-OP SEM FIM (MUNDOS 2 A 9)
-- ══════════════════════════════════════════════════════════════
local isBossFighting = false
local isPvpFighting = false
local previousActivity = nil
local EndlessToggle = nil
local TrainToggle = nil
local WinToggle = nil
local RebirthToggle = nil
local FastClickToggle = nil
local bossWaitingForSpawn = false
local bossWaitStartTime = 0
local bossPlayerJoined = false
local bossEventPhase = "Idle"
local bossStartTime = 0
local lastKnownBossPos = nil
local isReturningToEndless = false
local BOSS_ARENA_CFRAME = CFrame.new(0, 84, -400)

local EndlessArenaCenters = {
    [2] = Vector3.new(764.57, 34.0, -1305.00),
    [3] = Vector3.new(1072.67, 34.0, -2569.20),
    [4] = Vector3.new(2293.47, 34.0, -1305.00),
    [5] = Vector3.new(3238.95, 34.0, -1305.00),
    [6] = Vector3.new(4009.25, 34.0, -1305.00),
    [7] = Vector3.new(4813.55, 34.0, -1305.00),
    [8] = Vector3.new(5663.95, 34.0, -1305.00),
    [9] = Vector3.new(6450.23, 34.0, -1305.00),
}

local function getActiveRaidFolder()
    local raidFolder = workspace:FindFirstChild("Raid")
    if raidFolder then
        for _, ch in ipairs(raidFolder:GetChildren()) do
            if ch.Name:match("^ActiveRaid") then
                return ch
            end
        end
    end
    for _, ch in ipairs(workspace:GetChildren()) do
        if ch.Name:match("^ActiveRaid") then
            return ch
        end
    end
    return nil
end

local function isRaidActive()
    local rf = getActiveRaidFolder()
    if rf then return true, rf end
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    local top = pgui and pgui:FindFirstChild("ScreenGui") and pgui.ScreenGui:FindFirstChild("Top")
    local ri = top and top:FindFirstChild("RaidInvite")
    if ri and ri.Visible then return true, nil end
    local rm = top and top:FindFirstChild("RaidsMode")
    if rm and rm.Visible then return true, nil end
    return false, nil
end

local function isInsideRaid()
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    local top = pgui and pgui:FindFirstChild("ScreenGui") and pgui.ScreenGui:FindFirstChild("Top")
    local rm = top and top:FindFirstChild("RaidsMode")
    if rm and rm.Visible then return true end
    
    local activeRaid = getActiveRaidFolder()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if activeRaid and hrp then
        for _, st in ipairs(activeRaid:GetChildren()) do
            local conn = st:FindFirstChild("Connectors")
            local startP = conn and conn:FindFirstChild("Start")
            local endP = conn and conn:FindFirstChild("End")
            local refPart = startP or endP or st:FindFirstChildWhichIsA("BasePart", true)
            if refPart and (hrp.Position - refPart.Position).Magnitude < 400 then
                return true
            end
        end
    end
    return false
end

local function isInsideEndless()
    if isBossFighting or isInsideRaid() or isRaidActive() then return false end
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
    if not hrp then return EndlessArenaCenters[9], 9 end
    
    local pPos = hrp.Position
    local targetWorld = nil
    if Config.EndlessWorld and Config.EndlessWorld ~= "current" then
        targetWorld = tonumber(string.match(tostring(Config.EndlessWorld), "%d+"))
    elseif Config.SelectedProgWorld and Config.SelectedProgWorld ~= "current" and Config.SelectedProgWorld ~= "all" then
        targetWorld = tonumber(string.match(tostring(Config.SelectedProgWorld), "%d+"))
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
    local closestWorld = 9
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
    return EndlessArenaCenters[9], 9
end

-- ══════════════════════════════════════════════════════════════
--  CONTROLE GLOBAL DE BOSS & TIMERS DE EVENTOS
-- ══════════════════════════════════════════════════════════════
local function isArenaBossForbidden(model)
    if not model or not model:IsA("Model") then return true end
    local n = model.Name
    if n:find("Coop") or n:find("Raid") then
        return true
    end
    local p = model.Parent
    if p then
        local pName = p.Name
        if pName:find("Endless") or pName:find("Raid") then
            return true
        end
    end
    return false
end

local cachedBossModel = nil
local cachedBossHum = nil

local function getActiveBossModel()
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    local top = pgui and pgui:FindFirstChild("ScreenGui") and pgui.ScreenGui:FindFirstChild("Top")
    local bhb = top and top:FindFirstChild("BossHealthBar")
    local ebm = top and top:FindFirstChild("EventBossMode")
    local bfi = top and top:FindFirstChild("BossFightInvite")
    local isBarActive = (bhb and bhb.Visible == true) or (ebm and ebm.Visible == true) or (bfi and bfi.Visible == true)

    if not isBossFighting and not isBarActive and not bossWaitingForSpawn and not bossPlayerJoined and bossEventPhase ~= "Active" then
        cachedBossModel = nil
        cachedBossHum = nil
        return nil, nil
    end

    local function isValidBoss(m)
        if not m or not m:IsA("Model") or not m.Parent or isArenaBossForbidden(m) then return false end
        if m == LocalPlayer.Character or Players:GetPlayerFromCharacter(m) ~= nil then return false end
        local bHum = m:FindFirstChildOfClass("Humanoid")
        local dying = m:GetAttribute("BEDying")
        local hpPct = m:GetAttribute("BEHealthPct")
        if dying then return false end
        if hpPct ~= nil and hpPct <= 0 then return false end
        if bHum then
            if bHum.Health > 0 then
                return true, bHum
            end
            return false
        end
        local hrp = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
        if hrp then
            return true, nil
        end
        return false
    end

    -- Se o boss já cacheado ainda estiver válido e no workspace, retorna instantaneamente (0ms)
    if cachedBossModel and isValidBoss(cachedBossModel) then
        return cachedBossModel, cachedBossHum
    else
        cachedBossModel = nil
        cachedBossHum = nil
    end

    -- 1. Se a barra de vida estiver visível com o nome do Boss, procurar por esse nome
    local targetBossName = nil
    if bhb and bhb.Visible then
        local nameL = bhb:FindFirstChild("Name", true)
        if nameL and nameL.Text and #nameL.Text > 0 then
            targetBossName = nameL.Text:gsub("<[^>]+>", ""):lower():match("^%s*(.-)%s*$")
        end
    end

    if targetBossName and #targetBossName > 0 then
        for _, child in ipairs(workspace:GetChildren()) do
            if child:IsA("Model") and string.find(string.lower(child.Name), targetBossName, 1, true) then
                local valid, bHum = isValidBoss(child)
                if valid then
                    cachedBossModel = child
                    cachedBossHum = bHum
                    return child, bHum
                end
            end
        end
    end

    -- 2. Verificar modelos conhecidos de Boss de Arena em Workspace (insensível a maiúsculas/minúsculas)
    local knownBosses = {"thanos", "drdoom", "tungtung", "zhallos", "playerboss", "smlik", "tgw", "boss"}
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") then
            local lowName = string.lower(child.Name)
            for _, bKey in ipairs(knownBosses) do
                if string.find(lowName, bKey, 1, true) then
                    local valid, bHum = isValidBoss(child)
                    if valid then
                        cachedBossModel = child
                        cachedBossHum = bHum
                        return child, bHum
                    end
                end
            end
        end
    end

    -- 3. Modelos na pasta BossFightStage
    local bossStage = workspace:FindFirstChild("BossFightStage")
    if bossStage then
        for _, child in ipairs(bossStage:GetDescendants()) do
            if child:IsA("Model") then
                local valid, bHum = isValidBoss(child)
                if valid then
                    cachedBossModel = child
                    cachedBossHum = bHum
                    return child, bHum
                end
            end
        end
    end

    -- 4. Tag BossEventNPC ou Atributos BEName / EnemyId
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") and (child:GetAttribute("BEName") or child:GetAttribute("EnemyId") or CollectionService:HasTag(child, "BossEventNPC")) then
            local valid, bHum = isValidBoss(child)
            if valid then
                cachedBossModel = child
                cachedBossHum = bHum
                return child, bHum
            end
        end
    end

    -- 5. Busca espacial: Qualquer modelo na Arena do Boss (< 220 studs de BOSS_ARENA_CFRAME) que não seja Player
    local arenaPos = BOSS_ARENA_CFRAME.Position
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") and child ~= LocalPlayer.Character and Players:GetPlayerFromCharacter(child) == nil then
            local cf = child:GetPivot()
            if (cf.Position - arenaPos).Magnitude < 220 then
                local valid, bHum = isValidBoss(child)
                if valid then
                    cachedBossModel = child
                    cachedBossHum = bHum
                    return child, bHum
                end
            end
        end
    end

    return nil, nil
end

local function isBossActive()
    -- Se o ataque automático do Boss não estiver ativado, o Boss nunca pausa outras funções
    if not Config.BossAutoAttack then return false end
    if isRaidActive() and Config.AutoEnterRaid then return false end
    if isHandlingBossFinish then return false end
    if bossDiedInCurrentEvent then return false end
    if isBossFighting then return true end

    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    local top = pgui and pgui:FindFirstChild("ScreenGui") and pgui.ScreenGui:FindFirstChild("Top")
    local bhb = top and top:FindFirstChild("BossHealthBar")
    return (bhb and bhb.Visible == true)
end

-- ══════════════════════════════════════════════════════════════
--  SISTEMA UNIFICADO DE MEMÓRIA & PAUSA/RETOMADA DE AUTOMAÇÕES
-- ══════════════════════════════════════════════════════════════
local EventMemory = {
    IsActive = false,
    CurrentEvent = nil, -- "Raid" ou "Boss"
    SavedStates = nil,
    SavedWorld = nil,
    SavedZone = nil,
    SavedCFrame = nil,
    HasResetForBoss = false,
    HasResetForRaid = false,
    LastResetTime = 0
}

local function pauseAutomationsForEvent(eventName)
    -- Se já estamos em um evento e a Raid começou enquanto estávamos no Boss:
    if EventMemory.IsActive then
        if eventName == "Raid" and EventMemory.CurrentEvent == "Boss" then
            print("[Event Priority] Raid iniciou durante o Boss! Priorizando RAID!")
            EventMemory.CurrentEvent = "Raid"
            isBossFighting = false
            wasFightingBoss = false
        end
        return
    end

    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    EventMemory.IsActive = true
    EventMemory.CurrentEvent = eventName
    EventMemory.SavedStates = {
        AutoTrain = Config.AutoTrain or false,
        AutoWin = Config.AutoWin or false,
        AutoEndless = Config.AutoEndless or false,
        FastClick = Config.FastClick or false,
        AutoRebirth = Config.AutoRebirth or false
    }
    EventMemory.SavedWorld = Config.SelectedTrainWorld
    EventMemory.SavedZone = Config.SelectedTrainZone
    EventMemory.SavedProgWorld = Config.SelectedProgWorld
    EventMemory.SavedProgStage = Config.SelectedProgStage
    EventMemory.SavedEndlessWorld = Config.EndlessWorld
    EventMemory.SavedCFrame = hrp and hrp.CFrame
    
    print(string.format("[Event Memory] %s ativo! Pausando outras funções: AutoTrain=%s, AutoWin=%s, AutoEndless=%s, AutoRebirth=%s",
        tostring(eventName),
        tostring(EventMemory.SavedStates.AutoTrain),
        tostring(EventMemory.SavedStates.AutoWin),
        tostring(EventMemory.SavedStates.AutoEndless),
        tostring(EventMemory.SavedStates.AutoRebirth)
    ))
    
    -- Desativa as funções concorrentes para não conflitar
    Config.AutoTrain = false
    Config.AutoWin = false
    Config.AutoEndless = false
    Config.AutoRebirth = false
    
    -- Atualiza os botões visuais na interface
    if TrainToggle and TrainToggle.Set then TrainToggle.Set(false, true) end
    if WinToggle and WinToggle.Set then WinToggle.Set(false, true) end
    if EndlessToggle and EndlessToggle.Set then EndlessToggle.Set(false, true) end
    if RebirthToggle and RebirthToggle.Set then RebirthToggle.Set(false, true) end
    if FastClickToggle and FastClickToggle.Set then FastClickToggle.Set(false, true) end
end

local function resumeAutomationsAfterEvent(eventName)
    if not EventMemory.IsActive then return end
    
    -- Se o Boss finalizou mas a Raid está ativa, NÃO restaura: continua na Raid!
    if eventName == "Boss" and isRaidActive() and Config.AutoEnterRaid then
        print("[Event Priority] Boss acabou, mas a Raid está ativa! Mantendo foco na Raid.")
        EventMemory.CurrentEvent = "Raid"
        return
    end
    
    if EventMemory.CurrentEvent and EventMemory.CurrentEvent ~= eventName then
        return
    end
    
    print(string.format("[Event Memory] %s finalizado! Restaurando funções anteriores...", tostring(eventName)))
    
    local saved = EventMemory.SavedStates
    local savedCF = EventMemory.SavedCFrame
    local savedWorld = EventMemory.SavedWorld
    local savedZone = EventMemory.SavedZone
    local savedProgWorld = EventMemory.SavedProgWorld
    local savedProgStage = EventMemory.SavedProgStage
    local savedEndlessWorld = EventMemory.SavedEndlessWorld
    
    EventMemory.IsActive = false
    EventMemory.CurrentEvent = nil
    EventMemory.SavedStates = nil
    EventMemory.SavedCFrame = nil
    EventMemory.SavedWorld = nil
    EventMemory.SavedZone = nil
    EventMemory.SavedProgWorld = nil
    EventMemory.SavedProgStage = nil
    EventMemory.SavedEndlessWorld = nil
    
    if saved then
        if saved.AutoTrain then
            Config.AutoTrain = true
            if TrainToggle and TrainToggle.Set then TrainToggle.Set(true, true) end
            if Config.TitleTrainEnabled and equipTitle then equipTitle(Config.TitleTrain) end
        end
        if saved.AutoWin then
            if savedProgWorld then Config.SelectedProgWorld = savedProgWorld end
            if savedProgStage then Config.SelectedProgStage = savedProgStage end
            Config.AutoWin = true
            if WinToggle and WinToggle.Set then WinToggle.Set(true, true) end
            if Config.TitleWinEnabled and equipTitle then equipTitle(Config.TitleWin) end
        end
        if saved.AutoEndless then
            if savedEndlessWorld then Config.EndlessWorld = savedEndlessWorld end
            Config.AutoEndless = true
            if EndlessToggle and EndlessToggle.Set then EndlessToggle.Set(true, true) end
            if Config.TitleCoopEnabled and equipTitle then equipTitle(Config.TitleCoop) end
        end
        if saved.FastClick ~= nil then
            Config.FastClick = saved.FastClick
            if FastClickToggle and FastClickToggle.Set then FastClickToggle.Set(saved.FastClick, true) end
        end
        if saved.AutoRebirth ~= nil then
            Config.AutoRebirth = saved.AutoRebirth
            if RebirthToggle and RebirthToggle.Set then RebirthToggle.Set(saved.AutoRebirth, true) end
        end
        
        -- Retorna o personagem para a atividade anterior (Auto Train, Auto Win, Auto Endless ou posição memorizada)
        task.spawn(function()
            task.wait(0.8)
            local char, hrp = waitForCharacterAlive(6)
            if hrp and savedCF and (Config.EventReturnMemory or saved.AutoTrain or saved.AutoWin or saved.AutoEndless) then
                -- Restaura mundo correto se o jogador estiver em outro mundo
                local targetWorld = (saved.AutoTrain and savedWorld) or (saved.AutoWin and savedProgWorld) or (saved.AutoEndless and savedEndlessWorld) or savedWorld
                if targetWorld and targetWorld ~= "auto" and RemoteRequestWorldChange then
                    local wNum = tonumber(string.match(tostring(targetWorld), "%d+"))
                    if wNum then
                        RemoteRequestWorldChange:InvokeServer(wNum)
                        task.wait(1.5)
                    end
                end
                local curChar, curHrp = waitForCharacterAlive(4)
                if curHrp and savedCF then
                    curHrp.CFrame = savedCF
                    curHrp.Velocity = Vector3.zero
                    curHrp.RotVelocity = Vector3.zero
                    if curHrp.AssemblyLinearVelocity then curHrp.AssemblyLinearVelocity = Vector3.zero end
                    if curHrp.AssemblyAngularVelocity then curHrp.AssemblyAngularVelocity = Vector3.zero end
                    print("[Event Memory] Personagem reposicionado na coordenada salva com sucesso!")
                end
            end
        end)
    end
    EventMemory.HasResetForBoss = false
    EventMemory.HasResetForRaid = false
    print("[Event Memory] Funções reativadas com sucesso!")
end

local function performResetAndAccept(eventName, acceptAction)
    local now = os.clock()
    if (now - (EventMemory.LastResetTime or 0)) < 3 then
        if acceptAction then pcall(acceptAction) end
        return
    end
    EventMemory.LastResetTime = now

    print(string.format("[Reset Event] Dando reset de segurança antes de aceitar %s...", tostring(eventName)))
    
    -- 1. Reseta o personagem imediatamente (kill/BreakJoints)
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            hum.Health = 0
        elseif char then
            char:BreakJoints()
        end
    end)
    
    -- 2. Aguarda exatamente 0.5 segundo conforme solicitado
    task.wait(0.5)
    
    -- 3. Agora aceita o convite e envia os remotes para fazer o evento
    print(string.format("[Reset Event] 0.5s decorrido! Aceitando convite para %s...", tostring(eventName)))
    if acceptAction then
        pcall(acceptAction)
    end
end

local recordActivity = function() pauseAutomationsForEvent("Boss") end
local restoreActivity = function() resumeAutomationsAfterEvent("Boss") end

local function getEventTimersInfo()
    local bossInfo = "--:--"
    local raidInfo = "--:--"
    pcall(function()
        local gui = LocalPlayer:FindFirstChild("PlayerGui")
        local top = gui and gui:FindFirstChild("ScreenGui") and gui.ScreenGui:FindFirstChild("Top")
        local timers = top and top:FindFirstChild("Timers")
        
        -- Raid Timer (Apenas o tempo da Raid)
        if timers then
            local rt = timers:FindFirstChild("RaidTimer")
            if rt then
                for _, d in ipairs(rt:GetDescendants()) do
                    if d:IsA("TextLabel") and d.Text and #d.Text > 0 then
                        local clean = d.Text:gsub("<[^>]+>", "")
                        local rTime = clean:match("in:%s*([%d:]+)") or clean:match("(%d+:%d+)") or clean:match("(%d+%s*s)")
                        if rTime then
                            raidInfo = rTime
                            break
                        end
                    end
                end
            end
        end
        
        -- Boss Timer (Apenas o tempo do Boss de Arena)
        if timers then
            local bt = timers:FindFirstChild("BossFightTimer")
            if bt then
                for _, d in ipairs(bt:GetDescendants()) do
                    if d:IsA("TextLabel") and d.Text and #d.Text > 0 then
                        local clean = d.Text:gsub("<[^>]+>", "")
                        local bTime = clean:match("in:%s*([%d:]+)") or clean:match("(%d+:%d+)") or clean:match("(%d+%s*s)")
                        if bTime then
                            bossInfo = bTime
                            break
                        end
                    end
                end
            end
        end
    end)
    return bossInfo, raidInfo
end

-- ══════════════════════════════════════════════════════════════
--  PERSISTÊNCIA DE CONFIGURAÇÕES (JSON)
-- ══════════════════════════════════════════════════════════════
local CONFIG_FILE = "SuperHeroEvolution_Config_V5.json"

saveConfig = function()
    pcall(function()
        if not Config.AutoSaveSettings then return end
        if writefile then
            local data = {
                FastClick = Config.FastClick,
                ClickCPS = Config.ClickCPS,
                SelectedTrainWorld = Config.SelectedTrainWorld,
                TrainZoneFilter = Config.TrainZoneFilter,
                SelectedTrainZone = Config.SelectedTrainZone,
                TrainPositioning = Config.TrainPositioning,
                TrainDistanceOffset = Config.TrainDistanceOffset,
                AutoTrain = Config.AutoTrain,
                AutoRebirth = Config.AutoRebirth,
                SelectedProgWorld = Config.SelectedProgWorld,
                SelectedProgStage = Config.SelectedProgStage,
                AutoWin = Config.AutoWin,
                CombatTime = Config.CombatTime,
                WinGlideSpeed = Config.WinGlideSpeed,
                AutoEndless = Config.AutoEndless,
                AutoHopBlocked = Config.AutoHopBlocked,
                SelectedEgg = Config.SelectedEgg,
                AutoHatch = Config.AutoHatch,
                AutoHatchMultiple = Config.AutoHatchMultiple,
                FastHatch = Config.FastHatch,
                EndlessWorld = Config.EndlessWorld,
                SkipEggAnimation = Config.SkipEggAnimation,
                AutoClosePopups = Config.AutoClosePopups,
                AntiAfk = Config.AntiAfk,
                WalkSpeedEnabled = Config.WalkSpeedEnabled,
                WalkSpeed = Config.WalkSpeed,
                InfiniteJump = Config.InfiniteJump,
                Noclip = Config.Noclip,
                Invisibility = Config.Invisibility,
                FlyEnabled = Config.FlyEnabled,
                FlySpeed = Config.FlySpeed,
                SelectedTeleportWorld = Config.SelectedTeleportWorld,
                AutoReconnect = Config.AutoReconnect,
                AutoSaveSettings = Config.AutoSaveSettings,
                TitleTrainEnabled = Config.TitleTrainEnabled,
                TitleTrain = Config.TitleTrain,
                TitleWinEnabled = Config.TitleWinEnabled,
                TitleWin = Config.TitleWin,
                TitleCoopEnabled = Config.TitleCoopEnabled,
                TitleCoop = Config.TitleCoop,
                TitleBossEnabled = Config.TitleBossEnabled,
                TitleBoss = Config.TitleBoss,
                TitleRaidEnabled = Config.TitleRaidEnabled,
                TitleRaid = Config.TitleRaid,
                TitlePvpEnabled = Config.TitlePvpEnabled,
                TitlePvp = Config.TitlePvp,
                TitleEggEnabled = Config.TitleEggEnabled,
                TitleEgg = Config.TitleEgg,
                AutoEnterBoss = Config.AutoEnterBoss,
                BossDodge = Config.BossDodge,
                BossAutoAttack = Config.BossAutoAttack,
                BossLowHover = Config.BossLowHover,
                AutoEnterRaid = Config.AutoEnterRaid,
                RaidObbySmart = Config.RaidObbySmart,
                RaidAutoAttack = Config.RaidAutoAttack,
                EventReturnMemory = Config.EventReturnMemory,
                AutoPlaytimeRewards = Config.AutoPlaytimeRewards,
                PvpKillAura = Config.PvpKillAura,
                PvpStickToTarget = Config.PvpStickToTarget,
                PvpAuraRange = Config.PvpAuraRange
            }
            writefile(CONFIG_FILE, HttpService:JSONEncode(data))
            print("[Config] Configurações salvas com sucesso em " .. CONFIG_FILE)
        end
    end)
end

loadConfig = function()
    pcall(function()
        if not Config.AutoSaveSettings then return end
        if isfile and isfile(CONFIG_FILE) and readfile then
            local raw = readfile(CONFIG_FILE)
            local data = HttpService:JSONDecode(raw)
            if data and type(data) == "table" then
                for k, v in pairs(data) do
                    Config[k] = v
                end
                print("[Config] Configurações restauradas com sucesso!")
            end
        end
    end)
end

loadConfig()

-- ══════════════════════════════════════════════════════════════
--  CORREÇÃO DEFINITIVA DE COMBATE & RECUO (ANTI-BUG AO BATER)
-- ══════════════════════════════════════════════════════════════
pcall(function()
    local fcMod = ReplicatedStorage:FindFirstChild("Client") and ReplicatedStorage.Client:FindFirstChild("FacingController")
    if fcMod then
        local fc = require(fcMod)
        if fc then
            fc.setTargetPosition = function() end
            fc.setTarget = function() end
        end
    end
end)

local function stabilizeCharacter(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hum or not hrp then return end
    
    --  REMOVE A CAIXA CINZA/AZUL DO CORPO (HumanoidRootPart sempre 100% invisível)
    hrp.Transparency = 1
    local hrpTrConn = hrp:GetPropertyChangedSignal("Transparency"):Connect(function()
        if hrp.Transparency < 1 then
            hrp.Transparency = 1
        end
    end)
    table.insert(ActiveConnections, hrpTrConn)
    
    hum.AutoRotate = true
    
    local arConn = hum:GetPropertyChangedSignal("AutoRotate"):Connect(function()
        if not hum.AutoRotate and not Config.FlyEnabled then
            hum.AutoRotate = true
        end
    end)
    table.insert(ActiveConnections, arConn)
    
    --  ANTI-LEVIDADE & ANTI-RECUO DE ANIMAÇÃO DE GOLPE
    local anim = hum:WaitForChild("Animator", 5) or hum:FindFirstChildOfClass("Animator")
    if anim then
        -- Encerra de imediato qualquer animação de levitação/Hold (ex: Loki/Thanos LazerBeam) que tenha ficado presa
        for _, t in ipairs(anim:GetPlayingAnimationTracks()) do
            if t.Priority == Enum.AnimationPriority.Action2 or (t.Animation and t.Animation.AnimationId:find("128945315942664")) then
                if t.Looped then
                    t.Looped = false
                    t:Stop(0.1)
                end
            end
        end
        
        -- Garante que animações de golpes futuros nunca fiquem em loop perpétuo fazendo o personagem flutuar/levitar
        local apConn = anim.AnimationPlayed:Connect(function(track)
            local animId = track.Animation and track.Animation.AnimationId
            if animId and (animId:find("128945315942664") or track.Priority == Enum.AnimationPriority.Action2) then
                if track.Looped then
                    track.Looped = false
                    task.delay(0.35, function()
                        if track and track.IsPlaying then
                            track:Stop(0.15)
                        end
                    end)
                end
            end
        end)
        table.insert(ActiveConnections, apConn)
    end
    
    -- TRAVAMENTO CONTRA RECUO / ANDAR PARA TRÁS AO SOCAR
    local fixedPos = nil
    
    local stepConn = RunService.Stepped:Connect(function()
        if not char or not hum or not hrp or hum.Health <= 0 then return end
        
        -- Remove colisão dos membros para que pés e pernas não empurrem o personagem para trás ao socar
        for _, p in ipairs(char:GetChildren()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.CanCollide then
                p.CanCollide = false
            end
        end
        
        -- Se o jogador estiver andando intencionalmente no analógico/teclado ou voando, atualiza posição livremente
        if hum.MoveDirection.Magnitude > 0.01 or Config.FlyEnabled then
            fixedPos = hrp.Position
        else
            local curPos = hrp.Position
            -- Se houve teleporte da automação (distância > 6 studs), reancora no novo destino
            if not fixedPos or (Vector3.new(curPos.X, 0, curPos.Z) - Vector3.new(fixedPos.X, 0, fixedPos.Z)).Magnitude > 6 then
                fixedPos = curPos
            else
                -- Trava X e Z no ponto de repouso, anulando qualquer recuo ou impulso para trás gerado pelos ataques
                hrp.CFrame = CFrame.new(fixedPos.X, curPos.Y, fixedPos.Z) * (hrp.CFrame - curPos)
                local curVel = hrp.AssemblyLinearVelocity
                hrp.AssemblyLinearVelocity = Vector3.new(0, curVel.Y, 0)
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end)
    table.insert(ActiveConnections, stepConn)
end

if LocalPlayer.Character then
    stabilizeCharacter(LocalPlayer.Character)
end
table.insert(ActiveConnections, LocalPlayer.CharacterAdded:Connect(stabilizeCharacter))

-- ══════════════════════════════════════════════════════════════
-- ️ 24/7 ANTI-AFK SILENCIOSO (SEMPRE ATIVO)
-- ══════════════════════════════════════════════════════════════
table.insert(ActiveConnections, LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
    print("[Anti-AFK] Sinal de ociosidade interceptado! Clicando para manter ativo...")
end))

spawnThread(function()
    while true do
        if Config.AntiAfk then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(10, 10))
            end)
        end
        task.wait(60)
    end
end)

-- ══════════════════════════════════════════════════════════════
-- ══════════════════════════════════════════════════════════════
-- SERVER HOP & AUTO RECONNECT (OCULTO & AUTOMATICO)
-- ══════════════════════════════════════════════════════════════
local function queueScriptOnTeleport()
    pcall(function()
        local queueTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
        if queueTeleport then
            local qCode = [[
                task.spawn(function()
                    repeat task.wait(0.5) until game:IsLoaded()
                    task.wait(2)
                    pcall(function()
                        if readfile and isfile and isfile("hub.lua") then
                            loadstring(readfile("hub.lua"))()
                        elseif readfile and isfile and isfile("script.lua") then
                            loadstring(readfile("script.lua"))()
                        end
                    end)
                end)
            ]]
            queueTeleport(qCode)
        end
    end)
end

-- Prepara a fila de teleporte para rodar automaticamente ao mudar de servidor
queueScriptOnTeleport()

pcall(function()
    local tpConn = LocalPlayer.OnTeleport:Connect(function()
        queueScriptOnTeleport()
    end)
    table.insert(ActiveConnections, tpConn)
end)

serverHop = function()
    pcall(function()
        if saveConfig then saveConfig() end
    end)
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

-- Troca automatica de servidor caso desconecte/erro/kick (oculto e sem necessidade de configuracao manual)
pcall(function()
    local guiService = game:GetService("GuiService")
    local reconnectConn = guiService.ErrorMessageChanged:Connect(function()
        task.wait(1.5)
        pcall(function() if saveConfig then saveConfig() end end)
        queueScriptOnTeleport()
        serverHop()
    end)
    table.insert(ActiveConnections, reconnectConn)
end)

pcall(function()
    local failConn = TeleportService.TeleportInitFailed:Connect(function()
        task.wait(1.5)
        pcall(function() if saveConfig then saveConfig() end end)
        queueScriptOnTeleport()
        serverHop()
    end)
    table.insert(ActiveConnections, failConn)
end)

pcall(function()
    local promptGui = CoreGui:FindFirstChild("RobloxPromptGui")
    if promptGui then
        local promptConn = promptGui.DescendantAdded:Connect(function(descendant)
            if not Config.AutoReconnect then return end
            local name = descendant.Name:lower()
            if descendant:IsA("TextLabel") and (name:find("errortitle") or name:find("errormessage")) and descendant.Text ~= "" then
                task.wait(1.5)
                pcall(function() if saveConfig then saveConfig() end end)
                queueScriptOnTeleport()
                serverHop()
            end
        end)
        table.insert(ActiveConnections, promptConn)
    end
end)

-- Desativar menu de emotes nativo do Roblox e cancelar animacoes de emote
pcall(function()
    game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
end)

local function disableEmoteTracks(char)
    pcall(function()
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
    end)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        local animConn = hum.AnimationPlayed:Connect(function(track)
            local name = (track.Name or ""):lower()
            local anim = track.Animation
            local id = (anim and anim.AnimationId or ""):lower()
            if name:find("emote") or name:find("dance") or id:find("emote") or name:find("wave") or name:find("cheer") or name:find("point") or name:find("laugh") then
                track:Stop(0)
            end
        end)
        table.insert(ActiveConnections, animConn)
    end
end

if LocalPlayer.Character then disableEmoteTracks(LocalPlayer.Character) end
table.insert(ActiveConnections, LocalPlayer.CharacterAdded:Connect(disableEmoteTracks))

-- ══════════════════════════════════════════════════════════════
--  AUTO FECHAR POP-UPS (ROBUX, EVENTOS NATIVOS, CONVITES & LOJA)
-- ══════════════════════════════════════════════════════════════
-- ══════════════════════════════════════════════════════════════
-- 🛡️ AUTO FECHAR POP-UPS (ROBUX & AVISOS DE EVENTOS NATIVOS)
-- ⚠️ AVISOS DE INÍCIO DE BOSS E RAID SÃO 100% PRESERVADOS ("DEIXA")
-- ══════════════════════════════════════════════════════════════
do
local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)

-- Verifica se o elemento é aviso do jogo, Boss, Raid ou evento in-game (NUNCA FECHAR, SEMPRE PERMITIR QUE APAREÇA)
local function isAllowedInGameEventOrNotification(name, text)
    local n = string.lower(name or "")
    local t = string.lower(text or "")
    return n:find("boss") ~= nil or n:find("raid") ~= nil or n:find("invas") ~= nil
        or n:find("invite") ~= nil or n:find("event") ~= nil or n:find("meteor") ~= nil
        or n:find("battle") ~= nil or n:find("survival") ~= nil
        or t:find("boss") ~= nil or t:find("raid") ~= nil or t:find("invas") ~= nil
        or t:find("lute contra") ~= nil or t:find("saque insano") ~= nil
        or t:find("tung") ~= nil or t:find("sahur") ~= nil
        or t:find("vá!") ~= nil or t:find("va!") ~= nil
end

local isBossOrRaid = isAllowedInGameEventOrNotification

-- Identifica com precisão textos de pop-ups indesejados (Apenas itens de Robux e pop-ups de fora do jogo da plataforma Roblox)
local function isUnwantedPopupText(txt)
    if not txt or type(txt) ~= "string" then return false end
    local lower = string.lower(txt)
    
    -- Notificações de eventos e raids do jogo PODEM aparecer
    if isAllowedInGameEventOrNotification(nil, lower) then
        return false
    end
    
    -- 1. Pop-ups de Compra de Itens e Robux
    if lower:find("comprar robux")
       or lower:find("robux e item")
       or lower:find("comprar item")
       or lower:find("termos de uso da roblox")
       or lower:find("método de pagamento")
       or lower:find("metodo de pagamento")
       or lower:find("ganhe 10%% de desconto")
       or lower:find("starter pack")
       or lower:find("special offer")
       or lower:find("oferta especial")
       or lower:find("compre agora")
       or lower:find("buy now") then
        return true
    end
    
    -- 2. Pop-ups nativos da plataforma Roblox (de fora do jogo, ex: Admin Abuse / Eventos da plataforma)
    if lower:find("abuso de administrador")
       or lower:find("abuso de admin")
       or lower:find("admin abuse")
       or lower:find("evento da experiência")
       or lower:find("evento da experiencia")
       or lower:find("experience event") then
        return true
    end
    
    return false
end

-- Dispara clique real em botão com VirtualInputManager e fallback para firesignal
local function clickGuiButton(btn)
    if not btn or not btn:IsA("GuiButton") then return false end
    local clicked = false
    pcall(function()
        if VirtualInputManager and btn.AbsoluteSize.X > 0 and btn.AbsoluteSize.Y > 0 then
            local pos = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
            clicked = true
        end
        if firesignal then
            if btn.Activated then firesignal(btn.Activated) end
            if btn.MouseButton1Click then firesignal(btn.MouseButton1Click) end
            if btn.MouseButton1Up then firesignal(btn.MouseButton1Up) end
            clicked = true
        end
        if firebutton1click then
            firebutton1click(btn)
            clicked = true
        end
    end)
    return clicked
end

-- Fecha o popup nativamente buscando e acionando o botão "X" / Fechar e ocultando a tela
local function dismissGuiPopup(frameOrGui)
    if not frameOrGui then return end
    
    -- NUNCA fechar se for aviso ou convite de Boss ou Raid ("DEIXA")
    if isBossOrRaid(frameOrGui.Name) then
        return
    end

    -- 1. Se for ScreenGui fora do CoreGui, tenta desabilitar
    if frameOrGui:IsA("ScreenGui") and frameOrGui.Parent ~= game:GetService("CoreGui") then
        pcall(function() frameOrGui.Enabled = false end)
    end

    -- 2. Varre botões para fechar/recusar nativamente (acionando botões "X", Cancelar, Fechar)
    for _, btn in ipairs(frameOrGui:GetDescendants()) do
        if btn:IsA("GuiButton") then
            local bn = btn.Name:lower()
            local isClose = false
            
            -- Por nome do botão
            if bn:find("cancel") or bn:find("close") or bn:find("decline") or bn:find("dismiss")
               or bn == "x" or bn == "button2" or bn:find("exit") or bn:find("fechar") or bn:find("voltar") or bn:find("back") then
                isClose = true
            end
            
            -- Por texto (TextButton)
            if not isClose and btn:IsA("TextButton") then
                local txt = btn.Text:lower():gsub("%s+", "")
                if txt == "x" or txt:find("fechar") or txt:find("cancelar") or txt:find("cancel")
                   or txt:find("close") or txt == "não" or txt == "nao" or txt == "no" or txt:find("voltar") then
                    isClose = true
                end
            end
            
            -- Por imagem (ImageButton - ex: ícone X ou fechar)
            if not isClose and btn:IsA("ImageButton") then
                local img = btn.Image:lower()
                if img:find("close") or img:find("cross") or img:find("cancel") or img:find("x") or img:find("back") or img:find("reject") then
                    isClose = true
                end
            end
            
            -- Detecção por posição no cabeçalho (Botão X no topo esquerdo da Imagem 1 ou topo direito da Imagem 2)
            if not isClose and btn.AbsoluteSize.X > 0 and btn.AbsoluteSize.X <= 75 and btn.AbsoluteSize.Y <= 75 then
                local pModal = btn:FindFirstAncestorWhichIsA("GuiObject")
                if pModal and pModal.AbsoluteSize.X > 150 and pModal.AbsoluteSize.Y > 150 then
                    local relX = btn.AbsolutePosition.X - pModal.AbsolutePosition.X
                    local relY = btn.AbsolutePosition.Y - pModal.AbsolutePosition.Y
                    if relY >= 0 and relY < 90 then
                        if relX < 90 or relX > (pModal.AbsoluteSize.X - 90) then
                            isClose = true
                        end
                    end
                end
            end
            
            if isClose then
                clickGuiButton(btn)
            end
        end
    end
    
    -- 3. Oculta e joga fora da tela para garantir que nada permaneça visível
    pcall(function()
        if frameOrGui:IsA("GuiObject") then
            frameOrGui.Visible = false
            frameOrGui.Position = UDim2.new(10, 0, 10, 0)
        elseif frameOrGui:IsA("ScreenGui") and frameOrGui.Parent ~= game:GetService("CoreGui") then
            frameOrGui.Enabled = false
        end
        for _, c in ipairs(frameOrGui:GetChildren()) do
            if c:IsA("GuiObject") then
                c.Visible = false
            end
        end
    end)
end

-- Listener instantâneo em PlayerGui e CoreGui
local function hookContainerDismiss(container)
    if not container then return end
    local conn = container.ChildAdded:Connect(function(child)
        if not Config.AutoClosePopups then return end
        task.defer(function()
            pcall(function()
                local cn = child.Name:lower()
                -- NUNCA fechar aviso de Boss ou Raid ("DEIXA")
                if isBossOrRaid(cn) then
                    return
                end
                
                -- Se for pop-up indesejado conhecido
                if cn:find("adminabuse") or cn:find("purchase") or cn:find("eventnotification")
                   or cn:find("experienceevent") or cn:find("eventsapp") or cn:find("eventmodal")
                   or cn:find("notificationmodal") or cn:find("speedboost") or cn:find("starterpack")
                   or cn:find("limitedoffer") or cn:find("specialoffer") or cn:find("offlineearnings") then
                    dismissGuiPopup(child)
                    return
                end
                
                -- Checa se contém texto indesejado
                for _, lbl in ipairs(child:GetDescendants()) do
                    if (lbl:IsA("TextLabel") or lbl:IsA("TextButton")) and isUnwantedPopupText(lbl.Text) then
                        dismissGuiPopup(child)
                        break
                    end
                end
            end)
        end)
    end)
    table.insert(ActiveConnections, conn)
end

pcall(function()
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    if pgui then
        local sg = pgui:FindFirstChild("ScreenGui")
        if sg then
            -- Menus de loja / ofertas (NÃO hooka Top para que todos os eventos do jogo e avisos apareçam livremente)
            hookContainerDismiss(sg:FindFirstChild("Menus"))
        end
    end
end)

pcall(function()
    local cg = game:GetService("CoreGui")
    if cg then
        hookContainerDismiss(cg)
    end
end)

-- Loop contínuo de limpeza (a cada 0.3s): Remove apenas pop-ups de fora do jogo (CoreGui da Roblox) e itens de Robux
spawnThread(function()
    while true do
        if Config.AutoClosePopups then
            pcall(function()
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                local cg = game:GetService("CoreGui")
                
                -- 1. Pop-ups DE FORA DO JOGO (Plataforma Roblox / CoreGui: Compras nativas de Robux e Notificações de Evento do Roblox)
                local targetCoreGuis = {
                    "PurchasePromptApp", "PurchasePrompt", "RobloxPromptGui",
                    "ExperienceEventNotification", "EventNotification", "EventsApp",
                    "EventModal", "NotificationModal", "BulkPurchaseApp", "CommercePurchaseApp"
                }
                for _, promptName in ipairs(targetCoreGuis) do
                    local pGui = cg:FindFirstChild(promptName)
                    if pGui then
                        dismissGuiPopup(pGui)
                    end
                end
                
                for _, child in ipairs(cg:GetChildren()) do
                    if child:IsA("ScreenGui") and not isAllowedInGameEventOrNotification(child.Name) then
                        local cn = child.Name:lower()
                        if cn:find("purchase") or cn:find("event") or cn:find("prompt") then
                            for _, d in ipairs(child:GetDescendants()) do
                                if (d:IsA("TextLabel") or d:IsA("TextButton")) and isUnwantedPopupText(d.Text) then
                                    dismissGuiPopup(child)
                                    break
                                end
                            end
                        end
                    end
                end
                
                -- 2. PlayerGui: Apenas menus intrusivos de loja e compra de Robux (NUNCA fecha Top nem avisos do jogo)
                if pgui then
                    local sg = pgui:FindFirstChild("ScreenGui")
                    if sg then
                        -- Menus de loja / ofertas de Robux
                        local menus = sg:FindFirstChild("Menus")
                        if menus then
                            for _, n in ipairs({"Store", "SpecialOffer", "OfflineEarnings", "LimitedOffer", "StarterPack"}) do
                                local f = menus:FindFirstChild(n)
                                if f and f.Visible then dismissGuiPopup(f) end
                            end
                        end
                        
                        -- Pop-ups específicos de compra/anúncio de Robux
                        for _, n in ipairs({"AdminAbuse", "OfflineEarnings", "SpeedBoostPrompt", "StarterPackPromo"}) do
                            local f = sg:FindFirstChild(n)
                            if f and f.Visible then dismissGuiPopup(f) end
                        end
                    end
                end
                
                -- 3. Restaura Blur de tela se todos os popups estiverem fechados
                local blur = Lighting:FindFirstChild("Blur")
                if blur and blur.Size > 0 then
                    local menus = pgui and pgui:FindFirstChild("ScreenGui") and pgui.ScreenGui:FindFirstChild("Menus")
                    local hasVisibleMenu = false
                    if menus then
                        for _, m in ipairs(menus:GetChildren()) do
                            if m:IsA("GuiObject") and m.Visible then
                                hasVisibleMenu = true
                                break
                            end
                        end
                    end
                    if not hasVisibleMenu then
                        for _, b in ipairs(Lighting:GetChildren()) do
                            if b:IsA("BlurEffect") and b.Size > 0 then
                                b.Size = 0
                            end
                        end
                        if workspace.CurrentCamera and not Config.FlyEnabled then
                            workspace.CurrentCamera.FieldOfView = 70
                        end
                    end
                end
            end)
        end
        task.wait(0.3)
    end
end)
end

-- ══════════════════════════════════════════════════════════════
-- ══════════════════════════════════════════════════════════════
-- 🥚 CONTROLE DE ANIMAÇÃO DE ABERTURA DE OVOS (ESCOLHA: VER OU PULAR)
-- ══════════════════════════════════════════════════════════════
pcall(function()
    local sc = require(ReplicatedStorage.Client.ScreenController)
    if sc and not sc._origHide then
        sc._origHide = sc.hide
        sc.hide = function(...)
            if Config.SkipEggAnimation then return end
            return sc._origHide(...)
        end
    end
end)

local function protectScreenElements()
    pcall(function()
        local pgui = LocalPlayer:WaitForChild("PlayerGui", 5)
        local sg = pgui and pgui:WaitForChild("ScreenGui", 5)
        if sg then
            for _, name in ipairs({"Right", "Bottom", "LeftSide", "Top"}) do
                local frame = sg:FindFirstChild(name)
                if frame and frame:IsA("GuiObject") then
                    local posConn = frame:GetPropertyChangedSignal("Position"):Connect(function()
                        if Config.SkipEggAnimation and frame.Position ~= UDim2.new(0, 0, 0, 0) then
                            frame.Position = UDim2.new(0, 0, 0, 0)
                        end
                    end)
                    table.insert(ActiveConnections, posConn)
                    
                    local visConn = frame:GetPropertyChangedSignal("Visible"):Connect(function()
                        if Config.SkipEggAnimation and not frame.Visible then
                            frame.Visible = true
                        end
                    end)
                    table.insert(ActiveConnections, visConn)
                end
            end
        end
    end)
end
protectScreenElements()

applySkipAnimation = function(state)
    pcall(function()
        local sounds = game:GetService("SoundService"):FindFirstChild("Sounds")
        if sounds then
            local shake = sounds:FindFirstChild("EggShake")
            local eggOpen = sounds:FindFirstChild("EggOpen")
            if shake then shake.Volume = state and 0 or 0.5 end
            if eggOpen then eggOpen.Volume = state and 0 or 0.5 end
        end
    end)
    pcall(function()
        if RemotePlayHatchVisuals and getconnections then
            for _, conn in ipairs(getconnections(RemotePlayHatchVisuals.OnClientEvent)) do
                if state then
                    if conn.Disable then conn:Disable() end
                else
                    if conn.Enable then conn:Enable() end
                end
            end
        end
    end)
    if state then
        pcall(function()
            local hatchStage = workspace:FindFirstChild("HatchStage")
            if hatchStage then hatchStage:Destroy() end
            Camera.CameraType = Enum.CameraType.Custom
        end)
    end
end

table.insert(ActiveConnections, workspace.ChildAdded:Connect(function(child)
    if Config.SkipEggAnimation and child.Name == "HatchStage" then
        task.defer(function()
            pcall(function() child:Destroy() end)
            Camera.CameraType = Enum.CameraType.Custom
        end)
    end
end))

table.insert(ActiveConnections, Camera:GetPropertyChangedSignal("CameraType"):Connect(function()
    if Config.SkipEggAnimation and Camera.CameraType ~= Enum.CameraType.Custom then
        Camera.CameraType = Enum.CameraType.Custom
    end
end))

applySkipAnimation(Config.SkipEggAnimation)

-- ══════════════════════════════════════════════════════════════
--  PLAYTIME REWARDS CLAIM SYSTEM
-- ══════════════════════════════════════════════════════════════
local PlaytimeSchedule = {
    [1] = 0, [2] = 60, [3] = 120, [4] = 300, [5] = 600, [6] = 1200,
    [7] = 1800, [8] = 2700, [9] = 3600, [10] = 4800, [11] = 6000, [12] = 7200
}

local function claimAvailablePlaytimeRewards()
    local totalClaimed = 0
    pcall(function()
        -- 1. Método Remoto Direto via State
        local state = nil
        if RemoteGetPlaytimeRewardsState then
            local ok, res = pcall(function() return RemoteGetPlaytimeRewardsState:InvokeServer() end)
            if ok and type(res) == "table" then state = res end
        end
        local firstPlay = (state and state.FirstPlayTimestamp) or os.time()
        local claimedMap = (state and state.Claimed) or {}
        local elapsed = os.time() - firstPlay
        
        for slot = 1, 12 do
            local reqTime = PlaytimeSchedule[slot] or (slot * 300)
            if elapsed >= reqTime and not claimedMap[slot] then
                if RemoteClaimPlaytimeReward then
                    RemoteClaimPlaytimeReward:FireServer(slot)
                    print("[Playtime Rewards] Recompensa do slot " .. slot .. " resgatada via Remote!")
                end
                claimedMap[slot] = true
                totalClaimed = totalClaimed + 1
                task.wait(0.12)
            end
        end
        
        -- 2. Método GUI (detecta e clica nos botões prontos na interface)
        local pgui = LocalPlayer:FindFirstChild("PlayerGui")
        local pr = pgui and pgui:FindFirstChild("ScreenGui") and pgui.ScreenGui:FindFirstChild("Menus") and pgui.ScreenGui.Menus:FindFirstChild("PlaytimeRewards")
        local sf = pr and pr:FindFirstChild("ScrollingFrame", true)
        if sf then
            for slot = 1, 12 do
                local btn = sf:FindFirstChild(tostring(slot))
                if btn and btn:IsA("GuiButton") then
                    local claimF = btn:FindFirstChild("Claim", true)
                    local claimL = claimF and claimF:FindFirstChildWhichIsA("TextLabel")
                    local cText = claimL and claimL.Text:upper() or ""
                    if claimF and claimF.Visible and not cText:find("CLAIMED") and not cText:find("REIVINDICADO") then
                        if RemoteClaimPlaytimeReward then RemoteClaimPlaytimeReward:FireServer(slot) end
                        pcall(function()
                            if firesignal then
                                firesignal(btn.Activated)
                                firesignal(btn.MouseButton1Click)
                            elseif firebutton1click then
                                firebutton1click(btn)
                            end
                        end)
                        print("[Playtime Rewards] Recompensa do slot " .. slot .. " resgatada via GUI!")
                        totalClaimed = totalClaimed + 1
                    end
                end
            end
        end
    end)
    return totalClaimed
end

local function claimDailyReward()
    pcall(function()
        if not RemoteClaimDailyReward then return end
        local state = nil
        if RemoteGetDailyRewardState then
            local ok, res = pcall(function() return RemoteGetDailyRewardState:InvokeServer() end)
            if ok and type(res) == "table" then state = res end
        end
        local canClaim = true
        if state and state.Now and state.LastClaim and state.ClaimInterval then
            canClaim = (state.Now - state.LastClaim >= state.ClaimInterval)
        end
        if canClaim then
            RemoteClaimDailyReward:FireServer()
        end
    end)
end

spawnThread(function()
    while true do
        if Config.AutoPlaytimeRewards then claimAvailablePlaytimeRewards() end
        if Config.AutoDailyRewards then claimDailyReward() end
        task.wait(5)
    end
end)

-- ══════════════════════════════════════════════════════════════
--  LISTA DE OVOS COM VALOR NA FRENTE
-- ══════════════════════════════════════════════════════════════
local function formatEggCost(cost, currency)
    if currency == "Robux" then
        return "Robux"
    end
    local currName = (currency == "Wins" and "Vitórias") or (currency == "Tokens" and "Tokens") or currency or ""
    if not cost or cost == 0 then
        return currName
    end
    local units = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "N", "De"}
    local c = tonumber(cost) or 0
    local unitIdx = 1
    while c >= 1000 and unitIdx < #units do
        c = c / 1000
        unitIdx = unitIdx + 1
    end
    local numStr = (c >= 100 or c == math.floor(c)) and string.format("%d", c) or string.format("%.1f", c):gsub("%.0$", "")
    return numStr .. units[unitIdx] .. " " .. currName
end

local EggsList = {
    {Id = "basic_egg", Name = "10 Vitórias - Basic Egg", Cost = 10, Currency = "Wins"},
    {Id = "farm_egg", Name = "2.5K Vitórias - Farm Egg", Cost = 2500, Currency = "Wins"},
    {Id = "meme_egg", Name = "500K Vitórias - Meme Egg", Cost = 500000, Currency = "Wins"},
    {Id = "mystery_egg", Name = "1M Tokens - Mystery Egg", Cost = 1000000, Currency = "Tokens"},
    {Id = "evil_egg", Name = "5M Tokens - Evil Egg", Cost = 5000000, Currency = "Tokens"},
    {Id = "cool_egg", Name = "100M Vitórias - Cool Egg", Cost = 100000000, Currency = "Wins"},
    {Id = "steampunk_egg", Name = "500M Vitórias - Steampunk Egg", Cost = 500000000, Currency = "Wins"},
    {Id = "cupcake_egg", Name = "100B Vitórias - Cupcake Egg", Cost = 100000000000, Currency = "Wins"},
    {Id = "cactus_egg", Name = "1T Vitórias - Cactus Egg", Cost = 1000000000000, Currency = "Wins"},
    {Id = "volcano_egg", Name = "500T Vitórias - Volcano Egg", Cost = 5e+14, Currency = "Wins"},
    {Id = "yeti_egg", Name = "5Qa Vitórias - Yeti Egg", Cost = 5e+15, Currency = "Wins"},
    {Id = "overgrown_egg", Name = "2.5Qi Vitórias - Overgrown Egg", Cost = 2.5e+18, Currency = "Wins"},
    {Id = "regalini_egg", Name = "50Qi Vitórias - Regalini Egg", Cost = 5e+19, Currency = "Wins"},
    {Id = "saturnini_egg", Name = "25Sx Vitórias - Saturnini Egg", Cost = 2.5e+22, Currency = "Wins"},
    {Id = "demon_egg", Name = "500Sx Vitórias - Demon Egg", Cost = 5e+23, Currency = "Wins"},
    {Id = "pirate_egg", Name = "250Sp Vitórias - Pirate Egg", Cost = 2.5e+26, Currency = "Wins"},
    {Id = "flower_egg", Name = "5Oc Vitórias - Flower Egg", Cost = 5e+27, Currency = "Wins"},
    {Id = "milkshake_egg", Name = "2.5N Vitórias - Milkshake Egg", Cost = 2.5e+30, Currency = "Wins"},
    {Id = "ocean_egg", Name = "50N Vitórias - Ocean Egg", Cost = 5e+31, Currency = "Wins"},
    {Id = "summer_egg", Name = "25De Vitórias - Summer Egg", Cost = 2.5e+34, Currency = "Wins"},
    {Id = "goldensteampunk_egg", Name = "Robux - Golden Steampunk Egg", Cost = 0, Currency = "Robux"},
    {Id = "neon_egg", Name = "Robux - Neon Egg", Cost = 0, Currency = "Robux"},
    {Id = "dominus_egg", Name = "Robux - Dominus Egg", Cost = 0, Currency = "Robux"},
    {Id = "goldendemon_egg", Name = "Robux - Golden Demon Egg", Cost = 0, Currency = "Robux"},
    {Id = "goldencactus_egg", Name = "Robux - Golden Cactus Egg", Cost = 0, Currency = "Robux"},
    {Id = "goldencupcake_egg", Name = "Robux - Golden Cupcake Egg", Cost = 0, Currency = "Robux"},
    {Id = "goldenvolcano_egg", Name = "Robux - Golden Volcano Egg", Cost = 0, Currency = "Robux"},
    {Id = "goldenyeti_egg", Name = "Robux - Golden Yeti Egg", Cost = 0, Currency = "Robux"},
    {Id = "goldenovergrown_egg", Name = "Robux - Golden Overgrown Egg", Cost = 0, Currency = "Robux"},
    {Id = "goldenpirate_egg", Name = "Robux - Golden Pirate Egg", Cost = 0, Currency = "Robux"},
    {Id = "goldenflower_egg", Name = "Robux - Golden Flower Egg", Cost = 0, Currency = "Robux"},
    {Id = "goldenmilkshake_egg", Name = "Robux - Golden Milkshake Egg", Cost = 0, Currency = "Robux"},
    {Id = "goldenocean_egg", Name = "Robux - Golden Ocean Egg", Cost = 0, Currency = "Robux"},
    {Id = "goldensummer_egg", Name = "Robux - Golden Summer Egg", Cost = 0, Currency = "Robux"},
    {Id = "goldenregalini_egg", Name = "Robux - Golden Regalini Egg", Cost = 0, Currency = "Robux"},
    {Id = "goldensaturnini_egg", Name = "Robux - Golden Saturnini Egg", Cost = 0, Currency = "Robux"},
    {Id = "brainrot_egg", Name = "Robux - Brainrot Egg", Cost = 0, Currency = "Robux"},
    {Id = "coconut_egg", Name = "Robux - Coconut Egg", Cost = 0, Currency = "Robux"},
    {Id = "sus_egg", Name = "Robux - Sus Egg", Cost = 0, Currency = "Robux"},
    {Id = "admin_egg", Name = "Admin Egg", Cost = 0, Currency = "Admin"}
}

pcall(function()
    local configMod = ReplicatedStorage.Shared.Config:FindFirstChild("EggsConfig")
    if configMod then
        local cfg = require(configMod)
        if type(cfg) == "table" then
            local temp = {}
            for k, v in pairs(cfg) do
                local dName = (type(v) == "table" and v.Name) or tostring(k)
                local prefix = ""
                if type(v) == "table" then
                    prefix = formatEggCost(v.Cost, v.Currency)
                end
                if prefix ~= "" then
                    dName = prefix .. " - " .. dName
                end
                table.insert(temp, {
                    Id = tostring(k),
                    Name = dName,
                    Cost = (type(v) == "table" and v.Cost) or 0,
                    Currency = (type(v) == "table" and v.Currency) or ""
                })
            end
            if #temp > 0 then
                table.sort(temp, function(a, b)
                    if a.Currency ~= b.Currency then
                        if a.Currency == "Wins" then return true end
                        if b.Currency == "Wins" then return false end
                        if a.Currency == "Tokens" then return true end
                        if b.Currency == "Tokens" then return false end
                    end
                    return (a.Cost or 0) < (b.Cost or 0)
                end)
                EggsList = temp
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  TABELAS DE MUNDOS, ESTÁGIOS & ZONAS DE TREINO (1 A 8)
-- ══════════════════════════════════════════════════════════════
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
    {Id = "all", Name = "Todos os Mundos", WorldNum = nil, MapName = nil, Min = 1, Max = 135}
}

local WorldsTeleportList = {
    {Id = 1, Name = "Mundo 1"}, {Id = 2, Name = "Mundo 2"}, {Id = 3, Name = "Mundo 3"},
    {Id = 4, Name = "Mundo 4"}, {Id = 5, Name = "Mundo 5"}, {Id = 6, Name = "Mundo 6"},
    {Id = 7, Name = "Mundo 7"}, {Id = 8, Name = "Mundo 8"}, {Id = 9, Name = "Mundo 9"}
}

local TrainPositioningOptions = {
    {Id = "melee", Name = "🥊 Corpo a Corpo (Colado no Saco)"},
    {Id = "distance", Name = "🏹 A Distância (Borda da Área/Pad)"}
}

local TrainingWorldsList = {
    {Id = "auto", Name = "Auto - Todos os Mundos"},
    {Id = "world1", Name = "Mundo 1", WorldNum = 1},
    {Id = "world2", Name = "Mundo 2", WorldNum = 2},
    {Id = "world3", Name = "Mundo 3", WorldNum = 3},
    {Id = "world4", Name = "Mundo 4", WorldNum = 4},
    {Id = "world5", Name = "Mundo 5", WorldNum = 5},
    {Id = "world6", Name = "Mundo 6", WorldNum = 6},
    {Id = "world7", Name = "Mundo 7", WorldNum = 7},
    {Id = "world8", Name = "Mundo 8", WorldNum = 8},
    {Id = "world9", Name = "Mundo 9", WorldNum = 9}
}

local TrainingFilterOptions = {
    {Id = "all", Name = "Todas as Zonas (Grátis & Robux)"},
    {Id = "free", Name = "Apenas Zonas Grátis"},
    {Id = "robux", Name = "Apenas Zonas Robux"}
}

local AllTrainingZones = {
    -- Mundo 1
    {Id = "1", Name = "Multiplicador 1x - Rebirth 0", World = 1, Multiplier = 1, Rebirth = 0, IsRobux = false},
    {Id = "2", Name = "Multiplicador 4x - Rebirth 2", World = 1, Multiplier = 4, Rebirth = 2, IsRobux = false},
    {Id = "3", Name = "Multiplicador 10x - Rebirth 4", World = 1, Multiplier = 10, Rebirth = 4, IsRobux = false},
    {Id = "4", Name = "Multiplicador 20x - Rebirth 6", World = 1, Multiplier = 20, Rebirth = 6, IsRobux = false},
    {Id = "5", Name = "Multiplicador 35x - Rebirth 8", World = 1, Multiplier = 35, Rebirth = 8, IsRobux = false},
    {Id = "6", Name = "Multiplicador 50x - Rebirth 10", World = 1, Multiplier = 50, Rebirth = 10, IsRobux = false},
    {Id = "7", Name = "Multiplicador 10x - Robux", World = 1, Multiplier = 10, Rebirth = 0, IsRobux = true, GamepassId = 1931106296},
    {Id = "8", Name = "Multiplicador 50x - Robux", World = 1, Multiplier = 50, Rebirth = 0, IsRobux = true, GamepassId = 1929169918},
    {Id = "9", Name = "Multiplicador 250x - Robux", World = 1, Multiplier = 250, Rebirth = 0, IsRobux = true, GamepassId = 1927364032},

    -- Mundo 2
    {Id = "10", Name = "Multiplicador 50x - Rebirth 0", World = 2, Multiplier = 50, Rebirth = 0, IsRobux = false},
    {Id = "11", Name = "Multiplicador 100x - Rebirth 15", World = 2, Multiplier = 100, Rebirth = 15, IsRobux = false},
    {Id = "12", Name = "Multiplicador 150x - Rebirth 25", World = 2, Multiplier = 150, Rebirth = 25, IsRobux = false},
    {Id = "13", Name = "Multiplicador 250x - Rebirth 50", World = 2, Multiplier = 250, Rebirth = 50, IsRobux = false},
    {Id = "14", Name = "Multiplicador 350x - Rebirth 75", World = 2, Multiplier = 350, Rebirth = 75, IsRobux = false},
    {Id = "15", Name = "Multiplicador 500x - Rebirth 100", World = 2, Multiplier = 500, Rebirth = 100, IsRobux = false},
    {Id = "16", Name = "Multiplicador 150x - Robux", World = 2, Multiplier = 150, Rebirth = 0, IsRobux = true, GamepassId = 1931106296},
    {Id = "17", Name = "Multiplicador 500x - Robux", World = 2, Multiplier = 500, Rebirth = 0, IsRobux = true, GamepassId = 1929169918},
    {Id = "18", Name = "Multiplicador 999x - Robux", World = 2, Multiplier = 999, Rebirth = 0, IsRobux = true, GamepassId = 1927364032},

    -- Mundo 3
    {Id = "19", Name = "Multiplicador 500x - Rebirth 0", World = 3, Multiplier = 500, Rebirth = 0, IsRobux = false},
    {Id = "20", Name = "Multiplicador 750x - Rebirth 125", World = 3, Multiplier = 750, Rebirth = 125, IsRobux = false},
    {Id = "21", Name = "Multiplicador 1Kx - Rebirth 150", World = 3, Multiplier = 1000, Rebirth = 150, IsRobux = false},
    {Id = "22", Name = "Multiplicador 1.25Kx - Rebirth 200", World = 3, Multiplier = 1250, Rebirth = 200, IsRobux = false},
    {Id = "23", Name = "Multiplicador 1.5Kx - Rebirth 250", World = 3, Multiplier = 1500, Rebirth = 250, IsRobux = false},
    {Id = "24", Name = "Multiplicador 2Kx - Rebirth 300", World = 3, Multiplier = 2000, Rebirth = 300, IsRobux = false},
    {Id = "25", Name = "Multiplicador 600x - Robux", World = 3, Multiplier = 600, Rebirth = 0, IsRobux = true, GamepassId = 1931106296},
    {Id = "26", Name = "Multiplicador 1.2Kx - Robux", World = 3, Multiplier = 1200, Rebirth = 0, IsRobux = true, GamepassId = 1929169918},
    {Id = "27", Name = "Multiplicador 2.5Kx - Robux", World = 3, Multiplier = 2500, Rebirth = 0, IsRobux = true, GamepassId = 1927364032},

    -- Mundo 4
    {Id = "28", Name = "Multiplicador 2Kx - Rebirth 0", World = 4, Multiplier = 2000, Rebirth = 0, IsRobux = false},
    {Id = "29", Name = "Multiplicador 6Kx - Rebirth 350", World = 4, Multiplier = 6000, Rebirth = 350, IsRobux = false},
    {Id = "30", Name = "Multiplicador 10Kx - Rebirth 400", World = 4, Multiplier = 10000, Rebirth = 400, IsRobux = false},
    {Id = "31", Name = "Multiplicador 15Kx - Rebirth 450", World = 4, Multiplier = 15000, Rebirth = 450, IsRobux = false},
    {Id = "32", Name = "Multiplicador 20Kx - Rebirth 500", World = 4, Multiplier = 20000, Rebirth = 500, IsRobux = false},
    {Id = "33", Name = "Multiplicador 25Kx - Rebirth 550", World = 4, Multiplier = 25000, Rebirth = 550, IsRobux = false},
    {Id = "34", Name = "Multiplicador 8Kx - Robux", World = 4, Multiplier = 8000, Rebirth = 0, IsRobux = true, GamepassId = 1931106296},
    {Id = "35", Name = "Multiplicador 18Kx - Robux", World = 4, Multiplier = 18000, Rebirth = 0, IsRobux = true, GamepassId = 1929169918},
    {Id = "36", Name = "Multiplicador 35Kx - Robux", World = 4, Multiplier = 35000, Rebirth = 0, IsRobux = true, GamepassId = 1927364032},

    -- Mundo 5
    {Id = "37", Name = "Multiplicador 25Kx - Rebirth 0", World = 5, Multiplier = 25000, Rebirth = 0, IsRobux = false},
    {Id = "38", Name = "Multiplicador 60Kx - Rebirth 600", World = 5, Multiplier = 6000, Rebirth = 600, IsRobux = false},
    {Id = "39", Name = "Multiplicador 100Kx - Rebirth 650", World = 5, Multiplier = 100000, Rebirth = 650, IsRobux = false},
    {Id = "40", Name = "Multiplicador 150Kx - Rebirth 700", World = 5, Multiplier = 150000, Rebirth = 700, IsRobux = false},
    {Id = "41", Name = "Multiplicador 200Kx - Rebirth 750", World = 5, Multiplier = 200000, Rebirth = 750, IsRobux = false},
    {Id = "42", Name = "Multiplicador 250Kx - Rebirth 800", World = 5, Multiplier = 250000, Rebirth = 800, IsRobux = false},
    {Id = "43", Name = "Multiplicador 40Kx - Robux", World = 5, Multiplier = 40000, Rebirth = 0, IsRobux = true, GamepassId = 1931106296},
    {Id = "44", Name = "Multiplicador 180Kx - Robux", World = 5, Multiplier = 180000, Rebirth = 0, IsRobux = true, GamepassId = 1929169918},
    {Id = "45", Name = "Multiplicador 300Kx - Robux", World = 5, Multiplier = 300000, Rebirth = 0, IsRobux = true, GamepassId = 1927364032},

    -- Mundo 6
    {Id = "46", Name = "Multiplicador 250Kx - Rebirth 0", World = 6, Multiplier = 250000, Rebirth = 0, IsRobux = false},
    {Id = "47", Name = "Multiplicador 600Kx - Rebirth 850", World = 6, Multiplier = 600000, Rebirth = 850, IsRobux = false},
    {Id = "48", Name = "Multiplicador 1Mx - Rebirth 900", World = 6, Multiplier = 1000000, Rebirth = 900, IsRobux = false},
    {Id = "49", Name = "Multiplicador 1.5Mx - Rebirth 950", World = 6, Multiplier = 1500000, Rebirth = 950, IsRobux = false},
    {Id = "50", Name = "Multiplicador 2Mx - Rebirth 1000", World = 6, Multiplier = 2000000, Rebirth = 1000, IsRobux = false},
    {Id = "51", Name = "Multiplicador 2.5Mx - Rebirth 1050", World = 6, Multiplier = 2500000, Rebirth = 1050, IsRobux = false},
    {Id = "52", Name = "Multiplicador 400Kx - Robux", World = 6, Multiplier = 400000, Rebirth = 0, IsRobux = true, GamepassId = 1931106296},
    {Id = "53", Name = "Multiplicador 1.8Mx - Robux", World = 6, Multiplier = 1800000, Rebirth = 0, IsRobux = true, GamepassId = 1929169918},
    {Id = "54", Name = "Multiplicador 3Mx - Robux", World = 6, Multiplier = 3000000, Rebirth = 0, IsRobux = true, GamepassId = 1927364032},

    -- Mundo 7
    {Id = "55", Name = "Multiplicador 2.5Mx - Rebirth 0", World = 7, Multiplier = 2500000, Rebirth = 0, IsRobux = false},
    {Id = "56", Name = "Multiplicador 6Mx - Rebirth 1100", World = 7, Multiplier = 6000000, Rebirth = 1100, IsRobux = false},
    {Id = "57", Name = "Multiplicador 10Mx - Rebirth 1150", World = 7, Multiplier = 10000000, Rebirth = 1150, IsRobux = false},
    {Id = "58", Name = "Multiplicador 15Mx - Rebirth 1200", World = 7, Multiplier = 15000000, Rebirth = 1200, IsRobux = false},
    {Id = "59", Name = "Multiplicador 20Mx - Rebirth 1250", World = 7, Multiplier = 20000000, Rebirth = 1250, IsRobux = false},
    {Id = "60", Name = "Multiplicador 25Mx - Rebirth 1300", World = 7, Multiplier = 25000000, Rebirth = 1300, IsRobux = false},
    {Id = "61", Name = "Multiplicador 4Mx - Robux", World = 7, Multiplier = 4000000, Rebirth = 0, IsRobux = true, GamepassId = 1931106296},
    {Id = "62", Name = "Multiplicador 18Mx - Robux", World = 7, Multiplier = 18000000, Rebirth = 0, IsRobux = true, GamepassId = 1929169918},
    {Id = "63", Name = "Multiplicador 30Mx - Robux", World = 7, Multiplier = 30000000, Rebirth = 0, IsRobux = true, GamepassId = 1927364032},

    -- Mundo 8
    {Id = "64", Name = "Multiplicador 25Mx - Rebirth 0", World = 8, Multiplier = 25000000, Rebirth = 0, IsRobux = false},
    {Id = "65", Name = "Multiplicador 60Mx - Rebirth 1350", World = 8, Multiplier = 60000000, Rebirth = 1350, IsRobux = false},
    {Id = "66", Name = "Multiplicador 100Mx - Rebirth 1400", World = 8, Multiplier = 100000000, Rebirth = 1400, IsRobux = false},
    {Id = "67", Name = "Multiplicador 150Mx - Rebirth 1450", World = 8, Multiplier = 150000000, Rebirth = 1450, IsRobux = false},
    {Id = "68", Name = "Multiplicador 200Mx - Rebirth 1500", World = 8, Multiplier = 200000000, Rebirth = 1500, IsRobux = false},
    {Id = "69", Name = "Multiplicador 250Mx - Rebirth 1550", World = 8, Multiplier = 250000000, Rebirth = 1550, IsRobux = false},
    {Id = "70", Name = "Multiplicador 40Mx - Robux", World = 8, Multiplier = 40000000, Rebirth = 0, IsRobux = true, GamepassId = 1931106296},
    {Id = "71", Name = "Multiplicador 180Mx - Robux", World = 8, Multiplier = 180000000, Rebirth = 0, IsRobux = true, GamepassId = 1929169918},
    {Id = "72", Name = "Multiplicador 300Mx - Robux", World = 8, Multiplier = 300000000, Rebirth = 0, IsRobux = true, GamepassId = 1927364032},

    -- Mundo 9
    {Id = "73", Name = "Multiplicador 250Mx - Rebirth 0", World = 9, Multiplier = 250000000, Rebirth = 0, IsRobux = false},
    {Id = "74", Name = "Multiplicador 600Mx - Rebirth 1600", World = 9, Multiplier = 600000000, Rebirth = 1600, IsRobux = false},
    {Id = "75", Name = "Multiplicador 1Bx - Rebirth 1650", World = 9, Multiplier = 1000000000, Rebirth = 1650, IsRobux = false},
    {Id = "76", Name = "Multiplicador 1.5Bx - Rebirth 1700", World = 9, Multiplier = 1500000000, Rebirth = 1700, IsRobux = false},
    {Id = "77", Name = "Multiplicador 2Bx - Rebirth 1750", World = 9, Multiplier = 2000000000, Rebirth = 1750, IsRobux = false},
    {Id = "78", Name = "Multiplicador 2.5Bx - Rebirth 1800", World = 9, Multiplier = 2500000000, Rebirth = 1800, IsRobux = false},
    {Id = "79", Name = "Multiplicador 400Mx - Robux", World = 9, Multiplier = 400000000, Rebirth = 0, IsRobux = true, GamepassId = 1931106296},
    {Id = "80", Name = "Multiplicador 1.8Bx - Robux", World = 9, Multiplier = 1800000000, Rebirth = 0, IsRobux = true, GamepassId = 1929169918},
    {Id = "81", Name = "Multiplicador 3Bx - Robux", World = 9, Multiplier = 3000000000, Rebirth = 0, IsRobux = true, GamepassId = 1927364032}
}

local function getZonesForWorld(worldId, filterType)
    local list = {
        {Id = "auto", Name = "⭐ Auto - Melhor Zona"}
    }
    local wNum = nil
    if worldId and worldId ~= "auto" then
        wNum = tonumber(string.match(tostring(worldId), "%d+"))
    end
    local fType = filterType or Config.TrainZoneFilter or "all"
    for _, z in ipairs(AllTrainingZones) do
        if not wNum or z.World == wNum then
            if fType == "all" then
                table.insert(list, z)
            elseif fType == "free" and not z.IsRobux then
                table.insert(list, z)
            elseif fType == "robux" and z.IsRobux then
                table.insert(list, z)
            end
        end
    end
    return list
end

local AllTitlesList = {
    -- 🥚 Chocar Ovos (Sorte)
    {Id = "shell_breaker", Name = "Sidekick (+25% Sorte)"},
    {Id = "celestial", Name = "Beast Tamer (+75% Sorte)"},
    {Id = "hatchaholic", Name = "Beastmaster (+150% Sorte)"},
    {Id = "mother_of_dragons", Name = "Legion Commander (+300% Sorte)"},
    {Id = "beast_god", Name = "Beast God (+500% Sorte)"},

    -- ⚔️ Inimigos Derrotados (Dano)
    {Id = "rising_star", Name = "Vigilante (+25% Dano)"},
    {Id = "vigilante", Name = "Crimefighter (+75% Dano)"},
    {Id = "infernal", Name = "City Guardian (+150% Dano)"},
    {Id = "worlds_strongest", Name = "Legendary Hero (+300% Dano)"},
    {Id = "the_immortal", Name = "The Immortal (+500% Dano)"},

    -- 💀 Bosses Derrotados (Vitórias & Tokens)
    {Id = "giant_slayer", Name = "Villain Hunter (+15% Vitórias, +15% Tokens)"},
    {Id = "stormbringer", Name = "Nemesis (+45% Vitórias, +45% Tokens)"},
    {Id = "kingslayer", Name = "Villain Slayer (+90% Vitórias, +90% Tokens)"},
    {Id = "godslayer", Name = "Overlord Hunter (+180% Vitórias, +180% Tokens)"},
    {Id = "world_ender", Name = "Archenemy (+300% Vitórias, +300% Tokens)"},

    -- 🛡️ Invasões / Raids (Tokens)
    {Id = "breach_specialist", Name = "Team Player (+25% Tokens)"},
    {Id = "voidborn", Name = "Strike Leader (+75% Tokens)"},
    {Id = "last_one_standing", Name = "Raid Commander (+150% Tokens)"},
    {Id = "calamity", Name = "War Legend (+300% Tokens)"},
    {Id = "warbringer", Name = "Warbringer (+500% Tokens)"},

    -- 🏺 Coleção de Itens / Artefatos (Sorte)
    {Id = "scavenger", Name = "Scavenger (+25% Sorte)"},
    {Id = "relic_hunter", Name = "Relic Hunter (+75% Sorte)"},
    {Id = "prismatic", Name = "Relic Curator (+150% Sorte)"},
    {Id = "vault_keeper", Name = "Vault Keeper (+300% Sorte)"},
    {Id = "ancient_one", Name = "Ancient One (+500% Sorte)"},

    -- 🌀 Ondas do Endless (Tokens)
    {Id = "survivor", Name = "Survivor (+25% Tokens)"},
    {Id = "unyielding", Name = "Last Stand (+75% Tokens)"},
    {Id = "beyond_limits", Name = "Unbreakable (+150% Tokens)"},
    {Id = "the_endless", Name = "The Endless (+300% Tokens)"},
    {Id = "eternity", Name = "Eternity (+500% Tokens)"},

    -- 👊 Inimigos do Endless (Velocidade de Ataque)
    {Id = "crowd_control", Name = "Skirmisher (+25% Vel. Ataque)"},
    {Id = "horde_breaker", Name = "Horde Breaker (+75% Vel. Ataque)"},
    {Id = "walking_disaster", Name = "Wave Crusher (+150% Vel. Ataque)"},
    {Id = "extinction_event", Name = "Army Breaker (+300% Vel. Ataque)"},
    {Id = "apocalypse", Name = "Unstoppable Force (+500% Vel. Ataque)"},

    -- 🏆 Win Pads (Vitórias)
    {Id = "victory_lap", Name = "Contender (+25% Vitórias)"},
    {Id = "repeat_offender", Name = "Champion (+75% Vitórias)"},
    {Id = "born_to_win", Name = "Unstoppable (+150% Vitórias)"},
    {Id = "unstoppable", Name = "Undefeated (+300% Vitórias)"},
    {Id = "hall_of_famer", Name = "Hall of Famer (+500% Vitórias)"},

    -- 📜 Missões (Dano & Sorte)
    {Id = "quester", Name = "Do-Gooder (+15% Dano, +15% Sorte)"},
    {Id = "taskmaster", Name = "Taskmaster (+45% Dano, +45% Sorte)"},
    {Id = "relentless", Name = "Relentless (+90% Dano, +90% Sorte)"},
    {Id = "living_legend", Name = "Living Legend (+180% Dano, +180% Sorte)"},
    {Id = "mythic_hero", Name = "Mythic Hero (+300% Dano, +300% Sorte)"},

    -- ⚔️ PvP Kills (Dano)
    {Id = "pvp_kills_1", Name = "Fighter (+25% Dano)"},
    {Id = "pvp_kills_2", Name = "Brawler (+75% Dano)"},
    {Id = "pvp_kills_3", Name = "Slayer (+150% Dano)"},
    {Id = "pvp_kills_4", Name = "Executioner (+300% Dano)"},
    {Id = "pvp_kills_5", Name = "Bloodthirsty (+500% Dano)"},

    -- 🛡️ PvP Vitórias (Vida)
    {Id = "pvp_wins_1", Name = "Challenger (+10 Vida)"},
    {Id = "pvp_wins_2", Name = "Victor (+30 Vida)"},
    {Id = "pvp_wins_3", Name = "Conqueror (+75 Vida)"},
    {Id = "pvp_wins_4", Name = "Warlord (+150 Vida)"},
    {Id = "pvp_wins_5", Name = "Arena Champion (+300 Vida)"}
}

pcall(function()
    local tConfig = ReplicatedStorage.Shared.Config:FindFirstChild("TitlesConfig")
    if tConfig then
        local cfg = require(tConfig)
        if type(cfg) == "table" then
            local temp = {}
            for id, data in pairs(cfg) do
                local buffDesc = ""
                if data.Buffs and #data.Buffs > 0 then
                    local parts = {}
                    for _, b in ipairs(data.Buffs) do
                        local amount = b.Amount or 0
                        local str = ""
                        if b.Type == "Health" then
                            str = string.format("+%d Vida", amount)
                        elseif b.Type == "DamageMult" or b.Type == "Damage" then
                            str = string.format("+%d%% Dano", math.floor(amount * 100 + 0.5))
                        elseif b.Type == "AttackSpeed" then
                            str = string.format("+%d%% Vel. Ataque", math.floor(amount * 100 + 0.5))
                        elseif b.Type == "Luck" then
                            str = string.format("+%d%% Sorte", math.floor(amount * 100 + 0.5))
                        elseif b.Type == "Wins" then
                            str = string.format("+%d%% Vitórias", math.floor(amount * 100 + 0.5))
                        elseif b.Type == "Tokens" then
                            str = string.format("+%d%% Tokens", math.floor(amount * 100 + 0.5))
                        elseif b.Type == "Speed" then
                            str = string.format("+%d Velocidade", amount)
                        else
                            str = string.format("+%s %s", tostring(amount), tostring(b.Type))
                        end
                        table.insert(parts, str)
                    end
                    buffDesc = " (" .. table.concat(parts, ", ") .. ")"
                end
                table.insert(temp, {
                    Id = tostring(id),
                    Name = (data.Name or tostring(id)) .. buffDesc,
                    Order = data.Order or 9999
                })
            end
            if #temp > 4 then
                table.sort(temp, function(a, b)
                    if (a.Order or 9999) ~= (b.Order or 9999) then
                        return (a.Order or 9999) < (b.Order or 9999)
                    end
                    return a.Name < b.Name
                end)
                AllTitlesList = temp
            end
        end
    end
end)

local currentEquippedTitle = nil

equipTitle = function(titleId)
    if not titleId or not RemoteEquipTitle then return end
    pcall(function()
        RemoteEquipTitle:InvokeServer(titleId)
        currentEquippedTitle = titleId
        task.defer(function()
            if updateTitleCardVisual then updateTitleCardVisual() end
        end)
    end)
end

local function getDesiredTitleForCurrentActivity()
    -- 1. Arena Boss (Prioridade Máxima de Eventos)
    local inBoss = (isBossFighting == true) or (isBossActive and isBossActive())
    if inBoss then
        if Config.TitleBossEnabled and Config.TitleBoss and Config.TitleBoss ~= "" then
            return Config.TitleBoss
        end
    end
    
    -- 2. Raid / Invasão
    local inRaid = (isRaidActive and isRaidActive()) or (isInsideRaid and isInsideRaid())
    if inRaid then
        if Config.TitleRaidEnabled and Config.TitleRaid and Config.TitleRaid ~= "" then
            return Config.TitleRaid
        end
    end
    
    -- 3. PvP (Combate contra Jogadores)
    if isPvpFighting then
        if Config.TitlePvpEnabled and Config.TitlePvp and Config.TitlePvp ~= "" then
            return Config.TitlePvp
        end
    end
    
    -- 4. Auto CO-OP / Endless
    local inEndless = (isInsideEndless and isInsideEndless()) or (Config.AutoEndless and not inBoss and not inRaid)
    if inEndless then
        if Config.TitleCoopEnabled and Config.TitleCoop and Config.TitleCoop ~= "" then
            return Config.TitleCoop
        end
    end
    
    -- 5. Auto Win / Progressão de Estágios
    if Config.AutoWin and not inBoss and not inRaid and not inEndless then
        if Config.TitleWinEnabled and Config.TitleWin and Config.TitleWin ~= "" then
            return Config.TitleWin
        end
    end
    
    -- 6. Chocar Ovos (Auto Egg / Hatch)
    local isHatching = (Config.AutoHatch or Config.AutoHatchMultiple) and not inBoss and not inRaid and not inEndless and not Config.AutoWin
    if isHatching then
        if Config.TitleEggEnabled and Config.TitleEgg and Config.TitleEgg ~= "" then
            return Config.TitleEgg
        end
    end
    
    -- 7. Treino (Auto Treino)
    if Config.AutoTrain and not inBoss and not inRaid and not inEndless and not Config.AutoWin then
        if Config.TitleTrainEnabled and Config.TitleTrain and Config.TitleTrain ~= "" then
            return Config.TitleTrain
        end
    end
    
    return nil
end

autoSyncActiveTitle = function(force)
    if not RemoteEquipTitle then return end
    pcall(function()
        local desired = getDesiredTitleForCurrentActivity()
        if desired and desired ~= "" and (force or desired ~= currentEquippedTitle) then
            RemoteEquipTitle:InvokeServer(desired)
            currentEquippedTitle = desired
            task.defer(function()
                if updateTitleCardVisual then updateTitleCardVisual() end
            end)
        end
    end)
end

-- Thread contínua para manter o título correto equipado em tempo real para o modo em execução
spawnThread(function()
    while true do
        pcall(function() autoSyncActiveTitle(false) end)
        task.wait(1.0)
    end
end)

local function getCurrentMap()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return workspace:FindFirstChild("Map") end
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
    return bestMap or workspace:FindFirstChild("Map")
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
        for i = 1, 135 do table.insert(list, {Id = "Stage" .. i, Name = "Estágio " .. i}) end
        return list
    end
    for i = 1, 15 do table.insert(list, {Id = "Stage" .. i, Name = "Estágio " .. i}) end
    return list
end

-- ══════════════════════════════════════════════════════════════
--  DESIGN SYSTEM & INTERFACE VISUAL (PORTUGUÊS)
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
    Accent2 = Color3.fromRGB(56, 122, 255),    -- Azul Neon Vibrante das Fotos
    Text = Color3.fromRGB(245, 245, 252),
    TextDim = Color3.fromRGB(150, 155, 175),
    Success = Color3.fromRGB(46, 204, 113),    -- Verde das Fotos
    ToggleInactive = Color3.fromRGB(36, 42, 60),
    Warning = Color3.fromRGB(255, 185, 55),
    Error = Color3.fromRGB(255, 75, 75)
}

-- ══════════════════════════════════════════════════════════════
--  1. MINIBAR (COM ESTATÍSTICAS DE REBIRTH EM TEMPO REAL) [FOTO 1]
-- ══════════════════════════════════════════════════════════════
do
    --  1. MINIBAR (COM ESTATÍSTICAS DE REBIRTH EM TEMPO REAL) [FOTO 1]
    MiniBar = Instance.new("Frame")
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

    -- Estatísticas na MiniBar incluindo FPS, Ping E REBIRTHS!
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

    -- ️ 2. JANELA PRINCIPAL
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 720, 0, 490)
    MainFrame.Position = UDim2.new(0.5, -360, 0.5, -245)
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
    SubtitleLabel.Text = "Master Hub | " .. LocalPlayer.DisplayName
    SubtitleLabel.TextColor3 = Themes.TextDim
    SubtitleLabel.TextSize = 11
    SubtitleLabel.Font = Enum.Font.GothamMedium
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.Parent = Topbar

    HeaderStats = Instance.new("TextLabel")
    HeaderStats.Name = "HeaderStats"
    HeaderStats.Size = UDim2.new(0, 215, 0, 26)
    HeaderStats.Position = UDim2.new(1, -300, 0.5, -13)
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

    --  MINIMIZAR / ABRIR
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
                    MiniBar.Position = UDim2.new(0.5, -190, -0.15, 0)
                    TweenService:Create(MiniBar, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0.5, -190, 0.04, 0)
                    }):Play()
                end
            end)
        else
            local tweenBarOut = TweenService:Create(MiniBar, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -190, -0.15, 0)
            })
            tweenBarOut:Play()
            tweenBarOut.Completed:Connect(function()
                MiniBar.Visible = false
                MainFrame.Visible = true
                TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.5, -360, 0.5, -245)
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

    -- Smooth Draggable
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
end

-- Continuous FPS, Ping & REBIRTHS STATS na MiniBar e Topbar!
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
        
        HeaderStats.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end))

-- Sidebar & Tabs
do
    Sidebar = Instance.new("Frame")
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

    PageContainer = Instance.new("Frame")
    PageContainer.Name = "PageContainer"
    PageContainer.Size = UDim2.new(1, -160, 1, -56)
    PageContainer.Position = UDim2.new(0, 160, 0, 56)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainFrame
end

createTab = function(name, icon, layoutOrder)
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
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            onTabSelect()
        end
    end)
    return page
end

-- 7 Abas Organizadas
local TreinoTab = createTab("Treino", "⚡", 1)
local FarmTab = createTab("Farm", "🏆", 2)
local OvosTab = createTab("Ovos", "🥚", 3)
local TitulosTab = createTab("Títulos", "👑", 4)
local EventosTab = createTab("Eventos", "⚔️", 5)
local PvpTab = createTab("PvP", "🥊", 6)
local ConfigTab = createTab("Config", "⚙️", 7)

-- ══════════════════════════════════════════════════════════════
-- ️ COMPONENTES VISUAIS (EXATOS DAS FOTOS)
-- ══════════════════════════════════════════════════════════════

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
        if Config.AutoSaveSettings then saveConfig() end
    end
    
    card.Activated:Connect(onToggle)
    card.MouseButton1Click:Connect(onToggle)
    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            onToggle()
        end
    end)
    
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

-- 5. Interactive WalkSpeed Controller
local function createWalkSpeedControl(parent)
    local card = Instance.new("Frame")
    card.Name = "WalkSpeed_Card"
    card.Size = UDim2.new(1, 0, 0, 116)
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
    titleLbl.Size = UDim2.new(1, -74, 0, 26)
    titleLbl.Position = UDim2.new(0, 14, 0, 8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "Velocidade do Jogador"
    titleLbl.TextColor3 = Themes.Text
    titleLbl.TextSize = 13
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 46, 0, 24)
    toggleBtn.Position = UDim2.new(1, -58, 0, 9)
    toggleBtn.BackgroundColor3 = Config.WalkSpeedEnabled and Themes.Accent2 or Themes.Header
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = card
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn
    
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Thickness = 1
    toggleStroke.Color = Themes.CardBorder
    toggleStroke.Parent = toggleBtn
    
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 18, 0, 18)
    thumb.Position = Config.WalkSpeedEnabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    thumb.BackgroundColor3 = Themes.Text
    thumb.BorderSizePixel = 0
    thumb.Parent = toggleBtn
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb
    
    local controlsRow = Instance.new("Frame")
    controlsRow.Size = UDim2.new(1, -28, 0, 32)
    controlsRow.Position = UDim2.new(0, 14, 0, 40)
    controlsRow.BackgroundTransparency = 1
    controlsRow.Parent = card
    
    local ctrlLayout = Instance.new("UIListLayout")
    ctrlLayout.FillDirection = Enum.FillDirection.Horizontal
    ctrlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ctrlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ctrlLayout.Padding = UDim.new(0, 6)
    ctrlLayout.Parent = controlsRow
    
    local speedBox = nil
    
    local function applySpeed(newSpeed, enableIfDisabled)
        Config.WalkSpeed = math.clamp(math.floor(newSpeed), 16, 500)
        if enableIfDisabled then
            Config.WalkSpeedEnabled = true
        end
        
        local targetPos = Config.WalkSpeedEnabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        local targetColor = Config.WalkSpeedEnabled and Themes.Accent2 or Themes.Header
        TweenService:Create(thumb, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Config.WalkSpeedEnabled and Config.WalkSpeed or 16
        end
        
        if speedBox then
            speedBox.Text = tostring(Config.WalkSpeed)
        end
    end
    
    local function createAdjustBtn(text, width, delta)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, width, 0, 30)
        btn.BackgroundColor3 = Themes.Header
        btn.Text = text
        btn.TextColor3 = Themes.TextDim
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.AutoButtonColor = false
        btn.Parent = controlsRow
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn
        
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = Themes.CardBorder
        stroke.Parent = btn
        
        btn.Activated:Connect(function()
            applySpeed(Config.WalkSpeed + delta, true)
        end)
        return btn
    end
    
    createAdjustBtn("-10", 42, -10)
    createAdjustBtn("-5", 38, -5)
    
    speedBox = Instance.new("TextBox")
    speedBox.Name = "SpeedBox"
    speedBox.Size = UDim2.new(0, 80, 0, 30)
    speedBox.BackgroundColor3 = Themes.Background
    speedBox.Text = tostring(Config.WalkSpeed)
    speedBox.TextColor3 = Themes.Accent2
    speedBox.TextSize = 14
    speedBox.Font = Enum.Font.GothamBold
    speedBox.ClearTextOnFocus = false
    speedBox.Parent = controlsRow
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = speedBox
    
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Thickness = 1
    boxStroke.Color = Themes.CardBorder
    boxStroke.Parent = speedBox
    
    speedBox.FocusLost:Connect(function()
        local num = tonumber(speedBox.Text)
        if num then
            applySpeed(num, true)
        end
        speedBox.Text = tostring(Config.WalkSpeed)
    end)
    
    createAdjustBtn("+5", 38, 5)
    createAdjustBtn("+10", 42, 10)
    
    local presetsRow = Instance.new("Frame")
    presetsRow.Size = UDim2.new(1, -28, 0, 26)
    presetsRow.Position = UDim2.new(0, 14, 0, 78)
    presetsRow.BackgroundTransparency = 1
    presetsRow.Parent = card
    
    local preLayout = Instance.new("UIListLayout")
    preLayout.FillDirection = Enum.FillDirection.Horizontal
    preLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    preLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    preLayout.Padding = UDim.new(0, 6)
    preLayout.Parent = presetsRow
    
    local presets = {
        {name = "16", val = 16},
        {name = "50", val = 50},
        {name = "100", val = 100},
        {name = "200", val = 200}
    }
    
    for _, p in ipairs(presets) do
        local pBtn = Instance.new("TextButton")
        pBtn.Size = UDim2.new(0, 72, 0, 22)
        pBtn.BackgroundColor3 = Themes.Header
        pBtn.Text = p.name
        pBtn.TextColor3 = Themes.TextDim
        pBtn.TextSize = 9
        pBtn.Font = Enum.Font.GothamBold
        pBtn.AutoButtonColor = false
        pBtn.Parent = presetsRow
        
        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(0, 5)
        pCorner.Parent = pBtn
        
        local pStroke = Instance.new("UIStroke")
        pStroke.Thickness = 1
        pStroke.Color = Themes.CardBorder
        pStroke.Parent = pBtn
        
        pBtn.Activated:Connect(function()
            applySpeed(p.val, true)
        end)
    end
    
    toggleBtn.Activated:Connect(function()
        Config.WalkSpeedEnabled = not Config.WalkSpeedEnabled
        applySpeed(Config.WalkSpeed, false)
    end)
    
    return card
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
            if Config.AutoSaveSettings then saveConfig() end
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
                if Config.AutoSaveSettings then saveConfig() end
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
                    if onSelected then onSelected(options[1].Id, options[1].Name) end
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
    statusBadge.RichText = false
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

-- ══════════════════════════════════════════════════════════════
--  1. ABA CLIQUE & REBIRTH [SEÇÃO CLIQUE]
-- ══════════════════════════════════════════════════════════════
createSectionHeader(TreinoTab, "⚡ CLIQUE & REBIRTH")

MainStatsCard = createInfoCard(TreinoTab, "📊 Estatísticas em Tempo Real", "Clicks: 0 | Rebirths: 0", Themes.Accent2)

FastClickToggle = createToggle(TreinoTab, "Auto Click (Fast Click)", Config.FastClick, function(val)
    Config.FastClick = val
end)

createSlider(TreinoTab, "Velocidade de Cliques por Segundo (CPS)", 1, 50, Config.ClickCPS, "", false, function(val)
    Config.ClickCPS = val
end)

RebirthToggle = createToggle(TreinoTab, "Auto Rebirth", Config.AutoRebirth, function(val)
    Config.AutoRebirth = val
end)

createSlider(TreinoTab, "Intervalo de Rebirth (segundos)", 0.5, 5, Config.RebirthDelay, "s", false, function(val)
    Config.RebirthDelay = val
end)

-- ══════════════════════════════════════════════════════════════
--  2. SEÇÃO DE AUTO TREINO INTELIGENTE COM EMOJI DE MÚSCULO 💪
-- ══════════════════════════════════════════════════════════════
createSectionHeader(TreinoTab, "💪 AUTO TREINO INTELIGENTE")

createLabel(TreinoTab, "Modo de Posicionamento / Ataque:")
createDropdown(TreinoTab, "", TrainPositioningOptions, Config.TrainPositioning, function(posId)
    Config.TrainPositioning = posId
end)

createSlider(TreinoTab, "Distância no Pad (Modo A Distância)", 2.0, 8.0, Config.TrainDistanceOffset or 5.0, " studs", true, function(val)
    Config.TrainDistanceOffset = val
end)

createLabel(TreinoTab, "Mundo de Treino:")

local trainZoneDropdown = nil
createDropdown(TreinoTab, "", TrainingWorldsList, Config.SelectedTrainWorld, function(worldId)
    Config.SelectedTrainWorld = worldId
    if trainZoneDropdown and trainZoneDropdown.UpdateOptions then
        local newOptions = getZonesForWorld(worldId, Config.TrainZoneFilter)
        trainZoneDropdown.UpdateOptions(newOptions, "auto")
        Config.SelectedTrainZone = "auto"
    end
end)

createLabel(TreinoTab, "Filtro de Zonas (Grátis / Robux):")

createDropdown(TreinoTab, "", TrainingFilterOptions, Config.TrainZoneFilter or "all", function(filterId)
    Config.TrainZoneFilter = filterId
    if trainZoneDropdown and trainZoneDropdown.UpdateOptions then
        local newOptions = getZonesForWorld(Config.SelectedTrainWorld, filterId)
        trainZoneDropdown.UpdateOptions(newOptions, "auto")
        Config.SelectedTrainZone = "auto"
    end
end)

createLabel(TreinoTab, "Zona de Treino:")

trainZoneDropdown = createDropdown(TreinoTab, "", getZonesForWorld(Config.SelectedTrainWorld, Config.TrainZoneFilter), Config.SelectedTrainZone, function(id)
    Config.SelectedTrainZone = id
end)

TrainToggle = createToggle(TreinoTab, "Auto Treino", Config.AutoTrain, function(val)
    Config.AutoTrain = val
    if val then
        Config.AutoEndless = false
        if EndlessToggle and EndlessToggle.Set then EndlessToggle.Set(false, true) end
        if Config.TitleTrainEnabled then equipTitle(Config.TitleTrain) end
    end
end)

local function isPaidOrRobuxZone(inst)
    if not inst then return false end
    local zNum = tonumber(inst.Name:match("^TrainingZone(%d+)$")) or tonumber(inst:GetAttribute("ZoneId"))
    if zNum then
        for _, z in ipairs(AllTrainingZones) do
            if tonumber(z.Id) == zNum then
                return z.IsRobux == true
            end
        end
    end
    local hb = inst:FindFirstChild("Hitbox")
    local bb = hb and hb:FindFirstChild("TrainingZoneBillboard")
    if bb then
        local gp = bb:FindFirstChild("GamepassRequirement")
        if gp and gp.Visible then return true end
        local reb = bb:FindFirstChild("RebirthRequirement")
        if reb and reb.Visible then return false end
    end
    if inst:GetAttribute("IsRobux") == true or inst:GetAttribute("GamepassId") then return true end
    return false
end

local ownedGamepassesCache = {}

local function ownsGamepass(gamepassId)
    if not gamepassId then return false end
    if ownedGamepassesCache[gamepassId] ~= nil then
        return ownedGamepassesCache[gamepassId]
    end
    local s, res = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, gamepassId)
    end)
    local owns = (s and res == true)
    ownedGamepassesCache[gamepassId] = owns
    return owns
end

local function getPlayerRebirths()
    local rebirths = 0
    pcall(function()
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        local r = ls and ls:FindFirstChild("Rebirths")
        if r then rebirths = tonumber(r.Value) or 0 end
    end)
    if rebirths <= 0 then
        pcall(function()
            local DC = require(ReplicatedStorage.Client.DataController)
            local d = DC and DC.getData and DC.getData()
            if d then
                rebirths = tonumber(d.Rebirths or d.Rebirth or d.rebirths) or rebirths
            end
        end)
    end
    return rebirths
end

local function findTrainingBag(worldNum, zoneId)
    local targetZoneStr = tostring(zoneId)
    local targetModelName = "TrainingZone" .. targetZoneStr
    
    -- 1. Busca rápida em CollectionService
    for _, tz in ipairs(CollectionService:GetTagged("TrainingZone")) do
        if tz:GetAttribute("ZoneId") == targetZoneStr or tz.Name == targetModelName then
            local bag = tz:FindFirstChild("PunchingBag")
            local hb = tz:FindFirstChild("Hitbox")
            if bag or hb then
                return bag, hb, tz
            end
        end
    end
    
    -- 2. Busca na hierarquia do mapa correspondente
    local mapName = (worldNum == 1 and "Map") or (worldNum == 2 and "MapTest") or ("Map" .. tostring(worldNum))
    local map = workspace:FindFirstChild(mapName) or getCurrentMap()
    if map then
        local tzFolder = map:FindFirstChild("TrainingZone") or (map:FindFirstChild("Lobby") and map.Lobby:FindFirstChild("Decor") and map.Lobby.Decor:FindFirstChild("Extra"))
        if tzFolder then
            local tz = tzFolder:FindFirstChild(targetModelName)
            if tz then
                local bag = tz:FindFirstChild("PunchingBag")
                local hb = tz:FindFirstChild("Hitbox")
                if bag or hb then return bag, hb, tz end
            end
        end
        for _, d in ipairs(map:GetDescendants()) do
            if d:IsA("Model") and (d.Name == targetModelName or d:GetAttribute("ZoneId") == targetZoneStr) then
                local bag = d:FindFirstChild("PunchingBag")
                local hb = d:FindFirstChild("Hitbox")
                if bag or hb then
                    return bag, hb, d
                end
            end
        end
    end
    return nil, nil, nil
end

local function getBestUnlockedZone(specificWorld, filterType)
    local rebirths = getPlayerRebirths()
    local targetFilter = filterType or Config.TrainZoneFilter or "all"
    
    local targetWorldNum = nil
    if specificWorld and specificWorld ~= "auto" then
        targetWorldNum = tonumber(string.match(tostring(specificWorld), "%d+"))
    end
    
    local best = nil
    local maxMult = -1
    
    -- Varre todas as zonas do AllTrainingZones (Mundos 1 a 9)
    for _, z in ipairs(AllTrainingZones) do
        if z.Id ~= "auto" then
            local worldMatches = (targetWorldNum == nil) or (z.World == targetWorldNum)
            if worldMatches then
                local isAllowed = false
                if z.IsRobux then
                    if targetFilter == "all" or targetFilter == "robux" then
                        if z.GamepassId and ownsGamepass(z.GamepassId) then
                            isAllowed = true
                        end
                    end
                else
                    if targetFilter == "all" or targetFilter == "free" then
                        local req = z.Rebirth or 0
                        if rebirths >= req then
                            isAllowed = true
                        end
                    end
                end
                
                if isAllowed then
                    local mult = z.Multiplier or 0
                    if mult > maxMult then
                        maxMult = mult
                        best = z
                    end
                end
            end
        end
    end
    
    return best or AllTrainingZones[1]
end

local cachedHitboxList = {}
local lastHitboxMapName = nil

local function getTrainingHitboxList()
    local curMap = getCurrentMap()
    local mapName = curMap and curMap.Name or "Map"
    if lastHitboxMapName == mapName and #cachedHitboxList > 0 then
        return cachedHitboxList
    end
    
    lastHitboxMapName = mapName
    cachedHitboxList = {}
    
    local containers = {}
    if curMap then
        local tz = curMap:FindFirstChild("TrainingZones") or curMap:FindFirstChild("Zones")
        if tz then table.insert(containers, tz) end
        table.insert(containers, curMap)
    end
    for _, extra in ipairs({"Map", "MapTest"}) do
        local m = workspace:FindFirstChild(extra)
        if m and m ~= curMap then
            local tz = m:FindFirstChild("TrainingZones") or m:FindFirstChild("Zones")
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

-- Helper ultra-leve para detectar saco de treino ou hitbox proximo ao jogador (0ms)
local function findNearbyTrainingHitbox(hrp, maxDist)
    if not hrp then return nil end
    local pPos = hrp.Position
    local bestHb = nil
    local bestDist = maxDist or 35
    
    local hitboxes = getTrainingHitboxList()
    for _, hb in ipairs(hitboxes) do
        if hb and hb.Parent then
            local dist = (hb.Position - pPos).Magnitude
            if dist < bestDist then
                bestDist = dist
                bestHb = hb
            end
        end
    end
    return bestHb
end

local cachedCombatEnemy = nil
local lastCombatEnemyTime = 0

-- Helper para detectar inimigo vivo proximo otimizado (com cache e busca direcionada, sem GetDescendants global)
local function findNearbyCombatEnemy(hrp, maxDist)
    if not hrp then return nil end
    local pPos = hrp.Position
    local bestDist = maxDist or 50
    local now = os.clock()
    
    -- Reutiliza alvo cacheado se ainda estiver vivo e dentro da proximidade (0ms)
    if cachedCombatEnemy and cachedCombatEnemy.Parent then
        local hum = cachedCombatEnemy:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            local eRoot = cachedCombatEnemy:FindFirstChild("HumanoidRootPart") or cachedCombatEnemy.PrimaryPart or cachedCombatEnemy:FindFirstChildWhichIsA("BasePart")
            if eRoot and (eRoot.Position - pPos).Magnitude <= (bestDist + 15) then
                return cachedCombatEnemy
            end
        end
    end
    
    -- Se realizou busca nos últimos 0.25s e não achou nada, evita re-escanear desnecessariamente a cada clique
    if now - lastCombatEnemyTime < 0.25 and cachedCombatEnemy == nil then
        return nil
    end
    lastCombatEnemyTime = now
    
    local bestEnemy = nil
    
    local function evaluateModel(m)
        if m:IsA("Model") and m ~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(m) then
            local hum = m:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local eRoot = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
                if eRoot then
                    local dist = (eRoot.Position - pPos).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestEnemy = m
                    end
                end
            end
        end
    end
    
    -- 1. Pastas e contêineres específicos onde inimigos realmente existem
    local containers = {}
    local curMap = getCurrentMap()
    if curMap then
        local st = curMap:FindFirstChild("Stages")
        if st then table.insert(containers, st) end
        local en = curMap:FindFirstChild("Enemies") or curMap:FindFirstChild("Mobs")
        if en then table.insert(containers, en) end
    end
    for _, name in ipairs({"Boss", "BossArena", "Raid", "ActiveRaid", "Endless", "Enemies", "Mobs"}) do
        local f = workspace:FindFirstChild(name)
        if f then table.insert(containers, f) end
    end
    
    for _, c in ipairs(containers) do
        for _, child in ipairs(c:GetChildren()) do
            evaluateModel(child)
            if child:IsA("Folder") or child:IsA("Model") then
                for _, sub in ipairs(child:GetChildren()) do
                    evaluateModel(sub)
                end
            end
        end
        if bestEnemy and bestDist < 20 then break end
    end
    
    -- 2. Se não achou em nenhuma pasta dedicada, checa filhos diretos do workspace
    if not bestEnemy then
        for _, child in ipairs(workspace:GetChildren()) do
            evaluateModel(child)
        end
    end
    
    cachedCombatEnemy = bestEnemy
    return bestEnemy
end

spawnThread(function()
    local lastBagHitbox = nil
    local lastBagCheck = 0
    local lastStatsUpdate = 0
    local lastTouchInterest = 0
    local lastVirtualClick = 0
    
    while true do
        if Config.FastClick then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not char or not hum or hum.Health <= 0 or not hrp then return end
                
                local now = os.clock()
                if now - lastBagCheck >= 0.5 then
                    lastBagCheck = now
                    lastBagHitbox = findNearbyTrainingHitbox(hrp, 30)
                end
                
                -- Se estiver perto de um saco de treino, aciona o hitbox suavemente sem inundar a física
                if lastBagHitbox and lastBagHitbox.Parent then
                    if now - lastTouchInterest >= 1.5 then
                        lastTouchInterest = now
                        if firetouchinterest then
                            firetouchinterest(hrp, lastBagHitbox, 0)
                            firetouchinterest(hrp, lastBagHitbox, 1)
                        end
                    end
                    if RemoteRequestTrain then
                        RemoteRequestTrain:FireServer()
                    end
                else
                    -- Se estiver perto de inimigo em combate, orienta para o inimigo somente se não estiver andando
                    local enemy = findNearbyCombatEnemy(hrp, 45)
                    if enemy then
                        local eRoot = enemy:FindFirstChild("HumanoidRootPart") or enemy.PrimaryPart or enemy:FindFirstChildWhichIsA("BasePart")
                        if eRoot and (not hum or hum.MoveDirection.Magnitude <= 0.05) then
                            local lookTarget = Vector3.new(eRoot.Position.X, hrp.Position.Y, eRoot.Position.Z)
                            hrp.CFrame = CFrame.lookAt(hrp.Position, lookTarget)
                        end
                    end
                end
                
                -- Dispara os remotes de ataque e clique diretamente na velocidade máxima sem congelar o cliente
                if RemoteRequestAttack then RemoteRequestAttack:FireServer() end
                if RemotePlayerClick then RemotePlayerClick:FireServer() end
                
                -- Aciona clique virtual suave para animar os golpes sem travar mouse ou câmera
                if now - lastVirtualClick >= 0.1 then
                    lastVirtualClick = now
                    pcall(function()
                        VirtualUser:ClickButton1(Vector2.new(100, 100))
                    end)
                end
                
                Config.ClicksCount = Config.ClicksCount + 1
            end)
            
            -- Atualiza o card de status a cada 0.25s para poupar renderização de UI
            local now = os.clock()
            if now - lastStatsUpdate >= 0.25 then
                lastStatsUpdate = now
                if MainStatsCard then
                    MainStatsCard.Update("Clicks: " .. Config.ClicksCount .. " | Rebirths: " .. SessionRebirths, Themes.Accent2)
                end
            end
        end
        local cps = math.clamp(Config.ClickCPS or 10, 1, 50)
        task.wait(1 / cps)
    end
end)

spawnThread(function()
    local lastDisabledBag = nil
    local lastTrainTouch = 0
    local lastTrainVClick = 0
    local currentTrainedBag = nil
    local lastPositionedMode = nil
    local lastPositionedDist = nil
    local lastPositionedZoneId = nil
    local isPositioned = false

    while true do
        if Config.AutoTrain and not isBossActive() and not Config.AutoEndless and not isInsideEndless() and not (isRaidActive() and Config.AutoEnterRaid) and not isInsideRaid() then
            pcall(function()
                if isBossActive() or Config.AutoEndless or isInsideEndless() or (isRaidActive() and Config.AutoEnterRaid) or isInsideRaid() then return end
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not char or not hum or hum.Health <= 0 or not hrp then
                    isPositioned = false
                    return
                end
                
                local targetZone = nil
                if Config.SelectedTrainZone == "auto" then
                    targetZone = getBestUnlockedZone(Config.SelectedTrainWorld, Config.TrainZoneFilter)
                else
                    for _, z in ipairs(AllTrainingZones) do
                        if z.Id == Config.SelectedTrainZone then
                            targetZone = z
                            break
                        end
                    end
                end
                if not targetZone then return end
                
                local wNum = targetZone.World or 1
                local mapName = (wNum == 1 and "Map") or (wNum == 2 and "MapTest") or ("Map" .. wNum)
                local curMap = getCurrentMap()
                if not curMap or curMap.Name ~= mapName then
                    if RemoteRequestWorldChange then
                        print(string.format("[Auto Treino] Mudando para o mundo da melhor zona (Mundo %d - %s)...", wNum, mapName))
                        RemoteRequestWorldChange:InvokeServer(wNum)
                        task.wait(1.5)
                        isPositioned = false
                        return
                    end
                end
                
                local bag, hitbox = findTrainingBag(wNum, targetZone.Id)
                if bag or hitbox then
                    -- Desativa colisão física das partes do PunchingBag (apenas 1 vez quando mudar de saco)
                    if bag and bag ~= lastDisabledBag then
                        lastDisabledBag = bag
                        for _, p in ipairs(bag:GetDescendants()) do
                            if p:IsA("BasePart") and p.CanCollide then
                                p.CanCollide = false
                            end
                        end
                    end
                    
                    local padCenter = (hitbox and hitbox.Position) or (bag and bag:GetPivot().Position)
                    local bagTargetPoint = (bag and bag:FindFirstChild("Bag") and bag.Bag:FindFirstChild("TargetPoint")) or (bag and bag:FindFirstChild("Bag") and bag.Bag:FindFirstChild("Pivot"))
                    local bagPos = (bagTargetPoint and bagTargetPoint.Position) or (bag and bag:GetPivot().Position) or padCenter
                    
                    -- Direção horizontal calculada a partir da orientação do pad
                    local forward = Vector3.new(0, 0, 1)
                    if hitbox then
                        local hLook = hitbox.CFrame.LookVector
                        local flatLook = Vector3.new(hLook.X, 0, hLook.Z)
                        if flatLook.Magnitude > 0.1 then
                            forward = flatLook.Unit
                        end
                    end
                    
                    local padRadius = (hitbox and math.min(hitbox.Size.X, hitbox.Size.Z) / 2) or 6.0
                    if padRadius < 2 then padRadius = 6.0 end
                    local maxSafeDist = math.max(1.8, padRadius - 0.8)
                    
                    -- Distância: Melee (colado no saco) vs A Distância (na borda da hitbox/pad, perfeitamente em cima do pad)
                    local targetDist = 1.8
                    if Config.TrainPositioning == "distance" then
                        targetDist = math.clamp(Config.TrainDistanceOffset or (maxSafeDist - 0.5), 2.2, maxSafeDist)
                    end
                    
                    local floorY = (hitbox and (hitbox.Position.Y + (hitbox.Size.Y / 2) + 2.6)) or (hrp.Position.Y)
                    local standPos = Vector3.new(padCenter.X + forward.X * targetDist, floorY, padCenter.Z + forward.Z * targetDist)
                    local targetCF = CFrame.lookAt(standPos, Vector3.new(bagPos.X, floorY, bagPos.Z))
                    
                    -- Se mudou de saco, de modo de ataque, de distância ou de zona, reposiciona imediatamente
                    local targetObj = bag or hitbox
                    if currentTrainedBag ~= targetObj or lastPositionedMode ~= Config.TrainPositioning or lastPositionedDist ~= targetDist or lastPositionedZoneId ~= targetZone.Id then
                        currentTrainedBag = targetObj
                        lastPositionedMode = Config.TrainPositioning
                        lastPositionedDist = targetDist
                        lastPositionedZoneId = targetZone.Id
                        isPositioned = false
                    end
                    
                    local currentDist = (hrp.Position - standPos).Magnitude
                    if not isPositioned or currentDist > 2.8 then
                        hrp.CFrame = targetCF
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                        isPositioned = true
                    end
                    
                    local now = os.clock()
                    -- Touch interest contínuo para manter registro no servidor (sem enviar 1 para não cortar a conexão da zona)
                    if hitbox and firetouchinterest and (now - lastTrainTouch >= 1.0) then
                        lastTrainTouch = now
                        firetouchinterest(hrp, hitbox, 0)
                    end
                    
                    if RemoteRequestTrain then RemoteRequestTrain:FireServer() end
                    if RemotePlayerClick then RemotePlayerClick:FireServer() end
                    if now - lastTrainVClick >= 0.1 then
                        lastTrainVClick = now
                        pcall(function()
                            VirtualUser:ClickButton1(Vector2.new(100, 100))
                        end)
                    end
                end
            end)
        else
            isPositioned = false
            currentTrainedBag = nil
            lastPositionedMode = nil
            lastPositionedDist = nil
            lastPositionedZoneId = nil
        end
        local cps = math.clamp(Config.ClickCPS or 5, 1, 50)
        task.wait(1 / cps)
    end
end)

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
                        if MainStatsCard then
                            MainStatsCard.Update("Clicks: " .. Config.ClicksCount .. " | Rebirths: " .. SessionRebirths, Themes.Accent2)
                        end
                    end
                end
            end)
        end
        task.wait(Config.RebirthDelay)
    end
end)

-- ══════════════════════════════════════════════════════════════
-- ️ 2. ABA FARM (PROGRESSÃO & ESTÁGIOS + CO-OP SEM FIM) [FOTO 2 & 3]
-- ══════════════════════════════════════════════════════════════
createSectionHeader(FarmTab, "🏆 PROGRESSÃO & ESTÁGIOS")

createLabel(FarmTab, "1. Selecione o Mundo:")

local stageProgDropdown = nil

local worldProgDropdown = createDropdown(FarmTab, "", WorldsData, Config.SelectedProgWorld, function(worldId)
    Config.SelectedProgWorld = worldId
    if stageProgDropdown then
        local opts = getStagesOptionsForWorld(worldId)
        local def = (opts[#opts] and opts[#opts].Id) or "Stage1"
        stageProgDropdown.UpdateOptions(opts, def)
        Config.SelectedProgStage = def
    end
end)

createLabel(FarmTab, "2. Até qual Estágio Progredir / Vencer:")

stageProgDropdown = createDropdown(FarmTab, "", getStagesOptionsForWorld(Config.SelectedProgWorld), Config.SelectedProgStage, function(stageId)
    Config.SelectedProgStage = stageId
end)

WinToggle = createToggle(FarmTab, "Auto Progressão Completa", Config.AutoWin, function(val)
    Config.AutoWin = val
    if val then
        Config.AutoEndless = false
        if EndlessToggle and EndlessToggle.Set then EndlessToggle.Set(false, true) end
        if Config.TitleWinEnabled then equipTitle(Config.TitleWin) end
    end
end)

createSlider(FarmTab, "Tempo de Combate por Estágio", 0.5, 10.0, Config.CombatTime, "s", true, function(val)
    Config.CombatTime = val
end)

createSectionHeader(FarmTab, "🌀 CO-OP SEM FIM")

local EndlessWorldsList = {
    {Id = "current", Name = "Mundo Atual / Mais Próximo"},
    {Id = "world9", Name = "Mundo 9"},
    {Id = "world8", Name = "Mundo 8"},
    {Id = "world7", Name = "Mundo 7"},
    {Id = "world6", Name = "Mundo 6"},
    {Id = "world5", Name = "Mundo 5"},
    {Id = "world4", Name = "Mundo 4"},
    {Id = "world3", Name = "Mundo 3"},
    {Id = "world2", Name = "Mundo 2"}
}

createLabel(FarmTab, "Selecione o Mundo do CO-OP:")
createDropdown(FarmTab, "", EndlessWorldsList, Config.EndlessWorld, function(worldId)
    Config.EndlessWorld = worldId
end)

EndlessToggle = createToggle(FarmTab, "Auto CO-OP Sem Fim", Config.AutoEndless, function(val)
    Config.AutoEndless = val
    if val then
        Config.AutoWin = false
        Config.AutoTrain = false
        if TrainToggle and TrainToggle.Set then TrainToggle.Set(false, true) end
        if WinToggle and WinToggle.Set then WinToggle.Set(false, true) end
        if Config.TitleCoopEnabled then equipTitle(Config.TitleCoop) end
    end
end)

createToggle(FarmTab, "Auto Hop se Bloqueado", Config.AutoHopBlocked, function(val)
    Config.AutoHopBlocked = val
end)

-- Farm Progressão Logic (Locks, Corredores & Vitória)
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

local function getStageFreePad(stageInstance)
    if not stageInstance then return nil end
    local padFolder = stageInstance:FindFirstChild("Pad")
    if not padFolder then return nil end
    local target = nil
    local free = padFolder:FindFirstChild("Free")
    if free then
        local padPart = free:FindFirstChild("Pad")
        if padPart and padPart:IsA("BasePart") then
            target = padPart
        else
            for _, child in ipairs(free:GetChildren()) do
                if child:IsA("BasePart") and (child.Name == "Pad" or child.BrickColor.Name == "New Yeller" or child.Name:lower():find("pad")) then
                    target = child
                    break
                end
            end
        end
    end
    if not target then
        local direct = padFolder:FindFirstChild("Pad")
        if direct and direct:IsA("BasePart") then target = direct end
    end
    if target then lockPadStationary(target) end
    return target
end

local function glideToCFrame(targetCFrame, speed, attackWhileMoving)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end
    
    local activeSpeed = (Config.WalkSpeedEnabled and Config.WalkSpeed) or Config.WinGlideSpeed or speed or 75
    if hum then hum.WalkSpeed = activeSpeed end
    
    local targetPos = targetCFrame.Position
    local startPos = hrp.Position
    local totalDist = (targetPos - startPos).Magnitude
    if totalDist < 0.25 then
        hrp.CFrame = targetCFrame
        return true
    end
    
    -- No-clip contínuo e anulação de gravidade/inércia em Stepped (elimina vibrações e stutter)
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
        hum.WalkSpeed = (Config.WalkSpeedEnabled and Config.WalkSpeed) or 50
        return reached
    end
    return false
end

local function glideAlongPath(waypoints, speed, attackWhileMoving)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 or not waypoints or #waypoints == 0 then return false end
    
    local activeSpeed = (Config.WalkSpeedEnabled and Config.WalkSpeed) or Config.WinGlideSpeed or speed or 75
    if hum then hum.WalkSpeed = activeSpeed end
    
    -- No-clip contínuo e anulação de gravidade/inércia em Stepped (elimina vibrações e stutter)
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
    local currentWpIndex = 1
    local totalWps = #waypoints
    local reachedFinal = false
    local currentWpStartTime = os.clock()
    
    while Config.AutoWin and not Config.AutoEndless and currentWpIndex <= totalWps do
        local dt = RunService.Heartbeat:Wait()
        char = LocalPlayer.Character
        hum = char and char:FindFirstChildOfClass("Humanoid")
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not hum or hum.Health <= 0 then break end
        
        -- Atualiza activeSpeed dinamicamente caso o jogador altere durante o movimento
        activeSpeed = (Config.WalkSpeedEnabled and Config.WalkSpeed) or Config.WinGlideSpeed or speed or 75
        if hum.WalkSpeed ~= activeSpeed then hum.WalkSpeed = activeSpeed end
        
        local currentTarget = waypoints[currentWpIndex]
        local targetPos = typeof(currentTarget) == "CFrame" and currentTarget.Position or currentTarget
        local currentPos = hrp.Position
        local toTarget = targetPos - currentPos
        local distRemaining = toTarget.Magnitude
        local step = activeSpeed * dt
        
        if attackWhileMoving and (os.clock() - lastAttackTick >= 0.05) then
            lastAttackTick = os.clock()
            if RemoteRequestAttack then RemoteRequestAttack:FireServer() end
            if RemotePlayerClick then RemotePlayerClick:FireServer() end
        end
        
        local isFinal = (currentWpIndex == totalWps)
        local arriveThreshold = isFinal and math.max(step * 1.15, 0.4) or math.max(step * 1.6, 9.0)
        
        -- Timeout de segurança por waypoint (máximo 6 segundos se ficar travado)
        local wpTimeout = (os.clock() - currentWpStartTime > 6.0)
        
        if distRemaining <= arriveThreshold or wpTimeout then
            if isFinal then
                if typeof(currentTarget) == "CFrame" then
                    hrp.CFrame = currentTarget
                else
                    hrp.CFrame = CFrame.new(targetPos)
                end
                reachedFinal = true
                break
            else
                currentWpIndex = currentWpIndex + 1
                currentWpStartTime = os.clock()
            end
        else
            local moveDir = toTarget.Unit
            local nextPos = currentPos + (moveDir * step)
            local flatDir = Vector3.new(moveDir.X, 0, moveDir.Z)
            if flatDir.Magnitude > 0.05 then
                local lookRot = CFrame.lookAt(nextPos, nextPos + flatDir)
                hrp.CFrame = hrp.CFrame:Lerp(lookRot, math.clamp(dt * 15, 0.08, 1.0))
            else
                hrp.CFrame = CFrame.new(nextPos)
            end
        end
    end
    
    pcall(function() ncConn:Disconnect() end)
    if hrp and hum and hum.Health > 0 then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hum.WalkSpeed = (Config.WalkSpeedEnabled and Config.WalkSpeed) or 50
        return reachedFinal
    end
    return false
end

local function getStageCorridorPath(stageInstance, targetPad)
    if not stageInstance or not targetPad then return nil, nil end
    local padFolder = stageInstance:FindFirstChild("Pad")
    local paidPad = padFolder and padFolder:FindFirstChild("Paid") and padFolder.Paid:FindFirstChild("Pad")
    local floor = stageInstance:FindFirstChild("Floor")
    local gate = stageInstance:FindFirstChild("Gate") or stageInstance:FindFirstChild("Barrier")
    
    local centerEnd = nil
    if paidPad and paidPad:IsA("BasePart") then
        centerEnd = Vector3.new((targetPad.Position.X + paidPad.Position.X) / 2, targetPad.Position.Y, (targetPad.Position.Z + paidPad.Position.Z) / 2)
    else
        local padFloor = nil
        if floor then
            for _, fp in ipairs(floor:GetChildren()) do
                if fp:IsA("BasePart") and (fp.Position - targetPad.Position).Magnitude < 30 then
                    padFloor = fp
                    break
                end
            end
        end
        if padFloor then
            centerEnd = Vector3.new(padFloor.Position.X, targetPad.Position.Y, padFloor.Position.Z)
        else
            centerEnd = targetPad.Position + (targetPad.CFrame.RightVector * 12.5)
        end
    end
    
    local centerStart = nil
    local mainFloor = nil
    if floor then
        local maxLen = 0
        for _, fp in ipairs(floor:GetChildren()) do
            if fp:IsA("BasePart") then
                local len = math.max(fp.Size.X, fp.Size.Z)
                if len > maxLen then maxLen = len; mainFloor = fp end
            end
        end
    end
    
    if mainFloor and centerEnd then
        local dz = math.abs(centerEnd.Z - mainFloor.Position.Z)
        local dx = math.abs(centerEnd.X - mainFloor.Position.X)
        if dz >= dx then
            local dirSign = math.sign(centerEnd.Z - mainFloor.Position.Z)
            if dirSign == 0 then dirSign = 1 end
            centerStart = Vector3.new(centerEnd.X, targetPad.Position.Y, mainFloor.Position.Z - dirSign * (mainFloor.Size.Z / 2 - 4))
        else
            local dirSign = math.sign(centerEnd.X - mainFloor.Position.X)
            if dirSign == 0 then dirSign = 1 end
            centerStart = Vector3.new(mainFloor.Position.X - dirSign * (mainFloor.Size.X / 2 - 4), targetPad.Position.Y, centerEnd.Z)
        end
    elseif gate then
        local gp = gate:IsA("BasePart") and gate.Position or (gate:FindFirstChildWhichIsA("BasePart") and gate:FindFirstChildWhichIsA("BasePart").Position)
        if gp and centerEnd then
            local dx = math.abs(centerEnd.X - gp.X)
            local dz = math.abs(centerEnd.Z - gp.Z)
            if dz >= dx then
                centerStart = Vector3.new(centerEnd.X, targetPad.Position.Y, gp.Z)
            else
                centerStart = Vector3.new(gp.X, targetPad.Position.Y, centerEnd.Z)
            end
        end
    end
    
    if not centerStart then
        local enemySpawns = stageInstance:FindFirstChild("EnemySpawns")
        local firstSp = enemySpawns and enemySpawns:FindFirstChildWhichIsA("BasePart")
        if firstSp and centerEnd then
            local dir = (centerEnd - firstSp.Position)
            local u = dir.Magnitude > 0.1 and dir.Unit or Vector3.new(0, 0, -1)
            centerStart = firstSp.Position - u * 35
        else
            centerStart = centerEnd - Vector3.new(0, 0, 70)
        end
    end
    return centerStart, centerEnd
end

local function getLiveStageEnemies(stageInstance, centerStart, centerEnd)
    local live = {}
    if not stageInstance then return live end
    local lineVec = (centerEnd and centerStart) and (centerEnd - centerStart) or Vector3.new(0, 0, 1)
    local lineLen = lineVec.Magnitude
    local unitDir = lineLen > 0.1 and lineVec.Unit or Vector3.new(0, 0, 1)
    
    local pivot = nil
    if stageInstance:IsA("Model") then
        pivot = stageInstance:GetPivot().Position
    else
        local bp = stageInstance:FindFirstChildWhichIsA("BasePart", true)
        if bp then pivot = bp.Position end
    end
    if not pivot and centerEnd then pivot = centerEnd end
    
    local candidateEnemies = {}
    for _, m in ipairs(workspace:GetChildren()) do
        if m:IsA("Model") and not Players:GetPlayerFromCharacter(m) then table.insert(candidateEnemies, m) end
    end
    local enFolder = workspace:FindFirstChild("enemynew")
    if enFolder then
        for _, m in ipairs(enFolder:GetChildren()) do
            if m:IsA("Model") and not Players:GetPlayerFromCharacter(m) then table.insert(candidateEnemies, m) end
        end
    end
    
    for _, m in ipairs(candidateEnemies) do
        if m:GetAttribute("EnemyId") or (m.Parent and m.Parent.Name == "enemynew") or m.Name:lower():find("enemy") or m.Name:lower():find("boss") or m.Name:lower():find("zombie") or m:FindFirstChild("DamageFlash") then
            local hum = m:FindFirstChildOfClass("Humanoid")
            local root = m.PrimaryPart or m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso") or m:FindFirstChildWhichIsA("BasePart")
            if hum and hum.Health > 0 and root then
                local inRange = false
                if centerStart and lineLen > 1 then
                    local v = root.Position - centerStart
                    local proj = v:Dot(unitDir)
                    local perp = (v - unitDir * proj).Magnitude
                    if proj >= -25 and proj <= lineLen + 30 and perp < 55 then inRange = true end
                elseif pivot and (root.Position - pivot).Magnitude < 150 then
                    inRange = true
                end
                if inRange then table.insert(live, {Model = m, Root = root, Hum = hum, Health = hum.Health}) end
            end
        end
    end
    return live
end

local lastWinCollectedTick = 0
local totalWinsCollectedCount = 0

if RemotePlayVFX then
    local winVfxConn = RemotePlayVFX.OnClientEvent:Connect(function(vfxName, _, targetPlr)
        if vfxName == "WinPadTouch" and targetPlr == LocalPlayer then
            lastWinCollectedTick = os.clock()
            totalWinsCollectedCount = totalWinsCollectedCount + 1
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
        end)
        table.insert(ActiveConnections, wConn)
    end
end)

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

local function findStageWithLiveEnemies(stagesList)
    if not stagesList or #stagesList == 0 then return nil end
    
    local candidateModels = {}
    for _, m in ipairs(workspace:GetChildren()) do
        if m:IsA("Model") and not Players:GetPlayerFromCharacter(m) then
            table.insert(candidateModels, m)
        end
    end
    local enFolder = workspace:FindFirstChild("enemynew")
    if enFolder then
        for _, m in ipairs(enFolder:GetChildren()) do
            if m:IsA("Model") and not Players:GetPlayerFromCharacter(m) then
                table.insert(candidateModels, m)
            end
        end
    end
    
    local allLiveEnemies = {}
    for _, m in ipairs(candidateModels) do
        if m:GetAttribute("EnemyId") or (m.Parent and m.Parent.Name == "enemynew") or m.Name:lower():find("enemy") or m.Name:lower():find("boss") or m.Name:lower():find("zombie") or m:FindFirstChild("DamageFlash") then
            local hum = m:FindFirstChildOfClass("Humanoid")
            local root = m.PrimaryPart or m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso") or m:FindFirstChildWhichIsA("BasePart")
            if hum and hum.Health > 0 and root then
                table.insert(allLiveEnemies, {Model = m, Root = root, Hum = hum})
            end
        end
    end
    
    if #allLiveEnemies == 0 then
        return nil
    end
    
    -- Checa cada estágio na lista por inimigos vivos
    for _, item in ipairs(stagesList) do
        local stg = item.Stage
        if stg then
            local pad = getStageFreePad(stg)
            local cStart, cEnd = getStageCorridorPath(stg, pad)
            local live = getLiveStageEnemies(stg, cStart, cEnd)
            if #live > 0 then
                return stg, item.Num
            end
        end
    end
    
    -- Fallback geométrico: encontra o estágio mais próximo do primeiro inimigo vivo
    local firstEnemy = allLiveEnemies[1]
    local ePos = firstEnemy.Root.Position
    local bestStage = nil
    local bestNum = nil
    local minDist = math.huge
    
    for _, item in ipairs(stagesList) do
        local pad = getStageFreePad(item.Stage)
        local pivot = pad and pad.Position or (item.Stage:FindFirstChildWhichIsA("BasePart", true) and item.Stage:FindFirstChildWhichIsA("BasePart", true).Position)
        if pivot then
            local d = (ePos - pivot).Magnitude
            if d < minDist then
                minDist = d
                bestStage = item.Stage
                bestNum = item.Num
            end
        end
    end
    
    return bestStage, bestNum
end

local function clearStageEnemies(stageInstance)
    if not stageInstance or not Config.AutoWin or Config.AutoEndless then return false, "cancelled" end
    local pad = getStageFreePad(stageInstance)
    local cStart, cEnd = getStageCorridorPath(stageInstance, pad)
    if not cStart or not cEnd then return false, "nopath" end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false, "dead" end
    
    local lineVec = cEnd - cStart
    local lineLen = lineVec.Magnitude
    local lineUnit = (lineLen > 0.1) and lineVec.Unit or Vector3.new(0, 0, 1)
    local combatPos = cStart + lineUnit * (lineLen * 0.55)
    
    if (hrp.Position - combatPos).Magnitude > 160 then
        hrp.CFrame = CFrame.new(combatPos + Vector3.new(0, 2.5, 0))
        if LocalPlayer.RequestStreamAroundAsync then
            pcall(function() LocalPlayer:RequestStreamAroundAsync(combatPos) end)
        end
        task.wait(0.15)
    else
        local ok = glideToCFrame(CFrame.new(combatPos + Vector3.new(0, 1.2, 0), combatPos + lineUnit + Vector3.new(0, 1.2, 0)), nil, true)
        if not ok then return false, "dead" end
    end
    
    local t0 = tick()
    local maxComb = math.max(0.05, Config.CombatTime or 0.5)
    while Config.AutoWin and not Config.AutoEndless and (tick() - t0 < maxComb) do
        char = LocalPlayer.Character
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return false, "dead" end
        
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        
        if RemoteRequestAttack then RemoteRequestAttack:FireServer() end
        if RemotePlayerClick then RemotePlayerClick:FireServer() end
        
        local live = getLiveStageEnemies(stageInstance, cStart, cEnd)
        if #live == 0 and tick() - t0 > 0.1 then break end
        task.wait(0.04)
    end
    
    glideToCFrame(CFrame.new(cEnd + Vector3.new(0, 1.2, 0), cEnd + lineUnit + Vector3.new(0, 1.2, 0)), nil, true)
    if RemoteRequestAttack then RemoteRequestAttack:FireServer() end
    if RemotePlayerClick then RemotePlayerClick:FireServer() end
    return true, "cleared"
end

local function farmStage(stage, shouldGlideToPad, stagesList)
    if shouldGlideToPad == nil then shouldGlideToPad = true end
    if not stage or not Config.AutoWin or Config.AutoEndless then return false, "cancelled" end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false, "dead" end
    
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
    
    local stagePos = nil
    if stage:IsA("Model") then
        stagePos = stage:GetPivot().Position
    else
        local bp = stage:FindFirstChildWhichIsA("BasePart", true)
        if bp then stagePos = bp.Position end
    end
    if stagePos and LocalPlayer.RequestStreamAroundAsync then
        pcall(function() LocalPlayer:RequestStreamAroundAsync(stagePos) end)
    end
    
    local targetPad = getStageFreePad(stage)
    if not targetPad then
        local proxyPart = stage:FindFirstChildWhichIsA("BasePart", true)
        if proxyPart then
            local ok = glideToCFrame(proxyPart.CFrame + Vector3.new(0, 3, 0), 60)
            if not ok then return false, "dead" end
            task.wait(0.2)
            if LocalPlayer.RequestStreamAroundAsync then
                pcall(function() LocalPlayer:RequestStreamAroundAsync(proxyPart.Position) end)
            end
            task.wait(0.15)
            targetPad = getStageFreePad(stage)
        end
    end
    if not targetPad or not targetPad:IsA("BasePart") then return false, "nopad" end
    
    char = LocalPlayer.Character
    hrp = char and char:FindFirstChild("HumanoidRootPart")
    hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false, "dead" end
    if hum then hum.WalkSpeed = (Config.WalkSpeedEnabled and Config.WalkSpeed) or 50 end
    
    local centerStart, centerEnd = getStageCorridorPath(stage, targetPad)
    local padTargetCF = targetPad.CFrame + Vector3.new(0, 1.0, 0)
    local stageY = targetPad.Position.Y + 1.2
    
    -- Normaliza altura horizontal para evitar oscilações verticais (gliding plano e estável)
    local startPos = centerStart and Vector3.new(centerStart.X, stageY, centerStart.Z) or nil
    local endPos = centerEnd and Vector3.new(centerEnd.X, stageY, centerEnd.Z) or nil
    local lineVec = (endPos and startPos) and (endPos - startPos) or nil
    local lineLen = lineVec and lineVec.Magnitude or 0
    local lineUnit = (lineLen > 0.1) and lineVec.Unit or Vector3.new(0, 0, 1)
    local combatPos = startPos and (startPos + lineUnit * (lineLen * 0.55)) or nil
    
    -- 1. Deslizamento fluido até a entrada / área de combate do corredor
    if combatPos then
        local distToComb = (hrp.Position - combatPos).Magnitude
        if distToComb > 160 then
            hrp.CFrame = CFrame.new(combatPos + Vector3.new(0, 1.5, 0))
            if LocalPlayer.RequestStreamAroundAsync then
                pcall(function() LocalPlayer:RequestStreamAroundAsync(combatPos) end)
            end
            task.wait(0.06)
        elseif distToComb > 2.0 then
            local okComb = glideToCFrame(CFrame.new(combatPos, combatPos + lineUnit), nil, true)
            if not okComb then return false, "dead" end
        end
    elseif startPos then
        local distToStart = (hrp.Position - startPos).Magnitude
        if distToStart > 160 then
            hrp.CFrame = CFrame.new(startPos + Vector3.new(0, 1.5, 0))
            task.wait(0.06)
        elseif distToStart > 2.0 then
            local ok = glideToCFrame(CFrame.new(startPos, startPos + lineUnit), nil, true)
            if not ok then return false, "dead" end
        end
    end
    
    if not Config.AutoWin or Config.AutoEndless then return false, "cancelled" end
    
    -- 2. Combate: Segue RIGOROSAMENTE o tempo configurado pelo usuário (Tempo de Combate por Estágio)
    local combatDuration = math.max(0.05, Config.CombatTime or 0.5)
    local fightStart = os.clock()
    while Config.AutoWin and not Config.AutoEndless and (os.clock() - fightStart < combatDuration) do
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
    
    -- 3. Se for o estágio final da vitória selecionado, desliza até o Pad e confirma a coleta
    if shouldGlideToPad and targetPad then
        local okPad = glideToCFrame(padTargetCF, nil, true)
        if not okPad then return false, "dead" end
        
        lockPadStationary(targetPad)
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
    local targetNum = nil
    if selectedStage and selectedStage ~= "all" then
        targetNum = tonumber(string.match(selectedStage, "%d+"))
    end
    local stagesList = getStagesToFarm(stagesFolder, selectedStage)
    if #stagesList == 0 then return end
    
    if cancelCheck and cancelCheck() then return end
    if not Config.AutoWin or Config.AutoEndless or isBossActive() then return end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hum or hum.Health <= 0 or not hrp then
        waitForCharacterAlive()
        task.wait(0.8)
        return
    end
    
    -- Encontra o estágio mais próximo para iniciar sem retroceder desnecessariamente
    local startIndex = 1
    local minDist = math.huge
    for idx, item in ipairs(stagesList) do
        local pad = getStageFreePad(item.Stage)
        local pPos = pad and pad.Position or (item.Stage:FindFirstChildWhichIsA("BasePart", true) and item.Stage:FindFirstChildWhichIsA("BasePart", true).Position)
        if pPos then
            local d = (hrp.Position - pPos).Magnitude
            if d < minDist then
                minDist = d
                startIndex = idx
            end
        end
    end
    
    -- Executa a progressão pelos estágios respeitando rigorosamente o Tempo de Combate por Estágio
    for i = startIndex, #stagesList do
        if cancelCheck and cancelCheck() then break end
        if not Config.AutoWin or Config.AutoEndless or isBossActive() then break end
        
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
        if Config.AutoWin and not isBossActive() and not Config.AutoEndless and not (isRaidActive() and Config.AutoEnterRaid) and not isInsideRaid() then
            pcall(function()
                local myChar, myHrp, myHum = waitForCharacterAlive(6)
                if not myHrp or not myHum or myHum.Health <= 0 then task.wait(0.5); return end
                if myHrp.Position.Z < -800 then return end
                
                -- Se o Boss ou Raid estiver ativo, ceder a vez para não conflitar
                if isBossActive() or (isRaidActive() and Config.AutoEnterRaid) or isInsideRaid() then
                    task.wait(0.5)
                    return
                end
                
                local chosenWorld = Config.SelectedProgWorld
                if chosenWorld == "all" then
                    for wNum = 1, 9 do
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
--  CO-OP SEM FIM & AUTO HOP SE BLOQUEADO (+1 MIN)
-- ══════════════════════════════════════════════════════════════
local endlessDeathTick = 0
local isDeadWaiting = false
local wasInsideEndless = false
local lastJoinAttempt = 0
local outsideArenaStart = os.clock()
local endlessEnteredCFrame = nil

local function onCharacterLoadedForEndless(char)
    endlessEnteredCFrame = nil
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        local diedConn = hum.Died:Connect(function()
            if Config.AutoEndless and (wasInsideEndless or isInsideEndless() or endlessEnteredCFrame ~= nil) then
                endlessDeathTick = os.clock()
                isDeadWaiting = true
                wasInsideEndless = false
                endlessEnteredCFrame = nil
                print("[Auto CO-OP] Morte no CO-OP Sem Fim detectada! Aguardando 15 segundos antes de reentrar...")
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
    elseif Config.SelectedProgWorld and Config.SelectedProgWorld ~= "current" and Config.SelectedProgWorld ~= "all" then
        local wNum = tonumber(string.match(tostring(Config.SelectedProgWorld), "%d+"))
        if wNum and wNum >= 2 then
            targetWorld = wNum
        end
    end
    
    if not targetWorld then
        local curMap = getCurrentMap()
        local curMapName = curMap and curMap.Name or "Map"
        if curMapName == "Map" then
            targetWorld = 2 -- Mundo 1 não possui CO-OP Sem Fim
        elseif curMapName == "MapTest" then
            targetWorld = 2
        else
            targetWorld = tonumber(string.match(curMapName, "%d+")) or 2
        end
    end
    
    if not targetWorld or targetWorld < 2 then targetWorld = 2 end
    if targetWorld > 9 then targetWorld = 9 end
    return targetWorld
end

local function getTargetEndlessPortal(targetWorldNum)
    if not targetWorldNum then targetWorldNum = getSelectedEndlessWorldNum() end
    local targetMapName = (targetWorldNum == 2 and "MapTest") or ("Map" .. tostring(targetWorldNum))
    
    -- 1. Tenta direto no mapa alvo
    local mapObj = workspace:FindFirstChild(targetMapName)
    local endlessFolder = mapObj and mapObj:FindFirstChild("Endless")
    local portal = endlessFolder and endlessFolder:FindFirstChild("Portal")
    if portal then
        return portal, targetWorldNum
    end
    
    -- 2. Tenta via CollectionService
    local portals = CollectionService:GetTagged("EndlessPortal")
    for _, p in ipairs(portals) do
        if getPortalWorld(p) == targetWorldNum then
            return p, targetWorldNum
        end
    end
    
    -- 3. Fallback: portal mais próximo
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
    
    -- Garante que o jogador está no mundo selecionado antes de interagir com o portal
    local curMap = getCurrentMap()
    local curMapName = curMap and curMap.Name or "Map"
    if curMapName ~= targetMapName then
        print(string.format("[Auto CO-OP] Jogador no mapa '%s'. Entrando no mundo selecionado (Mundo %d - %s)...", curMapName, targetWorldNum, targetMapName))
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
    if not portal then
        print(string.format("[Auto CO-OP] Portal do Mundo %d não encontrado!", targetWorldNum))
        return false
    end
    local hitbox = portal:FindFirstChild("Hitbox")
    if not hitbox or not hitbox:IsA("BasePart") then
        print(string.format("[Auto CO-OP] Hitbox do Portal do Mundo %d não encontrada!", targetWorldNum))
        return false
    end
    
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
        local inBoss = isReturningToEndless or (not bossDiedInCurrentEvent and (isBossFighting or isBossActive() or bossWaitingForSpawn or bossPlayerJoined or (bossEventPhase == "Active")))
        local inRaid = (isRaidActive() and Config.AutoEnterRaid) or isInsideRaid()
        if Config.AutoEndless and not inBoss and not inRaid then
            pcall(function()
                if inBoss or inRaid then
                    task.wait(0.5)
                    return
                end
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                local reviveGui = pgui and pgui:FindFirstChild("ScreenGui") and pgui.ScreenGui:FindFirstChild("Revive")
                local isReviveActive = (reviveGui and reviveGui.Visible)
                local isDead = (not hum or hum.Health <= 0 or isReviveActive)
                
                -- Se a tela de revive aparecer após morrer no Endless, dispensa imediatamente para respawnar no lobby
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
                
                if isInsideEndless() then
                    wasInsideEndless = true
                end
                
                if isDead and not isDeadWaiting then
                    if wasInsideEndless or isInsideEndless() or endlessEnteredCFrame ~= nil then
                        endlessDeathTick = os.clock()
                        isDeadWaiting = true
                        wasInsideEndless = false
                        endlessEnteredCFrame = nil
                        print("[Auto CO-OP] Morte no CO-OP Sem Fim detectada! Aguardando 15 segundos antes de reentrar...")
                    end
                end
                
                if isDeadWaiting then
                    endlessEnteredCFrame = nil
                    outsideArenaStart = os.clock()
                    local elapsed = os.clock() - endlessDeathTick
                    -- Aguarda rigorosamente 15 segundos após morrer no Endless antes de reentrar
                    if elapsed >= 15.0 and hum and hum.Health > 0 and hrp and not isReviveActive and not isInsideEndless() then
                        print("[Auto CO-OP] 15 segundos de espera após morte concluídos! Reentrando no CO-OP Sem Fim...")
                        isDeadWaiting = false
                        outsideArenaStart = os.clock()
                    else
                        task.wait(0.25)
                        return
                    end
                end
                
                if hum and hum.Health > 0 and hrp then
                    if isInsideEndless() then
                        wasInsideEndless = true
                        outsideArenaStart = os.clock()
                        
                        -- Captura exatamente a posição inicial onde o jogador apareceu ao entrar no Endless
                        if not endlessEnteredCFrame then
                            local arenaCenter = getEndlessArenaCenter()
                            if arenaCenter then
                                endlessEnteredCFrame = CFrame.lookAt(hrp.Position, Vector3.new(arenaCenter.X, hrp.Position.Y, arenaCenter.Z))
                            else
                                endlessEnteredCFrame = hrp.CFrame
                            end
                            hrp.CFrame = endlessEnteredCFrame
                        end
                        
                        -- Mantém o personagem 100% parado onde iniciou ao entrar no Endless
                        -- Nenhuma outra função ativa (sem socos, sem cliques, sem pulos)
                        if endlessEnteredCFrame then
                            local currentPos = hrp.Position
                            local distFromEntry = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(endlessEnteredCFrame.Position.X, 0, endlessEnteredCFrame.Position.Z)).Magnitude
                            
                            -- Se for empurrado por colisão de monstros (> 2 studs), retorna suavemente ao ponto inicial
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
                        
                        -- Deixa o personagem exclusivamente parado! Zero ataques ou ações extras.
                    else
                        endlessEnteredCFrame = nil
                        -- PROTEÇÃO: Se o Boss estiver ativo ou em atraso para retornar, aguarda
                        if isReturningToEndless or (not bossDiedInCurrentEvent and (isBossFighting or isBossActive() or bossWaitingForSpawn or bossPlayerJoined or (bossEventPhase == "Active"))) then
                            task.wait(0.5)
                            return
                        end
                        if Config.AutoHopBlocked and (os.clock() - outsideArenaStart > 60) then
                            print("[Auto Hop] Mais de 1 minuto fora da arena de CO-OP! Trocando de servidor...")
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
--  3. ABA OVOS (OVOS & PETS + PROTEÇÃO DE TELA) [FOTO 3]
-- ══════════════════════════════════════════════════════════════
createSectionHeader(OvosTab, "🥚 OVOS & PETS")

createLabel(OvosTab, "Selecione o Ovo para Chocar:")

createDropdown(OvosTab, "", EggsList, Config.SelectedEgg, function(eggId)
    Config.SelectedEgg = eggId
end)

createToggle(OvosTab, "Auto Hatch", Config.AutoHatch, function(val)
    Config.AutoHatch = val
    if autoSyncActiveTitle then autoSyncActiveTitle(true) end
end)

createToggle(OvosTab, "Auto Open Ovos Múltiplos", Config.AutoHatchMultiple, function(val)
    Config.AutoHatchMultiple = val
    if autoSyncActiveTitle then autoSyncActiveTitle(true) end
end)

createToggle(OvosTab, "Chocar Rápido", Config.FastHatch, function(val)
    Config.FastHatch = val
    Config.HatchSpeed = val and 0.08 or 0.5
end)

createToggle(OvosTab, "Pular Animação de Abrir Ovos", Config.SkipEggAnimation, function(val)
    Config.SkipEggAnimation = val
    applySkipAnimation(val)
end)

spawnThread(function()
    while true do
        if Config.SelectedEgg and (Config.AutoHatch or Config.AutoHatchMultiple) then
            pcall(function()
                if RemoteTryPurchaseEgg then
                    if Config.AutoHatchMultiple then
                        RemoteTryPurchaseEgg:FireServer(Config.SelectedEgg, 2)
                        RemoteTryPurchaseEgg:FireServer(Config.SelectedEgg, 1)
                        Config.EggsHatched = Config.EggsHatched + 2
                    elseif Config.AutoHatch then
                        RemoteTryPurchaseEgg:FireServer(Config.SelectedEgg, 1)
                        Config.EggsHatched = Config.EggsHatched + 1
                    end
                end
            end)
        end
        local speed = 0.5
        if Config.SkipEggAnimation then
            speed = Config.FastHatch and (Config.HatchSpeed or 0.08) or 0.35
        else
            -- Se estiver exibindo a animação de abertura, aguarda o tempo de exibição da animação
            speed = Config.FastHatch and 1.2 or 2.0
        end
        task.wait(speed)
    end
end)

-- ══════════════════════════════════════════════════════════════
-- ️ 4. ABA CONFIGURAÇÕES & MOVIMENTO
-- ══════════════════════════════════════════════════════════════
createSectionHeader(ConfigTab, "⚙️ CONFIGURAÇÕES GERAIS")

createToggle(ConfigTab, "Anti-AFK Silencioso", Config.AntiAfk, function(val)
    Config.AntiAfk = val
end)

createToggle(ConfigTab, "Auto Fechar Pop-ups (Robux & Eventos)", Config.AutoClosePopups, function(val)
    Config.AutoClosePopups = val
end)

createToggle(ConfigTab, "Auto Resgatar Recompensas Diárias", Config.AutoDailyRewards, function(val)
    Config.AutoDailyRewards = val
    if val then claimDailyReward() end
end)

createToggle(ConfigTab, "Auto Resgatar Recompensas de Tempo de Jogo", Config.AutoPlaytimeRewards, function(val)
    Config.AutoPlaytimeRewards = val
    if val then claimAvailablePlaytimeRewards() end
end)

createSectionHeader(ConfigTab, "🏃 MOVIMENTO & FÍSICA")

createWalkSpeedControl(ConfigTab)

createSlider(ConfigTab, "Velocidade de Deslize (Auto Win)", 40, 500, Config.WinGlideSpeed or 75, " WalkSpeed", true, function(val)
    Config.WinGlideSpeed = val
end)

createToggle(ConfigTab, "Pulo Infinito", Config.InfiniteJump, function(val)
    Config.InfiniteJump = val
end)

createToggle(ConfigTab, "Atravessar Paredes", Config.Noclip, function(val)
    Config.Noclip = val
    if updateNoclip then updateNoclip() end
end)

createSectionHeader(ConfigTab, "🕊️ VOO")

createToggle(ConfigTab, "Voo Suave", Config.FlyEnabled, function(val)
    Config.FlyEnabled = val
    if val then startFly() else stopFly() end
end)

createSlider(ConfigTab, "Velocidade de Voo", 10, 200, Config.FlySpeed, "", false, function(val)
    Config.FlySpeed = val
end)

createSectionHeader(ConfigTab, "💾 GERENCIAMENTO DO HUB")

createToggle(ConfigTab, "Salvar Configurações Automaticamente", Config.AutoSaveSettings, function(val)
    Config.AutoSaveSettings = val
    if val then saveConfig() end
end)

createButton(ConfigTab, "❌ Fechar Script", Themes.Error, function()
    if getgenv().SuperHeroEvolutionHubCleanup then
        getgenv().SuperHeroEvolutionHubCleanup()
    end
end)

local jumpConn = UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
table.insert(ActiveConnections, jumpConn)

local noclipConn = nil
local function updateNoclip()
    if Config.Noclip then
        if not noclipConn then
            noclipConn = RunService.Stepped:Connect(function()
                if not Config.Noclip then
                    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
                    return
                end
                local char = LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetChildren()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            table.insert(ActiveConnections, noclipConn)
        end
    else
        if noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end
    end
end
if Config.Noclip then updateNoclip() end

spawnThread(function()
    while true do
        if Config.WalkSpeedEnabled then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed ~= Config.WalkSpeed then
                    hum.WalkSpeed = Config.WalkSpeed
                end
            end)
        end
        task.wait(0.25)
    end
end)

applyInvisibility = function(state)
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if part.Name ~= "HumanoidRootPart" then part.Transparency = state and 0.85 or 0 end
        elseif part:IsA("Decal") then
            part.Transparency = state and 1 or 0
        end
    end
end

local invisCharConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    if Config.Invisibility then applyInvisibility(true) end
    if Config.WalkSpeedEnabled then
        local hum = newChar:WaitForChild("Humanoid", 5)
        if hum then hum.WalkSpeed = Config.WalkSpeed end
    end
end)
table.insert(ActiveConnections, invisCharConn)

local flyBV = nil
local flyBG = nil
local flyConn = nil

stopFly = function()
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

startFly = function()
    stopFly()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true
    
    flyBV = Instance.new("BodyVelocity")
    flyBV.Velocity = Vector3.zero
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV.Parent = hrp
    
    flyBG = Instance.new("BodyGyro")
    flyBG.CFrame = hrp.CFrame
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.P = 9e4
    flyBG.Parent = hrp
    
    flyConn = RunService.RenderStepped:Connect(function()
        if not Config.FlyEnabled then stopFly(); return end
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        local hm = c and c:FindFirstChildOfClass("Humanoid")
        if not h or not hm or hm.Health <= 0 then stopFly(); return end
        hm.PlatformStand = true
        
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end
        if flyBG and flyBG.Parent then flyBG.CFrame = cam.CFrame end
        if flyBV and flyBV.Parent then
            if moveDir.Magnitude > 0 then flyBV.Velocity = moveDir.Unit * (Config.FlySpeed or 50)
            else flyBV.Velocity = Vector3.zero end
        end
    end)
    table.insert(ActiveConnections, flyConn)
end

-- ══════════════════════════════════════════════════════════════
--  5. ABA TÍTULOS (TÍTULOS AUTOMÁTICOS POR MODO) [FOTOS 4 & 5]
-- ══════════════════════════════════════════════════════════════
do
    createSectionHeader(TitulosTab, "👑 TÍTULO EQUIPADO ATUALMENTE")
    
    local TitleStatusCard = Instance.new("Frame")
    TitleStatusCard.Name = "CurrentTitleCard"
    TitleStatusCard.Size = UDim2.new(1, 0, 0, 60)
    TitleStatusCard.BackgroundColor3 = Themes.Card
    TitleStatusCard.BorderSizePixel = 0
    TitleStatusCard.Parent = TitulosTab
    
    local tCardCorner = Instance.new("UICorner")
    tCardCorner.CornerRadius = UDim.new(0, 10)
    tCardCorner.Parent = TitleStatusCard
    
    local tCardStroke = Instance.new("UIStroke")
    tCardStroke.Thickness = 1.5
    tCardStroke.Color = Themes.Accent2
    tCardStroke.Parent = TitleStatusCard
    
    local tTopLbl = Instance.new("TextLabel")
    tTopLbl.Size = UDim2.new(1, -28, 0, 18)
    tTopLbl.Position = UDim2.new(0, 14, 0, 8)
    tTopLbl.BackgroundTransparency = 1
    tTopLbl.Text = "TÍTULO ATIVO NO MOMENTO:"
    tTopLbl.TextColor3 = Themes.Accent2
    tTopLbl.TextSize = 11
    tTopLbl.Font = Enum.Font.GothamBold
    tTopLbl.TextXAlignment = Enum.TextXAlignment.Left
    tTopLbl.Parent = TitleStatusCard
    
    local tActiveName = Instance.new("TextLabel")
    tActiveName.Name = "ActiveTitleName"
    tActiveName.Size = UDim2.new(1, -28, 0, 24)
    tActiveName.Position = UDim2.new(0, 14, 0, 28)
    tActiveName.BackgroundTransparency = 1
    tActiveName.Text = "Eternity"
    tActiveName.TextColor3 = Themes.Text
    tActiveName.TextSize = 13
    tActiveName.Font = Enum.Font.GothamBold
    tActiveName.TextXAlignment = Enum.TextXAlignment.Left
    tActiveName.Parent = TitleStatusCard
    
    updateTitleCardVisual = function()
        pcall(function()
            local equippedId = currentEquippedTitle
            if RemoteGetTitlesState then
                local res = RemoteGetTitlesState:InvokeServer()
                if res and res.Equipped then
                    equippedId = res.Equipped
                    currentEquippedTitle = res.Equipped
                end
            end
            if equippedId then
                for _, item in ipairs(AllTitlesList) do
                    if item.Id == equippedId then
                        tActiveName.Text = item.Name
                        return
                    end
                end
                tActiveName.Text = tostring(equippedId)
            else
                tActiveName.Text = "Nenhum / Padrão"
            end
        end)
    end
    task.defer(updateTitleCardVisual)
    
    createSectionHeader(TitulosTab, "👑 TÍTULOS AUTOMÁTICOS POR MODO")
    
    -- 1. Treino
    createToggle(TitulosTab, "⚡ Auto Equipar no Treino", Config.TitleTrainEnabled, function(val)
        Config.TitleTrainEnabled = val
        if autoSyncActiveTitle then autoSyncActiveTitle(true) end
    end)
    createLabel(TitulosTab, "Título para Treino (Recomendado: Vel. Ataque / Clicks)")
    createDropdown(TitulosTab, "", AllTitlesList, Config.TitleTrain, function(id)
        Config.TitleTrain = id
        if autoSyncActiveTitle then autoSyncActiveTitle(true) end
    end)
    
    -- 2. Vitória / Progressão
    createToggle(TitulosTab, "🏆 Auto Equipar na Vitória", Config.TitleWinEnabled, function(val)
        Config.TitleWinEnabled = val
        if autoSyncActiveTitle then autoSyncActiveTitle(true) end
    end)
    createLabel(TitulosTab, "Título para Vitória (Recomendado: +% Vitórias)")
    createDropdown(TitulosTab, "", AllTitlesList, Config.TitleWin, function(id)
        Config.TitleWin = id
        if autoSyncActiveTitle then autoSyncActiveTitle(true) end
    end)
    
    -- 3. Auto CO-OP (Sem Fim)
    createToggle(TitulosTab, "🌀 Auto Equipar no CO-OP Sem Fim", Config.TitleCoopEnabled, function(val)
        Config.TitleCoopEnabled = val
        if autoSyncActiveTitle then autoSyncActiveTitle(true) end
    end)
    createLabel(TitulosTab, "Título para CO-OP (Recomendado: +% Tokens)")
    createDropdown(TitulosTab, "", AllTitlesList, Config.TitleCoop, function(id)
        Config.TitleCoop = id
        if autoSyncActiveTitle then autoSyncActiveTitle(true) end
    end)
    
    -- 4. Arena Boss e Obby
    createToggle(TitulosTab, "⚔️ Auto Equipar no Boss de Arena", Config.TitleBossEnabled, function(val)
        Config.TitleBossEnabled = val
        if autoSyncActiveTitle then autoSyncActiveTitle(true) end
    end)
    createLabel(TitulosTab, "Título para Boss (Recomendado: +% Dano)")
    createDropdown(TitulosTab, "", AllTitlesList, Config.TitleBoss, function(id)
        Config.TitleBoss = id
        if autoSyncActiveTitle then autoSyncActiveTitle(true) end
    end)
    
    -- 5. Raid (Invasão)
    createToggle(TitulosTab, "🛡️ Auto Equipar na Raid", Config.TitleRaidEnabled, function(val)
        Config.TitleRaidEnabled = val
        if autoSyncActiveTitle then autoSyncActiveTitle(true) end
    end)
    createLabel(TitulosTab, "Título para Raid (Recomendado: +% Tokens)")
    createDropdown(TitulosTab, "", AllTitlesList, Config.TitleRaid, function(id)
        Config.TitleRaid = id
        if autoSyncActiveTitle then autoSyncActiveTitle(true) end
    end)
    
    -- 6. PvP
    createToggle(TitulosTab, "🥊 Auto Equipar no PvP", Config.TitlePvpEnabled, function(val)
        Config.TitlePvpEnabled = val
        if autoSyncActiveTitle then autoSyncActiveTitle(true) end
    end)
    createLabel(TitulosTab, "Título para PvP (Recomendado: +% Dano / Vida)")
    createDropdown(TitulosTab, "", AllTitlesList, Config.TitlePvp, function(id)
        Config.TitlePvp = id
        if autoSyncActiveTitle then autoSyncActiveTitle(true) end
    end)
    
    -- 7. Chocar Ovos
    createToggle(TitulosTab, "🥚 Auto Equipar ao Chocar Ovos", Config.TitleEggEnabled, function(val)
        Config.TitleEggEnabled = val
        if autoSyncActiveTitle then autoSyncActiveTitle(true) end
    end)
    createLabel(TitulosTab, "Título para Chocar Ovos (Recomendado: +% Sorte)")
    createDropdown(TitulosTab, "", AllTitlesList, Config.TitleEgg, function(id)
        Config.TitleEgg = id
        if autoSyncActiveTitle then autoSyncActiveTitle(true) end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  6. ABA EVENTOS (BOSS DE ARENA, RAID, SOBREVIVÊNCIA) [FOTOS 2 & 3]
-- ══════════════════════════════════════════════════════════════
local bossDiedInCurrentEvent = false

createSectionHeader(EventosTab, "⚔️ BOSS DE ARENA")

EventStatusCard = createInfoCard(EventosTab, "⏱️ TEMPO PARA OS EVENTOS", "Carregando...", Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255))

spawnThread(function()
    while true do
        pcall(function()
            local bInfo, rInfo = getEventTimersInfo()
            if EventStatusCard then
                EventStatusCard.Update(string.format("Próximo Boss: %s\nPróxima Raid: %s", bInfo, rInfo), Color3.fromRGB(255, 255, 255))
            end
        end)
        task.wait(1)
    end
end)

createToggle(EventosTab, "Auto Entrar no Boss (Prioridade Total)", Config.AutoEnterBoss, function(val)
    Config.AutoEnterBoss = val
    if val then
        if checkAndAcceptBossInvite then checkAndAcceptBossInvite() end
    else
        bossDiedInCurrentEvent = false
    end
end)

createToggle(EventosTab, "Auto Atacar Boss (Teleporte Direto)", Config.BossAutoAttack, function(val)
    Config.BossAutoAttack = val
end)

createSectionHeader(EventosTab, "🛡️ INVASÃO & RAID")

createToggle(EventosTab, "Auto Entrar na Invasão", Config.AutoEnterRaid, function(val)
    Config.AutoEnterRaid = val
end)

createToggle(EventosTab, "Travessia Inteligente dos OBBYs da Invasão", Config.RaidObbySmart, function(val)
    Config.RaidObbySmart = val
end)

createToggle(EventosTab, "Auto Atacar Monstros & Boss Final da Invasão", Config.RaidAutoAttack, function(val)
    Config.RaidAutoAttack = val
end)



createSectionHeader(EventosTab, "🧠 MEMÓRIA & RETORNO AUTOMÁTICO")

createToggle(EventosTab, "Retornar à Atividade Anterior ao Fim do Evento", Config.EventReturnMemory, function(val)
    Config.EventReturnMemory = val
end)

-- ══════════════════════════════════════════════════════════════
--  6. ABA PVP (KILL AURA, SEGUIR ALVO & COMBATE JOGADOR)
-- ══════════════════════════════════════════════════════════════
createSectionHeader(PvpTab, "🥊 AUTO COMBATE & KILL AURA PVP")

createToggle(PvpTab, "Kill Aura PvP (Atacar Jogadores Próximos)", Config.PvpKillAura, function(val)
    Config.PvpKillAura = val
end)

createToggle(PvpTab, "Grudar no Alvo (Teleporte Contínuo nas Costas)", Config.PvpStickToTarget, function(val)
    Config.PvpStickToTarget = val
end)

createSlider(PvpTab, "Distância da Aura PvP", 5, 50, Config.PvpAuraRange, " studs", false, function(val)
    Config.PvpAuraRange = val
end)

createSectionHeader(PvpTab, "👑 TÍTULO DE PVP AUTOMÁTICO")

createToggle(PvpTab, "Auto Equipar Título de PvP ao Lutar", Config.TitlePvpEnabled, function(val)
    Config.TitlePvpEnabled = val
    if autoSyncActiveTitle then autoSyncActiveTitle(true) end
end)

createLabel(PvpTab, "Título para PvP:")
createDropdown(PvpTab, "", AllTitlesList, Config.TitlePvp, function(id)
    Config.TitlePvp = id
    if autoSyncActiveTitle then autoSyncActiveTitle(true) end
end)

-- Boss Event Hooks (Prioridade Total com Aceitação Imediata e Teleporte para Arena)
local wasFightingBoss = false

local function teleportToBossArena()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local bossModel, bHum = getActiveBossModel()
        local bHrp = bossModel and (bossModel:FindFirstChild("HumanoidRootPart") or bossModel.PrimaryPart or bossModel:FindFirstChild("Torso") or bossModel:FindFirstChildWhichIsA("BasePart"))
        
        local targetCF
        if bHrp then
            targetCF = bHrp.CFrame * CFrame.new(0, 5, 8)
        elseif lastKnownBossPos then
            targetCF = CFrame.new(lastKnownBossPos + Vector3.new(0, 5, 0))
        else
            targetCF = BOSS_ARENA_CFRAME
        end
        
        if LocalPlayer.RequestStreamAroundAsync then
            pcall(function() LocalPlayer:RequestStreamAroundAsync(targetCF.Position) end)
        end
        
        hrp.CFrame = targetCF
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
        if hrp.AssemblyLinearVelocity then hrp.AssemblyLinearVelocity = Vector3.zero end
        if hrp.AssemblyAngularVelocity then hrp.AssemblyAngularVelocity = Vector3.zero end
        print("[Auto Boss] Personagem teleportado para a Arena do Boss!")
    end)
end

local isHandlingBossFinish = false

finishBossAndResetCharacter = function(reason)
    if isHandlingBossFinish then return end
    isHandlingBossFinish = true
    print("[Auto Boss] Finalizando Boss (" .. tostring(reason) .. ")! Processando retorno com memória...")
    
    bossDiedInCurrentEvent = true
    isBossFighting = false
    wasFightingBoss = false
    bossEventPhase = "Finished"
    
    task.spawn(function()
        task.wait(1.0) -- Aguarda 1s para o jogo processar os drops e recompensas
        
        -- Dá o reset no personagem para sair da arena do boss de forma limpa
        print("[Auto Boss] Resetando personagem para sair da arena do Boss...")
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                hum.Health = 0
            elseif char then
                char:BreakJoints()
            end
        end)
        task.wait(1.0)
        waitForCharacterAlive(8)
        
        isHandlingBossFinish = false
        resumeAutomationsAfterEvent("Boss")
    end)
end

checkAndAcceptBossInvite = function()
    if not Config.AutoEnterBoss then return end
    
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    local top = pgui and pgui:FindFirstChild("ScreenGui") and pgui.ScreenGui:FindFirstChild("Top")
    local bfi = top and top:FindFirstChild("BossFightInvite")
    
    if bfi and bfi.Visible then
        print("[Auto Boss] Convite de evento do Boss (BossFightInvite) detectado na tela! Aceitando...")
        
        -- Salva a posição e automações antes de aceitar o convite
        if not EventMemory.IsActive or EventMemory.CurrentEvent ~= "Boss" then
            pauseAutomationsForEvent("Boss")
        end
        bossDiedInCurrentEvent = false
        
        -- Dispara o Remote para o servidor aceitar o convite
        if RemoteBossEventResponse then
            RemoteBossEventResponse:FireServer(true)
        end
        
        -- Clica no botão de aceitar ('Vá!' / 'JoinButton')
        local joinBtn = bfi:FindFirstChild("JoinButton") or bfi:FindFirstChildWhichIsA("ImageButton", true) or bfi:FindFirstChildWhichIsA("GuiButton", true)
        if joinBtn then
            pcall(function()
                if firesignal then
                    firesignal(joinBtn.Activated)
                    firesignal(joinBtn.MouseButton1Click)
                elseif firebutton1click then
                    firebutton1click(joinBtn)
                end
            end)
        end
        
        for _, b in ipairs(bfi:GetDescendants()) do
            if b:IsA("GuiButton") and b ~= joinBtn then
                pcall(function()
                    if firesignal then firesignal(b.Activated) firesignal(b.MouseButton1Click)
                    elseif firebutton1click then firebutton1click(b) end
                end)
            end
        end
    end
end

-- Listener do evento de interface para aceitar o convite assim que aparecer na tela
pcall(function()
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    local top = pgui and pgui:FindFirstChild("ScreenGui") and pgui.ScreenGui:FindFirstChild("Top")
    local bfi = top and top:FindFirstChild("BossFightInvite")
    if bfi then
        local visConn = bfi:GetPropertyChangedSignal("Visible"):Connect(function()
            if bfi.Visible then checkAndAcceptBossInvite() end
        end)
        table.insert(ActiveConnections, visConn)
        if bfi.Visible then checkAndAcceptBossInvite() end
    end
end)

-- Monitor de convite contínuo (aceita instantaneamente assim que abre)
spawnThread(function()
    while true do
        if Config.AutoEnterBoss then
            pcall(checkAndAcceptBossInvite)
        end
        task.wait(0.2)
    end
end)

if RemoteBossEventReward then
    local brConn = RemoteBossEventReward.OnClientEvent:Connect(function(...)
        print("[Auto Boss] RemoteBossEventReward recebido! Boss finalizado com recompensa.")
        if (EventMemory.IsActive and EventMemory.CurrentEvent == "Boss") or isBossFighting or wasFightingBoss or (isBossActive and isBossActive()) then
            finishBossAndResetCharacter("Recompensa do Boss recebida")
        end
    end)
    table.insert(ActiveConnections, brConn)
end

if RemoteBossEventPrompt then
    local bpConn = RemoteBossEventPrompt.OnClientEvent:Connect(function(...)
        if Config.AutoEnterBoss then
            if not EventMemory.IsActive or EventMemory.CurrentEvent ~= "Boss" then
                pauseAutomationsForEvent("Boss")
            end
            checkAndAcceptBossInvite()
            if RemoteBossEventResponse then RemoteBossEventResponse:FireServer(true) end
        end
    end)
    table.insert(ActiveConnections, bpConn)
end

if RemoteBossEventCountdown then
    local bcConn = RemoteBossEventCountdown.OnClientEvent:Connect(function(secondsLeft)
        if secondsLeft and secondsLeft <= 5 and secondsLeft > 0 and Config.AutoEnterBoss then
            if not EventMemory.IsActive or EventMemory.CurrentEvent ~= "Boss" then
                pauseAutomationsForEvent("Boss")
            end
            checkAndAcceptBossInvite()
            if RemoteBossEventResponse then RemoteBossEventResponse:FireServer(true) end
        end
    end)
    table.insert(ActiveConnections, bcConn)
end

if RemoteBossEventUpdate then
    local buConn = RemoteBossEventUpdate.OnClientEvent:Connect(function(arg1, ...)
        local phase = nil
        if type(arg1) == "table" then
            phase = arg1.phase
        elseif type(arg1) == "string" then
            phase = arg1
        end
        if phase then bossEventPhase = phase end
        if phase == "Active" and Config.AutoEnterBoss then
            if not EventMemory.IsActive or EventMemory.CurrentEvent ~= "Boss" then
                pauseAutomationsForEvent("Boss")
            end
            checkAndAcceptBossInvite()
            if RemoteBossEventResponse then RemoteBossEventResponse:FireServer(true) end
        elseif (phase == "Finished" or phase == "Ended" or phase == "Inactive" or phase == "Cooldown") and Config.AutoEnterBoss then
            if (EventMemory.IsActive and EventMemory.CurrentEvent == "Boss") or isBossFighting or wasFightingBoss then
                finishBossAndResetCharacter("Fase do Boss finalizada: " .. tostring(phase))
            end
        end
    end)
    table.insert(ActiveConnections, buConn)
end

-- Thread de Combate Boss de Arena (Thanos / Doom / Tung Sahur / Kong)
spawnThread(function()
    local lastAttackTick = 0
    local bossMissingFrames = 0
    local lastBossImmunityChar = nil
    
    while true do
        pcall(function()
            if not Config.BossAutoAttack then
                if isBossFighting or wasFightingBoss then
                    isBossFighting = false
                    wasFightingBoss = false
                end
                -- Se AutoEnterBoss está ativo e o Boss terminou (sem barra de vida nem convite):
                if EventMemory.IsActive and EventMemory.CurrentEvent == "Boss" and not isHandlingBossFinish then
                    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                    local top = pgui and pgui:FindFirstChild("ScreenGui") and pgui.ScreenGui:FindFirstChild("Top")
                    local bhb = top and top:FindFirstChild("BossHealthBar")
                    local bfi = top and top:FindFirstChild("BossFightInvite")
                    if (not bhb or not bhb.Visible) and (not bfi or not bfi.Visible) and bossEventPhase ~= "Active" then
                        bossMissingFrames = bossMissingFrames + 1
                        if bossMissingFrames >= 8 then
                            finishBossAndResetCharacter("Boss finalizado")
                        end
                    else
                        bossMissingFrames = 0
                    end
                end
                task.wait(0.5)
                return
            end

            if isRaidActive() and Config.AutoEnterRaid then
                if isBossFighting or wasFightingBoss then
                    isBossFighting = false
                    wasFightingBoss = false
                end
                task.wait(0.5)
                return
            end
            local now = os.clock()
            
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not hrp or not hum or hum.Health <= 0 then
                task.wait(0.5)
                return
            end
            
            -- Detectar se a barra de vida do Boss de Arena abriu na tela
            local pgui = LocalPlayer:FindFirstChild("PlayerGui")
            local top = pgui and pgui:FindFirstChild("ScreenGui") and pgui.ScreenGui:FindFirstChild("Top")
            local bhb = top and top:FindFirstChild("BossHealthBar")
            local isBhbVisible = (bhb and bhb.Visible == true)
            
            local bossModel, bHum = getActiveBossModel()
            local hasLiveBoss = (bossModel ~= nil and ((bHum ~= nil and bHum.Health > 0) or bossModel:FindFirstChild("HumanoidRootPart") ~= nil or bossModel.PrimaryPart ~= nil))
            
            if (isBhbVisible or hasLiveBoss) and bossStartTime == 0 then
                bossStartTime = now
            end
            
            local isBossCombatActive = (isBhbVisible or hasLiveBoss or isBossFighting) and not bossDiedInCurrentEvent and not isHandlingBossFinish
            
            if isBossCombatActive then
                isBossFighting = true
                if not wasFightingBoss then
                    wasFightingBoss = true
                    if Config.TitleBossEnabled and equipTitle then equipTitle(Config.TitleBoss) end
                end
                
                -- Se o jogador ainda estiver longe da arena (> 150 studs), teleporta imediatamente
                if hrp and (hrp.Position - BOSS_ARENA_CFRAME.Position).Magnitude > 150 then
                    teleportToBossArena()
                    task.wait(0.2)
                end
                
                if hrp and hum and hum.Health > 0 and Config.BossAutoAttack then
                    -- Imunidade a toques de projéteis/hazards e sobrevivência (apenas 1 vez por spawn)
                    if lastBossImmunityChar ~= char then
                        lastBossImmunityChar = char
                        for _, p in ipairs(char:GetDescendants()) do
                            if p:IsA("BasePart") then
                                p.CanTouch = false
                                p.CanCollide = false
                            end
                        end
                        hum.BreakJointsOnDeath = false
                        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
                        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end)
                        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end)
                    end
                    
                    -- Determina a posição alvo do Boss
                    local bossPos = nil
                    if hasLiveBoss and bossModel then
                        local bHrp = bossModel:FindFirstChild("HumanoidRootPart") or bossModel.PrimaryPart or bossModel:FindFirstChild("Torso") or bossModel:FindFirstChildWhichIsA("BasePart")
                        local bossCF = (bHrp and bHrp.CFrame) or bossModel:GetPivot()
                        bossPos = bossCF.Position
                    else
                        bossPos = BOSS_ARENA_CFRAME.Position
                    end
                    lastKnownBossPos = bossPos
                    
                    -- Posicionamento no Boss: Teleporta diretamente quando a distância for > 10 studs (Sem voo circular)
                    local distToBoss = (hrp.Position - bossPos).Magnitude
                    if distToBoss > 10 then
                        if distToBoss > 150 and LocalPlayer.RequestStreamAroundAsync then
                            pcall(function() LocalPlayer:RequestStreamAroundAsync(bossPos) end)
                        end
                        -- Teleporta a 3.5 studs de distância em frente ao Boss, olhando diretamente para ele
                        local bHrp = hasLiveBoss and bossModel and (bossModel:FindFirstChild("HumanoidRootPart") or bossModel.PrimaryPart or bossModel:FindFirstChildWhichIsA("BasePart"))
                        local forwardVec = bHrp and bHrp.CFrame.LookVector or Vector3.new(0, 0, 1)
                        local attackPos = bossPos + (forwardVec * 3.5) + Vector3.new(0, 1.0, 0)
                        hrp.CFrame = CFrame.lookAt(attackPos, bossPos)
                    else
                        -- Já está a menos de 10 studs: mantém o personagem virado firmemente para o Boss atacando
                        hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(bossPos.X, hrp.Position.Y, bossPos.Z))
                    end
                    
                    hrp.Velocity = Vector3.zero
                    hrp.RotVelocity = Vector3.zero
                    if hrp.AssemblyLinearVelocity then hrp.AssemblyLinearVelocity = Vector3.zero end
                    if hrp.AssemblyAngularVelocity then hrp.AssemblyAngularVelocity = Vector3.zero end
                    
                    -- ATAQUES E CLIQUES RÁPIDOS CONTRA O BOSS (Executam sem parar enquanto em combate)
                    if now - lastAttackTick >= 0.06 then
                        lastAttackTick = now
                        if RemoteRequestAttack then RemoteRequestAttack:FireServer() end
                        if RemotePlayerClick then RemotePlayerClick:FireServer() end
                        local RemotePlayerConePunch = Remotes and Remotes:FindFirstChild("PlayerConePunch")
                        if RemotePlayerConePunch then pcall(function() RemotePlayerConePunch:FireServer() end) end
                    end
                end
            else
                -- Nenhum combate ativo no momento
                if bossWaitingForSpawn and not isReturningToEndless then
                    if (os.clock() - bossWaitStartTime) < 15.0 then
                        task.wait(0.2)
                        return
                    else
                        bossWaitingForSpawn = false
                    end
                end
                
                -- Se estava enfrentando o boss e ele sumiu/morreu:
                if wasFightingBoss and not isHandlingBossFinish then
                    bossMissingFrames = bossMissingFrames + 1
                    if bossMissingFrames >= 8 then
                        task.spawn(function()
                            finishBossAndResetCharacter("Boss derrotado")
                        end)
                    end
                elseif isBossFighting and not isBhbVisible and not isHandlingBossFinish then
                    task.spawn(function()
                        finishBossAndResetCharacter("Evento do Boss encerrado")
                    end)
                end
            end
        end)
        task.wait(0.02)
    end
end)

-- ══════════════════════════════════════════════════════════════
--  MOTOR DE INVASÃO & RAID (SISTEMA DOMINÓ CONNECTORS + SALA-A-SALA)
-- ══════════════════════════════════════════════════════════════
local wasInRaid = false
local disarmedRaidContainers = setmetatable({}, { __mode = "k" })

local function getStageAliveEnemies(stageFolder)
    local enemies = {}
    if not stageFolder then return enemies end
    local enemiesContainer = stageFolder:FindFirstChild("Enemies") or stageFolder:FindFirstChild("Mobs")
    local targets = enemiesContainer and enemiesContainer:GetChildren() or stageFolder:GetDescendants()
    for _, d in ipairs(targets) do
        if d:IsA("Model") and not Players:GetPlayerFromCharacter(d) then
            local hum = d:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local root = d:FindFirstChild("HumanoidRootPart") or d.PrimaryPart or d:FindFirstChild("Torso") or d:FindFirstChildWhichIsA("BasePart")
                if root then
                    table.insert(enemies, {Model = d, Humanoid = hum, Root = root})
                end
            end
        end
    end
    return enemies
end

local function disarmRaidHazards(container)
    if not container or disarmedRaidContainers[container] then return end
    disarmedRaidContainers[container] = true
    for _, d in ipairs(container:GetDescendants()) do
        if d:IsA("BasePart") then
            local dn = d.Name:lower()
            -- Neutraliza armadilhas mortais: Killblock, Void e variações
            if dn == "killblock" or dn == "void" or dn:find("kill") then
                pcall(function()
                    d.CanTouch = false
                    d.CanCollide = false
                end)
            -- Desativa colisões dos bloqueadores invisíveis de portas para permitir passagem fluida
            elseif dn == "blocker" then
                pcall(function()
                    d.CanCollide = false
                end)
            end
        end
    end
end

spawnThread(function()
    local lastRaidImmuneChar = nil
    while true do
        if Config.AutoEnterRaid then
            pcall(function()
                local raidActive, activeRaidFolder = isRaidActive()
                
                -- Se a Raid estiver ativa ou o convite na tela:
                if raidActive then
                    -- 1. PAUSA TODAS AS OUTRAS AUTOMAÇÕES IMEDIATAMENTE (Prioridade da Raid)
                    if not EventMemory.IsActive or EventMemory.CurrentEvent ~= "Raid" then
                        pauseAutomationsForEvent("Raid")
                    end
                    wasInRaid = true
                    
                    -- Se for o momento de entrar na Raid, dá reset de segurança, aguarda 0.5s e aceita o convite
                    if not EventMemory.HasResetForRaid then
                        EventMemory.HasResetForRaid = true
                        task.spawn(function()
                            performResetAndAccept("Raid", function()
                                if autoSyncActiveTitle then autoSyncActiveTitle(true) end
                                if RemoteRaidJoinRequest then RemoteRaidJoinRequest:FireServer() end
                                if RemoteRaidReviveRequest then RemoteRaidReviveRequest:FireServer() end
                                local RemoteRaidStateRequest = Remotes and Remotes:FindFirstChild("RaidStateRequest")
                                if RemoteRaidStateRequest then RemoteRaidStateRequest:FireServer() end
                                
                                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                                local top = pgui and pgui:FindFirstChild("ScreenGui") and pgui.ScreenGui:FindFirstChild("Top")
                                local raidInvite = top and top:FindFirstChild("RaidInvite")
                                if raidInvite and raidInvite.Visible then
                                    local joinBtn = raidInvite:FindFirstChild("JoinButton", true) or raidInvite:FindFirstChildWhichIsA("GuiButton", true)
                                    if joinBtn and joinBtn:IsA("GuiButton") then
                                        pcall(function()
                                            if firesignal then
                                                firesignal(joinBtn.Activated)
                                                firesignal(joinBtn.MouseButton1Click)
                                            elseif firebutton1click then
                                                firebutton1click(joinBtn)
                                            end
                                        end)
                                    end
                                end
                            end)
                        end)
                        task.wait(0.6)
                        return
                    end
                    
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    
                    if hum and hum.Health > 0 and hrp then
                        -- Imunidade a ragdoll/queda e proteção do personagem durante a Raid (apenas 1 vez por spawn)
                        if lastRaidImmuneChar ~= char then
                            lastRaidImmuneChar = char
                            hum.BreakJointsOnDeath = false
                            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
                            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end)
                            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end)
                        end
                        
                        -- Dispara remotes de entrada/revive na Raid
                        if RemoteRaidJoinRequest then RemoteRaidJoinRequest:FireServer() end
                        if RemoteRaidReviveRequest then RemoteRaidReviveRequest:FireServer() end
                        local RemoteRaidStateRequest = Remotes and Remotes:FindFirstChild("RaidStateRequest")
                        if RemoteRaidStateRequest then RemoteRaidStateRequest:FireServer() end
                        
                        -- Clica no JoinButton se a GUI de convite estiver aberta
                        local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                        local top = pgui and pgui:FindFirstChild("ScreenGui") and pgui.ScreenGui:FindFirstChild("Top")
                        local raidInvite = top and top:FindFirstChild("RaidInvite")
                        if raidInvite and raidInvite.Visible then
                            local joinBtn = raidInvite:FindFirstChild("JoinButton", true) or raidInvite:FindFirstChildWhichIsA("GuiButton", true)
                            if joinBtn and joinBtn:IsA("GuiButton") then
                                pcall(function()
                                    if firesignal then
                                        firesignal(joinBtn.Activated)
                                        firesignal(joinBtn.MouseButton1Click)
                                    elseif firebutton1click then
                                        firebutton1click(joinBtn)
                                    end
                                end)
                            end
                        end
                        
                        local activeRaid = activeRaidFolder or getActiveRaidFolder()
                        
                        -- Se ainda estiver no lobby da Entrada e a pasta ativa ainda não carregou, aciona o Touchpart da entrada
                        if not activeRaid then
                            local raidFolder = workspace:FindFirstChild("Raid")
                            local entrance = raidFolder and raidFolder:FindFirstChild("Entrance")
                            local touchPart = entrance and entrance:FindFirstChild("Touchpart", true)
                            if touchPart and touchPart:IsA("BasePart") and firetouchinterest then
                                firetouchinterest(hrp, touchPart, 0)
                                firetouchinterest(hrp, touchPart, 1)
                            end
                        end
                        
                        -- Se a pasta ActiveRaid existe, executa a travessia e combate sala a sala
                        if activeRaid then
                            -- Desativa armadilhas mortais e bloqueadores em toda a Raid
                            disarmRaidHazards(activeRaid)
                            
                            -- Mapeia todas as salas da Raid
                            local stages = {}
                            for _, ch in ipairs(activeRaid:GetChildren()) do
                                local conns = ch:FindFirstChild("Connectors")
                                local startP = conns and conns:FindFirstChild("Start")
                                local endP = conns and conns:FindFirstChild("End")
                                local endTrigger = ch:FindFirstChild("EndTrigger", true) or ch:FindFirstChild("Touchpart", true)
                                local pz = (startP and startP.Position.Z) or (ch:IsA("Model") and ch:GetPivot().Position.Z) or (endP and endP.Position.Z) or 0
                                local sn = ch.Name:lower()
                                local isBoss = (sn:find("boss") ~= nil)
                                local isCombat = (sn:find("enemies") or sn:find("combat")) ~= nil
                                local isObstacle = not isBoss and not isCombat
                                
                                table.insert(stages, {
                                    Folder = ch,
                                    Name = ch.Name,
                                    StartPart = startP,
                                    EndPart = endP,
                                    EndTrigger = endTrigger,
                                    Z = pz,
                                    IsBoss = isBoss,
                                    IsCombat = isCombat,
                                    IsObstacle = isObstacle
                                })
                            end
                            
                            -- Ordena do início ao fim (Z decrescente: do Entrance até o BossFinal)
                            table.sort(stages, function(a, b)
                                return a.Z > b.Z
                            end)
                            
                            -- Identifica a PRIMEIRA sala que ainda não foi concluída:
                            -- Para salas de combate: enquanto houver inimigos vivos, o portão está trancado!
                            -- Para salas de obstáculo: enquanto o jogador não atravessar o EndPart, é a sala atual.
                            -- Para a sala do Boss: é o destino final!
                            local currentStage = nil
                            local currentStageIndex = 1
                            
                            for idx, st in ipairs(stages) do
                                if st.IsCombat then
                                    local aliveEnemies = getStageAliveEnemies(st.Folder)
                                    if #aliveEnemies > 0 then
                                        currentStage = st
                                        currentStageIndex = idx
                                        break
                                    end
                                elseif st.IsObstacle then
                                    local endZ = (st.EndPart and st.EndPart.Position.Z) or st.Z
                                    if hrp.Position.Z > endZ + 6 then
                                        currentStage = st
                                        currentStageIndex = idx
                                        break
                                    end
                                elseif st.IsBoss then
                                    currentStage = st
                                    currentStageIndex = idx
                                    break
                                end
                            end
                            
                            if not currentStage and #stages > 0 then
                                currentStage = stages[#stages]
                            end
                            
                            if currentStage then
                                -- Disarma perigos específicos desta sala
                                disarmRaidHazards(currentStage.Folder)
                                
                                -- ══════════════════════════════════════════════════
                                -- CASO A: SALA DE COMBATE (Inimigos)
                                -- ══════════════════════════════════════════════════
                                if currentStage.IsCombat and Config.RaidAutoAttack then
                                    local aliveEnemies = getStageAliveEnemies(currentStage.Folder)
                                    
                                    if #aliveEnemies > 0 then
                                        -- Procura o inimigo mais próximo
                                        local closestEnemy = nil
                                        local closestDist = math.huge
                                        for _, e in ipairs(aliveEnemies) do
                                            local d = (hrp.Position - e.Root.Position).Magnitude
                                            if d < closestDist then
                                                closestDist = d
                                                closestEnemy = e
                                            end
                                        end
                                        
                                        if closestEnemy then
                                            local eRoot = closestEnemy.Root
                                            local ePos = eRoot.Position
                                            
                                            -- Se estiver muito longe da sala, teleporta para o Start da sala primeiro
                                            if currentStage.StartPart and (hrp.Position - currentStage.StartPart.Position).Magnitude > 250 then
                                                hrp.CFrame = currentStage.StartPart.CFrame * CFrame.new(0, 3, 0)
                                                task.wait(0.1)
                                            end
                                            
                                            -- Posiciona de frente para o inimigo a uma distância perfeita para acertar socos
                                            local attackCF = CFrame.lookAt(Vector3.new(ePos.X, ePos.Y + 2, ePos.Z + 3.5), ePos)
                                            hrp.CFrame = attackCF
                                            hrp.Velocity = Vector3.zero
                                            hrp.RotVelocity = Vector3.zero
                                            if hrp.AssemblyLinearVelocity then hrp.AssemblyLinearVelocity = Vector3.zero end
                                            if hrp.AssemblyAngularVelocity then hrp.AssemblyAngularVelocity = Vector3.zero end
                                            
                                            -- Desfere ataques contínuos com clique virtual e remotes até derrotar
                                            VirtualUser:CaptureController()
                                            VirtualUser:ClickButton1(Vector2.new(0, 0))
                                            if RemoteRequestAttack then RemoteRequestAttack:FireServer() end
                                            if RemotePlayerClick then RemotePlayerClick:FireServer() end
                                            local RemotePlayerConePunch = Remotes and Remotes:FindFirstChild("PlayerConePunch")
                                            if RemotePlayerConePunch then pcall(function() RemotePlayerConePunch:FireServer() end) end
                                            Config.ClicksCount = Config.ClicksCount + 1
                                        end
                                    else
                                        -- Todos os inimigos da sala foram derrotados!
                                        -- O portão para a próxima sala foi liberado!
                                        -- Teleporta até o EndTrigger / Connectors.End para acionar a passagem:
                                        if currentStage.EndTrigger and firetouchinterest then
                                            firetouchinterest(hrp, currentStage.EndTrigger, 0)
                                            task.wait(0.01)
                                            firetouchinterest(hrp, currentStage.EndTrigger, 1)
                                        end
                                        if currentStage.EndPart then
                                            hrp.CFrame = currentStage.EndPart.CFrame * CFrame.new(0, 3, -4)
                                            hrp.Velocity = Vector3.zero
                                        end
                                    end
                                    
                                -- ══════════════════════════════════════════════════
                                -- CASO B: SALA DE OBSTÁCULO (Plataformas, Obby, etc.)
                                -- ══════════════════════════════════════════════════
                                elseif currentStage.IsObstacle and Config.RaidObbySmart then
                                    -- Atravessa o obstáculo com segurança direto até o Conector de Saída (End) e Touchpart
                                    if currentStage.EndTrigger and firetouchinterest then
                                        firetouchinterest(hrp, currentStage.EndTrigger, 0)
                                        task.wait(0.01)
                                        firetouchinterest(hrp, currentStage.EndTrigger, 1)
                                    end
                                    if currentStage.EndPart then
                                        hrp.CFrame = currentStage.EndPart.CFrame * CFrame.new(0, 3, -4)
                                        hrp.Velocity = Vector3.zero
                                        task.wait(0.1)
                                    end
                                    
                                -- ══════════════════════════════════════════════════
                                -- CASO C: SALA FINAL (Boss Fight - Skeletor / Wards)
                                -- ══════════════════════════════════════════════════
                                elseif currentStage.IsBoss and Config.RaidAutoAttack then
                                    -- Se estiver longe da sala do Boss, teleporta para o Start
                                    if currentStage.StartPart and (hrp.Position - currentStage.StartPart.Position).Magnitude > 250 then
                                        hrp.CFrame = currentStage.StartPart.CFrame * CFrame.new(0, 3, 0)
                                        task.wait(0.1)
                                    end
                                    
                                    -- Prioridade 1: Quebra Totens de Cura (Wards / Totem) | Prioridade 2: Ataca o Boss Skeletor
                                    local targetWard = nil
                                    local bossModel = nil
                                    
                                    local searchPool = currentStage.Folder:GetChildren()
                                    for _, m in ipairs(searchPool) do
                                        if m:IsA("Model") and not Players:GetPlayerFromCharacter(m) then
                                            local mn = m.Name:lower()
                                            local wHum = m:FindFirstChildOfClass("Humanoid")
                                            local wPart = m.PrimaryPart or m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                                            if (mn:find("ward") or mn:find("totem")) and wPart and (not wHum or wHum.Health > 0) then
                                                targetWard = wPart
                                                break
                                            elseif wHum and wHum.Health > 0 and not bossModel then
                                                bossModel = m
                                            end
                                        end
                                    end
                                    
                                    if not targetWard and not bossModel then
                                        for _, m in ipairs(currentStage.Folder:GetDescendants()) do
                                            if m:IsA("Model") and not Players:GetPlayerFromCharacter(m) then
                                                local mn = m.Name:lower()
                                                local wHum = m:FindFirstChildOfClass("Humanoid")
                                                local wPart = m.PrimaryPart or m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                                                if (mn:find("ward") or mn:find("totem")) and wPart and (not wHum or wHum.Health > 0) then
                                                    targetWard = wPart
                                                    break
                                                elseif wHum and wHum.Health > 0 and not bossModel then
                                                    bossModel = m
                                                end
                                            end
                                        end
                                    end
                                    
                                    if targetWard then
                                        hrp.CFrame = CFrame.lookAt(targetWard.Position + Vector3.new(0, 2, 4), targetWard.Position)
                                        hrp.Velocity = Vector3.zero
                                        VirtualUser:CaptureController()
                                        VirtualUser:ClickButton1(Vector2.new(0, 0))
                                        if RemoteRequestAttack then RemoteRequestAttack:FireServer() end
                                        if RemotePlayerClick then RemotePlayerClick:FireServer() end
                                        local RemotePlayerConePunch = Remotes and Remotes:FindFirstChild("PlayerConePunch")
                                        if RemotePlayerConePunch then pcall(function() RemotePlayerConePunch:FireServer() end) end
                                        Config.ClicksCount = Config.ClicksCount + 1
                                    elseif bossModel then
                                        local bHrp = bossModel:FindFirstChild("HumanoidRootPart") or bossModel.PrimaryPart or bossModel:FindFirstChildWhichIsA("BasePart")
                                        if bHrp then
                                            local bPos = bHrp.Position
                                            hrp.CFrame = CFrame.lookAt(Vector3.new(bPos.X, bPos.Y + 2.5, bPos.Z + 5), bPos)
                                            hrp.Velocity = Vector3.zero
                                            VirtualUser:CaptureController()
                                            VirtualUser:ClickButton1(Vector2.new(0, 0))
                                            if RemoteRequestAttack then RemoteRequestAttack:FireServer() end
                                            if RemotePlayerClick then RemotePlayerClick:FireServer() end
                                            local RemotePlayerConePunch = Remotes and Remotes:FindFirstChild("PlayerConePunch")
                                            if RemotePlayerConePunch then pcall(function() RemotePlayerConePunch:FireServer() end) end
                                            Config.ClicksCount = Config.ClicksCount + 1
                                        end
                                    end
                                end
                            end
                        end
                    end
                else
                    -- Raid NÃO está ativa no momento.
                    -- Se estávamos na Raid e ela acabou: restaura as funções salvas!
                    if wasInRaid then
                        wasInRaid = false
                        EventMemory.HasResetForRaid = false
                        disarmedRaidContainers = setmetatable({}, { __mode = "k" })
                        print("[Auto Raid] Raid finalizada com sucesso! Retomando funções salvas...")
                        task.wait(1.0)
                        
                        -- Se Config.EventReturnMemory estiver ativado, dá um reset para sair do mapa da raid
                        if Config.EventReturnMemory then
                            print("[Auto Raid] Resetando personagem para sair da Raid e retornar à atividade anterior...")
                            pcall(function()
                                local char = LocalPlayer.Character
                                local hum = char and char:FindFirstChildOfClass("Humanoid")
                                if hum and hum.Health > 0 then
                                    hum.Health = 0
                                elseif char then
                                    char:BreakJoints()
                                end
                            end)
                            task.wait(1.0)
                            waitForCharacterAlive(8)
                        end
                        
                        resumeAutomationsAfterEvent("Raid")
                    end
                end
            end)
        else
            -- Se o usuário desativou Config.AutoEnterRaid manualmente enquanto estava na raid:
            if wasInRaid then
                wasInRaid = false
                EventMemory.HasResetForRaid = false
                resumeAutomationsAfterEvent("Raid")
            end
        end
        task.wait(0.2)
    end
end)

-- ══════════════════════════════════════════════════════════════
-- 🥊 MOTOR DE COMBATE PVP (KILL AURA, SEGUIR ALVO & ATAQUES)
-- ══════════════════════════════════════════════════════════════
spawnThread(function()
    local lastPvpAttack = 0
    while true do
        pcall(function()
            if not Config.PvpKillAura and not Config.PvpStickToTarget then
                isPvpFighting = false
                task.wait(0.2)
                return
            end
            
            if Config.AutoEndless or isInsideEndless() then
                isPvpFighting = false
                task.wait(0.5)
                return
            end
            
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not hrp or not hum or hum.Health <= 0 then
                isPvpFighting = false
                task.wait(0.5)
                return
            end
            
            local bestTarget = nil
            local bestDist = Config.PvpAuraRange or 25
            local now = os.clock()
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local tChar = player.Character
                    local tHum = tChar:FindFirstChildOfClass("Humanoid")
                    local tHrp = tChar:FindFirstChild("HumanoidRootPart") or tChar:FindFirstChild("Torso") or tChar.PrimaryPart
                    if tHum and tHum.Health > 0 and tHrp then
                        local dist = (tHrp.Position - hrp.Position).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            bestTarget = player
                        end
                    end
                end
            end
            
            if bestTarget and bestTarget.Character then
                local tChar = bestTarget.Character
                local tHrp = tChar:FindFirstChild("HumanoidRootPart") or tChar:FindFirstChild("Torso") or tChar.PrimaryPart
                local tHum = tChar:FindFirstChildOfClass("Humanoid")
                
                if tHrp and tHum and tHum.Health > 0 then
                    isPvpFighting = true
                    if Config.TitlePvpEnabled and equipTitle and Config.TitlePvp then
                        equipTitle(Config.TitlePvp)
                    end
                    
                    if Config.PvpStickToTarget then
                        local behindPos = tHrp.Position - (tHrp.CFrame.LookVector * 2.5) + Vector3.new(0, 0.5, 0)
                        hrp.CFrame = CFrame.lookAt(behindPos, tHrp.Position)
                        hrp.Velocity = Vector3.zero
                        if hrp.AssemblyLinearVelocity then hrp.AssemblyLinearVelocity = Vector3.zero end
                    end
                    
                    if now - lastPvpAttack >= 0.05 then
                        lastPvpAttack = now
                        if RemoteRequestAttack then RemoteRequestAttack:FireServer() end
                        if RemotePlayerClick then RemotePlayerClick:FireServer() end
                        local RemotePlayerConePunch = Remotes and Remotes:FindFirstChild("PlayerConePunch")
                        if RemotePlayerConePunch then pcall(function() RemotePlayerConePunch:FireServer() end) end
                        local RemotePiercingSlash = Remotes and Remotes:FindFirstChild("PlayerPiercingSlash")
                        if RemotePiercingSlash then pcall(function() RemotePiercingSlash:FireServer() end) end
                    end
                end
            end
        end)
        task.wait(0.03)
    end
end)

-- ══════════════════════════════════════════════════════════════
-- 🔄 GERENCIADOR UNIVERSAL DE MORTE & RECUPERAÇÃO NO RESPAWN
-- ══════════════════════════════════════════════════════════════
local function handleUniversalCharacterRespawn(newChar)
    if not newChar then return end
    task.spawn(function()
        local char, hrp, hum = waitForCharacterAlive(8)
        if not char or not hrp or not hum then return end
        
        print("[Respawn Recovery] Personagem renasceu no Spawn! Verificando estado atual...")
        task.wait(1.0)
        
        -- 1. Se a Raid estiver em andamento e o jogador estiver com Auto Raid ativo:
        if isRaidActive() and Config.AutoEnterRaid then
            print("[Respawn Recovery] Raid ativa detectada após renascer! Retornando para a Raid...")
            if RemoteRaidReviveRequest then RemoteRaidReviveRequest:FireServer() end
            if RemoteRaidJoinRequest then RemoteRaidJoinRequest:FireServer() end
            return
        end
        
        -- 2. Se o Boss de Arena estiver ativo e o ataque ao Boss estiver ligado:
        if isBossActive() and Config.BossAutoAttack and not bossDiedInCurrentEvent then
            print("[Respawn Recovery] Boss de Arena ativo após renascer! Retornando para a Arena...")
            teleportToBossArena()
            return
        end
        
        -- 3. Se havia memória de atividade salva e o evento já foi encerrado, restaura:
        if EventMemory.IsActive and not isRaidActive() and not isBossActive() then
            print("[Respawn Recovery] Evento finalizado! Restaurando tarefas memorizadas...")
            resumeAutomationsAfterEvent(EventMemory.CurrentEvent or "General")
            return
        end
        
        -- 4. Se o Auto Treino estiver ligado, garante retorno imediato à área de treino:
        if Config.AutoTrain and not isInsideEndless() then
            local targetZone = nil
            if Config.SelectedTrainZone == "auto" then
                targetZone = getBestUnlockedZone(Config.SelectedTrainWorld, Config.TrainZoneFilter)
            else
                for _, z in ipairs(AllTrainingZones) do
                    if z.Id == Config.SelectedTrainZone then
                        targetZone = z
                        break
                    end
                end
            end
            if targetZone then
                local wNum = targetZone.World or 1
                local mapName = (wNum == 1 and "Map") or (wNum == 2 and "MapTest") or ("Map" .. wNum)
                local curMap = getCurrentMap()
                if not curMap or curMap.Name ~= mapName then
                    if RemoteRequestWorldChange then
                        RemoteRequestWorldChange:InvokeServer(wNum)
                        task.wait(1.5)
                    end
                end
                local bag, hitbox = findTrainingBag(wNum, targetZone.Id)
                if hitbox then
                    print("[Respawn Recovery] Retornando ao saco de treino após respawn...")
                    local curChar, curHrp = waitForCharacterAlive(4)
                    if curHrp then
                        curHrp.CFrame = hitbox.CFrame + Vector3.new(0, 2.5, 0)
                    end
                end
            end
        end
    end)
end

table.insert(ActiveConnections, LocalPlayer.CharacterAdded:Connect(handleUniversalCharacterRespawn))





-- ══════════════════════════════════════════════════════════════
--  CLEANUP FUNCTION
-- ══════════════════════════════════════════════════════════════
getgenv().SuperHeroEvolutionHubCleanup = function()
    -- 1. Desativa todas as opções
    for k, _ in pairs(Config) do
        if type(Config[k]) == "boolean" then
            Config[k] = false
        end
    end
    
    -- 2. Restaura físicas e propriedades do personagem
    pcall(function()
        if stopFly then stopFly() end
        if applyInvisibility then applyInvisibility(false) end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
        for _, part in ipairs(char and char:GetDescendants() or {}) do
            if part:IsA("BasePart") then
                part.CanCollide = true
                if part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 0
                else
                    part.Transparency = 1
                end
            end
        end
    end)
    
    -- 3. Restaura câmera e telas do jogo
    pcall(function()
        Camera.CameraType = Enum.CameraType.Custom
        local sc = ReplicatedStorage:FindFirstChild("Client") and ReplicatedStorage.Client:FindFirstChild("ScreenController")
        if sc then
            local scMod = require(sc)
            if scMod and scMod._origHide then
                scMod.hide = scMod._origHide
                scMod._origHide = nil
            end
        end
    end)
    
    if applySkipAnimation then pcall(applySkipAnimation, false) end
    
    -- 4. Cancela threads e desconecta listeners
    for _, t in ipairs(ActiveThreads) do pcall(task.cancel, t) end
    for _, c in ipairs(ActiveConnections) do pcall(function() c:Disconnect() end) end
    table.clear(ActiveThreads)
    table.clear(ActiveConnections)
    
    -- 5. Destrói interface visual completamente
    if ScreenGui and ScreenGui.Parent then pcall(function() ScreenGui:Destroy() end) end
    destroyExistingHubs()
    
    -- 6. Reseta estatísticas da sessão (reinicia do zero se reabrir)
    SessionRebirths = 0
    Config.RebirthsCount = 0
    Config.ClicksCount = 0
    Config.EggsHatched = 0
    
    -- 7. Limpa variáveis do ambiente global
    getgenv().SuperHeroEvolutionHubLoaded = nil
    getgenv().SuperHeroEvolutionHubCleanup = nil
    getgenv().SuperHeroEvolutionHubConfig = nil
    
    print("[Hub] Script descarregado completamente como se nunca tivesse sido executado.")
end

-- ══════════════════════════════════════════════════════════════
-- 🔄 AUTO-UPDATE EM TEMPO REAL (DETECÇÃO E RECARGA AUTOMÁTICA)
-- ══════════════════════════════════════════════════════════════
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
                        
                        -- Salva configurações atuais para preservar estado
                        pcall(function()
                            if saveConfig then saveConfig() end
                        end)
                        
                        -- Notifica o jogador na tela
                        pcall(function()
                            game:GetService("StarterGui"):SetCore("SendNotification", {
                                Title = "🚀 Hub Atualizado!",
                                Text = "Nova versão (" .. tostring(data.commit) .. ") carregada automaticamente!",
                                Duration = 5
                            })
                        end)
                        
                        -- Limpa a instância atual com segurança
                        pcall(function()
                            if getgenv().SuperHeroEvolutionHubCleanup then
                                getgenv().SuperHeroEvolutionHubCleanup()
                            end
                        end)
                        
                        task.wait(0.5)
                        
                        -- Executa a versão mais recente com cache-busting
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/miguelmarinho1420-hub/superhero-evolution/main/script.lua?t=" .. os.time()))()
                    end
                end
            end)
        end
    end
end)

-- Seleciona a primeira aba inicialmente
if TabButtons["Treino"] then
    TabButtons["Treino"].BackgroundTransparency = 0
    TabButtons["Treino"].BackgroundColor3 = Themes.Card
    TabButtons["Treino"].TextColor3 = Themes.Accent2
    Tabs["Treino"].Visible = true
end

print("══════════════════════════════════════════════════════")
print("[SUPERHERO EVOLUTION HUB V5.0] Carregado com Sucesso!")
print("Pressione 'K' para Minimizar / Abrir a interface.")
print("══════════════════════════════════════════════════════")
