--[[MIT License

Copyright (c) 2016 Pedro Polez

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.]]--

local json = require("dkjson")
--TODO: Load dkjson relative to mapDecoder's path.


map = {}
mapDec = {}
local mapTextures = {}
mapPositions = {}
mapProps = {}
local mapLighting = {}
mapPropsfield = {}
local tileWidth = 0
local tileHeight = 0

local mapPlayfieldWidthInTiles = 0
local mapPlayfieldHeightInTiles = 0

local objectListSize = 0

local zoomLevel = 1

function map.decodeJson(filename)
	assert(filename, "Filename is nil!")
	if not love.filesystem.isFile(filename) then error("Given filename is not a file! Is it a directory? Does it exist?") end

	--Reads file
	mapJson = love.filesystem.read(filename)

	--Attempts to decode file
	mapDec = json.decode(mapJson)

end


function map.generatePlayField()
	--TODO: Maps will be packed as renamed ZIP file extensios and will be able to be installed in users machines. So, textures and props have to be loaded from this directory.
	--Currently, the mapDecoder will look for textures in folder named textures in the root of the project, and props in a props folder.

	print("Current map information:")
	print("General information: =-=-=-=-=-=-=")
	if mapDec.general ~= nil then
		print("Map name: "..mapDec.general[1].name)
		print("Map version: "..mapDec.general[1].version)
		print("Map lighting: "..mapDec.general[1].lighting)
		if mapDec.general[1].lighting ~= nil then
			mapLighting = string.split_(mapDec.general[1].lighting, "|")
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
			table.insert(mapProps, {file = props.file, mnemonic = props.mnemonic, image = love.graphics.newImage("props/"..props.file), origins = string.split_(props.origin, "|")})
		end
	else
		print("No props found on current map!")
	end


	--Add each ground tile to a table according to their texture
	--TODO: the following should be done on a separate thread. I have not tested the performance of the following lines on a colossal map.
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

	--TODO: Merge these loops, since both save stuff to the same table?
	--Add object to map accordingly
	for i, props in ipairs(mapProps) do --For each object

		--Loop through map terrain information
		for colunas in ipairs(mapDec.data) do
			for linhas in ipairs(mapDec.data[colunas]) do

				--Iterate over the objects in a given 2D position
				for i, objects in ipairs(mapDec.data[colunas][linhas]) do
					if objects == props.mnemonic then
						--table.insert(mapPositions[colunas][linhas], {texture=props.image, x=linhas, y=colunas, offX=props.origins[1], offY=props.origins[2]})

						--VERY IMPORTANT NOTE ABOUT THE FOLLOWING LINES
						--these control the ZBuffer in some *dark manner*. IT WORKS. I **really** have to figure out why.
						pX, pY = map.toIso(linhas, colunas)

						colX = linhas * (tileWidth*zoomLevel)
						colY = colunas * (tileWidth*zoomLevel)
						colX, colY = map.toIso(colX, colY)
						table.insert(mapPropsfield,{texture=props.image, x=linhas, y=colunas, offX=props.origins[1], offY=props.origins[2], mapY = pY, mapX = pX, colX = colX, colY = colY, width = props.image:getWidth(), height = props.image:getHeight(), alpha = false})
					end
				end

			end
		end

	end
	--Calculate map dimensions
	mapPlayfieldWidthInTiles = #mapPositions
	mapPlayfieldHeightInTiles = #mapPositions[1]

	--Store map original object list size without any extra dynamic objects
	objectListSize = #mapPropsfield

	timerEnd = love.timer.getTime()
	print("Decode loop took "..((timerEnd-timerStart)*100).."ms")

end

function map.drawGround(xOff, yOff, size)
	assert(xOff)
	assert(yOff)
	assert(size)
	zoomLevel = size
	--Apply lighting
	love.graphics.setColor(tonumber(mapLighting[1]), tonumber(mapLighting[2]), tonumber(mapLighting[3]), 255)

	--Draw the flat ground layer for the map, without elevation or props.
	for i in ipairs(mapPositions) do
		for j=1,#mapPositions[i], 1 do
			local xPos = mapPositions[i][j][1].x * (tileWidth*zoomLevel)
			local yPos = mapPositions[i][j][1].y * (tileWidth*zoomLevel)
			local xPos, yPos = map.toIso(xPos, yPos)
			love.graphics.draw(mapPositions[i][j][1].texture,xPos+xOff, yPos+yOff, 0, size, size, mapPositions[i][j][1].texture:getWidth()/2, mapPositions[i][j][1].texture:getHeight()/2 )
		end
	end

end

