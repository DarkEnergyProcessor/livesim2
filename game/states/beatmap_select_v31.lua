-- Beatmap selection (v3.1)
-- Part of Live Simulator: 2
-- See copyright notice in main.lua

local love = require("love")
local Luaoop = require("libs.Luaoop")

local async = require("async")
local color = require("color")
local mainFont = require("font")
local setting = require("setting")
local fileDialog = require("file_dialog")
local util = require("util")
local gamestate = require("gamestate")
local loadingInstance = require("loading_instance")
local L = require("language")

local beatmapList = require("game.beatmap.list")
local glow = require("game.afterglow")
local ripple = require("game.ui.ripple")
local ciButton = require("game.ui.circle_icon_button")

local mipmaps = {mipmaps = true}

-- One shot usage, no need to have it in different file
-- 451x94
local beatmapSelectButton = Luaoop.class("Livesim2.BeatmapSelect.BeatmapSelectButton", glow.element)
local optionToggleButton = Luaoop.class("Livesim2.BeatmapSelect.OptionToggleButton", glow.element)
local playButton = Luaoop.class("Livesim2.BeatmapSelect.PlayButton", glow.element)
local diffDropdown = Luaoop.class("Livesim2.BeatmapSelect.DifficultyDropdown", glow.element)
local diffText = Luaoop.class("Livesim2.BeatmapSelect.DifficultySelect", glow.element)

