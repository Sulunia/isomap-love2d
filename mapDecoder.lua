require("modules/externals/autobatch")
json = require("modules/externals/dkjson")
require("modules/utils/miscUtils")

map = {}
mapDec = {}
mapTextures = {}
mapPositions = {}
mapProps = {}
mapLighting = {}
mapPropsfield = {}
tileWidth = 280
tileHeight = 160
xm = -60
ym = 160

function map.decodeJson(filename)
	--User checks
	assert(filename, "Filename is nil!")
	if not love.filesystem.isFile(filename) then error("Given filename is not a file! Is it a directory? Does it exist?") end
	
	--Reads file
	mapJson = love.filesystem.read(filename)
	
	--Attempts to decode file
	mapDec = json.decode(mapJson)

end


function map.generatePlayField()
	love.graphics.setDefaultFilter("nearest", "nearest", 1)
	
	print("Current map information:")
	print("General information: =-=-=-=-=-=-=")
	if mapDec.general ~= nil then
		print("Map name: "..mapDec.general[1].name)
		print("Map version: "..mapDec.general[1].version)
		print("Map lighting: "..mapDec.general[1].lighting)
		if mapDec.general[1].lighting ~= nil then
			mapLighting = string.split(mapDec.general[1].lighting, "|")
		end
		print("----")
	end
	
	print("Ground textures: =-=-=-=-=-=-=-=")
	for i, texture in ipairs(mapDec.textures) do
		--Print table contents for now
		print(texture.file)
		print(texture.mnemonic)
		print("---")
		
		table.insert(mapTextures, {file = texture.file, mnemonic = texture.mnemonic, image = love.graphics.newImage("textures/"..texture.file)})
		
	end
	
	--Get ground texture dimensions
	tileWidth = mapTextures[1].image:getWidth()/2
	tileHeight = mapTextures[1].image:getHeight()/2
	
	print("Playfield props: =-=-=-=-=-=-=-=")
	if mapDec.props ~= nil then
		for i, props in ipairs(mapDec.props) do
			print(props.file)
			print(props.mnemonic)
			print(props.origin)
			print("----")
			table.insert(mapProps, {file = props.file, mnemonic = props.mnemonic, image = love.graphics.newImage("props/"..props.file), origins = string.split(props.origin, "|")})
		end
	else
		print("No props found on current map!")
	end
	
	
	--Add each ground tile to a table according to their texture
	timerStart = love.timer.getTime()
	for i, groundTexture in ipairs(mapTextures) do
		for colunas in ipairs(mapDec.data) do
			for linhas in ipairs(mapDec.data[colunas]) do
				for i, properties in ipairs(mapDec.data[colunas][linhas]) do
					
					--Add ground texture if mnemonic is found
					if properties == groundTexture.mnemonic then
						local xPos = linhas
						local yPos = colunas
						if mapPositions[colunas] == nil then
							mapPositions[colunas] = {}
						end
						if mapPositions[colunas][linhas] == nil then
							mapPositions[colunas][linhas] = {}
						end
						table.insert(mapPositions[colunas][linhas], {texture = groundTexture.image, x=xPos, y=yPos})
					end
					
				end
			end
		end
	end
	
	--Add object to map accordingly
	for i, props in ipairs(mapProps) do --For each object
		
		--Loop through map terrain information
		for colunas in ipairs(mapDec.data) do 
			for linhas in ipairs(mapDec.data[colunas]) do
				
				--Iterate over the objects in a given 2D position
				for i, objects in ipairs(mapDec.data[colunas][linhas]) do
					if objects == props.mnemonic then
						table.insert(mapPropsfield, {texture=props.image, x=linhas, y=colunas, offX=props.origins[1], offY=props.origins[2]})
					end
				end
			end
		end
		
	end
	
	timerEnd = love.timer.getTime()
	print("Decode loop took "..((timerEnd-timerStart)*100).."ms")
	
end

function map.draw(xOff, yOff, size)
	assert(xOff)
	assert(yOff)
	assert(size)
	
	--Apply lighting
	love.graphics.setColor(tonumber(mapLighting[1]), tonumber(mapLighting[2]), tonumber(mapLighting[3]), 255)
	
	for i in ipairs(mapPositions) do
		for j=1,#mapPositions[i], 1 do
			xPos = mapPositions[i][j][1].x * (tileWidth*size)
			yPos = mapPositions[i][j][1].y * (tileWidth*size)
			xPos, yPos = map.toIso(xPos, yPos)
			love.graphics.draw(mapPositions[i][j][1].texture,xPos+xOff, yPos+yOff, 0, size, size, mapPositions[i][j][1].texture:getWidth()/2, mapPositions[i][j][1].texture:getHeight()/2 )
		end
	end
	
	for i in ipairs(mapPropsfield) do
		xPos = mapPropsfield[i].x * (tileWidth*size)
		yPos = mapPropsfield[i].y * (tileWidth*size)
		xPos, yPos = map.toIso(xPos, yPos)
		assert(mapPropsfield[i].texture)
		love.graphics.draw(mapPropsfield[i].texture, xPos+xOff, yPos+yOff, 0, size, size, mapPropsfield[i].offX, mapPropsfield[i].offY)
	end
	
end

--Links used whilst searching for information on isometric maps:
--http://stackoverflow.com/questions/892811/drawing-isometric-game-worlds
--https://gamedevelopment.tutsplus.com/tutorials/creating-isometric-worlds-a-primer-for-game-developers--gamedev-6511
--Give it a good read if you don't understand whats happening over here.

function map.toIso(x, y)
	assert(x, "Position X is nil!")
	assert(y, "Position Y is nil!")
	
	newX = x-y
	newY = (x + y)/2
	return newX, newY
end

function map.toCartesian(x, y)
	assert(x, "Position X is nil!")
	assert(y "Position Y is nil!")
	x = (2 * y + x)/2
	y = (2 * y - x)/2
	return x, y
end
