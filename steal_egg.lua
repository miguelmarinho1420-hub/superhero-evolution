--[[
    ========================================================================
    STEAL AN EGG - ULTIMATE HUB v2.5 (EVENTOS, PRIORIDADES & AUTO-FARM)
    Jogo: Steal An Egg (PlaceId: 107778070777162)
    Autor: Antigravity Assistant
    
    Funcionalidades Principais:
      📑 Abas Modernas de Navegação (Ovos, Eventos, Fila de Prioridades, Config)
      🦋 Evento de Borboleta: Teleporte automático para Vector3(6801.70, 67.62, -373.98) e AFK até o fim
      🧪 Dr. Scramble Lab: Identificação de ovos, rotação de ovo escolhida e auto-troca
      🏁 Corrida com Bots: Localiza portal, pega speed pads e garante vitória em 1º lugar
      🥚 Coleta de Ovos: Seleção de Área + Raridades e retorno à última tarefa após roubo
      🔀 Fila de Prioridades: Arraste / Reordene com botões ▲/▼ a ordem de execução das tarefas
      ⚡ Treino de Velocidade: Coleta contínua de velocidade / pads em segundo plano
      🎨 Visual Glassmorphism Futurista com Suporte a 'K' ou Botão Flutuante
    ========================================================================
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Destrói instâncias anteriores para não duplicar interface
local HUB_GUI_NAME = "StealAnEggUltimateHub"
local existingGui = (gethui and gethui():FindFirstChild(HUB_GUI_NAME)) or PlayerGui:FindFirstChild(HUB_GUI_NAME) or CoreGui:FindFirstChild(HUB_GUI_NAME)
if existingGui then
    pcall(function() existingGui:Destroy() end)
end

-- ========================================================================
-- BASE DE DADOS DOS BIOMAS, GUARDIÕES E OVOS DO JOGO
-- ========================================================================
local RARITY_COLORS = {
    ["Comum"]     = Color3.fromRGB(180, 180, 180),
    ["Common"]    = Color3.fromRGB(180, 180, 180),
    ["Incomum"]   = Color3.fromRGB(80, 220, 100),
    ["Uncommon"]  = Color3.fromRGB(80, 220, 100),
    ["Raro"]      = Color3.fromRGB(50, 150, 255),
    ["Rare"]      = Color3.fromRGB(50, 150, 255),
    ["Épico"]     = Color3.fromRGB(180, 70, 255),
    ["Epic"]      = Color3.fromRGB(180, 70, 255),
    ["Lendário"]  = Color3.fromRGB(255, 170, 20),
    ["Legendary"] = Color3.fromRGB(255, 170, 20),
    ["Mítico"]    = Color3.fromRGB(255, 50, 70),
    ["Mythic"]    = Color3.fromRGB(255, 50, 70),
    ["Cósmico"]   = Color3.fromRGB(0, 240, 255),
    ["Cosmic"]    = Color3.fromRGB(0, 240, 255),
    ["Celestial"] = Color3.fromRGB(255, 235, 100),
    ["Secreto"]   = Color3.fromRGB(140, 20, 240),
    ["Secret"]    = Color3.fromRGB(140, 20, 240),
    ["Eterno"]    = Color3.fromRGB(255, 80, 180),
    ["Eternal"]   = Color3.fromRGB(255, 80, 180),
    ["Divino"]    = Color3.fromRGB(255, 215, 0),
    ["Divine"]    = Color3.fromRGB(255, 215, 0),
}

local RARITY_ORDER = {
    "Comum", "Incomum", "Raro", "Épico", "Lendário", "Mítico", "Celestial", "Cósmico", "Secreto", "Eterno", "Divino"
}

local BIOMES_DATA = {
    {
        name = "Forest",
        displayName = "🌲 Floresta (Forest)",
        speedReq = "0",
        guardian = "Chicken (Galinha)",
        eggs = {
            { name = "Chicken Egg", pet = "Chicken", rarity = "Comum", income = "$1/s", color = Color3.fromRGB(240, 230, 210) },
            { name = "Dog Egg", pet = "Dog", rarity = "Comum", income = "$2/s", color = Color3.fromRGB(190, 150, 110) },
            { name = "Bird Egg", pet = "Bird", rarity = "Incomum", income = "$8/s", color = Color3.fromRGB(90, 200, 240) },
            { name = "Owl Egg", pet = "Owl", rarity = "Raro", income = "$35/s", color = Color3.fromRGB(140, 110, 80) },
            { name = "Raccoon Egg", pet = "Raccoon", rarity = "Raro", income = "$45/s", color = Color3.fromRGB(110, 110, 120) },
            { name = "Fox Egg", pet = "Fox", rarity = "Épico", income = "$180/s", color = Color3.fromRGB(240, 120, 40) },
            { name = "Bear Egg", pet = "Bear", rarity = "Épico", income = "$240/s", color = Color3.fromRGB(90, 60, 40) },
            { name = "Brr Brr Patapim Egg", pet = "Brr Brr Patapim", rarity = "Lendário", income = "$1.8k/s", color = Color3.fromRGB(255, 180, 30) },
        }
    },
    {
        name = "Lake",
        displayName = "🌊 Lago (Lake)",
        speedReq = "900",
        guardian = "Swan (Cisne)",
        eggs = {
            { name = "Frog Egg", pet = "Frog", rarity = "Comum", income = "$3/s", color = Color3.fromRGB(100, 200, 80) },
            { name = "Duckling Egg", pet = "Duckling", rarity = "Comum", income = "$4/s", color = Color3.fromRGB(255, 230, 80) },
            { name = "Catfish Egg", pet = "Catfish", rarity = "Incomum", income = "$12/s", color = Color3.fromRGB(70, 130, 180) },
            { name = "Turtle Egg", pet = "Turtle", rarity = "Raro", income = "$60/s", color = Color3.fromRGB(50, 170, 110) },
            { name = "Trulimero Egg", pet = "Trulimero Trulicina", rarity = "Épico", income = "$260/s", color = Color3.fromRGB(160, 80, 220) },
            { name = "Swan Egg", pet = "Swan", rarity = "Épico", income = "$320/s", color = Color3.fromRGB(245, 245, 255) },
            { name = "Axolotl Egg", pet = "Axolotl", rarity = "Lendário", income = "$2.8k/s", color = Color3.fromRGB(255, 140, 180) },
            { name = "Leviathan Egg", pet = "Leviathan", rarity = "Cósmico", income = "$220k/s", color = Color3.fromRGB(0, 230, 255) },
        }
    },
    {
        name = "Desert",
        displayName = "🏜️ Deserto (Desert)",
        speedReq = "10K",
        guardian = "Scorpion (Escorpião)",
        eggs = {
            { name = "Camel Egg", pet = "Camel", rarity = "Comum", income = "$15/s", color = Color3.fromRGB(210, 180, 130) },
            { name = "Sand Snake Egg", pet = "Sand Snake", rarity = "Incomum", income = "$50/s", color = Color3.fromRGB(200, 160, 90) },
            { name = "Desert Fox Egg", pet = "Desert Fox", rarity = "Raro", income = "$150/s", color = Color3.fromRGB(230, 140, 70) },
            { name = "Scorpion Egg", pet = "Scorpion", rarity = "Épico", income = "$650/s", color = Color3.fromRGB(130, 40, 40) },
            { name = "Mummy Dog Egg", pet = "Mummy Dog", rarity = "Lendário", income = "$5.5k/s", color = Color3.fromRGB(240, 210, 150) },
            { name = "Anubis Egg", pet = "Anubis", rarity = "Mítico", income = "$45k/s", color = Color3.fromRGB(50, 50, 60) },
            { name = "Sphinx Egg", pet = "Sphinx", rarity = "Cósmico", income = "$850k/s", color = Color3.fromRGB(255, 200, 50) },
        }
    },
    {
        name = "Jungle",
        displayName = "🌴 Selva (Jungle)",
        speedReq = "40K",
        guardian = "Tiger (Tigre)",
        eggs = {
            { name = "Monkey Egg", pet = "Monkey", rarity = "Comum", income = "$35/s", color = Color3.fromRGB(150, 100, 60) },
            { name = "Parrot Egg", pet = "Parrot", rarity = "Incomum", income = "$120/s", color = Color3.fromRGB(240, 50, 50) },
            { name = "Crocodile Egg", pet = "Crocodile", rarity = "Raro", income = "$400/s", color = Color3.fromRGB(60, 140, 60) },
            { name = "Jaguar Egg", pet = "Jaguar", rarity = "Épico", income = "$1.8k/s", color = Color3.fromRGB(220, 150, 30) },
            { name = "Tiger Egg", pet = "Tiger", rarity = "Lendário", income = "$15k/s", color = Color3.fromRGB(255, 120, 0) },
            { name = "Jungle King Egg", pet = "Silverback", rarity = "Mítico", income = "$120k/s", color = Color3.fromRGB(70, 70, 80) },
            { name = "Amazon Basilisk Egg", pet = "Basilisk", rarity = "Cósmico", income = "$2.5M/s", color = Color3.fromRGB(40, 230, 140) },
        }
    },
    {
        name = "Snow",
        displayName = "❄️ Neve (Snow)",
        speedReq = "170K",
        guardian = "Yeti",
        eggs = {
            { name = "Penguin Egg", pet = "Penguin", rarity = "Comum", income = "$80/s", color = Color3.fromRGB(40, 40, 50) },
            { name = "Seal Egg", pet = "Seal", rarity = "Incomum", income = "$280/s", color = Color3.fromRGB(180, 190, 205) },
            { name = "Polar Bear Egg", pet = "Polar Bear", rarity = "Raro", income = "$950/s", color = Color3.fromRGB(240, 245, 255) },
            { name = "Yeti Egg", pet = "Yeti", rarity = "Épico", income = "$4.5k/s", color = Color3.fromRGB(150, 210, 245) },
            { name = "Ice Dragon Egg", pet = "Ice Dragon", rarity = "Lendário", income = "$38k/s", color = Color3.fromRGB(90, 200, 255) },
            { name = "Frost Wyrm Egg", pet = "Frost Wyrm", rarity = "Mítico", income = "$350k/s", color = Color3.fromRGB(140, 100, 255) },
            { name = "Blizzard Phoenix Egg", pet = "Blizzard Phoenix", rarity = "Cósmico", income = "$8M/s", color = Color3.fromRGB(200, 240, 255) },
        }
    },
    {
        name = "Volcano",
        displayName = "🌋 Vulcão (Volcano)",
        speedReq = "700K",
        guardian = "Cerberus",
        eggs = {
            { name = "Magma Golem Egg", pet = "Magma Golem", rarity = "Raro", income = "$2.5k/s", color = Color3.fromRGB(180, 50, 20) },
            { name = "Obsidian Beast Egg", pet = "Obsidian Beast", rarity = "Épico", income = "$12k/s", color = Color3.fromRGB(50, 30, 40) },
            { name = "Dimetrodon Egg", pet = "Dimetrodon", rarity = "Lendário", income = "$95k/s", color = Color3.fromRGB(240, 90, 20) },
            { name = "Brachiosaurus Egg", pet = "Brachiosaurus", rarity = "Mítico", income = "$850k/s", color = Color3.fromRGB(200, 40, 40) },
            { name = "Cerberus Egg", pet = "Cerberus", rarity = "Celestial", income = "$12M/s", color = Color3.fromRGB(120, 20, 20) },
            { name = "Phoenix Egg", pet = "Phoenix", rarity = "Cósmico", income = "$25M/s", color = Color3.fromRGB(255, 140, 0) },
            { name = "Lava Dragon Egg", pet = "Lava Dragon", rarity = "Divino", income = "$100M/s", color = Color3.fromRGB(255, 210, 0) },
        }
    },
    {
        name = "Abyss Ocean",
        displayName = "🦑 Oceano Abissal (Abyss Ocean)",
        speedReq = "2.5M",
        guardian = "Moby / Beluga Whale",
        eggs = {
            { name = "Anglerfish Egg", pet = "Anglerfish", rarity = "Raro", income = "$8k/s", color = Color3.fromRGB(20, 60, 90) },
            { name = "Giant Squid Egg", pet = "Giant Squid", rarity = "Épico", income = "$35k/s", color = Color3.fromRGB(180, 40, 80) },
            { name = "Megalodon Egg", pet = "Megalodon", rarity = "Lendário", income = "$280k/s", color = Color3.fromRGB(70, 100, 130) },
            { name = "Abyssal Siren Egg", pet = "Abyssal Siren", rarity = "Mítico", income = "$2.2M/s", color = Color3.fromRGB(30, 150, 180) },
            { name = "Moby Whale Egg", pet = "Beluga Guardian", rarity = "Celestial", income = "$25M/s", color = Color3.fromRGB(220, 235, 255) },
            { name = "Kraken Egg", pet = "Kraken", rarity = "Cósmico", income = "$50M/s", color = Color3.fromRGB(100, 30, 180) },
            { name = "Deep Sovereign Egg", pet = "Leviathan Sovereign", rarity = "Divino", income = "$350M/s", color = Color3.fromRGB(0, 255, 200) },
        }
    },
    {
        name = "Prehistoric",
        displayName = "🦖 Pré-Histórico (Prehistoric)",
        speedReq = "18M",
        guardian = "T-Rex",
        eggs = {
            { name = "Dodo Egg", pet = "Dodo", rarity = "Raro", income = "$50k/s", color = Color3.fromRGB(170, 180, 160) },
            { name = "Velociraptor Egg", pet = "Velociraptor", rarity = "Épico", income = "$110k/s", color = Color3.fromRGB(160, 140, 80) },
            { name = "Pterodactyl Egg", pet = "Pterodactyl", rarity = "Lendário", income = "$850k/s", color = Color3.fromRGB(180, 90, 50) },
            { name = "Triceratops Egg", pet = "Triceratops", rarity = "Mítico", income = "$7M/s", color = Color3.fromRGB(80, 120, 60) },
            { name = "Spinosaurus Egg", pet = "Spinosaurus", rarity = "Cósmico", income = "$120M/s", color = Color3.fromRGB(190, 60, 30) },
            { name = "T-Rex Egg", pet = "King T-Rex", rarity = "Celestial", income = "$350M/s", color = Color3.fromRGB(130, 40, 20) },
            { name = "Ancient Titanosaur Egg", pet = "Titanosaur", rarity = "Divino", income = "$1B/s", color = Color3.fromRGB(255, 200, 80) },
        }
    },
    {
        name = "Cosmic",
        displayName = "🌌 Cósmico (Cosmic)",
        speedReq = "700M",
        guardian = "Cosmic Skeleton",
        eggs = {
            { name = "Star Cadet Egg", pet = "Star Cadet", rarity = "Lendário", income = "$2.5M/s", color = Color3.fromRGB(100, 140, 240) },
            { name = "Nebula Ray Egg", pet = "Nebula Ray", rarity = "Mítico", income = "$22M/s", color = Color3.fromRGB(180, 60, 240) },
            { name = "Celestial Skeleton Egg", pet = "Cosmic Skeleton", rarity = "Cósmico", income = "$350M/s", color = Color3.fromRGB(80, 240, 255) },
            { name = "Galaxy Phoenix Egg", pet = "Galaxy Phoenix", rarity = "Secreto", income = "$1.2B/s", color = Color3.fromRGB(220, 50, 180) },
            { name = "Eternal Lunar Dragon Egg", pet = "Lunar Dragon", rarity = "Eterno", income = "$4B/s", color = Color3.fromRGB(130, 100, 255) },
            { name = "Cosmic Unicorn Egg", pet = "Cosmic Unicorn", rarity = "Divino", income = "$10B/s", color = Color3.fromRGB(255, 230, 120) },
        }
    },
    {
        name = "Cherry Blossom",
        displayName = "🌸 Flor de Cerejeira (Cherry Blossom)",
        speedReq = "2.5B",
        guardian = "Oni Tiger",
        eggs = {
            { name = "Tanuki Egg", pet = "Tanuki", rarity = "Lendário", income = "$8M/s", color = Color3.fromRGB(140, 100, 70) },
            { name = "Red Panda Egg", pet = "Red Panda", rarity = "Mítico", income = "$60M/s", color = Color3.fromRGB(220, 70, 90) },
            { name = "Surgeon Fish Egg", pet = "Surgeon Fish", rarity = "Mítico", income = "$75M/s", color = Color3.fromRGB(230, 80, 130) },
            { name = "Kitsune Egg", pet = "Nine-Tailed Kitsune", rarity = "Cósmico", income = "$1B/s", color = Color3.fromRGB(255, 120, 60) },
            { name = "Oni Tiger Egg", pet = "Oni Tiger Guardian", rarity = "Secreto", income = "$3.5B/s", color = Color3.fromRGB(160, 20, 60) },
            { name = "Sakura Dragon Egg", pet = "Sakura Dragon", rarity = "Eterno", income = "$12B/s", color = Color3.fromRGB(255, 160, 200) },
            { name = "Mandarin Fish Egg", pet = "Mandarin Sovereign", rarity = "Divino", income = "$30B/s", color = Color3.fromRGB(255, 215, 0) },
        }
    },
    {
        name = "Titan Temple",
        displayName = "🏛️ Templo Titã (Titan Temple)",
        speedReq = "7B",
        guardian = "Gorilla King",
        eggs = {
            { name = "Temple Sentinel Egg", pet = "Temple Sentinel", rarity = "Lendário", income = "$25M/s", color = Color3.fromRGB(160, 150, 130) },
            { name = "Bladehide Egg", pet = "Bladehide", rarity = "Mítico", income = "$200M/s", color = Color3.fromRGB(80, 200, 100) },
            { name = "Sun Priest Egg", pet = "Sun Priest", rarity = "Mítico", income = "$240M/s", color = Color3.fromRGB(240, 180, 40) },
            { name = "Aztec Colossus Egg", pet = "Aztec Colossus", rarity = "Cósmico", income = "$3B/s", color = Color3.fromRGB(50, 200, 180) },
            { name = "Gorilla King Egg", pet = "Gorilla King", rarity = "Secreto", income = "$10B/s", color = Color3.fromRGB(100, 60, 40) },
            { name = "Titan Worldbreaker Egg", pet = "Worldbreaker", rarity = "Eterno", income = "$35B/s", color = Color3.fromRGB(190, 80, 30) },
            { name = "Solar Deity Egg", pet = "Solar Deity", rarity = "Divino", income = "$90B/s", color = Color3.fromRGB(255, 235, 60) },
        }
    },
    {
        name = "Light Dark",
        displayName = "⚖️ Luz & Trevas (Angels & Demons)",
        speedReq = "20B",
        guardian = "ArchAngel / World Burner / Aetheron",
        eggs = {
            { name = "Seraphim Egg", pet = "Seraphim", rarity = "Mítico", income = "$800M/s", color = Color3.fromRGB(240, 240, 255) },
            { name = "Infernal Behemoth Egg", pet = "Infernal Behemoth", rarity = "Cósmico", income = "$8B/s", color = Color3.fromRGB(180, 30, 30) },
            { name = "World Burner Egg", pet = "World Burner", rarity = "Secreto", income = "$30B/s", color = Color3.fromRGB(80, 20, 20) },
            { name = "Archangel Gabriel Egg", pet = "Archangel Gabriel", rarity = "Eterno", income = "$100B/s", color = Color3.fromRGB(255, 255, 200) },
            { name = "Aetheron Egg", pet = "Aetheron Guardian", rarity = "Divino", income = "$300B/s", color = Color3.fromRGB(255, 220, 80) },
        }
    },
    {
        name = "Enchanted Forest",
        displayName = "✨ Floresta Encantada (Enchanted)",
        speedReq = "50B",
        guardian = "Special Forest Guardian",
        eggs = {
            { name = "Pixie Fairy Egg", pet = "Pixie Fairy", rarity = "Mítico", income = "$2.5B/s", color = Color3.fromRGB(255, 140, 240) },
            { name = "Elder Treant Egg", pet = "Elder Treant", rarity = "Cósmico", income = "$25B/s", color = Color3.fromRGB(40, 160, 90) },
            { name = "Fae Sovereign Egg", pet = "Fae Sovereign", rarity = "Secreto", income = "$90B/s", color = Color3.fromRGB(160, 60, 255) },
            { name = "Spirit Guardian Egg", pet = "Spirit Guardian", rarity = "Eterno", income = "$350B/s", color = Color3.fromRGB(80, 240, 200) },
            { name = "Yggdrasil Egg", pet = "Yggdrasil Origin", rarity = "Divino", income = "$1T/s", color = Color3.fromRGB(255, 215, 0) },
        }
    }
}

-- Mapeia biomas por chave simples
local BIOMES_MAP = {}
for idx, biome in ipairs(BIOMES_DATA) do
    BIOMES_MAP[biome.name:lower()] = biome
    biome.index = idx
end

-- ========================================================================
-- ESTADO GLOBAL E CONFIGURAÇÃO
-- ========================================================================
local HubState = {
    currentTab = "Events", -- "Eggs", "Events", "Priorities", "Config"
    
    -- Configurações de Ovos
    selectedBiome = BIOMES_DATA[1],
    selectedEgg = BIOMES_DATA[1].eggs[1],
    selectedScopeArea = "All", -- "All" ou Biome Name
    selectedRarities = {
        ["Divino"]    = true,
        ["Divine"]    = true,
        ["Eterno"]    = true,
        ["Eternal"]   = true,
        ["Secreto"]   = true,
        ["Secret"]    = true,
        ["Cósmico"]   = true,
        ["Cosmic"]    = true,
        ["Celestial"] = true,
        ["Mítico"]    = true,
        ["Mythic"]    = true,
        ["Lendário"]  = true,
        ["Legendary"] = true,
        ["Épico"]     = false,
        ["Raro"]      = false,
        ["Incomum"]   = false,
        ["Comum"]     = false,
    },
    autoStealActive = false,
    autoStealMode = "SafeGlide", -- "SafeGlide" ou "InstantTP"
    autoReturnSafeZone = true,
    returnToLastTaskAfterEgg = true,
    flightAltitude = 75,
    savedBaseCFrame = nil,
    isStealing = false,
    
    -- Evento de Borboleta
    butterflyCoord = Vector3.new(6801.70, 67.62, -373.98),
    autoButterflyActive = true,
    isWaitingButterfly = false,
    butterflyActiveInGame = false,
    
    -- Laboratório do Dr. Scramble
    drScrambleActive = true,
    chosenRotation = "DNA Instável", -- "DNA Instável", "Animais de Risco Biológico", "Animais de Estimação Experimentais", "Qualquer"
    currentDetectedRotation = "DNA Instável",
    drScrambleMissingEggs = {}, -- lista de ovos que faltam entregar
    
    -- Corrida (Race Bots)
    autoRaceActive = true,
    inRace = false,
    raceFinished = false,
    
    -- Treino de Velocidade
    speedTrainActive = true,
    
    -- Gerenciador de Prioridades e Tarefas
    currentRunningTask = "Nenhuma",
    lastActiveTask = "SpeedTrain",
    taskPriorities = {
        { id = "Race",         name = "🏁 Corrida (Race)",            icon = "🏁", enabled = true },
        { id = "DrScramble",   name = "🧪 Dr. Scramble (Troca)",     icon = "🧪", enabled = true },
        { id = "Butterfly",    name = "🦋 Evento Borboleta (AFK)",    icon = "🦋", enabled = true },
        { id = "EggFarm",      name = "🥚 Coleta de Ovos (Área)",    icon = "🥚", enabled = true },
        { id = "SpeedTrain",   name = "⚡ Treino de Velocidade",     icon = "⚡", enabled = true },
    },
    
    espActive = false,
    espDrawings = {},
}

-- Salva a posição inicial como base segura do jogador
task.spawn(function()
    repeat task.wait(0.5) until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    HubState.savedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
end)

local function getRootPart()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ========================================================================
-- SCANNER DO WORKSPACE (LOCALIZAÇÃO DINÂMICA DE ÁREAS E OVOS)
-- ========================================================================
local function getAreasFolder()
    local world = Workspace:FindFirstChild("World")
    if world and world:FindFirstChild("Areas") then
        return world.Areas
    end
    if Workspace:FindFirstChild("Areas") then
        return Workspace.Areas
    end
    return nil
end

local function scanWorldEggs()
    local results = {
        byArea = {},
        allEggs = {}
    }
    
    local areasFolder = getAreasFolder()
    if areasFolder then
        for _, areaInstance in ipairs(areasFolder:GetChildren()) do
            local areaName = areaInstance.Name
            results.byArea[areaName] = {}
            
            for _, desc in ipairs(areaInstance:GetDescendants()) do
                local isEgg = false
                if desc:IsA("Model") or desc:IsA("BasePart") then
                    if desc.Name:lower():find("egg") or desc:FindFirstChildWhichIsA("ProximityPrompt") then
                        isEgg = true
                    end
                end
                
                if isEgg then
                    local prompt = desc:FindFirstChildWhichIsA("ProximityPrompt", true)
                    local pivot = (desc:IsA("Model") and desc:GetPivot()) or (desc:IsA("BasePart") and desc.CFrame)
                    
                    if pivot then
                        local eggEntry = {
                            instance = desc,
                            name = desc.Name,
                            areaName = areaName,
                            cframe = pivot,
                            prompt = prompt,
                        }
                        table.insert(results.byArea[areaName], eggEntry)
                        table.insert(results.allEggs, eggEntry)
                    end
                end
            end
        end
    end
    
    -- Varre também ovos soltos no Workspace caso existam
    for _, obj in ipairs(Workspace:GetChildren()) do
        if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower():find("egg") and not (areasFolder and obj:IsDescendantOf(areasFolder)) then
            local pivot = (obj:IsA("Model") and obj:GetPivot()) or (obj:IsA("BasePart") and obj.CFrame)
            if pivot then
                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                table.insert(results.allEggs, {
                    instance = obj,
                    name = obj.Name,
                    areaName = "Geral",
                    cframe = pivot,
                    prompt = prompt
                })
            end
        end
    end
    
    return results
end

local function triggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return false end
    
    if typeof(fireproximityprompt) == "function" then
        pcall(function() fireproximityprompt(prompt, 0) end)
        return true
    end
    
    pcall(function()
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration or 0.1)
        prompt:InputHoldEnd()
    end)
    return true
end

local function hasStolenEgg()
    local char = LocalPlayer.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if (item:IsA("Tool") or item:IsA("Model")) and item.Name:lower():find("egg") then
                return true, item
            end
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item.Name:lower():find("egg") then
                return true, item
            end
        end
    end
    return false, nil
end

local function safeGlideTo(targetCFrame, onArrived)
    local hrp = getRootPart()
    if not hrp then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    end
    
    local startPos = hrp.Position
    local highStart = Vector3.new(startPos.X, startPos.Y + HubState.flightAltitude, startPos.Z)
    local highTarget = Vector3.new(targetCFrame.Position.X, targetCFrame.Position.Y + HubState.flightAltitude, targetCFrame.Position.Z)
    local finalTarget = targetCFrame.Position + Vector3.new(0, 2, 0)
    
    hrp.CFrame = CFrame.new(highStart)
    task.wait(0.06)
    
    local dist = (highStart - highTarget).Magnitude
    local glideTime = math.clamp(dist / 160, 0.2, 1.8)
    
    local tweenInfo = TweenInfo.new(glideTime, Enum.EasingStyle.Linear)
    local glideTween = TweenService:Create(hrp, tweenInfo, { CFrame = CFrame.new(highTarget) })
    glideTween:Play()
    glideTween.Completed:Wait()
    
    hrp.CFrame = CFrame.new(finalTarget)
    task.wait(0.1)
    
    if onArrived then
        onArrived()
    end
end

local function returnToSafeZone()
    local hrp = getRootPart()
    if not hrp or not HubState.savedBaseCFrame then return end
    
    if HubState.autoStealMode == "SafeGlide" then
        safeGlideTo(HubState.savedBaseCFrame, function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
        end)
    else
        hrp.CFrame = HubState.savedBaseCFrame
    end
end

local function executeStealTarget(eggTarget, customCallback)
    if HubState.isStealing then return end
    HubState.isStealing = true
    
    local hrp = getRootPart()
    if not hrp then
        HubState.isStealing = false
        return
    end
    
    local targetCFrame = eggTarget.cframe
    if not targetCFrame and eggTarget.instance then
        targetCFrame = (eggTarget.instance:IsA("Model") and eggTarget.instance:GetPivot()) or eggTarget.instance.CFrame
    end
    
    if not targetCFrame then
        HubState.isStealing = false
        return
    end
    
    local function doGrab()
        local prompt = eggTarget.prompt
        if not prompt and eggTarget.instance then
            prompt = eggTarget.instance:FindFirstChildWhichIsA("ProximityPrompt", true)
        end
        
        if prompt then
            triggerPrompt(prompt)
        end
        
        task.wait(0.25)
        
        local gotEgg, eggTool = hasStolenEgg()
        if gotEgg then
            print("[STEAL SUCCESS] Ovo adquirido:", eggTool.Name)
        end
        
        if customCallback then
            customCallback(gotEgg, eggTool)
        elseif HubState.autoReturnSafeZone then
            returnToSafeZone()
        end
        
        HubState.isStealing = false
    end
    
    if HubState.autoStealMode == "SafeGlide" then
        safeGlideTo(targetCFrame, doGrab)
    else
        hrp.CFrame = targetCFrame + Vector3.new(0, 2, 0)
        task.wait(0.08)
        doGrab()
    end
end

-- ========================================================================
-- MÓDULO 1: EVENTO DE BORBOLETA (BUTTERFLY EVENT)
-- Coordenada exata: 6801.70, 67.62, -373.98
-- ========================================================================
local function checkButterflyEventActive()
    -- Detecta se o evento de borboleta está acontecendo no mapa / gui
    for _, obj in ipairs(Workspace:GetChildren()) do
        local n = obj.Name:lower()
        if n:find("butterfly") or n:find("borboleta") then
            return true, obj
        end
    end
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, desc in ipairs(gui:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Visible then
                    local t = desc.Text:lower()
                    if t:find("butterfly") or t:find("borboleta") then
                        return true, desc
                    end
                end
            end
        end
    end
    return false, nil
end

local function runButterflyEvent()
    local hrp = getRootPart()
    if not hrp then return end
    
    HubState.currentRunningTask = "🦋 Borboleta (AFK na Coordenada)"
    local targetCF = CFrame.new(HubState.butterflyCoord)
    
    -- Teleporta para a coordenada requisitada
    hrp.CFrame = targetCF
    task.wait(0.1)
    
    -- Cria um BodyVelocity ou ancla levemente para estabilidade perfeita
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bv.Parent = hrp
    
    HubState.isWaitingButterfly = true
    print("[EVENTO BORBOLETA] Teleportado para", tostring(HubState.butterflyCoord), "- Aguardando fim do evento...")
    
    -- Permanece estático até o evento acabar ou o usuário desativar
    local waitStart = os.time()
    while HubState.isWaitingButterfly and HubState.autoButterflyActive do
        task.wait(1.5)
        
        -- Mantém a posição exata
        if (hrp.Position - HubState.butterflyCoord).Magnitude > 5 then
            hrp.CFrame = targetCF
        end
        
        -- Verifica se o evento terminou
        local isActive = checkButterflyEventActive()
        HubState.butterflyActiveInGame = isActive
        
        -- Se o evento não for detectado e já passou um tempo mínimo, finaliza
        if not isActive and (os.time() - waitStart > 10) then
            print("[EVENTO BORBOLETA] Evento concluído com sucesso!")
            break
        end
    end
    
    pcall(function() bv:Destroy() end)
    HubState.isWaitingButterfly = false
    print("[EVENTO BORBOLETA] Retomando próxima tarefa da fila.")
end

-- ========================================================================
-- MÓDULO 2: LABORATÓRIO DO DR. SCRAMBLE
-- Identifica ovos do laboratório, rotação atual e realiza troca
-- ========================================================================
local function detectScrambleRotation()
    -- Varre PlayerGui em busca do painel de rotação atual
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, label in ipairs(gui:GetDescendants()) do
                if label:IsA("TextLabel") and label.Visible then
                    local text = label.Text
                    if text:find("DNA Instável") or text:find("Unstable DNA") then
                        return "DNA Instável"
                    elseif text:find("Animais de Risco Biológico") or text:find("Biohazard") then
                        return "Animais de Risco Biológico"
                    elseif text:find("Animais de Estimação Experimentais") or text:find("Experimental") then
                        return "Animais de Estimação Experimentais"
                    end
                end
            end
        end
    end
    return HubState.currentDetectedRotation or "DNA Instável"
end

local function scanScrambleMissingEggs()
    -- Identifica quais ovos estão no laboratório do Dr. Scramble
    local missing = {}
    
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and (gui.Name:lower():find("scramble") or gui.Name:lower():find("lab")) then
            for _, btn in ipairs(gui:GetDescendants()) do
                if btn:IsA("TextButton") or btn:IsA("TextLabel") then
                    local parent = btn.Parent
                    local text = btn.Text:lower()
                    if text:find("adicionar") or text:find("add") or text:find("0/1") then
                        -- Tenta achar o nome do ovo no container
                        local eggName = "Desconhecido"
                        local areaHint = "Pré-histórico"
                        for _, sibling in ipairs(parent:GetDescendants()) do
                            if sibling:IsA("TextLabel") then
                                local sText = sibling.Text
                                if sText:lower():find("ovo de") or sText:lower():find("egg") then
                                    eggName = sText
                                elseif sText:lower():find("encontrado em") or sText:lower():find("found in") then
                                    areaHint = sText:match("%[(.-)%]") or sText
                                end
                            end
                        end
                        table.insert(missing, {
                            name = eggName,
                            area = areaHint,
                            button = btn
                        })
                    end
                end
            end
        end
    end
    
    -- Se a GUI não estiver aberta, adiciona a lista padrão do evento do Dr. Scramble (Dodo, Red Panda, Bladehide)
    if #missing == 0 then
        table.insert(missing, { name = "Ovo de Dodo", area = "Pré-histórico", pet = "Dodo" })
        table.insert(missing, { name = "Ovo de Panda Vermelho", area = "Flor de cerejeira", pet = "Red Panda" })
        table.insert(missing, { name = "Ovo de Bladehide", area = "Templo Titan", pet = "Bladehide" })
    end
    
    HubState.drScrambleMissingEggs = missing
    return missing
end

local function findScrambleLabLocation()
    -- Procura o modelo ou máquina do Dr. Scramble no Workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if n:find("scramble") or n:find("dr. scramble") or n:find("lab") then
            if obj:IsA("Model") and obj:GetPivot() then
                return obj:GetPivot()
            elseif obj:IsA("BasePart") then
                return obj.CFrame
            end
        end
    end
    -- Posição padrão caso não ache o modelo
    return HubState.savedBaseCFrame or CFrame.new(0, 10, 0)
end

local function runDrScrambleExchange()
    HubState.currentRunningTask = "🧪 Dr. Scramble (Verificando Rotação)"
    
    -- 1. Identifica a rotação atual
    local currentRot = detectScrambleRotation()
    HubState.currentDetectedRotation = currentRot
    print("[DR. SCRAMBLE] Rotação Atual Detectada:", currentRot)
    
    -- 2. Condição Crítica: Só realiza a troca se o ovo da rotação for o escolhido!
    local rotationMatches = (HubState.chosenRotation == "Qualquer") or 
                            (currentRot:lower():find(HubState.chosenRotation:lower()))
    
    if not rotationMatches then
        print("[DR. SCRAMBLE] Rotação atual (" .. currentRot .. ") diferente da escolhida (" .. HubState.chosenRotation .. "). Pulando troca.")
        return false
    end
    
    print("[DR. SCRAMBLE] Rotação confirmada! Identificando ovos necessários...")
    local needed = scanScrambleMissingEggs()
    
    local scanData = scanWorldEggs()
    
    for _, eggRequirement in ipairs(needed) do
        local eggFound = nil
        local targetAreaName = eggRequirement.area:lower()
        
        -- Busca o ovo específico no mundo
        for _, worldEgg in ipairs(scanData.allEggs) do
            local wName = worldEgg.name:lower()
            local rName = eggRequirement.name:lower()
            if (eggRequirement.pet and wName:find(eggRequirement.pet:lower())) or wName:find(rName) then
                eggFound = worldEgg
                break
            end
        end
        
        -- Se não achou pelo nome exato, busca nos biomas mapeados
        if not eggFound then
            for _, b in ipairs(BIOMES_DATA) do
                if b.name:lower():find(targetAreaName) or b.displayName:lower():find(targetAreaName) then
                    for _, bEgg in ipairs(b.eggs) do
                        if (eggRequirement.pet and bEgg.pet:lower():find(eggRequirement.pet:lower())) or bEgg.name:lower():find(eggRequirement.name:lower()) then
                            for _, wEgg in ipairs(scanData.allEggs) do
                                if wEgg.name:lower():find(bEgg.pet:lower()) or wEgg.name:lower():find(bEgg.name:lower()) then
                                    eggFound = wEgg
                                    break
                                end
                            end
                        end
                        if eggFound then break end
                    end
                end
                if eggFound then break end
            end
        end
        
        if eggFound then
            HubState.currentRunningTask = "🧪 Dr. Scramble (Pegando " .. eggRequirement.name .. ")"
            print("[DR. SCRAMBLE] Coletando ovo necessário:", eggRequirement.name)
            
            local grabbed = false
            executeStealTarget(eggFound, function(success)
                grabbed = success
            end)
            
            task.wait(0.5)
            
            -- Leva o ovo até o laboratório do Dr. Scramble e realiza a troca
            HubState.currentRunningTask = "🧪 Dr. Scramble (Entregando no Lab)"
            local labCF = findScrambleLabLocation()
            local hrp = getRootPart()
            if hrp and labCF then
                hrp.CFrame = labCF + Vector3.new(0, 3, 0)
                task.wait(0.3)
                
                -- Se tiver botão "Adicionar" na GUI, ativa-o
                if eggRequirement.button then
                    pcall(function()
                        if typeof(firesignal) == "function" and eggRequirement.button.MouseButton1Click then
                            firesignal(eggRequirement.button.MouseButton1Click)
                        else
                            eggRequirement.button:Activate()
                        end
                    end)
                end
                
                -- Aciona prompts no laboratório se existirem
                local prompt = Workspace:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then triggerPrompt(prompt) end
                
                print("[DR. SCRAMBLE] Troca de " .. eggRequirement.name .. " submetida!")
            end
            task.wait(0.8)
        end
    end
    
    return true
end

-- ========================================================================
-- MÓDULO 3: CORRIDA (RACE BOTS & SPEED PADS)
-- Localiza portal, entra no portal, pega pads de velocidade e ganha em 1º
-- ========================================================================
local function findRacePortal()
    -- Procura o portal da corrida no Workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if (n:find("race") or n:find("corrida")) and (n:find("portal") or n:find("start") or n:find("enter")) then
            if obj:IsA("Model") and obj:GetPivot() then
                return obj:GetPivot()
            elseif obj:IsA("BasePart") then
                return obj.CFrame
            end
        end
    end
    
    -- Checa se a pasta RaceBots existe e pega a posição próxima
    local raceBots = Workspace:FindFirstChild("RaceBots")
    if raceBots and #raceBots:GetChildren() > 0 then
        local firstBot = raceBots:GetChildren()[1]
        if firstBot:IsA("Model") and firstBot:GetPivot() then
            return firstBot:GetPivot() + Vector3.new(0, 0, -20)
        end
    end
    
    return nil
end

local function getSpeedPads()
    local pads = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("speed") or n:find("pad") or n:find("boost") or n:find("arrow") then
                table.insert(pads, obj)
            end
        end
    end
    return pads
end

local function runRaceToFirstPlace()
    local hrp = getRootPart()
    if not hrp then return end
    
    HubState.currentRunningTask = "🏁 Corrida (Localizando Portal)"
    local portalCF = findRacePortal()
    
    if not portalCF then
        print("[CORRIDA] Portal de corrida não encontrado no momento.")
        return false
    end
    
    -- 1. Entra no portal da corrida
    print("[CORRIDA] Entrando no portal da corrida...")
    hrp.CFrame = portalCF + Vector3.new(0, 2, 0)
    task.wait(0.5)
    
    HubState.currentRunningTask = "🏁 Corrida (Na Pista - Passando Bots)"
    HubState.inRace = true
    
    -- 2. Varre os Speed Pads do trajeto
    local pads = getSpeedPads()
    print("[CORRIDA] Speed Pads encontrados no percurso:", #pads)
    
    -- 3. Monitora os RaceBots para garantir a primeira posição
    local raceBots = Workspace:FindFirstChild("RaceBots")
    local botsList = (raceBots and raceBots:GetChildren()) or {}
    print("[CORRIDA] Bots concorrentes detectados:", #botsList)
    
    -- Percorre os Speed Pads com boost contínuo acelerado
    for idx, pad in ipairs(pads) do
        if not HubState.autoRaceActive then break end
        
        -- Garante que o jogador esteja sempre à frente do bot mais avançado
        local leadingBotDist = -math.huge
        local leadingBotPos = nil
        for _, bot in ipairs(botsList) do
            if bot:IsA("Model") and bot:GetPivot() then
                local bPos = bot:GetPivot().Position
                if bPos.Z > leadingBotDist then
                    leadingBotDist = bPos.Z
                    leadingBotPos = bPos
                end
            end
        end
        
        -- Teleporta suavemente para o pad para pegar o boost de velocidade
        hrp.CFrame = pad.CFrame + Vector3.new(0, 2, 0)
        
        -- Se houver bot na frente, ultrapassa instantaneamente
        if leadingBotPos and hrp.Position.Z <= leadingBotPos.Z then
            hrp.CFrame = CFrame.new(leadingBotPos + Vector3.new(0, 2, 25))
        end
        
        task.wait(0.08)
    end
    
    -- 4. Cruza a linha de chegada em primeiro
    local finish = Workspace:FindFirstChild("Finish") or Workspace:FindFirstChild("FinishLine") or Workspace:FindFirstChild("WinPad")
    if finish then
        local finishCF = (finish:IsA("Model") and finish:GetPivot()) or finish.CFrame
        hrp.CFrame = finishCF + Vector3.new(0, 2, 0)
        task.wait(0.2)
    end
    
    print("[CORRIDA] Corrida Finalizada! 🏆 Vitória em 1º Lugar Garantida!")
    HubState.inRace = false
    HubState.raceFinished = true
    
    task.wait(1.0)
    return true
end

-- ========================================================================
-- MÓDULO 4: COLETA DE OVOS (ÁREA, RARIDADES & RETORNO À ÚLTIMA TAREFA)
-- ========================================================================
local function runEggCollectionTask()
    HubState.currentRunningTask = "🥚 Coleta de Ovos (" .. HubState.selectedScopeArea .. ")"
    
    local scanData = scanWorldEggs()
    local eligibleEggs = {}
    
    -- Filtra por área se o usuário selecionou uma área específica
    local candidateEggs = scanData.allEggs
    if HubState.selectedScopeArea ~= "All" then
        candidateEggs = {}
        for _, egg in ipairs(scanData.allEggs) do
            if egg.areaName:lower():find(HubState.selectedScopeArea:lower()) then
                table.insert(candidateEggs, egg)
            end
        end
    end
    
    -- Filtra por raridades selecionadas
    for _, egg in ipairs(candidateEggs) do
        local matched = false
        for rName, enabled in pairs(HubState.selectedRarities) do
            if enabled and (egg.name:lower():find(rName:lower()) or (egg.instance and egg.instance.Name:lower():find(rName:lower()))) then
                matched = true
                break
            end
        end
        if matched then
            table.insert(eligibleEggs, egg)
        end
    end
    
    -- Se não encontrou ovos com nome da raridade, usa a base de dados oficial dos biomas
    if #eligibleEggs == 0 then
        local targetBiomes = (HubState.selectedScopeArea ~= "All" and { BIOMES_MAP[HubState.selectedScopeArea:lower()] or BIOMES_DATA[1] }) or BIOMES_DATA
        for _, biome in ipairs(targetBiomes) do
            for _, eggDef in ipairs(biome.eggs) do
                if HubState.selectedRarities[eggDef.rarity] then
                    for _, worldEgg in ipairs(scanData.allEggs) do
                        if worldEgg.name:lower():find(eggDef.pet:lower()) or worldEgg.name:lower():find(eggDef.name:lower()) then
                            table.insert(eligibleEggs, worldEgg)
                            break
                        end
                    end
                end
            end
        end
    end
    
    if #eligibleEggs > 0 then
        local target = eligibleEggs[1]
        print("[AUTO EGG] Roubando ovo selecionado:", target.name)
        executeStealTarget(target, function()
            -- Entrega na base segura
            returnToSafeZone()
            task.wait(0.5)
            
            -- Requisito do usuário: "com isso depois de pegar os ovos volte para a ultima tarefa"
            if HubState.returnToLastTaskAfterEgg and HubState.lastActiveTask and HubState.lastActiveTask ~= "EggFarm" then
                print("[AUTO EGG] Ovo entregue! Retornando para a última tarefa ativa:", HubState.lastActiveTask)
            end
        end)
    else
        task.wait(1.0)
    end
end

-- ========================================================================
-- MÓDULO 5: TREINO DE VELOCIDADE (BACKGROUND TASK)
-- ========================================================================
local function runSpeedTrainingTask()
    HubState.currentRunningTask = "⚡ Treino de Velocidade"
    local hrp = getRootPart()
    if not hrp then return end
    
    -- Toca nos pads de treino ou speed pads disponíveis no mapa
    local pads = getSpeedPads()
    if #pads > 0 then
        local p = pads[math.random(1, math.min(5, #pads))]
        if p then
            hrp.CFrame = p.CFrame + Vector3.new(0, 2, 0)
        end
    end
    task.wait(1.0)
end

-- ========================================================================
-- MOTOR CENTRAL DE PRIORIDADES (TASK SCHEDULER & DISPATCHER)
-- Executa as tarefas rigorosamente de acordo com a ordem definida pelo usuário
-- ========================================================================
task.spawn(function()
    while true do
        task.wait(1.2)
        
        -- Só executa se o auto-farm geral estiver ativo
        if HubState.autoStealActive and not HubState.isStealing then
            -- Avalia cada tarefa da lista em ordem estrita de prioridade (do topo para o fundo)
            for _, taskEntry in ipairs(HubState.taskPriorities) do
                if taskEntry.enabled then
                    local taskId = taskEntry.id
                    
                    if taskId == "Race" and HubState.autoRaceActive then
                        local hasPortal = findRacePortal()
                        if hasPortal then
                            HubState.lastActiveTask = "Race"
                            runRaceToFirstPlace()
                            break
                        end
                        
                    elseif taskId == "DrScramble" and HubState.drScrambleActive then
                        local rot = detectScrambleRotation()
                        local rotMatch = (HubState.chosenRotation == "Qualquer") or rot:lower():find(HubState.chosenRotation:lower())
                        if rotMatch then
                            HubState.lastActiveTask = "DrScramble"
                            local ran = runDrScrambleExchange()
                            if ran then break end
                        end
                        
                    elseif taskId == "Butterfly" and HubState.autoButterflyActive then
                        local isButterflyUp = checkButterflyEventActive()
                        if isButterflyUp or HubState.isWaitingButterfly then
                            HubState.lastActiveTask = "Butterfly"
                            runButterflyEvent()
                            break
                        end
                        
                    elseif taskId == "EggFarm" then
                        HubState.lastActiveTask = "EggFarm"
                        runEggCollectionTask()
                        break
                        
                    elseif taskId == "SpeedTrain" and HubState.speedTrainActive then
                        HubState.lastActiveTask = "SpeedTrain"
                        runSpeedTrainingTask()
                        break
                    end
                end
            end
        end
    end
end)

-- ========================================================================
-- CRIAÇÃO DA INTERFACE VISUAL (GLASSMORPHISM, ABAS & ARRASTAR PRIORIDADES)
-- ========================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = HUB_GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = PlayerGui
end

-- Janela Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 920, 0, 580)
MainFrame.Position = UDim2.new(0.5, -460, 0.5, -290)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 25)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.4
MainStroke.Color = Color3.fromRGB(0, 230, 255)
MainStroke.Transparency = 0.5
MainStroke.Parent = MainFrame

-- Suporte a Arrastar a Janela (Draggable)
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- Barra de Título (TopBar)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 24, 36)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 14)
TopBarCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 380, 1, 0)
TitleLabel.Position = UDim2.new(0, 18, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "🥚 STEAL AN EGG • <font color='#00E6FF'>ULTIMATE HUB v2.5</font>"
TitleLabel.RichText = true
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Status em tempo real no TopBar
local StatusBadge = Instance.new("TextLabel")
StatusBadge.Name = "StatusBadge"
StatusBadge.Size = UDim2.new(0, 320, 0, 26)
StatusBadge.Position = UDim2.new(0.5, -160, 0, 11)
StatusBadge.BackgroundColor3 = Color3.fromRGB(25, 32, 48)
StatusBadge.Font = Enum.Font.GothamBold
StatusBadge.Text = "Tarefa: Inativo"
StatusBadge.TextColor3 = Color3.fromRGB(0, 230, 255)
StatusBadge.TextSize = 11
StatusBadge.Parent = TopBar

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusBadge

task.spawn(function()
    while true do
        task.wait(0.5)
        if HubState.autoStealActive then
            StatusBadge.Text = "🟢 " .. HubState.currentRunningTask
            StatusBadge.TextColor3 = Color3.fromRGB(80, 240, 120)
        else
            StatusBadge.Text = "⚪ Automação Desativada (Clique em Iniciar)"
            StatusBadge.TextColor3 = Color3.fromRGB(180, 190, 210)
        end
    end
end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -42, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 60)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = TopBar

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 8)
CloseBtnCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Botão Flutuante
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Name = "StealEggToggle"
FloatingBtn.Size = UDim2.new(0, 52, 0, 52)
FloatingBtn.Position = UDim2.new(0, 20, 0.5, -26)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
FloatingBtn.Text = "🥚"
FloatingBtn.TextSize = 26
FloatingBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatingBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Thickness = 1.5
FloatStroke.Color = Color3.fromRGB(0, 230, 255)
FloatStroke.Parent = FloatingBtn

FloatingBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.K then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ========================================================================
-- BARRA DE NAVEGAÇÃO DE ABAS (TABS BAR)
-- ========================================================================
local TabsBar = Instance.new("Frame")
TabsBar.Name = "TabsBar"
TabsBar.Size = UDim2.new(1, -20, 0, 40)
TabsBar.Position = UDim2.new(0, 10, 0, 54)
TabsBar.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
TabsBar.Parent = MainFrame

local TabsBarCorner = Instance.new("UICorner")
TabsBarCorner.CornerRadius = UDim.new(0, 8)
TabsBarCorner.Parent = TabsBar

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.FillDirection = Enum.FillDirection.Horizontal
TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabsLayout.Padding = UDim.new(0, 10)
TabsLayout.Parent = TabsBar

local TabFrames = {}

local function createTabButton(tabId, tabName, icon)
    local btn = Instance.new("TextButton")
    btn.Name = "TabBtn_" .. tabId
    btn.Size = UDim2.new(0, 200, 0, 32)
    btn.BackgroundColor3 = (HubState.currentTab == tabId and Color3.fromRGB(0, 180, 216)) or Color3.fromRGB(28, 34, 48)
    btn.Text = icon .. " " .. tabName
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Parent = TabsBar
    
    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        HubState.currentTab = tabId
        for tId, frame in pairs(TabFrames) do
            frame.Visible = (tId == tabId)
        end
        for _, otherBtn in ipairs(TabsBar:GetChildren()) do
            if otherBtn:IsA("TextButton") then
                otherBtn.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 180, 216)
    end)
    
    return btn
