-- Debug utilities for Love2d

function debugBeginTimer()
	startTime = love.timer.getTime()
	love.mouse.setVisible(false)
	debugLog("Initialized debugger internal timer. Code execution has begun.")
	return startTime
end

function debugLog(text)
	assert(text, "Can't print nil value onscreen! (Debug)")
	newTime = love.timer.getTime()
	debugTime = newTime - startTime
	print('['..round(debugTime, 4)..']' .. "\t" .. text)
end
 
 function debugDrawMousePos()
	mx, my = love.mouse.getPosition()
	love.graphics.rectangle("fill", mx, my, 4, 4)
	love.graphics.print("X: "..mx.." Y: "..my, mx-40, my-23)
 end
