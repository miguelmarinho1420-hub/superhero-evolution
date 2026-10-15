--[[
    ========================================================================
    STEAL AN EGG - ULTIMATE HUB (ÁREAS, OVOS & AUTO-STEAL)
    Jogo: Steal An Egg (PlaceId: 107778070777162)
    Autor: Antigravity Assistant
    
    Funcionalidades Principais:
      🗺️ Scanner em Tempo Real de Todas as Áreas / Biomas
      🥚 Localização de Todos os Ovos por Área com Status em Tempo Real
      🎨 Desenho e Modelo 3D Interativo do Ovo (ViewportFrame Giratório)
      ⚡ Sistema de Roubo Automático por Seleção de Raridade
      🛡️ Modo Voo Seguro Anti-Guarda (Evita T-Rex, Oni Tiger, Swan, etc.)
      🏠 Retorno Automático para a Zona Segura (Safe Zone / Base)
      👁️ Egg ESP (Rastreamento Visual de Ovos através das Paredes)
      ⚙️ Tecla de Atalho: 'K' ou Botão Flutuante para Abrir/Fechar
    ========================================================================
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

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
        displayName = "🌸 Jardim Sakura (Cherry Blossom)",
        speedReq = "2.5B",
        guardian = "Oni Tiger",
        eggs = {
            { name = "Tanuki Egg", pet = "Tanuki", rarity = "Lendário", income = "$8M/s", color = Color3.fromRGB(140, 100, 70) },
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
    selectedBiome = BIOMES_DATA[1],
    selectedEgg = BIOMES_DATA[1].eggs[1],
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
    },
    autoStealActive = false,
    autoStealMode = "SafeGlide", -- "SafeGlide" ou "InstantTP"
    autoStealScope = "SelectedArea", -- "SelectedArea" ou "GlobalMap"
    autoReturnSafeZone = true,
    espActive = false,
    flightAltitude = 75, -- Altura segura acima do solo para evitar Guardas
    savedBaseCFrame = nil,
    isStealing = false,
    espDrawings = {},
}

-- Salva a posição inicial como base segura do jogador
task.spawn(function()
    repeat task.wait(0.5) until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    HubState.savedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
end)

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
        if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower():find("egg") and not obj:IsDescendantOf(areasFolder or Workspace) then
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

-- ========================================================================
-- FUNÇÕES DE INTERAÇÃO E ROUBO (PROXIMITY PROMPT & SAFE GLIDE)
-- ========================================================================
local function triggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return false end
    
    if typeof(fireproximityprompt) == "function" then
        pcall(function()
            fireproximityprompt(prompt, 0)
        end)
        return true
    end
    
    pcall(function()
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration or 0.1)
        prompt:InputHoldEnd()
    end)
    return true
end

local function getRootPart()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function hasStolenEgg()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, item in ipairs(char:GetChildren()) do
        if (item:IsA("Tool") or item:IsA("Model")) and item.Name:lower():find("egg") then
            return true, item
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
    
    -- 1. Sobe rapidamente para o céu
    hrp.CFrame = CFrame.new(highStart)
    task.wait(0.08)
    
    -- 2. Voa acima das hitboxes dos guardas
    local dist = (highStart - highTarget).Magnitude
    local glideTime = math.clamp(dist / 140, 0.25, 2.0)
    
    local tweenInfo = TweenInfo.new(glideTime, Enum.EasingStyle.Linear)
    local glideTween = TweenService:Create(hrp, tweenInfo, { CFrame = CFrame.new(highTarget) })
    glideTween:Play()
    glideTween.Completed:Wait()
    
    -- 3. Desce verticalmente sobre o ovo
    hrp.CFrame = CFrame.new(finalTarget)
    task.wait(0.12)
    
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

local function executeStealTarget(eggTarget)
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
        
        -- Verifica se o ovo foi adquirido
        local gotEgg, eggTool = hasStolenEgg()
        if gotEgg then
            print("[STEAL SUCCESS] Ovo roubado com sucesso:", eggTool.Name)
        end
        
        if HubState.autoReturnSafeZone then
            returnToSafeZone()
        end
        
        HubState.isStealing = false
    end
    
    if HubState.autoStealMode == "SafeGlide" then
        safeGlideTo(targetCFrame, doGrab)
    else
        hrp.CFrame = targetCFrame + Vector3.new(0, 2, 0)
        task.wait(0.1)
        doGrab()
    end