function map.drawObjects(xOff, yOff, size)

	--Figure out dynamic object occlusion
	if #mapPropsfield > objectListSize then
		for i=objectListSize+1, #mapPropsfield do
			for j=1, objectListSize do
				if CheckCollision(mapPropsfield[j].colX, mapPropsfield[j].colY, mapPropsfield[j].width, mapPropsfield[j].height, mapPropsfield[i].colX, mapPropsfield[i].colY, mapPropsfield[i].width, mapPropsfield[i].height) and mapPropsfield[i].y < mapPropsfield[j].y and mapPropsfield[i].x < mapPropsfield[j].x then
					mapPropsfield[j].alpha = true
				end
			end
		end
	end

	--Sort ZBuffer and draw objects.
	for k,v in spairs(mapPropsfield, function(t,a,b) return t[b].mapY > t[a].mapY end) do
		local xPos = v.x * (tileWidth*zoomLevel)
		local yPos = v.y * (tileWidth*zoomLevel)
		local xPos, yPos = map.toIso(xPos, yPos)

		if v.alpha then
			love.graphics.setColor(255, 255, 255, 90)
		else
			love.graphics.setColor(255, 255, 255, 255)
		end
		love.graphics.draw(v.texture, xPos+xOff, yPos+yOff, 0, size, size, v.offX, v.offY)

		--Update values in order to minimize for loops
		v.alpha = false
		v.colX = xPos-v.offX
		v.colY = yPos-v.offY
		v.mapX, v.mapY = map.toIso(v.x, v.y)
	end
end


function map.getTileCoordinates2D(i, j)
	local xP = mapPositions[i][j][1].x * (tileWidth*zoomLevel)
	local yP = mapPositions[i][j][1].y * (tileWidth*zoomLevel)
	xP, yP = map.toIso(xP, yP)
	return xP, yP
end

function map.getPlayfieldWidth()
	return mapPlayfieldWidthInTiles
end

function map.getPlayfieldHeight()
	return mapPlayfieldHeightInTiles
end

function map.getGroundTileWidth()
	return tileWidth
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
	assert(y, "Position Y is nil!")
	x = (2 * y + x)/2
	y = (2 * y - x)/2
	return x, y
end

function map.insertNewObject(textureI, isoX, isoY, offXR, offYR)
	--User checks
	if offXR == nil then offXR = 0 end
	if offYR == nil then offYR = 0 end
	assert(textureI, "Invalid texture file for object!")
	assert(isoX, "No X position for object! (Isometric coordinates)")
	assert(isoY, "No Y position for object! (Isometric coordinates)")
	assert(mapPlayfieldWidthInTiles>=isoX, "Insertion coordinates out of map bounds! (X)")
	assert(mapPlayfieldWidthInTiles>=isoY, "Insertion coordinates out of map bounds! (Y)")
	local rx, ry = map.toIso(isoX, isoY)

	local colX = isoX * (tileWidth*zoomLevel)
	local colY = isoY * (tileWidth*zoomLevel)
	colX, colY = map.toIso(colX, colY)
	--Insert object on map
	table.insert(mapPropsfield, {texture=textureI, x=isoY, y=isoX+0.001, offX=offXR, offY = offYR, mapY = ry, mapX = rx, colX = colX, colY = colY, width = textureI:getWidth(), height = textureI:getHeight(), alpha = false})
end

function map.removeObject(x, y)
	if #mapPositions[x][y] > 1 then
		table.remove(mapPositions[x][y], #mapPositions[x][y])
	end
end


--This next function had the underscore added to avoid collisions with
--any other possible split function the user may want to use.
function string:split_(sSeparator, nMax, bRegexp)
	assert(sSeparator ~= '')
	assert(nMax == nil or nMax >= 1)

	local aRecord = {}

	if self:len() > 0 then
		local bPlain = not bRegexp
		nMax = nMax or -1

		local nField, nStart = 1, 1
		local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
		while nFirst and nMax ~= 0 do
			aRecord[nField] = self:sub(nStart, nFirst-1)
			nField = nField+1
			nStart = nLast+1
			nFirst,nLast = self:find(sSeparator, nStart, bPlain)
			nMax = nMax-1
		end
		aRecord[nField] = self:sub(nStart)
	end

	return aRecord
--Credit goes to JoanOrdinas @ lua-users.org
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
		--https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
		--Function "spairs" by Michal Kottman.
end

-- Collision detection function;
-- Returns true if two boxes overlap, false if they don't;
-- x1,y1 are the top-left coords of the first box, while w1,h1 are its width and height;
-- x2,y2,w2 & h2 are the same, but for the second box.
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

return map