do
	local coverShader

	local function commonPressed(self, _, x, y)
		self.isPressed = true
		self.ripple:pressed(x, y)
	end

	local function commonReleased(self)
		self.isPressed = false
		self.ripple:released()
	end

	function beatmapSelectButton:new(state, name, format, coverImage)
		coverShader = coverShader or state.data.coverMaskShader

		self.name = love.graphics.newText(state.data.mainFont)
		self.name:add(name, 0, 0, 0, 24/44)
		self.format = love.graphics.newText(state.assets.fonts.formatFont, format)
		self:setCoverImage(coverImage)

		self.width, self.height = 450, 94
		self.x, self.y = 0, 0
		self.ripple = ripple(460.691871)
		self.selected = false
		self.stencilFunc = function()
			love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
		end
		self.isPressed = false
		self:addEventListener("mousepressed", commonPressed)
		self:addEventListener("mousereleased", commonReleased)
		self:addEventListener("mousecanceled", commonReleased)
	end

	function beatmapSelectButton:setCoverImage(coverImage)
		if coverImage then
			local w, h = coverImage:getDimensions()
			self.coverScaleW, self.coverScaleH = 82 / w, 82 / h
		end

		self.coverImage = coverImage
	end

	function beatmapSelectButton:update(dt)
		self.ripple:update(dt)
	end

	function beatmapSelectButton:render(x, y)
		local shader = love.graphics.getShader()
		self.x, self.y = x, y

		love.graphics.setColor(self.selected and color.hexFF4FAE or color.hex434242)
		love.graphics.rectangle("fill", x, y, self.width, self.height)
		love.graphics.setShader(util.drawText.workaroundShader)
		love.graphics.setColor(color.white)
		love.graphics.draw(self.name, x + 110, y + 20)
		love.graphics.draw(self.format, x + 110, y + 60)

		if self.coverImage then
			love.graphics.setShader(coverShader)
			love.graphics.draw(self.coverImage, x + 6, y + 6, 0, self.coverScaleW, self.coverScaleH)
		else
			love.graphics.setShader()
			love.graphics.setColor(color.hexC4C4C4)
			love.graphics.rectangle("fill", x + 6, y + 6, 82, 82, 12, 12)
			love.graphics.rectangle("line", x + 6, y + 6, 82, 82, 12, 12)
		end

		love.graphics.setShader(shader)

		if self.ripple:isActive() then
			love.graphics.stencil(self.stencilFunc, "replace", 1, false)
			love.graphics.setStencilTest("equal", 1)
			self.ripple:draw(255, 255, 255, x, y)
			love.graphics.setStencilTest()
		end
	end

	function optionToggleButton:new(checked, image, imageS, imageY, font, text, textY)
		self.image = image
		self.imageW, self.imageH = image:getDimensions()
		self.imageS = imageS
		self.imageY = imageY
		self.description = love.graphics.newText(font)
		self.descriptionY = textY
		self.description:add(text, font:getWidth(text) * -0.5, 0)

		self.width, self.height = 120, 98
		self.x, self.y = 0, 0
		self.ripple = ripple(154.932243)
		self.selected = false
		self.stencilFunc = function()
			love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
		end
		self.isPressed = false
		self.checked = not(not(checked))
		self:addEventListener("mousepressed", commonPressed)
		self:addEventListener("mousereleased", optionToggleButton._released)
		self:addEventListener("mousecanceled", commonReleased)
	end

	function optionToggleButton:_released()
		commonReleased(self)
		self.checked = not(self.checked)
		self:triggerEvent("changed", self.checked)
	end

	function optionToggleButton:update(dt)
		self.ripple:update(dt)
	end

	function optionToggleButton:render(x, y)
		self.x, self.y = x, y

		love.graphics.setColor(color.hexEF46A1)
		love.graphics.rectangle("fill", x, y, self.width, self.height)
		love.graphics.setColor(self.checked and color.white or color.black)
		love.graphics.draw(
			self.image, x + 60, y + self.imageY, 0,
			self.imageS, self.imageS,
			self.imageW * 0.5, self.imageH * 0.5
		)
		util.drawText(self.description, x + 60, y + self.descriptionY)

		if self.ripple:isActive() then
			love.graphics.stencil(self.stencilFunc, "replace", 1, false)
			love.graphics.setStencilTest("equal", 1)
			self.ripple:draw(255, 255, 255, x, y)
			love.graphics.setStencilTest()
		end
	end

	function playButton:new(font, pb)
		local text = L"beatmapSelect:play"
		self.text = love.graphics.newText(font)
		self.text:add(text, 0, 0, 0, 15/16)
		self.image = pb

		self.height = 40
		self.width = math.ceil(pb:getWidth() * 0.24 + font:getWidth(text) * 15/16 + 40)
		self.x, self.y = 0, 0
		self.ripple = ripple(math.sqrt(self.width * self.width + 1600))
		self.selected = false
		self.stencilFunc = function()
			love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 20, 20)
		end
		self.isPressed = false
		self:addEventListener("mousepressed", playButton._pressed)
		self:addEventListener("mousereleased", commonReleased)
		self:addEventListener("mousecanceled", commonReleased)
	end

	function playButton:_pressed(_, x, y)
		if
			-- Square
			(x >= 20 and y >= 0 and x < self.width - 20 and y < 40) or
			-- Circle left
			util.distance(x, y, 20, 20) <= 20 or
			-- Circle right
			util.distance(x, y, self.width - 20, 20) <= 20
		then
			self.isPressed = true
			self.ripple:pressed(x, y)
			return false
		else
			return true
		end
	end

	function playButton:update(dt)
		self.ripple:update(dt)
	end

	function playButton:render(x, y)
		self.x, self.y = x, y
		love.graphics.setColor(color.hexFFDF35)
		love.graphics.rectangle("fill", x, y, self.width, self.height, 20, 20)
		love.graphics.rectangle("line", x, y, self.width, self.height, 20, 20)
		love.graphics.setColor(color.white)
		love.graphics.draw(self.image, x + 12, y + 7, 0, 0.32)
		util.drawText(self.text, x + 37, y + 12)

		if self.ripple:isActive() then
			love.graphics.stencil(self.stencilFunc, "replace", 1, false)
			love.graphics.setStencilTest("equal", 1)
			self.ripple:draw(255, 255, 255, x, y)
			love.graphics.setStencilTest()
		end
	end

	local cb = require("libs.cubic_bezier")
	local dropdownInterpolation = cb(0.4, 0, 0.2, 1):getFunction()

	-- This one is not meant to be "glow.addElement" directly.
	-- font = mainFont2
	function diffDropdown:new(font)
		self.optionText = love.graphics.newText(font)
		self.optionUpdated = true
		self.timer = 0
		self.width, self.height = 150, 0
		self.realHeight = 26
		self.items = {}
		self.destFrame = nil
		self.x, self.y = 0, 0

		self:addEventListener("mousepressed", diffDropdown._pressed)
		self:addEventListener("mousemoved", diffDropdown._moved)
		self:addEventListener("mousereleased", diffDropdown._released)
		self:addEventListener("mousecanceled", diffDropdown.hide)
	end

	function diffDropdown:_pressed(_, x, y)
		self.x, self.y = x, y
	end

	function diffDropdown:_moved(_, x, y)
		self.x, self.y = x, y
	end

	function diffDropdown:_released()
		local clickedIndex = math.floor(self.y / 26) + 1
		if self.items[clickedIndex] then
			self:triggerEvent("selected", self.items[clickedIndex], clickedIndex)
		end

		self:hide()
	end

	function diffDropdown:_updateList()
		if not(self.optionUpdated) then
			self.optionText:clear()
			self.itemCount = #self.items
			self.realHeight = self.itemCount * 26

			for i, v in ipairs(self.items) do
				self.optionText:add(tostring(v), 18, (i - 1) * 26 + 4)
			end

			self.optionUpdated = true
		end
	end

	function diffDropdown:setItems(items)
		self.items = {}
		for i = 1, #items do
			self.items[i] = items[i]
		end

		self.optionUpdated = false
	end

	function diffDropdown:show(frame, x, y)
		if #self.items == 0 then
			error("attempt to show empty dropdown")
		end

		if self.destFrame then return end

		self.timer = 0
		self.destFrame = frame
		self:_updateList()
		frame:addElement(self, x, y)
	end

	function diffDropdown:hide()
		self.timer = 0
		self.destFrame:removeElement(self)
		self.destFrame = nil
	end

	function diffDropdown:update(dt)
		self.timer = math.min(self.timer + dt * 5, 1)
		self:_updateList()
		self.height = dropdownInterpolation(self.timer) * self.realHeight
	end

	function diffDropdown:render(x, y)
		local maxloop = math.ceil(self.height / #self.items)

		love.graphics.setColor(color.hex434242)
		love.graphics.rectangle("fill", x, y, self.width, self.height)
		love.graphics.setColor(color.white75PT)
		for i = 1, maxloop do
			love.graphics.rectangle("line", x, y + (i - 1) * 26, 150, 26)
		end
		love.graphics.setColor(color.white)
		util.drawText(self.optionText)
	end

	function diffText:new(font, img)
		self.text = love.graphics.newText(font)
		self.image = img -- "dropDown" image
		self.showImage = false
		self.width, self.height = 150, 26
	end

	function diffText:setText(text, showlist)
		self.text:clear()
		self.text:add(tostring(text))
		self.showImage = not(not(showlist))
	end

	function diffText:render(x, y)
		love.graphics.setColor(color.hexC31C76)
		love.graphics.rectangle("fill", x, y, 150, 26, 13, 13)
		love.graphics.rectangle("line", x, y, 150, 26, 13, 13)
		love.graphics.setColor(color.white)
		util.drawText(self.text, x + 18, y + 4)
		if self.showImage then
			love.graphics.draw(self.image, x + 120, y + 2, 0, 0.32)
		end
	end
end

local function leave()
	return gamestate.leave(loadingInstance.getInstance())
end

local function setStatusText(self, text, blink)
	self.persist.statusText:clear()
	if not(text) or #text == 0 then return end

	local x = self.persist.beatmapText:getWidth() + 54
	self.persist.statusText:add(text, x, 106, 0, 23/44)
	self.persist.statusTextBlink = blink and 0 or math.huge
end

local function createOptionToggleSetting(settingName, image, imageS, imageY, font, text, textY)
	local x = optionToggleButton(setting.get(settingName) == 1, image, imageS, imageY, font, text, textY)
	x:addEventListener("changed", function(_, _, value)
		setting.set(settingName, value and 1 or 0)
	end)
	return x
end

local function startPlayBeatmap(_, self)
	if self.persist.selectedBeatmap and self.persist.beatmapSummary then
		local target = self.persist.beatmaps[self.persist.selectedBeatmap]

		gamestate.enter(loadingInstance.getInstance(), "livesim2", {
			summary = self.persist.beatmapSummary,
			beatmapName = target.id,
			random = self.data.randomToggle.checked,
			storyboard = self.data.storyToggle.checked,
			videoBackground = self.data.videoToggle.checked
		})
	end
end

local function resizeImage(img, w, h)
	local canvas = util.newCanvas(w, h, nil, true)
	love.graphics.push("all")
	love.graphics.reset()
	love.graphics.setCanvas(canvas)
	love.graphics.setColor(color.white)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(img, 0, 0, 0, 128 / w, 128 / h)
	love.graphics.pop()
	return canvas
end

local beatmapSelect = gamestate.create {
	images = {
		coverMask = {"assets/image/ui/cover_mask.png", mipmaps},
		downloadCircle = {"assets/image/ui/over_the_rainbow/download_beatmap.png", mipmaps},
		dropDown = {"assets/image/ui/over_the_rainbow/expand.png", mipmaps},
		fastForward = {"assets/image/ui/over_the_rainbow/fast_forward.png", mipmaps},
		movie = {"assets/image/ui/over_the_rainbow/movie.png", mipmaps},
		navigateBack = {"assets/image/ui/over_the_rainbow/navigate_back.png", mipmaps},
		play = {"assets/image/ui/over_the_rainbow/play.png", mipmaps},
		shuffle = {"assets/image/ui/over_the_rainbow/shuffle.png", mipmaps},
		star = {"assets/image/ui/over_the_rainbow/star.png", mipmaps},
		video = {"assets/image/ui/over_the_rainbow/video.png", mipmaps},
	},
	fonts = {
		formatFont = {"fonts/Roboto-Regular.ttf", 15}
	},
}

function beatmapSelect:load()
	glow.clear()

	self.data.mainFont, self.data.mainFont2 = mainFont.get(44, 16)

	if self.data.shadowGradient == nil then
		self.data.shadowGradient = util.gradient("vertical", color.black75PT, color.transparent)
	end

	if self.data.coverMaskShader == nil then
		self.data.coverMaskShader = love.graphics.newShader([[
			extern Image mask;
			vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc)
			{
				vec4 col1 = Texel(tex, tc);
				return color * vec4(col1.rgb, col1.a * Texel(mask, tc).r);
			}
		]])
		self.data.coverMaskShader:send("mask", self.assets.images.coverMask)
	end

	if self.data.back == nil then
		self.data.back = ciButton(color.hex333131, 36, self.assets.images.navigateBack, 0.48, color.hexFF4FAE)
		self.data.back:setData(self)
		self.data.back:addEventListener("mousereleased", leave)
	end
	glow.addFixedElement(self.data.back, 32, 4)

	if self.data.downloadBeatmap == nil then
		self.data.downloadBeatmap = ciButton(color.hex333131, 36, self.assets.images.downloadCircle, 0.64, color.hexFF4FAE)
		self.data.downloadBeatmap:addEventListener("mousereleased", function()
			gamestate.enter(loadingInstance.getInstance(), "beatmapDownload")
		end)
		self.data.downloadBeatmap:setData(self)
	end
	glow.addFixedElement(self.data.downloadBeatmap, 856, 4)

	-- Option toggle
	if self.data.autoplayToggle == nil then
		self.data.autoplayToggle = createOptionToggleSetting(
			"AUTOPLAY",
			self.assets.images.fastForward, 0.32, 44,
			self.data.mainFont2, L"beatmapSelect:optionAutoplay", 60
		)
	end
	glow.addFixedElement(self.data.autoplayToggle, 480, 248)

	if self.data.randomToggle == nil then
		self.data.randomToggle = optionToggleButton(
			false,
			self.assets.images.shuffle, 0.32, 44,
			self.data.mainFont2, L"beatmapSelect:optionRandom", 60
		)
	end
	glow.addFixedElement(self.data.randomToggle, 600, 248)

	if self.data.storyToggle == nil then
		self.data.storyToggle = createOptionToggleSetting(
			"STORYBOARD",
			self.assets.images.video, 0.32, 44,
			self.data.mainFont2, L"beatmapSelect:optionStoryboard", 60
		)
	end
	glow.addFixedElement(self.data.storyToggle, 720, 248)

	if self.data.videoToggle == nil then
		self.data.videoToggle = createOptionToggleSetting(
			"VIDEOBG",
			self.assets.images.movie, 0.32, 44,
			self.data.mainFont2, L"beatmapSelect:optionVideo", 60
		)
	end
	glow.addFixedElement(self.data.videoToggle, 840, 248)

	if self.data.playButton == nil then
		self.data.playButton = playButton(self.data.mainFont2, self.assets.images.play)
		self.data.playButton:addEventListener("mousereleased", startPlayBeatmap)
		self.data.playButton:setData(self)
	end
	do
		local width = self.data.playButton.width
		-- Place in between "Random" and "Storyboard" text
		glow.addFixedElement(self.data.playButton, 720 - width * 0.5, 336)
	end

	if self.data.difficultyButton == nil then
		local b = diffText(self.data.mainFont2, self.assets.images.dropDown)

		if self.persist.selectedBeatmap then
			local selectedBeatmap = self.persist.beatmaps[self.persist.selectedBeatmap]

			if selectedBeatmap.group then
				b:setText(selectedBeatmap.difficulty[selectedBeatmap.selected], true)
			else
				b:setText(selectedBeatmap.difficulty, false)
			end
		end

		self.data.difficultyButton = b
	end
	glow.addFixedElement(self.data.difficultyButton, 508, 206)