end

-- ========================================================================
-- CRIAÇÃO DA INTERFACE VISUAL (GLASSMORPHISM / FLUENT UI)
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
MainFrame.Size = UDim2.new(0, 860, 0, 560)
MainFrame.Position = UDim2.new(0.5, -430, 0.5, -280)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.2
MainStroke.Color = Color3.fromRGB(45, 55, 75)
MainStroke.Transparency = 0.2
MainStroke.Parent = MainFrame

-- Suporte a Arrastar (Draggable)
local UserInputService = game:GetService("UserInputService")
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
TopBar.BackgroundColor3 = Color3.fromRGB(20, 24, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 14)
TopBarCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(0, 360, 1, 0)
TitleLabel.Position = UDim2.new(0, 18, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "🥚 STEAL AN EGG • <font color='#00E6FF'>ULTIMATE HUB</font>"
TitleLabel.RichText = true
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 17
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Botão Minimizar / Fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
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

-- Botão Flutuante para reabrir
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

-- Tecla 'K' de atalho
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.K then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ========================================================================
-- LAYOUT EM 3 COLUNAS
-- Coluna 1 (Esquerda): Lista de Áreas / Biomas
-- Coluna 2 (Centro): Lista de Ovos na Área Selecionada
-- Coluna 3 (Direita): Desenho / Visual 3D do Ovo + Detalhes + Auto Steal
-- ========================================================================
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -64)
ContentFrame.Position = UDim2.new(0, 10, 0, 54)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- 1. Coluna de Áreas
local AreasCol = Instance.new("Frame")
AreasCol.Name = "AreasCol"
AreasCol.Size = UDim2.new(0, 230, 1, 0)
AreasCol.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
AreasCol.BackgroundTransparency = 0.3
AreasCol.Parent = ContentFrame

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
AreasScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 75, 105)
AreasScroll.CanvasSize = UDim2.new(0, 0, 0, #BIOMES_DATA * 46)
AreasScroll.Parent = AreasCol

local AreasListLayout = Instance.new("UIListLayout")
AreasListLayout.Padding = UDim.new(0, 4)
AreasListLayout.SortOrder = Enum.SortOrder.LayoutOrder
AreasListLayout.Parent = AreasScroll

-- 2. Coluna de Ovos da Área
local EggsCol = Instance.new("Frame")
EggsCol.Name = "EggsCol"
EggsCol.Size = UDim2.new(0, 270, 1, 0)
EggsCol.Position = UDim2.new(0, 240, 0, 0)
EggsCol.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
EggsCol.BackgroundTransparency = 0.3
EggsCol.Parent = ContentFrame

local EggsCorner = Instance.new("UICorner")
EggsCorner.CornerRadius = UDim.new(0, 10)
EggsCorner.Parent = EggsCol

local EggsTitle = Instance.new("TextLabel")
EggsTitle.Name = "EggsTitle"
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
EggsScroll.Name = "EggsScroll"
EggsScroll.Size = UDim2.new(1, -10, 1, -44)
EggsScroll.Position = UDim2.new(0, 5, 0, 38)
EggsScroll.BackgroundTransparency = 1
EggsScroll.ScrollBarThickness = 4
EggsScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 75, 105)
EggsScroll.Parent = EggsCol

local EggsListLayout = Instance.new("UIListLayout")
EggsListLayout.Padding = UDim.new(0, 4)
EggsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
EggsListLayout.Parent = EggsScroll

-- 3. Coluna de Showcase (Desenho do Ovo 3D + Roubo Automático)
local ShowcaseCol = Instance.new("Frame")
ShowcaseCol.Name = "ShowcaseCol"
ShowcaseCol.Size = UDim2.new(1, -520, 1, 0)
ShowcaseCol.Position = UDim2.new(0, 520, 0, 0)
ShowcaseCol.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
ShowcaseCol.BackgroundTransparency = 0.3
ShowcaseCol.Parent = ContentFrame