end

-- ========================================================================
-- CONTAINER DAS PÁGINAS DAS ABAS
-- ========================================================================
local PagesContainer = Instance.new("Frame")
PagesContainer.Name = "PagesContainer"
PagesContainer.Size = UDim2.new(1, -20, 1, -104)
PagesContainer.Position = UDim2.new(0, 10, 0, 98)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

-- ========================================================================
-- ABA 1: 🎪 EVENTOS (DR. SCRAMBLE, BORBOLETA, CORRIDA)
-- ========================================================================
local EventsPage = Instance.new("Frame")
EventsPage.Name = "EventsPage"
EventsPage.Size = UDim2.new(1, 0, 1, 0)
EventsPage.BackgroundTransparency = 1
EventsPage.Visible = true
EventsPage.Parent = PagesContainer
TabFrames["Events"] = EventsPage

local EventsLayout = Instance.new("UIListLayout")
EventsLayout.FillDirection = Enum.FillDirection.Horizontal
EventsLayout.Padding = UDim.new(0, 12)
EventsLayout.Parent = EventsPage

-- Card 1: 🧪 Laboratório do Dr. Scramble
local CardScramble = Instance.new("Frame")
CardScramble.Size = UDim2.new(0.32, 0, 1, 0)
CardScramble.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
CardScramble.Parent = EventsPage

