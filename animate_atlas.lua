--[[--
	Carrot-Animate
	Copyright (c) 2025 - ShadowMario

	This library is free software; you can redistribute it and/or modify it
	under the terms of the MIT license. See LICENSE for details.
--]]--

local CARROTANIMATE_VERSION = "0.0.1"

local AnimateAtlasSprite = {
	image = nil,

	-- Canvas
	canvas = nil,
	canvasDrawOffset = nil,

	-- Animation data
	curAnim = nil, --Current animation playing from the table below
	animations = nil,

	-- Animation variables
	animFinished = false,
	animPaused = true,
	animDelta = 1,
	curFrame = 1, --Rounded integer of animDelta
	animSpeedMult = 1,

	-- Callbacks
	onAnimationFinish = nil, --function(anim)
	
	-- Recommended not to touch these unless you know what you are doing
	_animateAtlasSprites = nil,
	_animateAtlasSymbols = nil,
	_animateAtlasFrames = nil,
	_lastFrameDrawn = nil
}

function AnimateAtlasSprite:new()
	return setmetatable({}, { __index = self })
end

function AnimateAtlasSprite:update(dt)
	if not self.animPaused and self.curAnim.fps ~= 0 then
		local fps = self.animSpeedMult * self.curAnim.fps
		local fr = self.animDelta + dt * fps
		if self.curAnim.loop then
			self.animFinished = false
			if fps > 0 then
				while fr > #self.curAnim.frames do
					self.animFinished = true
					fr = fr - #self.curAnim.frames
					if self.onAnimationFinish ~= nil then
						self:onAnimationFinish(self.curAnim.name)
					end
				end
			elseif fps < 1 then
				while fr < 1 do
					self.animFinished = true
					fr = fr + #self.curAnim.frames
					if self.onAnimationFinish ~= nil then
						self:onAnimationFinish(self.curAnim.name)
					end
				end
			end
		else
			fr = math.max(1, math.min(#self.curAnim.frames, fr))
			if fr ~= self.animDelta then
				if (fps > 0 and fr == #self.curAnim.frames) or (fps < 1 and fr == 1) then
					self.animFinished = true
					if self.onAnimationFinish ~= nil then
						self:onAnimationFinish(self.curAnim.name)
					end
				else
					self.animFinished = false
				end
			end
		end

		self.animDelta = fr
		self.curFrame = math.floor(self.animDelta)
	end
end

function AnimateAtlasSprite:draw()
	if self.canvas then
		if self._lastFrameDrawn ~= self.curFrame then
			self:updateCanvas()
			self._lastFrameDrawn = self.curFrame
		end
		love.graphics.draw(self.canvas)
	else
		self:drawAnimateAtlas()
	end
end

function AnimateAtlasSprite:drawAnimateAtlas()
	if self.curAnim then
		if self.curAnim.kind == "timeline" then
			self:_drawTimelineAnimation(self.curAnim.anim, self.curAnim.frames[self.curFrame])
		elseif self.curAnim.kind == "symbol" then
			self:_drawSymbol(self._animateAtlasSymbols[self.curAnim.anim], self.curAnim.frames[self.curFrame])
		else
			error(string.format("Unknown animation kind \"%s\"", self.curAnim.anim))
		end
	else
		love.graphics.setColor(1, 0, 1, 1)
		love.graphics.rectangle("fill", 0, 0, 100, 100)
	end
end

function AnimateAtlasSprite:updateCanvas()
	if not self.canvas then
		error("Animate Atlas was not initialized with a canvas.")
	end

	local r,g,b,a = love.graphics.getColor()

	love.graphics.push()
	love.graphics.setCanvas(self.canvas)

	love.graphics.origin()
	love.graphics.clear()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setBlendMode("alpha", "premultiplied")

	love.graphics.translate(self.canvasDrawOffset.x, self.canvasDrawOffset.y)
	self:drawAnimateAtlas()
	love.graphics.setCanvas()

	love.graphics.setBlendMode("alpha")
	love.graphics.pop()

	love.graphics.setColor(r, g, b, a)
end

function AnimateAtlasSprite:playAnimation(name)
	self.curAnim = self.animations[name]
	if not self.curAnim then
		error(string.format("No animation named \"%s\" found", name))
	end
	
	self.animPaused = false
	self.animDelta = 1
	self.curFrame = 1
	self.animSpeedMult = 1
end

function AnimateAtlasSprite:addAnimationFromTimeline(name, anim, fps, loop, frames)
	if name == nil then
		name = anim
	elseif anim == nil then
		anim = name
	end

	if not name and not anim then
		error("Args #1 and #2 are not valid.")
		return
	end
	
	local hasAnim = false
	local maxFrame = 1
	for _, l in pairs(self._animateAtlasFrames) do
		local tlLayer = l.elements[anim]
		if tlLayer then
			maxFrame = math.max(maxFrame, #tlLayer)
			hasAnim = true
		end
	end

	if hasAnim then
		local frameList = frames
		if not frameList then
			frameList = {}
			for i = 1, maxFrame do
				table.insert(frameList, i)
			end
		end
		self.animations[name] = {kind = "timeline", frames = frameList, anim = anim, name = name, fps = fps or 24, loop = loop or false}
		return true
	else
		error(string.format("There is no timeline animation named \"%s\".", anim))
	end
	return false
end

function AnimateAtlasSprite:addAnimationFromSymbol(name, symbol, fps, loop, frames)
	if name == nil then
		name = symbol
	elseif symbol == nil then
		symbol = name
	end

	if not name and not symbol then
		error("Args #1 and #2 are not valid.")
		return
	end
	
	local atlasSymbol = self._animateAtlasSymbols[symbol]
	if atlasSymbol then
		local frameList = frames
		if not frameList then
			frameList = {}
			local maxFrame = 1
			for _, layer in pairs(atlasSymbol) do
				if layer then
					maxFrame = math.max(maxFrame, #layer.elements)
				end
			end
			
			for i = 1, maxFrame do
				table.insert(frameList, i)
			end
		end
		self.animations[name] = {kind = "symbol", frames = frameList, anim = symbol, name = name, fps = fps or 24, loop = loop or false}
		return true
	else
		error(string.format("There is no symbol named \"%s\".", symbol))
	end
	return false
end

function AnimateAtlasSprite:_drawTimelineAnimation(animation, n)
	for _, l in pairs(self._animateAtlasFrames) do
		local v = ((math.max(1, n or 1) - 1) % (#l.elements[animation])) + 1
		local tlLayer = l.elements[animation][v]
		if tlLayer then
			for _, symbols in pairs(tlLayer) do
				for _, element in pairs(symbols) do
					if element.kind == "ASI" then
						self:_drawElement(element)
					elseif element.kind == "SI" then
						love.graphics.push()
						love.graphics.applyTransform(element.transform)
						love.graphics.transformPoint(element.transformPoint.x, element.transformPoint.y)
						self:_drawSymbol(self._animateAtlasSymbols[element.symbol], v)
						love.graphics.pop()
					end
				end
			end
		end
	end
end

function AnimateAtlasSprite:_drawSymbol(symbol, n)
	for _, layer in ipairs(symbol) do
		if layer then
			local v = ((math.max(1, n or 1) - 1) % (#layer.elements)) + 1
			for _, symbols in pairs(layer.elements[v]) do
				for _, element in pairs(symbols) do
					if element.kind == "ASI" then
						self:_drawElement(element)
					elseif element.kind == "SI" then
						love.graphics.push()
						love.graphics.applyTransform(element.transform)
						love.graphics.transformPoint(element.transformPoint.x, element.transformPoint.y)
						self:_drawSymbol(self._animateAtlasSymbols[element.symbol], n)
						love.graphics.pop()
					end
				end
			end
		end
	end
end

function AnimateAtlasSprite:_drawElement(element)
	local spr = self._animateAtlasSprites[element.symbol]
	love.graphics.push()
	love.graphics.applyTransform(element.transform)
	love.graphics.draw(self.image, spr.quad)
	love.graphics.pop()
end

function AnimateAtlasSprite:loadSpritemap(image, json)
	self.animations = {}
	self._animateAtlasSprites = {}
	self.image = image

	local sprites = json.ATLAS
	if sprites.SPRITES then
		sprites = sprites.SPRITES
	end

	local imgW, imgH = image:getWidth(), image:getHeight()
	for _, v in ipairs(sprites) do
		local sprite = v
		if sprite.SPRITE then
			sprite = sprite.SPRITE
		end

		--"SPRITE" : {"name": "0000","x":128,"y":511,"w":194,"h":124,"rotated": false}
		local spriteData = {
			x = sprite.x,
			y = sprite.y,
			w = sprite.w,
			h = sprite.h,
			name = "unknown",
			quad = love.graphics.newQuad(sprite.x, sprite.y, sprite.w, sprite.h, imgW, imgH),
			rotated = sprite.rotated
		}
		self._animateAtlasSprites[sprite.name] = spriteData
	end
end

function AnimateAtlasSprite:loadAnimateAtlas(animationJson)
	self.animations = {}
	self._animateAtlasSymbols = {}
	self._animateAtlasFrames = {}
	if not animationJson.SD and not animationJson.AN then
		error("Invalid Animation Data: "..folderPrefix.."Animation.json")
	end

	-- Setup Symbol Dictionary (SD)
	local symbolsData = animationJson.SD
	if symbolsData.S then
		symbolsData = symbolsData.S
	end

	local function m3dToTransform(m3d)
		
		local m11, m12, m13, m14 = m3d[1], m3d[5], m3d[9], m3d[13]
		local m21, m22, m23, m24 = m3d[2], m3d[6], m3d[10], m3d[14]
		local m31, m32, m33, m34 = m3d[3], m3d[7], m3d[11],m3d[15]
		local m41, m42, m43, m44 = m3d[4], m3d[8], m3d[12], m3d[16]
		local transform = love.math.newTransform()		
		transform:setMatrix(
			m11, m12, m13, m14,
			m21, m22, m23, m24,
			m31, m32, m33, m34,
			m41, m42, m43, m44
		)
		return transform
	end

	local function setupASI(symb)
		local symbolName = symb.N
		local m3d = m3dToTransform(symb.M3D)
		return {
			symbol = symbolName,
			transform = m3d,
			kind = "ASI"
		}
	end

	local function setupSI(symb)
		local symbolName = symb.SN
		local instanceName = symb.IN
		local firstFrame = symb.FF

		local loopType = symb.LP
		if loopType == "LP" then
			loopType = "looping"
		else
			error("Unsupported loop type: "..symb.LP)
		end

		local symbolType = symb.ST
		if symbolType then
			if symb.ST == "G" then
				symbolType = "graphic"
			elseif symb.ST == "MC" then
				symbolType = "movie_clip"
			else
				error("Unsupported animate atlas layer type: "..symb.ST)
			end
		end
		local transformPoint = {x = symb.TRP.x, y = symb.TRP.y}
		local m3d = m3dToTransform(symb.M3D)
		return {
			symbol = symbolName,
			instanceName = instanceName,
			firstFrame = firstFrame,
			loopType = loopType,
			transformPoint = transformPoint,
			transform = m3d,
			kind = "SI"
		}
	end

	local function getElements(fr)
		local elements = {}
		if fr.E then
			for _, el in pairs(fr.E) do
				local nothingFound = true

				-- Setting up ASI
				local symb = el.ASI
				if symb then
					table.insert(elements, setupASI(symb))
					nothingFound = false
				end

				-- Setting up SI
				local symb = el.SI
				if symb then
					local element = setupSI(symb)
					element._frameNumber = index
					table.insert(elements, element)
					nothingFound = false
				end

				-- Return error if none is found
				-- TO DO: Maybe remove this if it actually makes any FLA unusable
				if nothingFound then
					for wtf, wtf2 in pairs(el) do
						error("Unsupported element data: \""..wtf.."\", value: "..tostring(wtf2))
					end
				end
			end
		end
		return elements
	end

	for _, symbol in pairs(symbolsData) do
		local name = symbol.SN
		local timeline = symbol.TL
		if timeline.L then
			timeline = timeline.L
		end

		--print("Making symbol\t "..name..":")
		local layers = {}
		for _, l in ipairs(timeline) do
			local layerType = l.LT
			if layerType then
				if l.LT == "G" then --Is it really named "G"? This is just a hard guess...
					layerType = "graphic"
				elseif l.LT == "Clp" then
					layerType = "movie_clip"
				else
					error("Unsupported animate atlas layer type: "..l.LT)
				end
			else --failsafe
				layerType = "graphic"
			end

			local layer = {name = l.LN, elements = {}, layerType = layerType}
			for _, fr in ipairs(l.FR) do
				local index = fr.I+1
				local duration = fr.DU
				local elements = getElements(fr)
				for i = index, index+duration-1 do
					if layer.elements[i] == nil then layer.elements[i] = {} end
					table.insert(layer.elements[i], 1, elements)
				end
			end
			table.insert(layers, 1, layer)
		end
		self._animateAtlasSymbols[name] = layers
		--print("-----------------")
	end
	--print("Symbol dictionary completed!")

	local timeline = animationJson.AN.TL
	if not timeline then
		error("Animation has no timeline: "..folderPrefix.."Animation.json")
	end
	
	if timeline.L then
		timeline = timeline.L
	end

	local layers = {}
	local name = nil
	for _, l in ipairs(timeline) do
		local layer = {name = l.LN, elements = {}, layerType = layerType}
		local _lastAnimEndsAt = 0
		for ifr, fr in ipairs(l.FR) do
			if fr.N then
				_lastAnimEndsAt = ifr
				name = fr.N
			end
			
			if name == nil then
				goto continue
			end

			local index = fr.I+1 - (_lastAnimEndsAt-1)
			local duration = fr.DU
			local elements = getElements(fr)
			for i = index, index+duration-1 do
				if layer.elements[name] == nil then layer.elements[name] = {} end
				if layer.elements[name][i] == nil then layer.elements[name][i] = {} end
				table.insert(layer.elements[name][i], elements)
			end
			::continue::
		end
		table.insert(layers, layer)
	end
	self._animateAtlasFrames = layers
	--print("Timeline completed!")
	--print("-------")
end

function AnimateAtlasSprite:setupCanvas(canvasX, canvasY, drawOffsetX, drawOffsetY)
	if self.canvas then
		self.canvas:release()
	end
	
	self.canvasDrawOffset = {x = drawOffsetX or 0, y = drawOffsetY or 0}
	self.canvas = love.graphics.newCanvas(canvasX, canvasY)
end

return AnimateAtlasSprite