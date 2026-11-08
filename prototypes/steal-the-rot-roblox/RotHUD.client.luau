-- PROTOTYPE - NOT FOR PRODUCTION
-- Question: Is "dive deeper for rarer creatures while your base is open to thieves" fun on Roblox?
-- Date: 2026-11-08
--
-- LocalScript. In Roblox Studio put it in StarterPlayer > StarterPlayerScripts and name it: RotHUD
-- Draws the screen: cash, the Sanity bar in the cave, pop-up messages, the Shop, and the cave mood lighting.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("RotConfig"))
local remotes = ReplicatedStorage:WaitForChild("RotRemotes")
local NotifyEvent = remotes:WaitForChild("Notify")
local KnockEvent = remotes:WaitForChild("Knockback")
local BuyUpgrade = remotes:WaitForChild("BuyUpgrade")

local FONT = Enum.Font.FredokaOne
local WHITE = Color3.new(1, 1, 1)

local function formatMoney(n)
	if n >= 1e6 then
		return string.format("$%.1fM", n / 1e6)
	elseif n >= 1e3 then
		return string.format("$%.1fK", n / 1e3)
	end
	return "$" .. tostring(math.floor(n))
end

------------------------------------------------------------------ ui helpers
local function new(className, props, parent)
	local obj = Instance.new(className)
	for k, v in props do
		obj[k] = v
	end
	obj.Parent = parent
	return obj
end

local function stroke(obj, thickness)
	new("UIStroke", { Thickness = thickness or 2, Color = Color3.new(0, 0, 0),
		ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual }, obj)
end

local function corner(obj, radius)
	new("UICorner", { CornerRadius = UDim.new(0, radius or 12) }, obj)
end

local function textLabel(parent, props)
	local t = new("TextLabel", { BackgroundTransparency = 1, Font = FONT, TextScaled = true, TextColor3 = WHITE }, parent)
	for k, v in props do
		t[k] = v
	end
	stroke(t, 2)
	return t
end

local function button(parent, text, color, props)
	local b = new("TextButton", { BackgroundColor3 = color, Font = FONT, TextScaled = true, TextColor3 = WHITE,
		Text = text, AutoButtonColor = true }, parent)
	for k, v in props do
		b[k] = v
	end
	corner(b, 10)
	stroke(b, 2)
	local border = new("UIStroke", { Thickness = 3, Color = Color3.new(0, 0, 0),
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, b)
	border.Transparency = 0.3
	new("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, b)
	return b
end

local gui = new("ScreenGui", { Name = "RotHUD", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling },
	player:WaitForChild("PlayerGui"))

------------------------------------------------------------------ full-screen effects
local surgeTint = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(150, 0, 220),
	BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 0 }, gui)
local rotTint = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(180, 0, 0),
	BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 0 }, gui)

------------------------------------------------------------------ cash (left side, clear of the mobile thumbstick)
local shopButton = button(gui, "SHOP", Color3.fromRGB(70, 200, 90),
	{ Size = UDim2.fromOffset(140, 50), Position = UDim2.new(0, 16, 0.38, 0) })
local cashLabel = textLabel(gui, { Size = UDim2.fromOffset(220, 46), Position = UDim2.new(0, 16, 0.38, 60),
	TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(120, 255, 120), Text = "$0" })
local incomeLabel = textLabel(gui, { Size = UDim2.fromOffset(220, 26), Position = UDim2.new(0, 16, 0.38, 106),
	TextXAlignment = Enum.TextXAlignment.Left, Text = "+$0/s" })
local lockLabel = textLabel(gui, { Size = UDim2.fromOffset(240, 24), Position = UDim2.new(0, 16, 0.38, 134),
	TextXAlignment = Enum.TextXAlignment.Left, Text = "" })

------------------------------------------------------------------ cave panel (top middle)
local cavePanel = new("Frame", { Size = UDim2.new(0.6, 0, 0, 70), Position = UDim2.new(0.5, 0, 0, 6),
	AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, Visible = false }, gui)
new("UISizeConstraint", { MaxSize = Vector2.new(520, 70) }, cavePanel)
local barBack = new("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(30, 25, 40) }, cavePanel)
corner(barBack, 10)
new("UIStroke", { Thickness = 3, Color = Color3.new(0, 0, 0) }, barBack)
local barFill = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(110, 230, 120) }, barBack)
corner(barFill, 10)
local barText = textLabel(barBack, { Size = UDim2.fromScale(1, 1), Text = "SANITY", ZIndex = 2 })
local caveInfo = textLabel(cavePanel, { Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 36), Text = "" })