local CsCorner = Instance.new("UICorner")
CsCorner.CornerRadius = UDim.new(0, 10)
CsCorner.Parent = CardScramble

local CsStroke = Instance.new("UIStroke")
CsStroke.Color = Color3.fromRGB(60, 220, 120)
CsStroke.Thickness = 1.2
CsStroke.Parent = CardScramble

local CsTitle = Instance.new("TextLabel")
CsTitle.Size = UDim2.new(1, -20, 0, 36)
CsTitle.Position = UDim2.new(0, 10, 0, 8)
CsTitle.BackgroundTransparency = 1
CsTitle.Font = Enum.Font.GothamBold
CsTitle.Text = "🧪 DR. SCRAMBLE LAB"
CsTitle.TextColor3 = Color3.fromRGB(60, 220, 120)
CsTitle.TextSize = 14
CsTitle.TextXAlignment = Enum.TextXAlignment.Left
CsTitle.Parent = CardScramble

local CsDesc = Instance.new("TextLabel")
CsDesc.Size = UDim2.new(1, -20, 0, 48)
CsDesc.Position = UDim2.new(0, 10, 0, 42)
CsDesc.BackgroundTransparency = 1
CsDesc.Font = Enum.Font.Gotham
CsDesc.Text = "Identifica os 3 ovos solicitados e realiza a troca somente se a rotação escolhida estiver ativa."
CsDesc.TextColor3 = Color3.fromRGB(180, 190, 210)
CsDesc.TextSize = 11
CsDesc.TextWrapped = true
CsDesc.TextXAlignment = Enum.TextXAlignment.Left
CsDesc.Parent = CardScramble