local ShowcaseCorner = Instance.new("UICorner")
ShowcaseCorner.CornerRadius = UDim.new(0, 10)
ShowcaseCorner.Parent = ShowcaseCol

-- ========================================================================
-- PAINEL DO DESENHO E MODELO 3D DO OVO (VIEWPORTFRAME)
-- ========================================================================
local ViewportContainer = Instance.new("Frame")
ViewportContainer.Name = "ViewportContainer"
ViewportContainer.Size = UDim2.new(1, -20, 0, 160)
ViewportContainer.Position = UDim2.new(0, 10, 0, 10)
ViewportContainer.BackgroundColor3 = Color3.fromRGB(12, 15, 22)
ViewportContainer.ClipsDescendants = true
ViewportContainer.Parent = ShowcaseCol

local VpCorner = Instance.new("UICorner")
VpCorner.CornerRadius = UDim.new(0, 10)
VpCorner.Parent = ViewportContainer

local VpStroke = Instance.new("UIStroke")
VpStroke.Thickness = 1.2
VpStroke.Color = Color3.fromRGB(0, 230, 255)
VpStroke.Parent = ViewportContainer

local EggViewport = Instance.new("ViewportFrame")
EggViewport.Name = "EggViewport"
EggViewport.Size = UDim2.new(1, 0, 1, 0)
EggViewport.BackgroundTransparency = 1
EggViewport.Parent = ViewportContainer

-- Câmera e Iluminação do Viewport
local vpCamera = Instance.new("Camera")
vpCamera.FieldOfView = 45
vpCamera.Parent = EggViewport
EggViewport.CurrentCamera = vpCamera

local vpWorldModel = Instance.new("WorldModel")
vpWorldModel.Parent = EggViewport

-- Luz direcional simulada dentro do Viewport
EggViewport.Ambient = Color3.fromRGB(140, 140, 160)
EggViewport.LightColor = Color3.fromRGB(255, 255, 255)
EggViewport.LightDirection = Vector3.new(-1, -1.5, -2)

-- Modelo do Ovo dentro do Viewport
local currentVpEgg = nil
local vpAngle = 0

local function createEgg3DModel(eggColor, rarityColor)
    if currentVpEgg then
        currentVpEgg:Destroy()
        currentVpEgg = nil
    end
    
    local model = Instance.new("Model")
    model.Name = "VpEggModel"
    
    -- Cria formato de ovo com SpecialMesh Sphere escalada
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
    
    -- Anel de Aura Neon para a raridade
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
    
    -- Posiciona a Câmera
    vpCamera.CFrame = CFrame.new(Vector3.new(0, 0.2, 5), Vector3.new(0, 0, 0))
    return model
end

-- Rotação Contínua do Ovo no Viewport
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

-- ========================================================================
-- INFORMAÇÕES DETALHADAS DO OVO SELECIONADO
-- ========================================================================
local InfoFrame = Instance.new("Frame")
InfoFrame.Name = "InfoFrame"
InfoFrame.Size = UDim2.new(1, -20, 0, 140)
InfoFrame.Position = UDim2.new(0, 10, 0, 178)
InfoFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 27)
InfoFrame.Parent = ShowcaseCol

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 8)
InfoCorner.Parent = InfoFrame

local EggNameLabel = Instance.new("TextLabel")
EggNameLabel.Size = UDim2.new(1, -16, 0, 26)
EggNameLabel.Position = UDim2.new(0, 10, 0, 8)
EggNameLabel.BackgroundTransparency = 1
EggNameLabel.Font = Enum.Font.GothamBold
EggNameLabel.Text = "Ovo Selecionado"
EggNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
EggNameLabel.TextSize = 16
EggNameLabel.TextXAlignment = Enum.TextXAlignment.Left
EggNameLabel.Parent = InfoFrame

local RarityBadge = Instance.new("TextLabel")
RarityBadge.Size = UDim2.new(0, 110, 0, 22)
RarityBadge.Position = UDim2.new(0, 10, 0, 36)
RarityBadge.BackgroundColor3 = Color3.fromRGB(255, 170, 20)
RarityBadge.Font = Enum.Font.GothamBold
RarityBadge.Text = "LENDÁRIO"
RarityBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
RarityBadge.TextSize = 11
RarityBadge.Parent = InfoFrame

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 6)
BadgeCorner.Parent = RarityBadge

