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

end


function map.generatePlayField()
	for i, texture in ipairs(mapDec.textures) do
		--Print table contents for now
		print(texture.file)
		print(texture.mnemonic)
		print("---")
		
		--TODO: Add texture insertion to table for drawing
		mapTextures[texture.mnemonic] = texture.file
		
	end
	for i, fieldData in ipairs(mapDec.data) do
		--Print playfield information and tile position
		print("Column "..i.." :")
		for j, column in ipairs(fieldData) do
			print("Line "..j.." :")
			for k, row in ipairs(column) do
				print(row)
			end
		end
	end
end