-- Seletor de Rotação Escolhida
local RotLabel = Instance.new("TextLabel")
RotLabel.Size = UDim2.new(1, -20, 0, 20)
RotLabel.Position = UDim2.new(0, 10, 0, 96)
RotLabel.BackgroundTransparency = 1
RotLabel.Font = Enum.Font.GothamBold
RotLabel.Text = "Ovo de Rotação Escolhido:"
RotLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
RotLabel.TextSize = 11
RotLabel.TextXAlignment = Enum.TextXAlignment.Left
RotLabel.Parent = CardScramble

local RotOptions = {
    "DNA Instável",
    "Animais de Risco Biológico",
    "Animais de Estimação Experimentais",
    "Qualquer"
}
local currentRotIndex = 1

local RotBtn = Instance.new("TextButton")
RotBtn.Size = UDim2.new(1, -20, 0, 34)
RotBtn.Position = UDim2.new(0, 10, 0, 120)
RotBtn.BackgroundColor3 = Color3.fromRGB(28, 36, 52)
RotBtn.Font = Enum.Font.GothamBold
RotBtn.Text = "🧬 " .. RotOptions[currentRotIndex]
RotBtn.TextColor3 = Color3.fromRGB(0, 230, 255)
RotBtn.TextSize = 11
RotBtn.Parent = CardScramble