local DetailsText = Instance.new("TextLabel")
DetailsText.Size = UDim2.new(1, -20, 0, 70)
DetailsText.Position = UDim2.new(0, 10, 0, 64)
DetailsText.BackgroundTransparency = 1
DetailsText.Font = Enum.Font.Gotham
DetailsText.Text = "• Área: -\n• Guardião: -\n• Rendimento Base: -\n• Status: 🟢 Disponível"
DetailsText.TextColor3 = Color3.fromRGB(190, 200, 220)
DetailsText.TextSize = 12
DetailsText.TextXAlignment = Enum.TextXAlignment.Left
DetailsText.TextYAlignment = Enum.TextYAlignment.Top
DetailsText.Parent = InfoFrame

-- Botões de Ação Direta
local StealNowBtn = Instance.new("TextButton")
StealNowBtn.Size = UDim2.new(1, -20, 0, 36)
StealNowBtn.Position = UDim2.new(0, 10, 0, 326)
StealNowBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 216)
StealNowBtn.Font = Enum.Font.GothamBold
StealNowBtn.Text = "⚡ ROUBAR ESTE OVO AGORA"
StealNowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StealNowBtn.TextSize = 13
StealNowBtn.Parent = ShowcaseCol

local StealNowCorner = Instance.new("UICorner")
StealNowCorner.CornerRadius = UDim.new(0, 8)
StealNowCorner.Parent = StealNowBtn

-- ========================================================================
-- PAINEL DE CONTROLE DO AUTO STEAL (SELEÇÃO DE RARIDADES & MODO)
-- ========================================================================
local AutoStealBox = Instance.new("Frame")
AutoStealBox.Name = "AutoStealBox"
AutoStealBox.Size = UDim2.new(1, -20, 0, 126)
AutoStealBox.Position = UDim2.new(0, 10, 0, 370)
AutoStealBox.BackgroundColor3 = Color3.fromRGB(15, 18, 27)
AutoStealBox.Parent = ShowcaseCol

local AsCorner = Instance.new("UICorner")
AsCorner.CornerRadius = UDim.new(0, 8)
AsCorner.Parent = AutoStealBox

local AsTitle = Instance.new("TextLabel")
AsTitle.Size = UDim2.new(1, -16, 0, 24)
AsTitle.Position = UDim2.new(0, 10, 0, 6)
AsTitle.BackgroundTransparency = 1
AsTitle.Font = Enum.Font.GothamBold
AsTitle.Text = "🤖 ROUBO AUTOMÁTICO (AUTO FARM)"
AsTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
AsTitle.TextSize = 12
AsTitle.TextXAlignment = Enum.TextXAlignment.Left
AsTitle.Parent = AutoStealBox

-- Toggle Auto Steal
local ToggleAutoBtn = Instance.new("TextButton")
ToggleAutoBtn.Size = UDim2.new(0, 130, 0, 30)
ToggleAutoBtn.Position = UDim2.new(0, 10, 0, 32)
ToggleAutoBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
ToggleAutoBtn.Font = Enum.Font.GothamBold
ToggleAutoBtn.Text = "▶ INICIAR AUTO"
ToggleAutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleAutoBtn.TextSize = 12
ToggleAutoBtn.Parent = AutoStealBox

local ToggleAutoCorner = Instance.new("UICorner")
ToggleAutoCorner.CornerRadius = UDim.new(0, 6)
ToggleAutoCorner.Parent = ToggleAutoBtn

-- Toggle Modo Seguro (Glide) vs Instant TP
local ModeToggleBtn = Instance.new("TextButton")
ModeToggleBtn.Size = UDim2.new(1, -160, 0, 30)
ModeToggleBtn.Position = UDim2.new(0, 150, 0, 32)
ModeToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
ModeToggleBtn.Font = Enum.Font.GothamBold
ModeToggleBtn.Text = "🛡️ Modo: Voo Seguro"
ModeToggleBtn.TextColor3 = Color3.fromRGB(0, 230, 255)
ModeToggleBtn.TextSize = 11
ModeToggleBtn.Parent = AutoStealBox

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0, 6)
ModeCorner.Parent = ModeToggleBtn

