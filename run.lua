http = require "socket.http"
json = require "json"

function get_app_ids()
	local configf = io.open("config", "r")
	local config = json.decode(configf:read"*all")
	local api_key = config.key
	local steam_id = config.steam_id
	configf:close()

	local link = "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key="..api_key.."&steamid="..steam_id.."&format=json"
	local response = http.request(link)
	local player = json.decode(response)

	local app_ids = {}
	
	for i=1, player.response.game_count do 
		table.insert(app_ids, tostring(player.response.games[i].appid)) 
	end

	return app_ids
end

function get_steam_data()
	local app_ids = get_app_ids()

	local fsteam_data = io.open("steam_data.json", "r")

	local steam_data = {}

	if fsteam_data ~= nil then
		steam_data = json.decode(fsteam_data:read("*all"))
	end

	local count = 0
	for i, id in ipairs(app_ids) do
		if steam_data[id] == nil then
			local res_str = http.request("https://api.steamcmd.net/v1/info/" .. id)
			local success, res_json = pcall(json.decode, res_str)

			if success then
				steam_data[id] = {name = res_json.data[id].common.name, depots = res_json.data[id].depots}
				count = count + 1
				print(count, steam_data[id].name)
			end
		end
	end

	local encode, ssteam_data = pcall(json.encode, steam_data)

	local fjson = io.open("steam_data.json", "w")
	if encode then
		fjson:write(ssteam_data)
	end
	fjson:close()

	return steam_data
end

function get_size(depots)
	local size = 0
	local download = 0
	local size_noDLC = 0
	local download_noDLC = 0
	for id, depo in pairs(depots) do
	if type(depo) == 'table' then
		local eng = true
		local win = true
		if depo.config ~= nil then
			if depo.config.oslist == 'macos' or depo.config.oslist == 'linux' then
				win = false
			end
			if depo.config.language ~= 'english' and depo.config.language ~= '' and depo.config.language ~= nil then
				eng = false
			end
		end
		if depo.manifests ~= nil and eng and win then
			if depo.manifests.public ~= nil then
				size = size + depo.manifests.public.size
				download = download + depo.manifests.public.download
				if depo.dlcappid == nil then
					size_noDLC = size_noDLC + depo.manifests.public.size
					download_noDLC = download + depo.manifests.public.download
				end
			end
		end
	end
	end
	return size, download, size_noDLC, download_noDLC
end

function to_mb(bytes)
	local kb = bytes/1024
	local mb = kb/1024
	mb = math.floor(mb+0.5) --round to nearest mb
	return mb
end

function size_to_mb(a, b, c, d) --helper
	a = to_mb(a)
	b = to_mb(b)
	c = to_mb(c)
	d = to_mb(d)
	return a, b, c, d
end

function sort_data(data)
	local file = io.open("data.csv","w")
	for id, info in pairs(data) do
		local size, download, size_noDLC, download_noDLC = get_size(info.depots)
		size, download, size_noDLC, download_noDLC = size_to_mb(size, download, size_noDLC, download_noDLC)
		local name = string.gsub(info.name, ",", "")
		file:write(id,", ",name,", ",size,", ",download,", ",size_noDLC,", ",download_noDLC,"\n")
	end

	file:close()
end

sort_data(get_steam_data())