local RotBtnCorner = Instance.new("UICorner")
RotBtnCorner.CornerRadius = UDim.new(0, 6)
RotBtnCorner.Parent = RotBtn

RotBtn.MouseButton1Click:Connect(function()
    currentRotIndex = (currentRotIndex % #RotOptions) + 1
    HubState.chosenRotation = RotOptions[currentRotIndex]
    RotBtn.Text = "🧬 " .. HubState.chosenRotation
end)

-- Rotação detectada em tempo real
local RotDetectedLabel = Instance.new("TextLabel")
RotDetectedLabel.Size = UDim2.new(1, -20, 0, 36)
RotDetectedLabel.Position = UDim2.new(0, 10, 0, 162)
RotDetectedLabel.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
RotDetectedLabel.Font = Enum.Font.Gotham
RotDetectedLabel.Text = "Rotação no Jogo: Detectando..."
RotDetectedLabel.TextColor3 = Color3.fromRGB(150, 220, 255)
RotDetectedLabel.TextSize = 10
RotDetectedLabel.Parent = CardScramble

local RdlCorner = Instance.new("UICorner")
RdlCorner.CornerRadius = UDim.new(0, 6)
RdlCorner.Parent = RotDetectedLabel

task.spawn(function()
    while true do
        task.wait(2.0)
        local det = detectScrambleRotation()
        RotDetectedLabel.Text = "Rotação no Jogo:\n" .. det
    end
end)

-- Status dos 3 ovos solicitados
local MissingEggsBox = Instance.new("TextLabel")
MissingEggsBox.Size = UDim2.new(1, -20, 0, 120)
MissingEggsBox.Position = UDim2.new(0, 10, 0, 206)
MissingEggsBox.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
MissingEggsBox.Font = Enum.Font.Gotham
MissingEggsBox.Text = "• Ovo 1: Dodo (Pré-histórico)\n• Ovo 2: Panda Vermelho (Sakura)\n• Ovo 3: Bladehide (Templo Titan)"
MissingEggsBox.TextColor3 = Color3.fromRGB(200, 210, 230)
MissingEggsBox.TextSize = 10
MissingEggsBox.TextYAlignment = Enum.TextYAlignment.Top
MissingEggsBox.Parent = CardScramble

local MebCorner = Instance.new("UICorner")
MebCorner.CornerRadius = UDim.new(0, 6)
MebCorner.Parent = MissingEggsBox

-- Botão Executar Troca Agora
local RunScrambleBtn = Instance.new("TextButton")
RunScrambleBtn.Size = UDim2.new(1, -20, 0, 38)
RunScrambleBtn.Position = UDim2.new(0, 10, 1, -50)
RunScrambleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
RunScrambleBtn.Font = Enum.Font.GothamBold
RunScrambleBtn.Text = "⚡ EXECUTAR TROCA AGORA"
RunScrambleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RunScrambleBtn.TextSize = 12
RunScrambleBtn.Parent = CardScramble

local RsCorner = Instance.new("UICorner")
RsCorner.CornerRadius = UDim.new(0, 8)
RsCorner.Parent = RunScrambleBtn

RunScrambleBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        runDrScrambleExchange()
    end)
end)

-- Card 2: 🦋 Evento de Borboleta (Butterfly Event)
local CardButterfly = Instance.new("Frame")
CardButterfly.Size = UDim2.new(0.32, 0, 1, 0)
CardButterfly.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
CardButterfly.Parent = EventsPage

local CbCorner = Instance.new("UICorner")
CbCorner.CornerRadius = UDim.new(0, 10)
CbCorner.Parent = CardButterfly

local CbStroke = Instance.new("UIStroke")
CbStroke.Color = Color3.fromRGB(240, 100, 220)
CbStroke.Thickness = 1.2
CbStroke.Parent = CardButterfly

local CbTitle = Instance.new("TextLabel")
CbTitle.Size = UDim2.new(1, -20, 0, 36)
CbTitle.Position = UDim2.new(0, 10, 0, 8)
CbTitle.BackgroundTransparency = 1
CbTitle.Font = Enum.Font.GothamBold
CbTitle.Text = "🦋 EVENTO BORBOLETA"
CbTitle.TextColor3 = Color3.fromRGB(240, 100, 220)
CbTitle.TextSize = 14
CbTitle.TextXAlignment = Enum.TextXAlignment.Left
CbTitle.Parent = CardButterfly

local CbDesc = Instance.new("TextLabel")
CbDesc.Size = UDim2.new(1, -20, 0, 56)
CbDesc.Position = UDim2.new(0, 10, 0, 42)
CbDesc.BackgroundTransparency = 1
CbDesc.Font = Enum.Font.Gotham
CbDesc.Text = "Teleporta para a coordenada exata configurada e fica parado/estático no local até o evento terminar completamente."
CbDesc.TextColor3 = Color3.fromRGB(180, 190, 210)
CbDesc.TextSize = 11
CbDesc.TextWrapped = true
CbDesc.TextXAlignment = Enum.TextXAlignment.Left
CbDesc.Parent = CardButterfly

local CoordBox = Instance.new("Frame")
CoordBox.Size = UDim2.new(1, -20, 0, 60)
CoordBox.Position = UDim2.new(0, 10, 0, 108)
CoordBox.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
CoordBox.Parent = CardButterfly

local CoordCorner = Instance.new("UICorner")
CoordCorner.CornerRadius = UDim.new(0, 6)
CoordCorner.Parent = CoordBox

local CoordTitle = Instance.new("TextLabel")
CoordTitle.Size = UDim2.new(1, -12, 0, 18)
CoordTitle.Position = UDim2.new(0, 8, 0, 6)
CoordTitle.BackgroundTransparency = 1
CoordTitle.Font = Enum.Font.GothamBold
CoordTitle.Text = "📍 Coordenada Alvo (Fixa):"
CoordTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
CoordTitle.TextSize = 11
CoordTitle.TextXAlignment = Enum.TextXAlignment.Left
CoordTitle.Parent = CoordBox

local CoordValue = Instance.new("TextLabel")
CoordValue.Size = UDim2.new(1, -12, 0, 28)
CoordValue.Position = UDim2.new(0, 8, 0, 26)
CoordValue.BackgroundTransparency = 1
CoordValue.Font = Enum.Font.GothamBold
CoordValue.Text = "6801.70, 67.62, -373.98"
CoordValue.TextColor3 = Color3.fromRGB(0, 230, 255)
CoordValue.TextSize = 13
CoordValue.TextXAlignment = Enum.TextXAlignment.Left
CoordValue.Parent = CoordBox

local BfStatus = Instance.new("TextLabel")
BfStatus.Size = UDim2.new(1, -20, 0, 40)
BfStatus.Position = UDim2.new(0, 10, 0, 180)
BfStatus.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
BfStatus.Font = Enum.Font.Gotham
BfStatus.Text = "Status: Aguardando Evento..."
BfStatus.TextColor3 = Color3.fromRGB(240, 180, 255)
BfStatus.TextSize = 11
BfStatus.Parent = CardButterfly

local BfsCorner = Instance.new("UICorner")
BfsCorner.CornerRadius = UDim.new(0, 6)
BfsCorner.Parent = BfStatus