ModeToggleBtn.MouseButton1Click:Connect(function()
    if HubState.autoStealMode == "SafeGlide" then
        HubState.autoStealMode = "InstantTP"
        ModeToggleBtn.Text = "⚡ Modo: Instant TP"
        ModeToggleBtn.TextColor3 = Color3.fromRGB(255, 170, 20)
    else
        HubState.autoStealMode = "SafeGlide"
        ModeToggleBtn.Text = "🛡️ Modo: Voo Seguro"
        ModeToggleBtn.TextColor3 = Color3.fromRGB(0, 230, 255)
    end
end)

-- Botão de Configuração de Raridades / Filtro Rápido
local RarityFilterBtn = Instance.new("TextButton")
RarityFilterBtn.Size = UDim2.new(1, -20, 0, 26)
RarityFilterBtn.Position = UDim2.new(0, 10, 0, 68)
RarityFilterBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
RarityFilterBtn.Font = Enum.Font.Gotham
RarityFilterBtn.Text = "⚙️ Filtro: Lendário, Mítico, Cósmico, Divino..."
RarityFilterBtn.TextColor3 = Color3.fromRGB(220, 220, 240)
RarityFilterBtn.TextSize = 10
RarityFilterBtn.Parent = AutoStealBox

local RfCorner = Instance.new("UICorner")
RfCorner.CornerRadius = UDim.new(0, 6)
RfCorner.Parent = RarityFilterBtn

-- Botão Salvar Posição da Base
local SaveBaseBtn = Instance.new("TextButton")
SaveBaseBtn.Size = UDim2.new(1, -20, 0, 22)
SaveBaseBtn.Position = UDim2.new(0, 10, 0, 98)
SaveBaseBtn.BackgroundColor3 = Color3.fromRGB(25, 30, 42)
SaveBaseBtn.Font = Enum.Font.Gotham
SaveBaseBtn.Text = "📍 Definir Posição Atual Como Base Segura"
SaveBaseBtn.TextColor3 = Color3.fromRGB(150, 240, 150)
SaveBaseBtn.TextSize = 10
SaveBaseBtn.Parent = AutoStealBox

local SbCorner = Instance.new("UICorner")
SbCorner.CornerRadius = UDim.new(0, 6)
SbCorner.Parent = SaveBaseBtn

SaveBaseBtn.MouseButton1Click:Connect(function()
    local hrp = getRootPart()
    if hrp then
        HubState.savedBaseCFrame = hrp.CFrame
        SaveBaseBtn.Text = "✅ Base Segura Salva com Sucesso!"
        task.delay(1.5, function()
            SaveBaseBtn.Text = "📍 Definir Posição Atual Como Base Segura"
        end)
    end
end)

-- ========================================================================
-- ATUALIZAÇÃO DO SHOWCASE VISUAL QUANDO UM OVO É SELECIONADO
-- ========================================================================
local function updateShowcase(eggData, biomeData)
    if not eggData then return end
    HubState.selectedEgg = eggData
    
    EggNameLabel.Text = "🥚 " .. eggData.name
    
    local rColor = RARITY_COLORS[eggData.rarity] or Color3.fromRGB(200, 200, 200)
    RarityBadge.Text = string.upper(eggData.rarity)
    RarityBadge.BackgroundColor3 = rColor
    
    DetailsText.Text = string.format(
        "• Área: %s\n• Guardião: %s\n• Rendimento Base: %s\n• Velocidade Mínima: %s\n• Status: 🟢 Disponível para Roubo",
        biomeData.displayName,
        biomeData.guardian,
        eggData.income or "$??",
        biomeData.speedReq or "0"
    )
    
    -- Atualiza o modelo 3D no Viewport
    createEgg3DModel(eggData.color, rColor)
end

