require("modules/externals/autobatch")
json = require("modules/externals/dkjson")
require ("modules/mapDecoder")

map = {}
x = 0
y = 0
mapTextures = {}

function love.load()
	map.decodeJson("MothafuckingJSONMap.json")
	--map.decodeJson("JSONMap.json")
	
	grass = love.graphics.newImage("Tiles/GrassTile.png")
	dirt = love.graphics.newImage("Tiles/DirtTile.png")
	water = love.graphics.newImage("Tiles/WaterTile.png")
	
	--mapaImagem = love.graphics.newCanvas(9000, 9000)
end

function love.update(dt)
	if love.keyboard.isDown("left") then x = x + 900*dt end
	if love.keyboard.isDown("right") then x = x - 900*dt end
	if love.keyboard.isDown("up") then y = y+900*dt end
	if love.keyboard.isDown("down") then y = y-900*dt end
	
	
	if not mapHasDrawnToCanvas then
		for linha, val in ipairs(mapDec.data) do
			for coluna, val2 in ipairs(val) do
				if val2[1] == "grass" then
					--love.graphics.draw(grass, (coluna - linha)*(grass:getWidth()/2) + x, (linha + coluna) * (grass:getHeight()/2) + y)
					table.insert(mapTextures, {grass, (coluna - linha)*(grass:getWidth()/2) + x, (linha + coluna) * (grass:getHeight()/2) + y, "grass"})
				elseif val2[1] == "water" then
					--love.graphics.draw(water, (coluna - linha)*(water:getWidth()/2) + x, (linha + coluna) * (water:getHeight()/2) + y)
					table.insert(mapTextures, {water, (coluna - linha)*(water:getWidth()/2) + x, (linha + coluna) * (water:getHeight()/2) + y, "water"})
				elseif val2[1] == "dirt" then
					--love.graphics.draw(dirt, (coluna - linha)*(dirt:getWidth()/2) + x, (linha + coluna) * (dirt:getHeight()/2) + y)
					table.insert(mapTextures, {dirt, (coluna - linha)*(dirt:getWidth()/2) + x, (linha + coluna) * (dirt:getHeight()/2) + y, "dirt"})
				end
			end
		end
		mapHasDrawnToCanvas = true
	end
end

function love.draw()
	
	--love.graphics.draw(mapaImagem, x, y)
	
	for i, v in ipairs(mapTextures) do
		if v[4] == "grass" then
			love.graphics.draw(v[1], v[2]+x, v[3]+y)
		end
	end
	
	for i, v in ipairs(mapTextures) do
		if v[4] == "water" then
			love.graphics.draw(v[1], v[2]+x, v[3]+y)
		end
	end
	
	for i, v in ipairs(mapTextures) do
		if v[4] == "dirt" then
			love.graphics.draw(v[1], v[2]+x, v[3]+y)
		end
	end
	
	info = love.graphics.getStats()
	love.graphics.print("FPS: "..love.timer.getFPS())
	love.graphics.print("Draw calls: "..info.drawcalls, 0, 10)
	love.graphics.print("Texture memory: "..((info.texturememory/1024)/1024).."mb", 0, 20)
end

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