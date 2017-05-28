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


local map = {}
local mapDec = {}
local mapTextures = {}
local mapPositions = {}
local mapProps = {}
local mapLighting = {}
local mapPropsfield = {}
local tileWidth = 0
local tileHeight = 0

local mapPlayfieldWidthInTiles = 0
local mapPlayfieldHeightInTiles = 0

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
						pX = linhas
						pY = colunas
						pX, pY = map.toIso(pX, pY)
						table.insert(mapPropsfield,{texture=props.image, x=linhas, y=colunas, offX=props.origins[1], offY=props.origins[2], mapY = pY, mapX = pX})
					end
				end

			end
		end

	end
	--Calculate map dimensions
	mapPlayfieldWidthInTiles = #mapPositions
	mapPlayfieldHeightInTiles = #mapPositions[1]

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
	--Sort ZBuffer and draw objects.
	for k,v in spairs(mapPropsfield, function(t,a,b) return t[b].mapY > t[a].mapY end) do
		local xPos = v.x * (tileWidth*zoomLevel)
		local yPos = v.y * (tileWidth*zoomLevel)
		local xPos, yPos = map.toIso(xPos, yPos)
		love.graphics.draw(v.texture, xPos+xOff, yPos+yOff, 0, size, size, v.offX, v.offY)
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

--The two functions below may be deprecated, since they relied on an old method of object handling
--which didn't previously use a proper Z-buffer.
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
	--Insert object on map
	table.insert(mapPropsfield, {texture=textureI, x=isoY, y=isoX+0.001, offX=offXR, offY = offYR, mapY = ry, mapX = rx})
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
	--https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
	--Function "spairs" by Michal Kottman.
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
end

return map
