--[[
    ==============================================================
    LOADER OFICIAL - ULTIMATE HUB
    Compatível com: Steal An Egg & Superhero Evolution
    Sempre busca e executa a versão mais recente sem cache
    ==============================================================
]]

-- 1. Conexão em segundo plano com o assistente (MCP Server se ativo)
task.spawn(function()
    pcall(function()
        if not getgenv().MCP_Loaded then
            local bridgeUrl = getgenv().BridgeURL or "127.0.0.1:16384"
            pcall(function() loadstring(game:HttpGet("http://" .. bridgeUrl .. "/script.luau"))() end)
        end
    end)
end)

-- 2. Função de Download Resiliente (Multi-Executor)
local function fetchScript(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and res and #res > 50 then return res end

    local ok2, res2 = pcall(function() return game:HttpGet(url, true) end)
    if ok2 and res2 and #res2 > 50 then return res2 end

    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if req then
        local ok3, res3 = pcall(function()
            return req({ Url = url, Method = "GET" })
        end)
        if ok3 and res3 and res3.Body and #res3.Body > 50 then
            return res3.Body
        end
    end
    return nil
end

-- 3. Identifica o Script Apropriado pelo PlaceId
local targetFile = (game.PlaceId == 107778070777162) and "steal_egg.lua" or "script.lua"
local baseUrl = "https://raw.githubusercontent.com/miguelmarinho1420-hub/superhero-evolution/main/" .. targetFile

local content = fetchScript(baseUrl .. "?t=" .. os.time()) or fetchScript(baseUrl)

if not content then
    warn("[LOADER ERROR] Não foi possível baixar o script do GitHub. Verifique sua conexão.")
    return
end

local func, err = loadstring(content, targetFile)
if func then
    print("[LOADER] " .. targetFile .. " compilado com sucesso! Executando...")
    func()
else
    warn("[LOADER ERROR] Falha ao compilar script:", tostring(err))
end
