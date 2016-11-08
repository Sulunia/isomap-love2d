require("modules/externals/autobatch")
json = require("modules/externals/dkjson")
require("modules/utils/miscUtils")

map = {}
mapDec = {}
mapTextures = {}
mapPositions = {}
mapProps = {}
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
	--print(mapJson)
	
	--Attempts to decode file
	mapDec = json.decode(mapJson)

end


function map.generatePlayField()
	love.graphics.setDefaultFilter("nearest", "nearest", 1)
	print("Ground textures: =-=-=-=-=-=-=-=")
	for i, texture in ipairs(mapDec.textures) do
		--Print table contents for now
		print(texture.file)
		print(texture.mnemonic)
		print("---")
		
		--TODO: Add texture insertion to table for drawing
		table.insert(mapTextures, {file = texture.file, mnemonic = texture.mnemonic, image = love.graphics.newImage("textures/"..texture.file)})
		
	end
	print("Playfield props: =-=-=-=-=-=-=-=")
	for i, props in ipairs(mapDec.props) do
		print(props.file)
		print(props.mnemonic)
		print(props.origin)
		print("----")
		table.insert(mapProps, {file = props.file, mnemonic = props.mnemonic, image = love.graphics.newImage("props/"..props.file), origins = string.split(props.origin, "|")})
	end
	
	--Add each tile to a table according to their texture
	timerStart = love.timer.getTime()
	for index, textureQnty in ipairs(mapTextures) do
		mapPositions[index] = {}
		for i, fieldData in ipairs(mapDec.data) do
			--Print playfield information and tile position
			for j, column in ipairs(fieldData) do
				for k, row in ipairs(column) do
					if row == textureQnty.mnemonic then
						table.insert(mapPositions[index], {(j - i)*(textureQnty.image:getWidth()/2), (j + i) * (textureQnty.image:getHeight()/2)})
					end
				end
			end
		end
	end
	for index, propsQnty in ipairs(mapProps) do
		mapPropsfield[index] = {}
		for i, fieldData in ipairs(mapDec.data) do
			--Print playfield information and tile position
			for j, column in ipairs(fieldData) do
				for k, row in ipairs(column) do
					if row == propsQnty.mnemonic then
						--table.insert(mapPropsfield[index], {(j - i)*(tileWidth/2), (j + i) * (tileHeight/2)})
						table.insert(mapPropsfield[index], {(j - i)*(tileWidth/2), (j + i) * (tileHeight/2), propsQnty.origins[1], propsQnty.origins[2]})
					end
				end
			end
		end
	end
	
	timerEnd = love.timer.getTime()
	print("Decode loop took "..((timerEnd-timerStart)*100).."ms")
	
end

function map.draw(xOff, yOff)
	love.graphics.setColor(122, 167, 255, 255)
	assert(xOff)
	assert(yOff)
	--I thought this wasn't a 2D table.. apparently i was wrong
	for index, pos in ipairs(mapPositions) do
		for j, tile in ipairs(pos) do
			love.graphics.draw(mapTextures[index].image, tile[1] + xOff, tile[2]+yOff)
		end
	end
	for index, pos in ipairs(mapPropsfield) do
		for j, tile in ipairs(pos) do
			love.graphics.draw(mapProps[index].image, tile[1] + xOff, tile[2]+yOff, 0, 1, 1, xm, ym)
		end
	end
end
