isomap = require ("isomap")
function love.load()
	--Variables
	x = 0
	y = 0

	--Set background to deep blue
	love.graphics.setBackgroundColor(0, 0, 69)

	--Decode JSON map file
	isomap.decodeJson("JSONMap.json")

	--Generate map from JSON file (loads assets and creates tables)
	isomap.generatePlayField()
end

function love.update(dt)
	--Get player input so map moves around.
	if love.keyboard.isDown("left") then x = x + 900*dt end
	if love.keyboard.isDown("right") then x = x - 900*dt end
	if love.keyboard.isDown("up") then y = y+900*dt end
	if love.keyboard.isDown("down") then y = y-900*dt end
end

function love.draw()
	isomap.draw(x, y, 1)
end
