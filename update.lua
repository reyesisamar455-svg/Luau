local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")

local GITHUB_RAW_URL = "TU_URL_RAW_AQUI"
local codeStore = DataStoreService:GetDataStore("LiveCodeUpdate")
local UPDATE_INTERVAL = 60

local currentHash = ""

local function executeLuau(code)
	local success, func = pcall(loadstring, code)
	if success and func then
		task.spawn(func)
		print("✅ Código de GitHub ejecutado con éxito")
	else
		warn("❌ Error al cargar código: " .. tostring(func))
	end
end

-- Función para obtener código de GitHub
local function fetchGitHubCode()
	local success, result = pcall(function()
		return HttpService:GetAsync(GITHUB_RAW_URL .. "?t=" .. os.time())
	end)
	
	if success and result then
		if result ~= currentHash then
			currentHash = result
			codeStore:SetAsync("LastCode", result) -- Guardado permanente
			executeLuau(result)
		end
	else
		warn("📡 Error conectando a GitHub. Usando respaldo de DataStore...")
		local backup = codeStore:GetAsync("LastCode")
		if backup and currentHash == "" then
			currentHash = backup
			executeLuau(backup)
		end
	end
end

task.spawn(function()
	while true do
		fetchGitHubCode()
		task.wait(UPDATE_INTERVAL)
	end
end)