task.spawn(function()
    while true do
        task.wait(1.0)
        if HubState.isWaitingButterfly then
            BfStatus.Text = "🟢 AFK na Coordenada\nAguardando término do evento..."
            BfStatus.TextColor3 = Color3.fromRGB(100, 255, 150)
        else
            local isUp = checkButterflyEventActive()
            if isUp then
                BfStatus.Text = "🦋 Evento Ativo no Jogo!"
                BfStatus.TextColor3 = Color3.fromRGB(255, 215, 0)
            else
                BfStatus.Text = "Status: Aguardando Início..."
                BfStatus.TextColor3 = Color3.fromRGB(180, 190, 210)
            end
        end
    end
end)

-- Botão Teleportar e Ficar Parado Agora
local TpButterflyBtn = Instance.new("TextButton")
TpButterflyBtn.Size = UDim2.new(1, -20, 0, 38)
TpButterflyBtn.Position = UDim2.new(0, 10, 1, -50)
TpButterflyBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 160)
TpButterflyBtn.Font = Enum.Font.GothamBold
TpButterflyBtn.Text = "📍 TELEPORTAR & FICAR AFK"
TpButterflyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpButterflyBtn.TextSize = 12
TpButterflyBtn.Parent = CardButterfly

local TpbCorner = Instance.new("UICorner")
TpbCorner.CornerRadius = UDim.new(0, 8)
TpbCorner.Parent = TpButterflyBtn

TpButterflyBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        runButterflyEvent()
    end)
end)

-- Card 3: 🏁 Corrida (Race Bots & Speed Pads)
local CardRace = Instance.new("Frame")
CardRace.Size = UDim2.new(0.32, 0, 1, 0)
CardRace.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
CardRace.Parent = EventsPage

local CrCorner = Instance.new("UICorner")
CrCorner.CornerRadius = UDim.new(0, 10)
CrCorner.Parent = CardRace

local CrStroke = Instance.new("UIStroke")
CrStroke.Color = Color3.fromRGB(255, 170, 20)
CrStroke.Thickness = 1.2
CrStroke.Parent = CardRace

local CrTitle = Instance.new("TextLabel")
CrTitle.Size = UDim2.new(1, -20, 0, 36)
CrTitle.Position = UDim2.new(0, 10, 0, 8)
CrTitle.BackgroundTransparency = 1
CrTitle.Font = Enum.Font.GothamBold
CrTitle.Text = "🏁 AUTO CORRIDA (1º LUGAR)"
CrTitle.TextColor3 = Color3.fromRGB(255, 170, 20)
CrTitle.TextSize = 14
CrTitle.TextXAlignment = Enum.TextXAlignment.Left
CrTitle.Parent = CardRace

local CrDesc = Instance.new("TextLabel")
CrDesc.Size = UDim2.new(1, -20, 0, 56)
CrDesc.Position = UDim2.new(0, 10, 0, 42)
CrDesc.BackgroundTransparency = 1
CrDesc.Font = Enum.Font.Gotham
CrDesc.Text = "Localiza o portal, entra na corrida, passa pelos speed pads e acelera à frente de todos os bots (RaceBots) garantindo o 1º lugar!"
CrDesc.TextColor3 = Color3.fromRGB(180, 190, 210)
CrDesc.TextSize = 11
CrDesc.TextWrapped = true
CrDesc.TextXAlignment = Enum.TextXAlignment.Left
CrDesc.Parent = CardRace

local BotsInfo = Instance.new("TextLabel")
BotsInfo.Size = UDim2.new(1, -20, 0, 68)
BotsInfo.Position = UDim2.new(0, 10, 0, 108)
BotsInfo.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
BotsInfo.Font = Enum.Font.Gotham
BotsInfo.Text = "Bots Detectados:\n• Bot_Kinger\n• Bot_ScrambleFan"
BotsInfo.TextColor3 = Color3.fromRGB(200, 210, 230)
BotsInfo.TextSize = 11
BotsInfo.Parent = CardRace

local BiCorner = Instance.new("UICorner")
BiCorner.CornerRadius = UDim.new(0, 6)
BiCorner.Parent = BotsInfo

task.spawn(function()
    while true do
        task.wait(2.0)
        local rb = Workspace:FindFirstChild("RaceBots")
        if rb then
            local names = {}
            for _, b in ipairs(rb:GetChildren()) do
                table.insert(names, b.Name)
            end
            BotsInfo.Text = "Bots no Workspace (" .. #names .. "):\n• " .. table.concat(names, "\n• ")
        else
            BotsInfo.Text = "Pasta RaceBots: Não encontrada\n(Aguardando corrida abrir)"
        end
    end
end)

-- Botão Entrar na Corrida & Ganhar Agora
local RunRaceBtn = Instance.new("TextButton")
RunRaceBtn.Size = UDim2.new(1, -20, 0, 38)
RunRaceBtn.Position = UDim2.new(0, 10, 1, -50)
RunRaceBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 20)
RunRaceBtn.Font = Enum.Font.GothamBold
RunRaceBtn.Text = "🏆 VENCER CORRIDA AGORA"
RunRaceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RunRaceBtn.TextSize = 12
RunRaceBtn.Parent = CardRace

local RrCorner = Instance.new("UICorner")
RrCorner.CornerRadius = UDim.new(0, 8)
RrCorner.Parent = RunRaceBtn

RunRaceBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        runRaceToFirstPlace()
    end)
end)

-- ========================================================================
-- ABA 2: 🥚 AUTO OVOS (ÁREAS & RARIDADES & SCANNER)
-- ========================================================================
local EggsPage = Instance.new("Frame")
EggsPage.Name = "EggsPage"
EggsPage.Size = UDim2.new(1, 0, 1, 0)
EggsPage.BackgroundTransparency = 1
EggsPage.Visible = false
EggsPage.Parent = PagesContainer
TabFrames["Eggs"] = EggsPage

-- Coluna 1: Lista de Áreas / Biomas
local AreasCol = Instance.new("Frame")
AreasCol.Size = UDim2.new(0, 240, 1, 0)
AreasCol.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
AreasCol.Parent = EggsPage

local AreasCorner = Instance.new("UICorner")
AreasCorner.CornerRadius = UDim.new(0, 10)
AreasCorner.Parent = AreasCol

local AreasTitle = Instance.new("TextLabel")
AreasTitle.Size = UDim2.new(1, -16, 0, 32)
AreasTitle.Position = UDim2.new(0, 10, 0, 4)
AreasTitle.BackgroundTransparency = 1
AreasTitle.Font = Enum.Font.GothamBold
AreasTitle.Text = "🗺️ ÁREAS (13 BIOMAS)"
AreasTitle.TextColor3 = Color3.fromRGB(0, 230, 255)
AreasTitle.TextSize = 13
AreasTitle.TextXAlignment = Enum.TextXAlignment.Left
AreasTitle.Parent = AreasCol

local AreasScroll = Instance.new("ScrollingFrame")
AreasScroll.Size = UDim2.new(1, -10, 1, -44)
AreasScroll.Position = UDim2.new(0, 5, 0, 38)
AreasScroll.BackgroundTransparency = 1
AreasScroll.ScrollBarThickness = 4
AreasScroll.CanvasSize = UDim2.new(0, 0, 0, (#BIOMES_DATA + 1) * 44)
AreasScroll.Parent = AreasCol

local AreasLayout = Instance.new("UIListLayout")
AreasLayout.Padding = UDim.new(0, 4)
AreasLayout.Parent = AreasScroll

-- Coluna 2: Ovos na Área
local EggsCol = Instance.new("Frame")
EggsCol.Size = UDim2.new(0, 280, 1, 0)
EggsCol.Position = UDim2.new(0, 250, 0, 0)
EggsCol.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
EggsCol.Parent = EggsPage

local EggsCorner = Instance.new("UICorner")
EggsCorner.CornerRadius = UDim.new(0, 10)
EggsCorner.Parent = EggsCol

local EggsTitle = Instance.new("TextLabel")
EggsTitle.Size = UDim2.new(1, -16, 0, 32)
EggsTitle.Position = UDim2.new(0, 10, 0, 4)
EggsTitle.BackgroundTransparency = 1
EggsTitle.Font = Enum.Font.GothamBold
EggsTitle.Text = "🥚 OVOS NA ÁREA"
EggsTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
EggsTitle.TextSize = 13
EggsTitle.TextXAlignment = Enum.TextXAlignment.Left
EggsTitle.Parent = EggsCol

local EggsScroll = Instance.new("ScrollingFrame")
EggsScroll.Size = UDim2.new(1, -10, 1, -44)
EggsScroll.Position = UDim2.new(0, 5, 0, 38)
EggsScroll.BackgroundTransparency = 1
EggsScroll.ScrollBarThickness = 4
EggsScroll.Parent = EggsCol

local EggsListLayout = Instance.new("UIListLayout")
EggsListLayout.Padding = UDim.new(0, 4)
EggsListLayout.Parent = EggsScroll

-- Coluna 3: Showcase & Controles de Roubo
local ShowcaseCol = Instance.new("Frame")
ShowcaseCol.Size = UDim2.new(1, -542, 1, 0)
ShowcaseCol.Position = UDim2.new(0, 542, 0, 0)
ShowcaseCol.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
ShowcaseCol.Parent = EggsPage

local ScCorner = Instance.new("UICorner")
ScCorner.CornerRadius = UDim.new(0, 10)
ScCorner.Parent = ShowcaseCol

-- Viewport 3D do Ovo
local ViewportContainer = Instance.new("Frame")
ViewportContainer.Size = UDim2.new(1, -20, 0, 140)
ViewportContainer.Position = UDim2.new(0, 10, 0, 10)
ViewportContainer.BackgroundColor3 = Color3.fromRGB(12, 15, 22)
ViewportContainer.ClipsDescendants = true
ViewportContainer.Parent = ShowcaseCol

local VpCorner = Instance.new("UICorner")
VpCorner.CornerRadius = UDim.new(0, 10)
VpCorner.Parent = ViewportContainer

local EggViewport = Instance.new("ViewportFrame")
EggViewport.Size = UDim2.new(1, 0, 1, 0)
EggViewport.BackgroundTransparency = 1
EggViewport.Parent = ViewportContainer

local vpCamera = Instance.new("Camera")
vpCamera.FieldOfView = 45
vpCamera.Parent = EggViewport
EggViewport.CurrentCamera = vpCamera

local vpWorldModel = Instance.new("WorldModel")
vpWorldModel.Parent = EggViewport

local currentVpEgg = nil
local vpAngle = 0

local function createEgg3DModel(eggColor, rarityColor)
    if currentVpEgg then
        currentVpEgg:Destroy()
        currentVpEgg = nil
    end
    
    local model = Instance.new("Model")
    local eggPart = Instance.new("Part")
    eggPart.Name = "EggBase"
    eggPart.Size = Vector3.new(2, 2.7, 2)
    eggPart.Anchored = true
    eggPart.CanCollide = false
    eggPart.Material = Enum.Material.SmoothPlastic
    eggPart.Color = eggColor or Color3.fromRGB(240, 240, 245)
    eggPart.Position = Vector3.new(0, 0, 0)
    eggPart.Parent = model
    
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Sphere
    mesh.Scale = Vector3.new(1.0, 1.35, 1.0)
    mesh.Parent = eggPart
    
    local auraPart = Instance.new("Part")
    auraPart.Name = "RarityAura"
    auraPart.Size = Vector3.new(2.8, 0.15, 2.8)
    auraPart.Anchored = true
    auraPart.CanCollide = false
    auraPart.Material = Enum.Material.Neon
    auraPart.Color = rarityColor or Color3.fromRGB(0, 230, 255)
    auraPart.Position = Vector3.new(0, -1.2, 0)
    auraPart.Parent = model
    
    local auraMesh = Instance.new("SpecialMesh")
    auraMesh.MeshType = Enum.MeshType.Cylinder
    auraMesh.Scale = Vector3.new(1, 0.1, 1)
    auraMesh.Parent = auraPart
    
    model.Parent = vpWorldModel
    currentVpEgg = model
    vpCamera.CFrame = CFrame.new(Vector3.new(0, 0.2, 5), Vector3.new(0, 0, 0))
end

RunService.RenderStepped:Connect(function(dt)
    if currentVpEgg and currentVpEgg:FindFirstChild("EggBase") then
        vpAngle = vpAngle + dt * 1.5
        local base = currentVpEgg.EggBase
        local aura = currentVpEgg:FindFirstChild("RarityAura")
        base.CFrame = CFrame.new(0, math.sin(vpAngle * 2) * 0.12, 0) * CFrame.Angles(0, vpAngle, math.sin(vpAngle) * 0.08)
        if aura then
            aura.CFrame = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, -vpAngle * 0.5, 0)
        end
    end
end)

-- Detalhes do Ovo
local EggDetailsLabel = Instance.new("TextLabel")
EggDetailsLabel.Size = UDim2.new(1, -20, 0, 70)
EggDetailsLabel.Position = UDim2.new(0, 10, 0, 158)
EggDetailsLabel.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
EggDetailsLabel.Font = Enum.Font.Gotham
EggDetailsLabel.Text = "Ovo Selecionado: -\nRaridade: -\nÁrea: -"
EggDetailsLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
EggDetailsLabel.TextSize = 11
EggDetailsLabel.Parent = ShowcaseCol

local EdCorner = Instance.new("UICorner")
EdCorner.CornerRadius = UDim.new(0, 6)
EdCorner.Parent = EggDetailsLabel

-- Controles de Coleta
local AutoCollectAreaBtn = Instance.new("TextButton")
AutoCollectAreaBtn.Size = UDim2.new(1, -20, 0, 32)
AutoCollectAreaBtn.Position = UDim2.new(0, 10, 0, 236)
AutoCollectAreaBtn.BackgroundColor3 = Color3.fromRGB(28, 38, 54)
AutoCollectAreaBtn.Font = Enum.Font.GothamBold
AutoCollectAreaBtn.Text = "📍 Área de Coleta: TODAS AS ÁREAS"
AutoCollectAreaBtn.TextColor3 = Color3.fromRGB(0, 230, 255)
AutoCollectAreaBtn.TextSize = 11
AutoCollectAreaBtn.Parent = ShowcaseCol

local AcaCorner = Instance.new("UICorner")
AcaCorner.CornerRadius = UDim.new(0, 6)
AcaCorner.Parent = AutoCollectAreaBtn

AutoCollectAreaBtn.MouseButton1Click:Connect(function()
    if HubState.selectedScopeArea == "All" then
        HubState.selectedScopeArea = HubState.selectedBiome.name
        AutoCollectAreaBtn.Text = "📍 Área de Coleta: " .. HubState.selectedBiome.displayName
    else
        HubState.selectedScopeArea = "All"
        AutoCollectAreaBtn.Text = "📍 Área de Coleta: TODAS AS ÁREAS"
    end
end)

local ReturnToggleBtn = Instance.new("TextButton")
ReturnToggleBtn.Size = UDim2.new(1, -20, 0, 32)
ReturnToggleBtn.Position = UDim2.new(0, 10, 0, 274)
ReturnToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 38, 54)
ReturnToggleBtn.Font = Enum.Font.GothamBold
ReturnToggleBtn.Text = "↩️ Voltar para Última Tarefa: SIM"
ReturnToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 150)
ReturnToggleBtn.TextSize = 11
ReturnToggleBtn.Parent = ShowcaseCol

