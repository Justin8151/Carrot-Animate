package.path = package.path .. ";../../?.lua"

local json = require("json")

-- DEFAULT ANTIALIASING
love.graphics.setDefaultFilter("linear", "linear", love.graphics.getSystemLimits().anisotropy)

--[[ FPS COUNTER ]]
local _lastTime = 0
local _drawTimes = {}
local _lastCalculatedTime = -1
local __currentgcmemory = 0
--

local carrot_animate = require("animate_atlas")
local atlas = nil
function love.load()
	-- Initialize Animate Atlas Sprite
	atlas = carrot_animate:new()
	atlas:loadSpritemap(
		love.graphics.newImage("assets/example/spritemap1.png"),
		json.decode(tostring(love.filesystem.read("assets/example/spritemap1.json")))
	)
	atlas:loadAnimateAtlas(json.decode(tostring(love.filesystem.read("assets/example/Animation.json"))))

	-- COMPLETELY OPTIONAL: Canvas Setup
	-- Removing this line will make the sprites draw directly on screen
	-- This makes shader/alpha work differently
	atlas:setupCanvas(
		300, 300, -- Canvas Size
		150, 150 -- Canvas Draw Offset
	)

	-- Animation Setup
	atlas:addAnimationFromTimeline("idle", "atlas_idle", 12, true)
	atlas:addAnimationFromTimeline("wave", "atlas_wave", 12, false)
	atlas:playAnimation("idle")

	-- Animation Callback
	function atlas:onAnimationFinish(animName)
		if animName == "wave" then
			atlas:playAnimation("idle")
		end
	end
end

local lastTime = 0
function love.update(dt)
	love.graphics.setColor(1, 1, 1, 1)
	atlas:update(dt)
	
	-- fps counter
	local curTime = love.timer.getTime()
	if math.floor(curTime) > math.floor(lastTime) then
		__currentgcmemory = collectgarbage("count")
	end
	lastTime = curTime
end

function love.keypressed(key, scancode, isrepeat)
	if key == "space" then
		atlas:playAnimation("wave")
	end
end

local function drawFPSCounter()
	local curTime = love.timer.getTime()
	table.insert(_drawTimes, curTime)
	_lastTime = curTime
	while _drawTimes[1] < curTime - 1 do
		table.remove(_drawTimes, 1)
	end

	if _lastCalculatedTime < 0 then
		_lastCalculatedTime = #_drawTimes
	end

	local stats = love.graphics.getStats()
	local fr = math.floor((#_drawTimes + _lastCalculatedTime) / 2)
	love.graphics.print(string.format("%d FPS\nMemory: %.2f MB", fr, (stats.texturememory / 1024 / 1024) + (__currentgcmemory / 1024)), 24, 16)
	_lastCalculatedTime = fr
end

function love.draw()
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.push()
	love.graphics.translate(180, 30)
	atlas:draw()
	love.graphics.pop()

	love.graphics.print("Press SPACE to make him wave!", 230, 300)
	drawFPSCounter()
end