end

function beatmapSelect:start()
	self.persist.beatmapFrame = glow.frame(0, 152, 480, 488)
	self.persist.beatmaps = {sorted = false}
	self.persist.selectedBeatmap = nil
	self.persist.beatmapSummary = nil
	self.persist.active = true
	self.persist.beatmapFrame:setVerticalSliderPosition("left")
	self.persist.beatmapFrame:setSliderColor(color.hex434242)
	self.persist.beatmapText = love.graphics.newText(self.data.mainFont, L"beatmapSelect:beatmaps")
	self.persist.statusText = love.graphics.newText(self.data.mainFont)
	self.persist.statusTextBlink = math.huge

	local function summaryGet(d)
		self.persist.beatmapSummary = d

		if d.coverArt and d.coverArt.image then
			self.persist.beatmapCoverArt = love.graphics.newImage(d.coverArt.image, mipmaps)
		end
	end

	local function beatmapSelected(_, index)
		if self.persist.selectedBeatmap ~= nil and self.persist.beatmapSummary == nil then
			-- Not fully loading
			return
		end

		local target = self.persist.beatmaps[index]
		for i, v in ipairs(self.persist.beatmaps) do
			v.element.selected = i == index
		end

		if target.group then
			beatmapList.getSummary(target.beatmaps[target.selected], summaryGet)
			self.data.difficultyButton:setText(target.difficulty[target.selected], true)
		else
			beatmapList.getSummary(target.id, summaryGet)
			self.data.difficultyButton:setText(target.difficulty, false)
		end

		self.persist.beatmapCoverArt = nil
		self.persist.beatmapSummary = nil
		self.persist.selectedBeatmap = index
	end

	local unprocessedBeatmaps = {}

	beatmapList.push()
	-- TODO: Categorize beatmaps based on their difficulty
	beatmapList.enumerate(function(id, name, fmt, diff, _, group)
		if id == "" then
			for i, v in ipairs(unprocessedBeatmaps) do
				if v.group then
					-- look for existing
					local targetGroup

					for _, w in ipairs(self.persist.beatmaps) do
						if w.name == v.group then
							targetGroup = w
							break
						end
					end

					-- create new group
					if not(targetGroup) then
						targetGroup = {
							name = v.group,
							format = v.format,
							beatmaps = {},
							difficulty = {},
							group = true,
							selected = 1,
							element = beatmapSelectButton(self, v.name, v.format)
						}

						beatmapList.getCoverArt(v.id, function(has, img, info)
							local imageCover = nil

							if has then
								local image = love.graphics.newImage(img, mipmaps)
								local w, h = image:getDimensions()
								util.releaseObject(img)
								v.coverArtImage = image
								v.info = info

								if w > 128 or h > 128 then
									imageCover = resizeImage(image, 128, 128)
									util.releaseObject(image)
								else
									imageCover = image
								end
							end

							targetGroup.element:setCoverImage(imageCover)
							targetGroup.element:addEventListener("mousereleased", beatmapSelected)
						end)

						self.persist.beatmaps[#self.persist.beatmaps + 1] = targetGroup
					end

					targetGroup.beatmaps[#targetGroup.beatmaps + 1] = v
					targetGroup.difficulty[#targetGroup.difficulty + 1] = v.difficulty
				else
					v.element = beatmapSelectButton(self, v.name, v.format)
					self.persist.beatmaps[#self.persist.beatmaps + 1] = v

					beatmapList.getCoverArt(v.id, function(has, img, info)
						local imageCover = nil

						if has then
							local image = love.graphics.newImage(img, mipmaps)
							local w, h = image:getDimensions()
							util.releaseObject(img)
							v.coverArtImage = image
							v.info = info

							if w > 128 or h > 128 then
								imageCover = util.newCanvas(128, 128, nil, true)
								love.graphics.push("all")
								love.graphics.reset()
								love.graphics.setCanvas(imageCover)
								love.graphics.setColor(color.white)
								love.graphics.setBlendMode("alpha", "premultiplied")
								love.graphics.draw(image, 0, 0, 0, 128 / w, 128 / h)
								love.graphics.pop()
								util.releaseObject(image)
							else
								imageCover = image
							end
						end

						v.element:setCoverImage(imageCover)
						v.element:addEventListener("mousereleased", beatmapSelected)
					end)
				end
			end

			-- sort
			table.sort(self.persist.beatmaps, function(a, b)
				if a.name == b.name then
					return (a.difficulty or "") < (b.difficulty or "")
				else
					return a.name < b.name
				end
			end)

			for i, v in ipairs(self.persist.beatmaps) do
				v.element:setData(i)
				self.persist.beatmapFrame:addElement(v.element, 30, (i - 1) * 94)
			end

			self.persist.beatmaps.sorted = true

			if self.persist.active then
				setStatusText(self, L("beatmapSelect:available", {amount = #self.persist.beatmaps}), false)
			end

			return false
		end

		unprocessedBeatmaps[#unprocessedBeatmaps + 1] = {
			id = id,
			name = name,
			format = fmt,
			difficulty = diff,
			group = group
		}
		return true
	end)

	glow.addFrame(self.persist.beatmapFrame)
	setStatusText(self, L"beatmapSelect:loading", true)
end

function beatmapSelect:exit()
	self.persist.active = false
	beatmapList.pop(true)
end

function beatmapSelect:resumed()
	self.persist.active = true
	if self.persist.beatmaps.sorted then
		setStatusText(self, L("beatmapSelect:available", {amount = #self.persist.beatmaps}), false)
	end
	glow.addFrame(self.persist.beatmapFrame)
end

function beatmapSelect:paused()
	self.persist.active = false
end

function beatmapSelect:update(dt)
	self.persist.beatmapFrame:update(dt)

	if self.persist.statusTextBlink ~= math.huge then
		self.persist.statusTextBlink = (self.persist.statusTextBlink + dt) % 2
	end
end

function beatmapSelect:draw()
	love.graphics.setColor(color.hex434242)
	love.graphics.rectangle("fill", -88, -43, 1136, 726)
	love.graphics.setColor(color.hexFF4FAE)
	love.graphics.rectangle("fill", 480, 10, 480, 336)

	local shader = love.graphics.getShader()
	love.graphics.setShader(util.drawText.workaroundShader)
	love.graphics.setColor(color.white)
	love.graphics.draw(self.persist.beatmapText, 30, 93)
	if self.persist.statusTextBlink ~= math.huge then
		love.graphics.setColor(color.compat(255, 255, 255, math.abs(1 - self.persist.statusTextBlink)))
	end
	love.graphics.draw(self.persist.statusText)
	love.graphics.setColor(color.white)

	if self.persist.selectedBeatmap and self.persist.beatmapSummary then
		local v = assert(self.persist.beatmaps[self.persist.selectedBeatmap])
		local summary = self.persist.beatmapSummary
		love.graphics.setFont(self.data.mainFont)
		love.graphics.printf(v.name, 500, 98, 280 / (24/44), "left", 0, 24/44)

		if summary.coverArt and summary.coverArt.info then
			love.graphics.setFont(self.data.mainFont2)
			love.graphics.printf(v.info, 500, 176, 280 / (9/16), "left", 0, 9/16)
		end

		if self.persist.beatmapCoverArt then
			local w, h = self.persist.beatmapCoverArt:getDimensions()
			love.graphics.setShader(self.data.coverMaskShader)
			love.graphics.draw(self.persist.beatmapCoverArt, 786, 94, 0, 140 / w, 140 / h)
		else
			love.graphics.setColor(color.hexC4C4C4)
			love.graphics.rectangle("fill", 786, 94, 140, 140, 15, 15)
			love.graphics.rectangle("line", 786, 94, 140, 140, 15, 15)
			love.graphics.setColor(color.white)
		end
	else
		love.graphics.setColor(color.hexC4C4C4)
		love.graphics.rectangle("fill", 786, 94, 140, 140, 15, 15)
		love.graphics.rectangle("line", 786, 94, 140, 140, 15, 15)
		love.graphics.setColor(color.white)
	end

	love.graphics.setShader(shader)
	love.graphics.rectangle("fill", 480, 346, 480, 294)
	love.graphics.draw(self.data.shadowGradient, -88, 77, 0, 1136, 8)
	love.graphics.setColor(color.hex333131)
	love.graphics.rectangle("fill", -88, 0, 1136, 80)

	glow.draw()
	self.persist.beatmapFrame:draw()
end

return beatmapSelect