local RtCorner = Instance.new("UICorner")
RtCorner.CornerRadius = UDim.new(0, 6)
RtCorner.Parent = ReturnToggleBtn

ReturnToggleBtn.MouseButton1Click:Connect(function()
    HubState.returnToLastTaskAfterEgg = not HubState.returnToLastTaskAfterEgg
    ReturnToggleBtn.Text = "↩️ Voltar para Última Tarefa: " .. (HubState.returnToLastTaskAfterEgg and "SIM" or "NÃO")
    ReturnToggleBtn.TextColor3 = HubState.returnToLastTaskAfterEgg and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(255, 120, 120)
end)

local FilterRarityBtn = Instance.new("TextButton")
FilterRarityBtn.Size = UDim2.new(1, -20, 0, 32)
FilterRarityBtn.Position = UDim2.new(0, 10, 0, 312)
FilterRarityBtn.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
FilterRarityBtn.Font = Enum.Font.GothamBold
FilterRarityBtn.Text = "⚙️ FILTRAR RARIDADES DOS OVOS"
FilterRarityBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
FilterRarityBtn.TextSize = 11
FilterRarityBtn.Parent = ShowcaseCol

local FrCorner = Instance.new("UICorner")
FrCorner.CornerRadius = UDim.new(0, 6)
FrCorner.Parent = FilterRarityBtn

local StealThisNowBtn = Instance.new("TextButton")
StealThisNowBtn.Size = UDim2.new(1, -20, 0, 38)
StealThisNowBtn.Position = UDim2.new(0, 10, 1, -50)
StealThisNowBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 216)
StealThisNowBtn.Font = Enum.Font.GothamBold
StealThisNowBtn.Text = "⚡ ROUBAR ESTE OVO AGORA"
StealThisNowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StealThisNowBtn.TextSize = 12
StealThisNowBtn.Parent = ShowcaseCol

local StnCorner = Instance.new("UICorner")
StnCorner.CornerRadius = UDim.new(0, 8)
StnCorner.Parent = StealThisNowBtn

StealThisNowBtn.MouseButton1Click:Connect(function()
    if HubState.selectedEgg then
        executeStealTarget(HubState.selectedEgg)
    end
end)

local function updateShowcase(eggData, biomeData)
    if not eggData then return end
    HubState.selectedEgg = eggData
    local rColor = RARITY_COLORS[eggData.rarity] or Color3.fromRGB(200, 200, 200)
    EggDetailsLabel.Text = string.format("🥚 %s\n• Raridade: %s\n• Bioma: %s\n• Renda: %s", eggData.name, eggData.rarity, biomeData.displayName, eggData.income or "$??")
    createEgg3DModel(eggData.color, rColor)
end

