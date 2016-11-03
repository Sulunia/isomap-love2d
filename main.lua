require("modules/externals/autobatch")
json = require("modules/externals/dkjson")
require ("modules/mapDecoder")

x = 0
y = 0


function love.load()
	map.decodeJson("BigJSONMap.json")
	
	map.generatePlayField()
end

function love.update(dt)
	if love.keyboard.isDown("left") then x = x + 900*dt end
	if love.keyboard.isDown("right") then x = x - 900*dt end
	if love.keyboard.isDown("up") then y = y+900*dt end
	if love.keyboard.isDown("down") then y = y-900*dt end
end

function love.draw()
	
	map.draw(x, y)
	
	info = love.graphics.getStats()
	love.graphics.print("FPS: "..love.timer.getFPS())
	love.graphics.print("Draw calls: "..info.drawcalls, 0, 10)
	love.graphics.print("Texture memory: "..((info.texturememory/1024)/1024).."mb", 0, 20)
end

