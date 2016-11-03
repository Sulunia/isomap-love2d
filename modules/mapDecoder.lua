require("modules/externals/autobatch")
json = require("modules/externals/dkjson")

map = {}
mapDec = {}
mapTextures = {}

function map.decodeJson(filename)
	--User checks
	assert(filename, "Filename is nil!")
	if not love.filesystem.isFile(filename) then error("Given filename is not a file! Is it a directory? Does it exist?") end
	
	--Reads file
	mapJson = love.filesystem.read(filename)
	print(mapJson)
	
	--Attempts to decode file
	mapDec = json.decode(mapJson)
	for k, v in ipairs(mapDec.data) do
		print("Coluna "..k..": =-=-=-=-=-=-=-=-=-=")
		for i, z in ipairs(v) do	
			print("Linha "..i..":")
			for x, r in ipairs(z) do
				print(r)
			end
		end
	end

end

function map.generatePlayField(decMap)
	


end