local function populateEggsList(biomeData)
    for _, child in ipairs(EggsScroll:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    HubState.selectedBiome = biomeData
    EggsTitle.Text = "🥚 OVOS: " .. biomeData.name:upper()
    EggsScroll.CanvasSize = UDim2.new(0, 0, 0, #biomeData.eggs * 50)
    
    for idx, egg in ipairs(biomeData.eggs) do
        local rColor = RARITY_COLORS[egg.rarity] or Color3.fromRGB(180, 180, 180)
        local eggBtn = Instance.new("TextButton")
        eggBtn.Size = UDim2.new(1, -8, 0, 44)
        eggBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
        eggBtn.Text = ""
        eggBtn.Parent = EggsScroll
        
        local ebCorner = Instance.new("UICorner")
        ebCorner.CornerRadius = UDim.new(0, 6)
        ebCorner.Parent = eggBtn
        
        local stripe = Instance.new("Frame")
        stripe.Size = UDim2.new(0, 4, 1, 0)
        stripe.BackgroundColor3 = rColor
        stripe.BorderSizePixel = 0
        stripe.Parent = eggBtn
        
        local eTitle = Instance.new("TextLabel")
        eTitle.Size = UDim2.new(1, -60, 0, 20)
        eTitle.Position = UDim2.new(0, 10, 0, 3)
        eTitle.BackgroundTransparency = 1
        eTitle.Font = Enum.Font.GothamBold
        eTitle.Text = egg.name
        eTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
        eTitle.TextSize = 12
        eTitle.TextXAlignment = Enum.TextXAlignment.Left
        eTitle.Parent = eggBtn
        
        local eSub = Instance.new("TextLabel")
        eSub.Size = UDim2.new(1, -60, 0, 16)
        eSub.Position = UDim2.new(0, 10, 0, 22)
        eSub.BackgroundTransparency = 1
        eSub.Font = Enum.Font.Gotham
        eSub.Text = egg.rarity .. " • " .. (egg.income or "")
        eSub.TextColor3 = rColor
        eSub.TextSize = 10
        eSub.TextXAlignment = Enum.TextXAlignment.Left
        eSub.Parent = eggBtn
        
        eggBtn.MouseButton1Click:Connect(function()
            updateShowcase(egg, biomeData)
        end)
        
        if idx == 1 then
            updateShowcase(egg, biomeData)
        end
    end
end

local function populateAreasList()
    for idx, biome in ipairs(BIOMES_DATA) do
        local areaBtn = Instance.new("TextButton")
        areaBtn.Size = UDim2.new(1, -8, 0, 40)
        areaBtn.BackgroundColor3 = (idx == 1 and Color3.fromRGB(28, 40, 60)) or Color3.fromRGB(15, 18, 26)
        areaBtn.Text = ""
        areaBtn.Parent = AreasScroll
        
        local abCorner = Instance.new("UICorner")
        abCorner.CornerRadius = UDim.new(0, 6)
        abCorner.Parent = areaBtn
        
        local aTitle = Instance.new("TextLabel")
        aTitle.Size = UDim2.new(1, -10, 0, 20)
        aTitle.Position = UDim2.new(0, 8, 0, 2)
        aTitle.BackgroundTransparency = 1
        aTitle.Font = Enum.Font.GothamBold
        aTitle.Text = biome.displayName
        aTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
        aTitle.TextSize = 11
        aTitle.TextXAlignment = Enum.TextXAlignment.Left
        aTitle.Parent = areaBtn
        
        local aSub = Instance.new("TextLabel")
        aSub.Size = UDim2.new(1, -10, 0, 16)
        aSub.Position = UDim2.new(0, 8, 0, 20)
        aSub.BackgroundTransparency = 1
        aSub.Font = Enum.Font.Gotham
        aSub.Text = "Velocidade: " .. biome.speedReq
        aSub.TextColor3 = Color3.fromRGB(140, 160, 180)
        aSub.TextSize = 9
        aSub.TextXAlignment = Enum.TextXAlignment.Left
        aSub.Parent = areaBtn
        
        areaBtn.MouseButton1Click:Connect(function()
            for _, b in ipairs(AreasScroll:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
                end
            end
            areaBtn.BackgroundColor3 = Color3.fromRGB(28, 40, 60)
            populateEggsList(biome)
        end)
    end
end

-- ========================================================================
-- ABA 3: 🔀 GERENCIADOR DE PRIORIDADES (TASK QUEUE REORDERABLE)
-- Permite ao usuário arrastar ou clicar nos botões ▲ / ▼ para priorizar
-- ========================================================================
local PrioritiesPage = Instance.new("Frame")
PrioritiesPage.Name = "PrioritiesPage"
PrioritiesPage.Size = UDim2.new(1, 0, 1, 0)
PrioritiesPage.BackgroundTransparency = 1
PrioritiesPage.Visible = false
PrioritiesPage.Parent = PagesContainer
TabFrames["Priorities"] = PrioritiesPage

local PrioHeader = Instance.new("Frame")
PrioHeader.Size = UDim2.new(1, 0, 0, 56)
PrioHeader.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
PrioHeader.Parent = PrioritiesPage

local PhCorner = Instance.new("UICorner")
PhCorner.CornerRadius = UDim.new(0, 10)
PhCorner.Parent = PrioHeader

local PhTitle = Instance.new("TextLabel")
PhTitle.Size = UDim2.new(1, -20, 0, 24)
PhTitle.Position = UDim2.new(0, 12, 0, 6)
PhTitle.BackgroundTransparency = 1
PhTitle.Font = Enum.Font.GothamBold
PhTitle.Text = "🔀 ORDEM DE PRIORIDADE DAS TAREFAS"
PhTitle.TextColor3 = Color3.fromRGB(0, 230, 255)
PhTitle.TextSize = 13
PhTitle.TextXAlignment = Enum.TextXAlignment.Left
PhTitle.Parent = PrioHeader

local PhDesc = Instance.new("TextLabel")
PhDesc.Size = UDim2.new(1, -20, 0, 20)
PhDesc.Position = UDim2.new(0, 12, 0, 28)
PhDesc.BackgroundTransparency = 1
PhDesc.Font = Enum.Font.Gotham
PhDesc.Text = "As tarefas no topo são executadas primeiro. Use os botões ▲ e ▼ ou arraste para definir a ordem."
PhDesc.TextColor3 = Color3.fromRGB(180, 190, 210)
PhDesc.TextSize = 11
PhDesc.TextXAlignment = Enum.TextXAlignment.Left
PhDesc.Parent = PrioHeader

local PrioScroll = Instance.new("ScrollingFrame")
PrioScroll.Size = UDim2.new(1, 0, 1, -130)
PrioScroll.Position = UDim2.new(0, 0, 0, 66)
PrioScroll.BackgroundTransparency = 1
PrioScroll.ScrollBarThickness = 4
PrioScroll.Parent = PrioritiesPage

local PrioLayout = Instance.new("UIListLayout")
PrioLayout.Padding = UDim.new(0, 6)
PrioLayout.Parent = PrioScroll

local renderPriorityList -- forward declaration

local function moveTaskPriority(index, direction)
    local targetIndex = index + direction
    if targetIndex >= 1 and targetIndex <= #HubState.taskPriorities then
        local temp = HubState.taskPriorities[index]
        HubState.taskPriorities[index] = HubState.taskPriorities[targetIndex]
        HubState.taskPriorities[targetIndex] = temp
        renderPriorityList()
    end
end

renderPriorityList = function()
    for _, child in ipairs(PrioScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    PrioScroll.CanvasSize = UDim2.new(0, 0, 0, #HubState.taskPriorities * 58)
    
    for idx, taskEntry in ipairs(HubState.taskPriorities) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(1, -6, 0, 52)
        itemFrame.BackgroundColor3 = Color3.fromRGB(22, 28, 40)
        itemFrame.Parent = PrioScroll
        
        local ifCorner = Instance.new("UICorner")
        ifCorner.CornerRadius = UDim.new(0, 8)
        ifCorner.Parent = itemFrame
        
        -- Badge de Prioridade (1º, 2º, 3º...)
        local badge = Instance.new("TextLabel")
        badge.Size = UDim2.new(0, 36, 0, 36)
        badge.Position = UDim2.new(0, 8, 0, 8)
        badge.BackgroundColor3 = (idx == 1 and Color3.fromRGB(0, 230, 255)) or Color3.fromRGB(35, 45, 65)
        badge.Font = Enum.Font.GothamBold
        badge.Text = "#" .. idx
        badge.TextColor3 = (idx == 1 and Color3.fromRGB(10, 15, 25)) or Color3.fromRGB(240, 240, 255)
        badge.TextSize = 13
        badge.Parent = itemFrame
        
        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 6)
        bCorner.Parent = badge
        
        -- Nome da Tarefa
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0, 320, 0, 22)
        nameLabel.Position = UDim2.new(0, 54, 0, 6)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Text = taskEntry.name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 13
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = itemFrame
        
        -- Status da Tarefa
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(0, 320, 0, 18)
        statusLabel.Position = UDim2.new(0, 54, 0, 26)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Font = Enum.Font.Gotham
        statusLabel.Text = taskEntry.enabled and "🟢 Habilitada na Fila" or "⚪ Desativada"
        statusLabel.TextColor3 = taskEntry.enabled and Color3.fromRGB(100, 240, 140) or Color3.fromRGB(160, 170, 180)
        statusLabel.TextSize = 10
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.Parent = itemFrame
        
        -- Toggle Ativar/Desativar Tarefa
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 100, 0, 32)
        toggleBtn.Position = UDim2.new(1, -210, 0, 10)
        toggleBtn.BackgroundColor3 = taskEntry.enabled and Color3.fromRGB(40, 140, 60) or Color3.fromRGB(70, 75, 90)
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.Text = taskEntry.enabled and "ATIVO" or "PAUSADO"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleBtn.TextSize = 11
        toggleBtn.Parent = itemFrame
        
        local tbCorner = Instance.new("UICorner")
        tbCorner.CornerRadius = UDim.new(0, 6)
        tbCorner.Parent = toggleBtn
        
        toggleBtn.MouseButton1Click:Connect(function()
            taskEntry.enabled = not taskEntry.enabled
            renderPriorityList()
        end)
        
        -- Botão Subir Prioridade (▲)
        local upBtn = Instance.new("TextButton")
        upBtn.Size = UDim2.new(0, 36, 0, 32)
        upBtn.Position = UDim2.new(1, -95, 0, 10)
        upBtn.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
        upBtn.Font = Enum.Font.GothamBold
        upBtn.Text = "▲"
        upBtn.TextColor3 = (idx > 1 and Color3.fromRGB(0, 230, 255)) or Color3.fromRGB(90, 100, 120)
        upBtn.TextSize = 13
        upBtn.Parent = itemFrame
        
        local upCorner = Instance.new("UICorner")
        upCorner.CornerRadius = UDim.new(0, 6)
        upCorner.Parent = upBtn
        
        upBtn.MouseButton1Click:Connect(function()
            if idx > 1 then
                moveTaskPriority(idx, -1)
            end
        end)
        
        -- Botão Descer Prioridade (▼)
        local downBtn = Instance.new("TextButton")
        downBtn.Size = UDim2.new(0, 36, 0, 32)
        downBtn.Position = UDim2.new(1, -50, 0, 10)
        downBtn.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
        downBtn.Font = Enum.Font.GothamBold
        downBtn.Text = "▼"
        downBtn.TextColor3 = (idx < #HubState.taskPriorities and Color3.fromRGB(0, 230, 255)) or Color3.fromRGB(90, 100, 120)
        downBtn.TextSize = 13
        downBtn.Parent = itemFrame
        
        local downCorner = Instance.new("UICorner")
        downCorner.CornerRadius = UDim.new(0, 6)
        downCorner.Parent = downBtn
        
        downBtn.MouseButton1Click:Connect(function()
            if idx < #HubState.taskPriorities then
                moveTaskPriority(idx, 1)
            end
        end)
    end
end

-- Painel Inferior de Controle Geral
local ControlBar = Instance.new("Frame")
ControlBar.Size = UDim2.new(1, 0, 0, 50)
ControlBar.Position = UDim2.new(0, 0, 1, -50)
ControlBar.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
ControlBar.Parent = PrioritiesPage

local CbCorner2 = Instance.new("UICorner")
CbCorner2.CornerRadius = UDim.new(0, 8)
CbCorner2.Parent = ControlBar

local MasterToggleBtn = Instance.new("TextButton")
MasterToggleBtn.Size = UDim2.new(0.48, 0, 0, 38)
MasterToggleBtn.Position = UDim2.new(0, 8, 0, 6)
MasterToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
MasterToggleBtn.Font = Enum.Font.GothamBold
MasterToggleBtn.Text = "▶ INICIAR TODAS AS PRIORIDADES"
MasterToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MasterToggleBtn.TextSize = 12
MasterToggleBtn.Parent = ControlBar

local MtCorner = Instance.new("UICorner")
MtCorner.CornerRadius = UDim.new(0, 8)
MtCorner.Parent = MasterToggleBtn

MasterToggleBtn.MouseButton1Click:Connect(function()
    HubState.autoStealActive = not HubState.autoStealActive
    if HubState.autoStealActive then
        MasterToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        MasterToggleBtn.Text = "⏹ PARAR TODAS AS TAREFAS"
    else
        MasterToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
        MasterToggleBtn.Text = "▶ INICIAR TODAS AS PRIORIDADES"
    end
end)

local SetBaseBtn = Instance.new("TextButton")
SetBaseBtn.Size = UDim2.new(0.48, 0, 0, 38)
SetBaseBtn.Position = UDim2.new(0.52, -8, 0, 6)
SetBaseBtn.BackgroundColor3 = Color3.fromRGB(28, 38, 54)
SetBaseBtn.Font = Enum.Font.GothamBold
SetBaseBtn.Text = "📍 DEFINIR POSIÇÃO ATUAL COMO BASE"
SetBaseBtn.TextColor3 = Color3.fromRGB(120, 220, 255)
SetBaseBtn.TextSize = 11
SetBaseBtn.Parent = ControlBar

local SbCorner2 = Instance.new("UICorner")
SbCorner2.CornerRadius = UDim.new(0, 8)
SbCorner2.Parent = SetBaseBtn

SetBaseBtn.MouseButton1Click:Connect(function()
    local hrp = getRootPart()
    if hrp then
        HubState.savedBaseCFrame = hrp.CFrame
        SetBaseBtn.Text = "✅ BASE SALVA COM SUCESSO!"
        task.delay(1.5, function()
            SetBaseBtn.Text = "📍 DEFINIR POSIÇÃO ATUAL COMO BASE"
        end)
    end
end)

-- ========================================================================
-- MODAL DE FILTRO DE RARIDADES
-- ========================================================================
local ModalRarities = Instance.new("Frame")
ModalRarities.Name = "ModalRarities"
ModalRarities.Size = UDim2.new(0, 320, 0, 420)
ModalRarities.Position = UDim2.new(0.5, -160, 0.5, -210)
ModalRarities.BackgroundColor3 = Color3.fromRGB(15, 18, 27)
ModalRarities.BorderSizePixel = 0
ModalRarities.Visible = false
ModalRarities.ZIndex = 20
ModalRarities.Parent = MainFrame

local MrCorner = Instance.new("UICorner")
MrCorner.CornerRadius = UDim.new(0, 12)
MrCorner.Parent = ModalRarities

local MrStroke = Instance.new("UIStroke")
MrStroke.Thickness = 1.5
MrStroke.Color = Color3.fromRGB(0, 230, 255)
MrStroke.Parent = ModalRarities

local MrTitle = Instance.new("TextLabel")
MrTitle.Size = UDim2.new(1, -20, 0, 36)
MrTitle.Position = UDim2.new(0, 10, 0, 6)
MrTitle.BackgroundTransparency = 1
MrTitle.Font = Enum.Font.GothamBold
MrTitle.Text = "⚙️ FILTRAR RARIDADES DE OVOS"
MrTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MrTitle.TextSize = 13
MrTitle.ZIndex = 21
MrTitle.Parent = ModalRarities

local MrScroll = Instance.new("ScrollingFrame")
MrScroll.Size = UDim2.new(1, -20, 1, -90)
MrScroll.Position = UDim2.new(0, 10, 0, 44)
MrScroll.BackgroundTransparency = 1
MrScroll.ScrollBarThickness = 3
MrScroll.CanvasSize = UDim2.new(0, 0, 0, #RARITY_ORDER * 34)
MrScroll.ZIndex = 21
MrScroll.Parent = ModalRarities

local MrLayout = Instance.new("UIListLayout")
MrLayout.Padding = UDim.new(0, 4)
MrLayout.Parent = MrScroll

for _, rName in ipairs(RARITY_ORDER) do
    local rColor = RARITY_COLORS[rName] or Color3.fromRGB(200, 200, 200)
    local item = Instance.new("TextButton")
    item.Size = UDim2.new(1, -6, 0, 30)
    item.BackgroundColor3 = Color3.fromRGB(20, 25, 38)
    item.Text = ""
    item.ZIndex = 22
    item.Parent = MrScroll
    
    local iCorner = Instance.new("UICorner")
    iCorner.CornerRadius = UDim.new(0, 6)
    iCorner.Parent = item
    
    local check = Instance.new("TextLabel")
    check.Size = UDim2.new(0, 26, 1, 0)
    check.BackgroundTransparency = 1
    check.Font = Enum.Font.GothamBold
    check.Text = HubState.selectedRarities[rName] and "☑" or "☐"
    check.TextColor3 = HubState.selectedRarities[rName] and Color3.fromRGB(0, 230, 255) or Color3.fromRGB(120, 130, 150)
    check.TextSize = 15
    check.ZIndex = 23
    check.Parent = item
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -30, 1, 0)
    lbl.Position = UDim2.new(0, 28, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = rName
    lbl.TextColor3 = rColor
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 23
    lbl.Parent = item
    
    item.MouseButton1Click:Connect(function()
        HubState.selectedRarities[rName] = not HubState.selectedRarities[rName]
        check.Text = HubState.selectedRarities[rName] and "☑" or "☐"
        check.TextColor3 = HubState.selectedRarities[rName] and Color3.fromRGB(0, 230, 255) or Color3.fromRGB(120, 130, 150)
    end)
end

local CloseMrBtn = Instance.new("TextButton")
CloseMrBtn.Size = UDim2.new(1, -20, 0, 34)
CloseMrBtn.Position = UDim2.new(0, 10, 1, -40)
CloseMrBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 216)
CloseMrBtn.Font = Enum.Font.GothamBold
CloseMrBtn.Text = "CONCLUÍDO"
CloseMrBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseMrBtn.TextSize = 12
CloseMrBtn.ZIndex = 22
CloseMrBtn.Parent = ModalRarities

local CmrCorner = Instance.new("UICorner")
CmrCorner.CornerRadius = UDim.new(0, 6)
CmrCorner.Parent = CloseMrBtn

CloseMrBtn.MouseButton1Click:Connect(function()
    ModalRarities.Visible = false
end)

FilterRarityBtn.MouseButton1Click:Connect(function()
    ModalRarities.Visible = not ModalRarities.Visible
end)

-- ========================================================================
-- INICIALIZAÇÃO DAS ABAS E LISTAS
-- ========================================================================
createTabButton("Events", "Eventos", "🎪")
createTabButton("Eggs", "Ovos & Biomas", "🥚")
createTabButton("Priorities", "Fila de Prioridades", "🔀")

populateAreasList()
populateEggsList(BIOMES_DATA[1])
renderPriorityList()

-- Anti-AFK
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
end)

print("========================================================================")
print("[STEAL AN EGG HUB v2.5] Carregado com Sucesso!")
print("• Aba de Eventos: Dr. Scramble, Borboleta e Corrida ativados.")
print("• Fila de Prioridades: Reordenação interativa com ▲ e ▼.")
print("• Tecla 'K' para Abrir / Minimizar.")
print("========================================================================")