------------------------------------------------------------------ pop-up messages
local toastArea = new("Frame", { Size = UDim2.new(0.7, 0, 0, 200), Position = UDim2.new(0.5, 0, 0, 84),
	AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1 }, gui)
new("UIListLayout", { HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder }, toastArea)
local toastCount = 0

local function toast(text, color)
	toastCount += 1
	local t = textLabel(toastArea, { Size = UDim2.new(1, 0, 0, 30), Text = text, TextColor3 = color or WHITE,
		LayoutOrder = toastCount })
	t.TextTransparency = 1
	TweenService:Create(t, TweenInfo.new(0.15), { TextTransparency = 0 }):Play()
	local kids = {}
	for _, k in toastArea:GetChildren() do
		if k:IsA("TextLabel") then
			table.insert(kids, k)
		end
	end
	if #kids > 5 then
		table.sort(kids, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)
		kids[1]:Destroy()
	end
	task.delay(3, function()
		if t.Parent then
			TweenService:Create(t, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
			local s = t:FindFirstChildOfClass("UIStroke")
			if s then
				TweenService:Create(s, TweenInfo.new(0.5), { Transparency = 1 }):Play()
			end
			task.wait(0.5)
			t:Destroy()
		end
	end)
end

NotifyEvent.OnClientEvent:Connect(toast)

------------------------------------------------------------------ shop
local shop = new("Frame", { Size = UDim2.fromOffset(340, 230), Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(40, 35, 60), Visible = false }, gui)
corner(shop, 16)
new("UIStroke", { Thickness = 4, Color = Color3.new(0, 0, 0) }, shop)
textLabel(shop, { Size = UDim2.new(1, -60, 0, 40), Position = UDim2.fromOffset(12, 8), Text = "SHOP",
	TextXAlignment = Enum.TextXAlignment.Left })
local closeButton = button(shop, "X", Color3.fromRGB(220, 60, 60), { Size = UDim2.fromOffset(40, 40),
	Position = UDim2.new(1, -50, 0, 8) })

local shopRows = {}
local order = { "Sanity", "Carry" }
for i, kind in order do
	local u = Config.Upgrades[kind]
	local y = 60 + (i - 1) * 80
	local name = textLabel(shop, { Size = UDim2.new(0.55, -12, 0, 30), Position = UDim2.fromOffset(12, y),
		TextXAlignment = Enum.TextXAlignment.Left, Text = u.label })
	local info = textLabel(shop, { Size = UDim2.new(0.55, -12, 0, 22), Position = UDim2.fromOffset(12, y + 32),
		TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(200, 200, 220), Text = "" })
	local buy = button(shop, "BUY", Color3.fromRGB(70, 200, 90), { Size = UDim2.new(0.45, -12, 0, 54),
		Position = UDim2.new(0.55, 0, 0, y) })
	shopRows[kind] = { name = name, info = info, buy = buy }
	buy.Activated:Connect(function()
		local ok, msg = BuyUpgrade:InvokeServer(kind)
		toast(msg, if ok then Color3.fromRGB(110, 255, 130) else Color3.fromRGB(255, 90, 90))
	end)
end

local function refreshShop()
	for kind, row in shopRows do
		local u = Config.Upgrades[kind]
		local level = player:GetAttribute(kind .. "Level") or 0
		if level >= u.maxLevel then
			row.info.Text = "Level " .. level .. " (max)"
			row.buy.Text = "MAXED"
		else
			row.info.Text = "Level " .. level .. "  +" .. u.perLevel .. " each"
			row.buy.Text = formatMoney(Config.upgradeCost(kind, level))
		end
	end
end

shopButton.Activated:Connect(function()
	shop.Visible = not shop.Visible
	refreshShop()
end)
closeButton.Activated:Connect(function()
	shop.Visible = false
end)
player:GetAttributeChangedSignal("SanityLevel"):Connect(refreshShop)
player:GetAttributeChangedSignal("CarryLevel"):Connect(refreshShop)

------------------------------------------------------------------ prompts: hide "Steal" on your own creatures, "Sell" on others'
local function filterPrompt(obj)
	if not obj:IsA("ProximityPrompt") then
		return
	end
	local only = obj:GetAttribute("OnlyForUserId")
	local notFor = obj:GetAttribute("NotForUserId")
	if only then
		obj.Enabled = only == player.UserId
	elseif notFor then
		obj.Enabled = notFor ~= player.UserId
	end
end
workspace.DescendantAdded:Connect(filterPrompt)
for _, d in workspace:GetDescendants() do
	filterPrompt(d)
end

------------------------------------------------------------------ getting bonked
KnockEvent.OnClientEvent:Connect(function(velocity)
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then
		return
	end
	hum.PlatformStand = true
	hrp.AssemblyLinearVelocity = velocity
	task.delay(0.8, function()
		hum.PlatformStand = false
	end)
end)

------------------------------------------------------------------ cave mood lighting (only on this player's screen)
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
local surface = {
	ClockTime = Lighting.ClockTime, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
	Brightness = Lighting.Brightness, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, FogColor = Lighting.FogColor,
}
local surfaceAtmo = atmosphere and { Density = atmosphere.Density, Color = atmosphere.Color, Decay = atmosphere.Decay, Haze = atmosphere.Haze }

local function applyLighting(inCave, floor)
	if inCave then
		local tint = Config.Cave.floorColors[floor] or Color3.fromRGB(60, 40, 60)
		Lighting.ClockTime = 0
		Lighting.Brightness = 0.6
		Lighting.Ambient = tint:Lerp(WHITE, 0.25)
		Lighting.OutdoorAmbient = tint
		Lighting.FogColor = tint:Lerp(Color3.new(0, 0, 0), 0.5)
		Lighting.FogStart = 20
		Lighting.FogEnd = 150
		if atmosphere then
			atmosphere.Density = 0.45
			atmosphere.Color = tint
			atmosphere.Decay = tint:Lerp(Color3.new(0, 0, 0), 0.6)
			atmosphere.Haze = 1.5
		end
	else
		for k, v in surface do
			Lighting[k] = v
		end
		if atmosphere and surfaceAtmo then
			for k, v in surfaceAtmo do
				atmosphere[k] = v
			end
		end
	end
end

local lastCave, lastFloor = nil, nil

------------------------------------------------------------------ every frame
RunService.RenderStepped:Connect(function()
	local inCave = player:GetAttribute("InCave") == true
	local floor = player:GetAttribute("Floor") or 0
	if inCave ~= lastCave or floor ~= lastFloor then
		applyLighting(inCave, floor)
		lastCave, lastFloor = inCave, floor
	end

	local ls = player:FindFirstChild("leaderstats")
	local cash = ls and ls:FindFirstChild("Cash")
	cashLabel.Text = formatMoney(if cash then cash.Value else 0)
	incomeLabel.Text = "+" .. formatMoney(player:GetAttribute("Income") or 0) .. "/s"

	local serverNow = workspace:GetServerTimeNow()
	local lockedUntil = player:GetAttribute("LockedUntil") or 0
	local locked = serverNow < lockedUntil
	if locked then
		lockLabel.Text = "Base locked " .. math.ceil(lockedUntil - serverNow) .. "s"
		lockLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
	else
		lockLabel.Text = "Base OPEN to thieves"
		lockLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
	end

	cavePanel.Visible = inCave
	local surging = serverNow < (player:GetAttribute("SurgeUntil") or 0)
	if inCave then
		local sanity = player:GetAttribute("Sanity") or 0
		local max = player:GetAttribute("SanityMax") or 100
		local frac = math.clamp(sanity / max, 0, 1)
		barFill.Size = UDim2.fromScale(frac, 1)
		barFill.BackgroundColor3 = if frac > 0.5 then Color3.fromRGB(110, 230, 120)
			elseif frac > 0.25 then Color3.fromRGB(240, 200, 60) else Color3.fromRGB(235, 60, 60)
		local drain = Config.drainForFloor(floor) * (if surging then Config.Sanity.surgeMultiplier else 1)
		barText.Text = "SANITY " .. math.ceil(sanity) .. "/" .. max .. "   -" .. string.format("%.1f", drain) .. "/s"
		caveInfo.Text = "FLOOR " .. floor .. "/" .. Config.Cave.floors .. "   HANDS " .. (player:GetAttribute("CarryCount") or 0)
			.. "/" .. (player:GetAttribute("CarryMax") or 0) .. (if locked then "" else "   BASE OPEN!")
		-- red creeps in as sanity drops, and pulses near the end
		local pulse = if frac < 0.25 then (math.sin(os.clock() * 8) + 1) * 0.05 else 0
		rotTint.BackgroundTransparency = 1 - math.clamp((0.5 - frac) * 0.5, 0, 0.25) - pulse
	else
		rotTint.BackgroundTransparency = 1
	end
	surgeTint.BackgroundTransparency = if inCave and surging then 0.75 + math.sin(os.clock() * 12) * 0.05 else 1
end)

refreshShop()