-- ========================================================================
-- RENDERIZAÇÃO DA LISTA DE OVOS DA ÁREA SELECIONADA
-- ========================================================================
local function populateEggsList(biomeData)
    for _, child in ipairs(EggsScroll:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    HubState.selectedBiome = biomeData
    EggsTitle.Text = "🥚 OVOS: " .. biomeData.name:upper()
    EggsScroll.CanvasSize = UDim2.new(0, 0, 0, #biomeData.eggs * 54)
    
    for idx, egg in ipairs(biomeData.eggs) do
        local rColor = RARITY_COLORS[egg.rarity] or Color3.fromRGB(180, 180, 180)
        
        local eggBtn = Instance.new("TextButton")
        eggBtn.Name = "Egg_" .. egg.name
        eggBtn.Size = UDim2.new(1, -8, 0, 48)
        eggBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
        eggBtn.Text = ""
        eggBtn.AutoButtonColor = true
        eggBtn.Parent = EggsScroll
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = eggBtn
        
        local leftStripe = Instance.new("Frame")
        leftStripe.Size = UDim2.new(0, 4, 1, 0)
        leftStripe.BackgroundColor3 = rColor
        leftStripe.BorderSizePixel = 0
        leftStripe.Parent = eggBtn
        
        local eName = Instance.new("TextLabel")
        eName.Size = UDim2.new(1, -70, 0, 22)
        eName.Position = UDim2.new(0, 12, 0, 4)
        eName.BackgroundTransparency = 1
        eName.Font = Enum.Font.GothamBold
        eName.Text = egg.name
        eName.TextColor3 = Color3.fromRGB(240, 240, 240)
        eName.TextSize = 13
        eName.TextXAlignment = Enum.TextXAlignment.Left
        eName.Parent = eggBtn
        
        local eSub = Instance.new("TextLabel")
        eSub.Size = UDim2.new(1, -70, 0, 18)
        eSub.Position = UDim2.new(0, 12, 0, 26)
        eSub.BackgroundTransparency = 1
        eSub.Font = Enum.Font.Gotham
        eSub.Text = egg.rarity .. " • " .. egg.income
        eSub.TextColor3 = rColor
        eSub.TextSize = 11
        eSub.TextXAlignment = Enum.TextXAlignment.Left
        eSub.Parent = eggBtn
        
        local quickSteal = Instance.new("TextButton")
        quickSteal.Size = UDim2.new(0, 44, 0, 32)
        quickSteal.Position = UDim2.new(1, -50, 0, 8)
        quickSteal.BackgroundColor3 = Color3.fromRGB(0, 180, 216)
        quickSteal.Text = "⚡"
        quickSteal.TextSize = 16
        quickSteal.Parent = eggBtn
        
        local qsCorner = Instance.new("UICorner")
        qsCorner.CornerRadius = UDim.new(0, 6)
        qsCorner.Parent = quickSteal
        
        eggBtn.MouseButton1Click:Connect(function()
            updateShowcase(egg, biomeData)
        end)
        
        quickSteal.MouseButton1Click:Connect(function()
            updateShowcase(egg, biomeData)
            executeStealTarget(egg)
        end)
        
        if idx == 1 then
            updateShowcase(egg, biomeData)
        end
    end
end

-- ========================================================================
-- RENDERIZAÇÃO DA LISTA DE ÁREAS (13 BIOMAS)
-- ========================================================================
local function populateAreasList()
    for idx, biome in ipairs(BIOMES_DATA) do
        local areaBtn = Instance.new("TextButton")
        areaBtn.Name = "Area_" .. biome.name
        areaBtn.Size = UDim2.new(1, -8, 0, 42)
        areaBtn.BackgroundColor3 = (idx == 1 and Color3.fromRGB(25, 38, 55)) or Color3.fromRGB(15, 18, 26)
        areaBtn.Text = ""
        areaBtn.AutoButtonColor = true
        areaBtn.Parent = AreasScroll
        
        local aCorner = Instance.new("UICorner")
        aCorner.CornerRadius = UDim.new(0, 8)
        aCorner.Parent = areaBtn
        
        local aTitle = Instance.new("TextLabel")
        aTitle.Size = UDim2.new(1, -12, 0, 20)
        aTitle.Position = UDim2.new(0, 10, 0, 3)
        aTitle.BackgroundTransparency = 1
        aTitle.Font = Enum.Font.GothamBold
        aTitle.Text = biome.displayName
        aTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
        aTitle.TextSize = 12
        aTitle.TextXAlignment = Enum.TextXAlignment.Left
        aTitle.Parent = areaBtn
        
        local aSub = Instance.new("TextLabel")
        aSub.Size = UDim2.new(1, -12, 0, 16)
        aSub.Position = UDim2.new(0, 10, 0, 22)
        aSub.BackgroundTransparency = 1
        aSub.Font = Enum.Font.Gotham
        aSub.Text = "Velocidade: " .. biome.speedReq .. " | " .. #biome.eggs .. " ovos"
        aSub.TextColor3 = Color3.fromRGB(140, 160, 180)
        aSub.TextSize = 10
        aSub.TextXAlignment = Enum.TextXAlignment.Left
        aSub.Parent = areaBtn
        
        areaBtn.MouseButton1Click:Connect(function()
            for _, b in ipairs(AreasScroll:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
                end
            end
            areaBtn.BackgroundColor3 = Color3.fromRGB(25, 38, 55)
            populateEggsList(biome)
        end)
    end
end

-- ========================================================================
-- FILTRO DE SELEÇÃO DE RARIDADES (JANELA MODAL)
-- ========================================================================
local ModalRarities = Instance.new("Frame")
ModalRarities.Name = "ModalRarities"
ModalRarities.Size = UDim2.new(0, 280, 0, 380)
ModalRarities.Position = UDim2.new(0.5, -140, 0.5, -190)
ModalRarities.BackgroundColor3 = Color3.fromRGB(15, 18, 27)
ModalRarities.BorderSizePixel = 0
ModalRarities.Visible = false
ModalRarities.ZIndex = 10
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
MrTitle.Text = "⚙️ FILTRO DE RARIDADES"
MrTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MrTitle.TextSize = 13
MrTitle.ZIndex = 11
MrTitle.Parent = ModalRarities

local MrScroll = Instance.new("ScrollingFrame")
MrScroll.Size = UDim2.new(1, -20, 1, -84)
MrScroll.Position = UDim2.new(0, 10, 0, 44)
MrScroll.BackgroundTransparency = 1
MrScroll.ScrollBarThickness = 3
MrScroll.CanvasSize = UDim2.new(0, 0, 0, #RARITY_ORDER * 32)
MrScroll.ZIndex = 11
MrScroll.Parent = ModalRarities

local MrLayout = Instance.new("UIListLayout")
MrLayout.Padding = UDim.new(0, 4)
MrLayout.Parent = MrScroll

for _, rName in ipairs(RARITY_ORDER) do
    local rColor = RARITY_COLORS[rName] or Color3.fromRGB(200, 200, 200)
    
    local item = Instance.new("TextButton")
    item.Size = UDim2.new(1, -6, 0, 28)
    item.BackgroundColor3 = Color3.fromRGB(20, 25, 38)
    item.Text = ""
    item.ZIndex = 12
    item.Parent = MrScroll
    
    local iCorner = Instance.new("UICorner")
    iCorner.CornerRadius = UDim.new(0, 6)
    iCorner.Parent = item
    
    local check = Instance.new("TextLabel")
    check.Size = UDim2.new(0, 24, 1, 0)
    check.BackgroundTransparency = 1
    check.Font = Enum.Font.GothamBold
    check.Text = HubState.selectedRarities[rName] and "☑" or "☐"
    check.TextColor3 = HubState.selectedRarities[rName] and Color3.fromRGB(0, 230, 255) or Color3.fromRGB(120, 130, 150)
    check.TextSize = 15
    check.ZIndex = 13
    check.Parent = item
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -30, 1, 0)
    lbl.Position = UDim2.new(0, 26, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = rName
    lbl.TextColor3 = rColor
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 13
    lbl.Parent = item
    
    item.MouseButton1Click:Connect(function()
        HubState.selectedRarities[rName] = not HubState.selectedRarities[rName]
        check.Text = HubState.selectedRarities[rName] and "☑" or "☐"
        check.TextColor3 = HubState.selectedRarities[rName] and Color3.fromRGB(0, 230, 255) or Color3.fromRGB(120, 130, 150)
    end)
end

local CloseMrBtn = Instance.new("TextButton")
CloseMrBtn.Size = UDim2.new(1, -20, 0, 30)
CloseMrBtn.Position = UDim2.new(0, 10, 1, -36)
CloseMrBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 216)
CloseMrBtn.Font = Enum.Font.GothamBold
CloseMrBtn.Text = "PRONTO"
CloseMrBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseMrBtn.TextSize = 12
CloseMrBtn.ZIndex = 12
CloseMrBtn.Parent = ModalRarities

local CmrCorner = Instance.new("UICorner")
CmrCorner.CornerRadius = UDim.new(0, 6)
CmrCorner.Parent = CloseMrBtn

CloseMrBtn.MouseButton1Click:Connect(function()
    ModalRarities.Visible = false
end)

RarityFilterBtn.MouseButton1Click:Connect(function()
    ModalRarities.Visible = not ModalRarities.Visible
end)

-- Conecta Botão "ROUBAR ESTE OVO AGORA"
StealNowBtn.MouseButton1Click:Connect(function()
    if HubState.selectedEgg then
        executeStealTarget(HubState.selectedEgg)
    end
end)

-- Toggle Auto Steal
ToggleAutoBtn.MouseButton1Click:Connect(function()
    HubState.autoStealActive = not HubState.autoStealActive
    if HubState.autoStealActive then
        ToggleAutoBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        ToggleAutoBtn.Text = "⏹ PARAR AUTO"
    else
        ToggleAutoBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
        ToggleAutoBtn.Text = "▶ INICIAR AUTO"
    end
end)

-- ========================================================================
-- MOTOR DO AUTO-STEAL EM SEGUNDO PLANO (THREAD CONTÍNUA)
-- ========================================================================
task.spawn(function()
    while true do
        task.wait(1.5)
        
        if HubState.autoStealActive and not HubState.isStealing then
            -- Se já está segurando um ovo, entrega na base antes de ir para o próximo
            local hasEgg = hasStolenEgg()
            if hasEgg then
                returnToSafeZone()
                task.wait(1.0)
            else
                local scanData = scanWorldEggs()
                local eligibleEggs = {}
                
                -- Filtra ovos conforme a raridade e escopo
                for _, egg in ipairs(scanData.allEggs) do
                    local matchedRarity = false
                    for rName, isSelected in pairs(HubState.selectedRarities) do
                        if isSelected and (egg.name:lower():find(rName:lower()) or (egg.instance and egg.instance.Name:lower():find(rName:lower()))) then
                            matchedRarity = true
                            break
                        end
                    end
                    
                    if matchedRarity then
                        table.insert(eligibleEggs, egg)
                    end
                end
                
                -- Se não encontrou ovos do scan dinâmico com o nome exato da raridade,
                -- busca da nossa base de dados oficial para os biomas
                if #eligibleEggs == 0 then
                    local targetBiomes = (HubState.autoStealScope == "SelectedArea" and { HubState.selectedBiome }) or BIOMES_DATA
                    for _, biome in ipairs(targetBiomes) do
                        for _, eggDef in ipairs(biome.eggs) do
                            if HubState.selectedRarities[eggDef.rarity] then
                                -- Procura se esse ovo existe no scan
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
                
                -- Executa o roubo do primeiro ovo qualificado encontrado
                if #eligibleEggs > 0 then
                    local target = eligibleEggs[1]
                    print("[AUTO STEAL] Alvo encontrado:", target.name)
                    executeStealTarget(target)
                end
            end
        end
    end
end)

-- ========================================================================
-- ANTI-AFK (IMPEDE DESCONEXÃO POR INATIVIDADE DE 20 MINUTOS)
-- ========================================================================
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
end)

-- Inicia a Interface com todas as áreas e ovos
populateAreasList()
populateEggsList(BIOMES_DATA[1])

print("========================================================================")
print("[STEAL AN EGG HUB] Carregado com Sucesso!")
print("Tecla 'K' para Abrir / Ocultar o Painel.")
print("========================================================================")
