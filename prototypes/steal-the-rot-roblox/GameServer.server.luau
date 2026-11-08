-- PROTOTYPE - NOT FOR PRODUCTION
-- Question: Is "dive deeper for rarer creatures while your base is open to thieves" fun on Roblox?
-- Date: 2026-11-07
--
-- Script (server). In Roblox Studio put it in ServerScriptService and name it: GameServer
-- It builds the whole map by itself: player bases, the Rot Cave entrance and 5 cave floors.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("RotConfig"))
local rng = Random.new()

local RED = Color3.fromRGB(255, 90, 90)
local GREEN = Color3.fromRGB(110, 255, 130)
local ORANGE = Color3.fromRGB(255, 180, 60)
local PURPLE = Color3.fromRGB(200, 120, 255)
local WHITE = Color3.new(1, 1, 1)

------------------------------------------------------------------ remotes
local remotes = Instance.new("Folder")
remotes.Name = "RotRemotes"
local NotifyEvent = Instance.new("RemoteEvent")
NotifyEvent.Name = "Notify"
NotifyEvent.Parent = remotes
local KnockEvent = Instance.new("RemoteEvent")
KnockEvent.Name = "Knockback"
KnockEvent.Parent = remotes
local BuyFunction = Instance.new("RemoteFunction")
BuyFunction.Name = "BuyUpgrade"
BuyFunction.Parent = remotes
remotes.Parent = ReplicatedStorage

local function notify(player, text, color)
	NotifyEvent:FireClient(player, text, color or WHITE)
end

local function announce(text, color)
	NotifyEvent:FireAllClients(text, color or ORANGE)
end

local function now()
	return workspace:GetServerTimeNow()
end

local function formatMoney(n)
	if n >= 1e6 then
		return string.format("$%.1fM", n / 1e6)
	elseif n >= 1e3 then
		return string.format("$%.1fK", n / 1e3)
	end
	return "$" .. tostring(math.floor(n))
end

------------------------------------------------------------------ building helpers
local world = Instance.new("Folder")
world.Name = "RotWorld"
world.Parent = workspace

-- Creates an anchored part from a table of properties. Parent defaults to the RotWorld folder.
local function part(props)
	local className = props.ClassName or "Part"
	local parent = props.Parent or world
	props.ClassName = nil
	props.Parent = nil
	local p = Instance.new(className)
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props do
		p[key] = value
	end
	p.Parent = parent
	return p
end

local function label(parent, text, color, size, position)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = size or UDim2.fromScale(1, 1)
	t.Position = position or UDim2.new()
	t.Font = Enum.Font.FredokaOne
	t.TextScaled = true
	t.TextColor3 = color or WHITE
	t.Text = text
	local s = Instance.new("UIStroke")
	s.Thickness = 2
	s.Color = Color3.new(0, 0, 0)
	s.Parent = t
	t.Parent = parent
	return t
end

local function surfaceSign(onPart, face, text, color)
	local g = Instance.new("SurfaceGui")
	g.Face = face
	g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	g.PixelsPerStud = 30
	g.Parent = onPart
	return label(g, text, color)
end

-- lines = { {text, color}, ... }. Returns the BillboardGui and its TextLabels.
local function billboard(adornee, offsetY, lines, maxDistance)
	local g = Instance.new("BillboardGui")
	g.Size = UDim2.fromOffset(220, 26 * #lines)
	g.StudsOffset = Vector3.new(0, offsetY, 0)
	g.MaxDistance = maxDistance or 90
	g.LightInfluence = 0
	g.Parent = adornee
	local out = {}
	for i, line in lines do
		out[i] = label(g, line[1], line[2], UDim2.new(1, 0, 1 / #lines, 0), UDim2.new(0, 0, (i - 1) / #lines, 0))
	end
	return g, out
end

local function sparkles(parentPart, color, rate)
	local e = Instance.new("ParticleEmitter")
	e.Color = ColorSequence.new(color)
	e.LightEmission = 1
	e.Rate = rate
	e.Lifetime = NumberRange.new(0.8, 1.5)
	e.Speed = NumberRange.new(1, 3)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Size = NumberSequence.new(0.5, 0)
	e.Parent = parentPart
	return e
end

local function makePrompt(parentPart, action, objectText, hold, attributes, key)
	local p = Instance.new("ProximityPrompt")
	p.ActionText = action
	p.ObjectText = objectText
	p.HoldDuration = hold
	p.MaxActivationDistance = 11
	p.RequiresLineOfSight = false
	if key then
		p.KeyboardKeyCode = key
	end
	if attributes then
		for k, v in attributes do
			p:SetAttribute(k, v) -- set before parenting so clients see it immediately
		end
	end
	p.Parent = parentPart
	return p
end

------------------------------------------------------------------ the lobby
local baseplate = workspace:FindFirstChild("Baseplate")
if baseplate and baseplate:IsA("BasePart") then
	baseplate.Color = Color3.fromRGB(110, 200, 90)
	baseplate.Material = Enum.Material.Grass
else
	part({ Name = "RotGround", Size = Vector3.new(700, 4, 700), Position = Vector3.new(0, -2, 0),
		Color = Color3.fromRGB(110, 200, 90), Material = Enum.Material.Grass })
end
local spawnLocation = workspace:FindFirstChildWhichIsA("SpawnLocation")
if spawnLocation then
	spawnLocation.Position = Vector3.new(0, 0.5, 35)
end

-- forward declarations (defined further down)
local onGrab, onSteal, onSell, onLock, onBat, finishDive, enterCave, goDeeper

-- The Rot Cave entrance, in the middle of the map
local entrance = part({ Name = "RotEntrance", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.6, 22, 22),
	CFrame = CFrame.new(0, 0.35, 0) * CFrame.Angles(0, 0, math.rad(90)),
	Color = Color3.fromRGB(15, 5, 25), Material = Enum.Material.SmoothPlastic })
part({ Name = "RotEntranceRing", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.4, 26, 26),
	CFrame = CFrame.new(0, 0.2, 0) * CFrame.Angles(0, 0, math.rad(90)),
	Color = Color3.fromRGB(170, 60, 255), Material = Enum.Material.Neon })
billboard(entrance, 9, { { "ENTER THE ROT", PURPLE }, { "Deeper = rarer creatures", WHITE } }, 250)
sparkles(entrance, Color3.fromRGB(190, 90, 255), 20)
makePrompt(entrance, "Dive", "Rot Cave", 0.5).Triggered:Connect(function(player)
	enterCave(player)
end)

------------------------------------------------------------------ player bases
local PLOT_W, PLOT_D = 64, 56
local PLOT_COLORS = {
	Color3.fromRGB(255, 120, 120), Color3.fromRGB(120, 200, 255), Color3.fromRGB(255, 220, 110),
	Color3.fromRGB(170, 255, 150), Color3.fromRGB(220, 150, 255), Color3.fromRGB(255, 170, 110),
}
local plots = {}

for i = 1, Config.Base.plots do
	local row = if i <= math.ceil(Config.Base.plots / 2) then -1 else 1 -- which side of the map
	local col = ((i - 1) % 3) - 1
	local center = Vector3.new(col * 90, 0, row * 85)
	local color = PLOT_COLORS[((i - 1) % #PLOT_COLORS) + 1]
	local folder = Instance.new("Folder")
	folder.Name = "Plot" .. i
	folder.Parent = world

	part({ Name = "Floor", Size = Vector3.new(PLOT_W, 1, PLOT_D), Position = center + Vector3.new(0, 0.5, 0),
		Color = color, Material = Enum.Material.SmoothPlastic, Parent = folder })

	local wood = Color3.fromRGB(150, 95, 50)
	local backZ = center.Z + row * PLOT_D / 2
	local openZ = center.Z - row * PLOT_D / 2 -- the open side faces the cave entrance
	part({ Name = "Fence", Size = Vector3.new(PLOT_W, 4, 1), Position = Vector3.new(center.X, 3, backZ),
		Color = wood, Material = Enum.Material.WoodPlanks, Parent = folder })
	for side = -1, 1, 2 do
		part({ Name = "Fence", Size = Vector3.new(1, 4, PLOT_D), Position = Vector3.new(center.X + side * PLOT_W / 2, 3, center.Z),
			Color = wood, Material = Enum.Material.WoodPlanks, Parent = folder })
	end

	local board = part({ Name = "Sign", Size = Vector3.new(26, 7, 1), Position = Vector3.new(center.X, 10, backZ),
		Color = Color3.fromRGB(35, 35, 45), Parent = folder })
	part({ Name = "SignPost", Size = Vector3.new(1, 7, 1), Position = Vector3.new(center.X, 4, backZ),
		Color = wood, Material = Enum.Material.Wood, Parent = folder })
	local signLabel = surfaceSign(board, if row == 1 then Enum.NormalId.Front else Enum.NormalId.Back, "Empty plot", WHITE)

	local pedestals = {}
	for r = 0, 1 do
		for k = 1, Config.Base.pedestals / 2 do
			local px = center.X - 24 + (k - 1) * 12
			local pz = center.Z + row * (2 + r * 14)
			local ped = part({ Name = "Pedestal", Size = Vector3.new(7, 1.4, 7), Position = Vector3.new(px, 1.7, pz),
				Color = Color3.fromRGB(240, 240, 245), Parent = folder })
			part({ Name = "PedestalRim", Size = Vector3.new(7.6, 0.4, 7.6), Position = Vector3.new(px, 1.2, pz),
				Color = color, Material = Enum.Material.Neon, Parent = folder })
			table.insert(pedestals, { part = ped, creature = nil })
		end
	end

	local barrier = part({ Name = "LockBarrier", Size = Vector3.new(PLOT_W, 10, 0.6), Position = Vector3.new(center.X, 5.5, openZ),
		Color = Color3.fromRGB(255, 50, 50), Material = Enum.Material.ForceField, Transparency = 1, CanCollide = false, Parent = folder })

	local lockPad = part({ Name = "LockPad", Size = Vector3.new(6, 0.6, 6),
		Position = Vector3.new(center.X + 24, 1.3, center.Z - row * (PLOT_D / 2 - 6)),
		Color = Color3.fromRGB(230, 60, 60), Material = Enum.Material.Neon, Parent = folder })
	billboard(lockPad, 3, { { "LOCK BASE", RED } }, 60)

	local homePos = Vector3.new(center.X, 4, center.Z - row * (PLOT_D / 2 - 10))
	local plot = {
		index = i, center = center, row = row, owner = nil, pedestals = pedestals,
		signLabel = signLabel, barrier = barrier,
		home = CFrame.lookAt(homePos, homePos + Vector3.new(0, 0, row)),
	}
	makePrompt(lockPad, "Lock base", Config.Base.lockSeconds .. " seconds", 0.3).Triggered:Connect(function(player)
		onLock(player, plot)
	end)
	plots[i] = plot
end

------------------------------------------------------------------ the Rot Cave (5 floors deep underground)
local C = Config.Cave
local HALF = C.roomSize / 2
local floors = {}

for f = 1, C.floors do
	local y = C.firstFloorY - (f - 1) * C.depthStep
	local folder = Instance.new("Folder")
	folder.Name = "CaveFloor" .. f
	folder.Parent = world
	local tint = C.floorColors[f] or C.floorColors[#C.floorColors]

	part({ Name = "Ground", Size = Vector3.new(C.roomSize, 4, C.roomSize), Position = Vector3.new(0, y - 2, 0),
		Color = tint, Material = Enum.Material.Slate, Parent = folder })
	part({ Name = "Ceiling", Size = Vector3.new(C.roomSize + 8, 4, C.roomSize + 8), Position = Vector3.new(0, y + 42, 0),
		Color = tint:Lerp(Color3.new(0, 0, 0), 0.6), Material = Enum.Material.Rock, Parent = folder })
	for side = -1, 1, 2 do
		part({ Name = "Wall", Size = Vector3.new(C.roomSize + 8, 44, 4), Position = Vector3.new(0, y + 20, side * (HALF + 2)),
			Color = tint:Lerp(Color3.new(0, 0, 0), 0.4), Material = Enum.Material.Rock, Parent = folder })
		part({ Name = "Wall", Size = Vector3.new(4, 44, C.roomSize + 8), Position = Vector3.new(side * (HALF + 2), y + 20, 0),
			Color = tint:Lerp(Color3.new(0, 0, 0), 0.4), Material = Enum.Material.Rock, Parent = folder })
	end
	-- glowing crystals for light and mood; more and weirder the deeper you go
	for _ = 1, 6 + f * 2 do
		local h = rng:NextNumber(4, 10)
		local crystalColor = Color3.fromHSV(rng:NextNumber(), 0.7, 1)
		local cx = rng:NextNumber(-HALF + 4, HALF - 4)
		local cz = if rng:NextNumber() < 0.5 then -HALF + 4 else HALF - 4
		if rng:NextNumber() < 0.5 then
			cx, cz = cz, cx
		end
		local crystal = part({ Name = "Crystal", Size = Vector3.new(2, h, 2),
			CFrame = CFrame.new(cx, y + h / 2, cz) * CFrame.Angles(0, rng:NextNumber(0, 3), math.rad(rng:NextNumber(-20, 20))),
			Color = crystalColor, Material = Enum.Material.Neon, Parent = folder })
		local light = Instance.new("PointLight")
		light.Color = crystalColor
		light.Range = 28
		light.Brightness = 1.5
		light.Parent = crystal
	end

	-- climb rope (back to your base)
	local ropeBase = Vector3.new(0, y, -HALF + 10)
	part({ Name = "Rope", Shape = Enum.PartType.Cylinder, Size = Vector3.new(42, 1.4, 1.4),
		CFrame = CFrame.new(ropeBase + Vector3.new(0, 21, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(255, 170, 60), Material = Enum.Material.Fabric, Parent = folder })
	local climbPad = part({ Name = "ClimbPad", Size = Vector3.new(9, 0.6, 9), Position = ropeBase + Vector3.new(0, 0.3, 0),
		Color = Color3.fromRGB(255, 170, 60), Material = Enum.Material.Neon, Parent = folder })
	billboard(climbPad, 5, { { "CLIMB OUT", ORANGE }, { "Floor " .. f, WHITE } }, 120)

	-- the hole to the next floor
	local holePos = Vector3.new(0, y, HALF - 16)
	part({ Name = "HoleRing", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.4, 18, 18),
		CFrame = CFrame.new(holePos + Vector3.new(0, 0.2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(255, 40, 60), Material = Enum.Material.Neon, Parent = folder })
	local hole = part({ Name = "Hole", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.6, 15, 15),
		CFrame = CFrame.new(holePos + Vector3.new(0, 0.3, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.new(0, 0, 0), Parent = folder })
	local lastFloor = f >= C.floors
	billboard(hole, 5, { { if lastFloor then "THE BOTTOM" else "GO DEEPER", RED },
		{ if lastFloor then "coming soon..." else "Floor " .. (f + 1) .. ": rarer, faster rot", WHITE } }, 120)

	local spawnPos = Vector3.new(0, y + 4, -HALF + 20)
	local fl = {
		index = f, y = y, creatures = {},
		spawn = CFrame.lookAt(spawnPos, spawnPos + Vector3.new(0, 0, 1)),
		minX = -HALF + 8, maxX = HALF - 8, minZ = -HALF + 28, maxZ = HALF - 30,
	}
	local climbPrompt = makePrompt(climbPad, "Climb out", "Back to your base", 0.3)
	climbPrompt.Triggered:Connect(function(player)
		finishDive(player, false, f)
	end)
	local deeperPrompt = makePrompt(hole, if lastFloor then "The Bottom" else "Go deeper",
		if lastFloor then "coming soon" else "Floor " .. (f + 1), 0.3)
	deeperPrompt.Triggered:Connect(function(player)
		goDeeper(player, f)
	end)
	floors[f] = fl
end

------------------------------------------------------------------ creatures
local defsByRarity = {}
for _, def in Config.Creatures do
	defsByRarity[def.rarity] = defsByRarity[def.rarity] or {}
	table.insert(defsByRarity[def.rarity], def)
end

local function pickRarity(floorIndex)
	local weights = Config.FloorWeights[floorIndex]
	local total = 0
	for _, w in weights do
		total += w
	end
	local roll = rng:NextNumber() * total
	for i, w in weights do
		roll -= w
		if roll < 0 and defsByRarity[i] then
			return i
		end
	end
	return 1
end

local function buildCreature(def)
	local rarity = Config.Rarities[def.rarity]
	local s = rarity.size
	local model = Instance.new("Model")
	model.Name = def.name
	local body = part({ Name = "Body", Shape = Enum.PartType.Ball, Size = Vector3.one * s, Color = def.body,
		Material = Enum.Material.SmoothPlastic, CanCollide = false, Massless = true, Parent = model })
	model.PrimaryPart = body
	local cf = body.CFrame

	for side = -1, 1, 2 do
		local eye = part({ Name = "Eye", Shape = Enum.PartType.Ball, Size = Vector3.one * (s * 0.34), Color = WHITE,
			CFrame = cf * CFrame.new(side * s * 0.2, s * 0.14, -s * 0.36), CanCollide = false, Massless = true, Parent = model })
		part({ Name = "Pupil", Shape = Enum.PartType.Ball, Size = Vector3.one * (s * 0.16), Color = Color3.new(0, 0, 0),
			CFrame = eye.CFrame * CFrame.new(0, 0, -s * 0.12), CanCollide = false, Massless = true, Parent = model })
	end
	part({ Name = "Mouth", Size = Vector3.new(s * 0.36, s * 0.08, 0.2), Color = Color3.fromRGB(60, 10, 20),
		CFrame = cf * CFrame.new(0, -s * 0.16, -s * 0.47), CanCollide = false, Massless = true, Parent = model })

	local feat = def.feature
	if feat then
		local rot = feat.rotate or Vector3.zero
		local props = {
			Name = "Feature", Size = feat.size * (s / 3), Color = feat.color,
			Material = if feat.neon then Enum.Material.Neon else Enum.Material.SmoothPlastic,
			CFrame = cf * CFrame.new(feat.offset * (s / 3)) * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z)),
			CanCollide = false, Massless = true, Parent = model,
		}
		if feat.shape == "Wedge" then
			props.ClassName = "WedgePart"
		elseif feat.shape == "Ball" then
			props.Shape = Enum.PartType.Ball
		elseif feat.shape == "Cylinder" then
			props.Shape = Enum.PartType.Cylinder
		end
		part(props)
	end

	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") and p ~= body then
			local w = Instance.new("WeldConstraint")
			w.Part0 = body
			w.Part1 = p
			w.Parent = body
		end
	end

	if rarity.glow then
		local light = Instance.new("PointLight")
		light.Color = rarity.color
		light.Range = 14
		light.Brightness = 2
		light.Parent = body
		sparkles(body, rarity.color, 8)
	end

	billboard(body, s / 2 + 2.2, {
		{ def.name, WHITE },
		{ rarity.name, rarity.color },
		{ formatMoney(def.income) .. "/s", Color3.fromRGB(120, 255, 120) },
	})

	model.Parent = world
	return { def = def, rarity = rarity, model = model, body = body, size = s, state = "new", seed = rng:NextNumber() * 10 }
end

local function clearPrompts(c)
	for _, p in c.body:GetChildren() do
		if p:IsA("ProximityPrompt") then
			p:Destroy()
		end
	end
end

local function creatureTitle(c)
	return c.def.name .. " (" .. c.rarity.name .. ")"
end

local function anchorModel(c, anchored)
	for _, p in c.model:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored = anchored
		end
	end
end

local function detach(c)
	local w = c.body:FindFirstChild("CarryWeld")
	if w then
		w:Destroy()
	end
	anchorModel(c, true)
end

-- Sticks a creature above the player's head. stackIndex 1 = lowest.
local function attachToPlayer(c, player, stackIndex)
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return false
	end
	c.model:PivotTo(hrp.CFrame * CFrame.new(0, 3.4 + c.size / 2 + (stackIndex - 1) * 4.8, 0))
	local w = Instance.new("WeldConstraint")
	w.Name = "CarryWeld"
	w.Part0 = hrp
	w.Part1 = c.body
	w.Parent = c.body
	anchorModel(c, false)
	return true
end

local function randomFloorPos(fl)
	return Vector3.new(rng:NextNumber(fl.minX, fl.maxX), fl.y, rng:NextNumber(fl.minZ, fl.maxZ))
end

local function poseWild(c, t)
	local bob = math.abs(math.sin(t * 4 + c.seed)) * 0.8
	local at = c.pos + Vector3.new(0, c.size / 2 + 0.2 + bob, 0)
	c.model:PivotTo(CFrame.lookAt(at, at + c.facing))
end

local function makeWild(c, fl, pos)
	detach(c)
	c.state = "wild"
	c.floor = fl.index
	c.owner = nil
	c.pedestal = nil
	c.stolenFrom = nil
	c.pos = Vector3.new(math.clamp(pos.X, fl.minX, fl.maxX), fl.y, math.clamp(pos.Z, fl.minZ, fl.maxZ))
	c.target = randomFloorPos(fl)
	c.facing = Vector3.new(0, 0, 1)
	clearPrompts(c)
	makePrompt(c.body, "Grab", creatureTitle(c), c.rarity.holdTime).Triggered:Connect(function(player)
		onGrab(player, c)
	end)
	table.insert(fl.creatures, c)
	poseWild(c, os.clock())
end

local function fillFloor(fl)
	while #fl.creatures < C.creaturesPerFloor do
		local list = defsByRarity[pickRarity(fl.index)]
		local def = list[rng:NextInteger(1, #list)]
		makeWild(buildCreature(def), fl, randomFloorPos(fl))
	end
end

-- Wild creatures wander; anything rarer than Common runs from nearby players.
local function stepWild(fl, dt, t, hrps)
	for _, c in fl.creatures do
		local speed = 3
		local dir = nil
		if c.rarity.fleeSpeed > 0 then
			for _, hrp in hrps do
				local away = c.pos - Vector3.new(hrp.Position.X, c.pos.Y, hrp.Position.Z)
				if away.Magnitude < 16 and away.Magnitude > 0.01 then
					dir = away.Unit
					speed = c.rarity.fleeSpeed
					break
				end
			end
		end
		if not dir then
			local to = c.target - c.pos
			if to.Magnitude < 2 then
				c.target = randomFloorPos(fl)
				to = c.target - c.pos
			end
			dir = if to.Magnitude > 0.01 then to.Unit else Vector3.new(0, 0, 1)
		end
		local np = c.pos + dir * speed * dt
		c.pos = Vector3.new(math.clamp(np.X, fl.minX, fl.maxX), fl.y, math.clamp(np.Z, fl.minZ, fl.maxZ))
		c.facing = dir
		poseWild(c, t)
	end
end

------------------------------------------------------------------ player state
local state = {} -- [Player] = per-player table, created in onPlayerAdded

local function cashValue(player)
	local ls = player:FindFirstChild("leaderstats")
	return ls and ls:FindFirstChild("Cash")
end

local function addCash(player, amount)
	local cash = cashValue(player)
	if cash then
		cash.Value += math.floor(amount)
	end
end

local function refreshAttrs(player)
	local st = state[player]
	if not st then
		return
	end
	player:SetAttribute("InCave", st.inCave)
	player:SetAttribute("Floor", st.floor)
	player:SetAttribute("Sanity", st.sanity)
	player:SetAttribute("SanityMax", st.sanityMax)
	player:SetAttribute("CarryCount", #st.carried)
	player:SetAttribute("CarryMax", st.carryLimit)
	player:SetAttribute("LockedUntil", st.lockedUntil)
	player:SetAttribute("SanityLevel", st.upgrades.Sanity)
	player:SetAttribute("CarryLevel", st.upgrades.Carry)
end

local function updateIncome(player)
	local st = player and state[player]
	if not st or not st.plot then
		return
	end
	local total = 0
	for _, ped in st.plot.pedestals do
		if ped.creature then
			total += ped.creature.def.income
		end
	end
	player:SetAttribute("Income", total)
end

local function teleport(player, cf)
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		-- New places stream the map in pieces; load the destination first so nobody falls into the void.
		pcall(function()
			player:RequestStreamAroundAsync(cf.Position, 2)
		end)
		char:PivotTo(cf)
	end
end

local function setWalkSpeed(player, speed)
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = speed
	end
end

local function freePedestal(plot)
	for _, ped in plot.pedestals do
		if not ped.creature then
			return ped
		end
	end
	return nil
end

local function removeFromPedestal(c)
	if c.pedestal then
		c.pedestal.creature = nil
		c.pedestal = nil
		updateIncome(c.owner)
	end
end

local function placeOnPedestal(c, player, ped)
	detach(c)
	c.state = "placed"
	c.owner = player
	c.pedestal = ped
	c.floor = nil
	ped.creature = c
	local plot = state[player].plot
	local top = ped.part.Position + Vector3.new(0, ped.part.Size.Y / 2 + c.size / 2 + 0.1, 0)
	c.model:PivotTo(CFrame.lookAt(top, top - Vector3.new(0, 0, plot.row)))
	clearPrompts(c)
	-- Both prompts exist on the server; each player's screen script hides the one that isn't for them.
	local stealPrompt = makePrompt(c.body, "Steal", creatureTitle(c), Config.Base.stealHoldTime, { NotForUserId = player.UserId })
	stealPrompt.Triggered:Connect(function(p)
		onSteal(p, c)
	end)
	local sellText = "Sell " .. formatMoney(c.def.income * Config.Base.sellMultiplier)
	local sellPrompt = makePrompt(c.body, sellText, creatureTitle(c), 1, { OnlyForUserId = player.UserId }, Enum.KeyCode.F)
	sellPrompt.Triggered:Connect(function(p)
		onSell(p, c)
	end)
	updateIncome(player)
end

-- Puts a creature on the player's base, or auto-sells it if the base is full.
local function bringHome(player, c)
	local st = state[player]
	local ped = st and st.plot and freePedestal(st.plot)
	if ped then
		placeOnPedestal(c, player, ped)
		return true
	end
	local pay = c.def.income * Config.Base.overflowSellMultiplier
	addCash(player, pay)
	notify(player, "Base full! Sold " .. c.def.name .. " for " .. formatMoney(pay), ORANGE)
	c.state = "gone"
	c.model:Destroy()
	return false
end

local function returnStolen(c, thief)
	local tst = state[thief]
	if tst and tst.stolen == c then
		tst.stolen = nil
	end
	setWalkSpeed(thief, 16)
	local owner = c.stolenFrom
	c.stolenFrom = nil
	local ost = owner and state[owner]
	local ped = ost and ost.plot and freePedestal(ost.plot)
	if ped then
		placeOnPedestal(c, owner, ped)
	else
		c.state = "gone"
		c.model:Destroy()
	end
end

------------------------------------------------------------------ actions
enterCave = function(player)
	local st = state[player]
	if not st or st.inCave then
		return
	end
	if st.stolen then
		notify(player, "Bring your stolen creature home first!", RED)
		return
	end
	st.inCave = true
	st.floor = 1
	st.sanity = st.sanityMax
	st.surgeUntil = 0
	teleport(player, floors[1].spawn)
	refreshAttrs(player)
	if now() >= st.lockedUntil then
		notify(player, "Your base is UNGUARDED while you dive!", ORANGE)
	end
end

goDeeper = function(player, fromFloor)
	local st = state[player]
	if not st or not st.inCave or st.floor ~= fromFloor then
		return
	end
	if fromFloor >= C.floors then
		notify(player, "The Bottom is coming soon...", PURPLE)
		return
	end
	st.floor = fromFloor + 1
	teleport(player, floors[st.floor].spawn)
	refreshAttrs(player)
	notify(player, "FLOOR " .. st.floor .. ": rarer creatures, faster rot", PURPLE)
end

-- Ends a dive. rotted = Sanity hit 0 (you keep only your rarest creature).
finishDive = function(player, rotted, fromFloor)
	local st = state[player]
	if not st or not st.inCave then
		return
	end
	if fromFloor and st.floor ~= fromFloor then
		return
	end
	st.inCave = false
	st.floor = 0
	local kept = st.carried
	st.carried = {}
	if rotted then
		local best = nil
		for _, c in kept do
			if not best or c.def.income > best.def.income then
				best = c
			end
		end
		for _, c in kept do
			if c ~= best then
				c.state = "gone"
				c.model:Destroy()
			end
		end
		kept = if best then { best } else {}
		notify(player, if best then "Your brain ROTTED! You kept only your " .. best.def.name
			else "Your brain ROTTED! You lost everything.", RED)
	elseif #kept > 0 then
		notify(player, "Brought home " .. #kept .. " creature" .. (if #kept == 1 then "" else "s") .. "!", GREEN)
	end
	for _, c in kept do
		bringHome(player, c)
	end
	teleport(player, if st.plot then st.plot.home else CFrame.new(0, 5, 35))
	refreshAttrs(player)
end

onGrab = function(player, c)
	local st = state[player]
	if not st or not st.inCave or c.state ~= "wild" or st.floor ~= c.floor then
		return
	end
	if #st.carried >= st.carryLimit then
		notify(player, "Hands full! Climb out, or buy a Carry Slot.", RED)
		return
	end
	local fl = floors[c.floor]
	local i = table.find(fl.creatures, c)
	if i then
		table.remove(fl.creatures, i)
	end
	clearPrompts(c)
	c.state = "carried"
	c.owner = player
	table.insert(st.carried, c)
	if not attachToPlayer(c, player, #st.carried) then
		table.remove(st.carried)
		makeWild(c, fl, c.pos)
		return
	end
	refreshAttrs(player)
	notify(player, "Got " .. creatureTitle(c) .. "!", c.rarity.color)
	if c.def.rarity >= 4 then
		announce(player.DisplayName .. " grabbed a " .. c.rarity.name .. " " .. c.def.name .. " on floor " .. c.floor .. "!", c.rarity.color)
	end
end

onSteal = function(thief, c)
	local tst = state[thief]
	local owner = c.owner
	if c.state ~= "placed" or not tst or owner == thief or tst.inCave or tst.stolen then
		return
	end
	if not tst.plot then
		notify(thief, "You need a base to steal into!", RED)
		return
	end
	local ost = owner and state[owner]
	if ost and now() < ost.lockedUntil then
		notify(thief, "This base is LOCKED for " .. math.ceil(ost.lockedUntil - now()) .. "s", RED)
		return
	end
	removeFromPedestal(c)
	clearPrompts(c)
	c.state = "stolen"
	c.stolenFrom = owner
	c.owner = thief
	if not attachToPlayer(c, thief, 1) then
		returnStolen(c, thief)
		return
	end
	tst.stolen = c
	setWalkSpeed(thief, 12)
	notify(thief, "Run it back to YOUR base!", ORANGE)
	if owner then
		notify(owner, thief.DisplayName .. " is stealing your " .. c.def.name .. "! Bonk them!", RED)
	end
end

onSell = function(player, c)
	if c.state ~= "placed" or c.owner ~= player then
		return
	end
	local pay = c.def.income * Config.Base.sellMultiplier
	removeFromPedestal(c)
	c.state = "gone"
	c.model:Destroy()
	addCash(player, pay)
	notify(player, "Sold " .. c.def.name .. " for " .. formatMoney(pay), GREEN)
end

onLock = function(player, plot)
	local st = state[player]
	if not st or plot.owner ~= player then
		notify(player, "That's not your base!", RED)
		return
	end
	local t = now()
	if t < st.lockedUntil then
		notify(player, "Already locked", ORANGE)
		return
	end
	local ready = st.lockStarted + Config.Base.lockCooldownSeconds
	if t < ready then
		notify(player, "Lock recharging: " .. math.ceil(ready - t) .. "s", RED)
		return
	end
	st.lockStarted = t
	st.lockedUntil = t + Config.Base.lockSeconds
	plot.barrier.Transparency = 0.4
	refreshAttrs(player)
	notify(player, "Base LOCKED for " .. Config.Base.lockSeconds .. "s", GREEN)
	local thisLock = st.lockedUntil
	task.delay(Config.Base.lockSeconds, function()
		if state[player] == st and st.lockedUntil == thisLock then
			plot.barrier.Transparency = 1
			notify(player, "Your base is UNLOCKED", ORANGE)
		end
	end)
end

local SWING = { Vector3.new(0, 0, 1), Vector3.new(0, -1, 0), Vector3.new(-1, 0, 0) } -- forward, right, up
local HOLD = { Vector3.new(-1, 0, 0), Vector3.new(0, 1, 0), Vector3.new(0, 0, 1) }

local function setGrip(tool, g)
	tool.GripForward = g[1]
	tool.GripRight = g[2]
	tool.GripUp = g[3]
end

onBat = function(player, tool, sound)
	local st = state[player]
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not st or not hrp then
		return
	end
	local t = os.clock()
	if t - st.lastBat < Config.Bat.cooldown then
		return
	end
	st.lastBat = t
	sound:Play()
	setGrip(tool, SWING)
	task.delay(0.25, function()
		setGrip(tool, HOLD)
	end)
	for other, ost in state do
		local ohrp = other ~= player and other.Character and other.Character:FindFirstChild("HumanoidRootPart")
		if ohrp then
			local offset = ohrp.Position - hrp.Position
			local flat = Vector3.new(offset.X, 0, offset.Z)
			if flat.Magnitude <= Config.Bat.range and flat.Magnitude > 0.01 and math.abs(offset.Y) < 8
				and hrp.CFrame.LookVector:Dot(flat.Unit) > 0.2 then
				KnockEvent:FireClient(other, flat.Unit * Config.Bat.knockback + Vector3.new(0, 35, 0))
				if ost.stolen then
					local c = ost.stolen
					returnStolen(c, other)
					notify(player, "BONK! " .. c.def.name .. " goes back home!", GREEN)
					notify(other, "BONKED! You dropped the " .. c.def.name, RED)
				elseif ost.inCave and #ost.carried > 0 then
					local c = table.remove(ost.carried)
					makeWild(c, floors[ost.floor], ohrp.Position)
					refreshAttrs(other)
					notify(other, "BONKED! You dropped your " .. c.def.name, RED)
					notify(player, "BONK! " .. other.DisplayName .. " dropped a " .. c.def.name .. ". Grab it!", ORANGE)
				else
					notify(other, "BONKED by " .. player.DisplayName .. "!", ORANGE)
				end
			end
		end
	end
end

local function giveBat(player)
	local backpack = player:FindFirstChild("Backpack")
	if not backpack or backpack:FindFirstChild("Bonk Bat") then
		return
	end
	local tool = Instance.new("Tool")
	tool.Name = "Bonk Bat"
	tool.CanBeDropped = false
	tool.ToolTip = "Bonk thieves to get your creature back"
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.8, 0.8, 4.5)
	handle.Color = Color3.fromRGB(170, 110, 60)
	handle.Material = Enum.Material.Wood
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool
	tool.GripPos = Vector3.new(0, 0, -1.6)
	setGrip(tool, HOLD)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxasset://sounds/swordslash.wav"
	sound.Volume = 0.6
	sound.Parent = handle
	tool.Activated:Connect(function()
		onBat(player, tool, sound)
	end)
	tool.Parent = backpack
end

------------------------------------------------------------------ upgrades (Shop button on screen)
BuyFunction.OnServerInvoke = function(player, kind)
	local st = state[player]
	local u = type(kind) == "string" and Config.Upgrades[kind]
	if not st or not u then
		return false, "Unknown upgrade"
	end
	local level = st.upgrades[kind]
	if level >= u.maxLevel then
		return false, u.label .. " is maxed"
	end
	local cost = Config.upgradeCost(kind, level)
	local cash = cashValue(player)
	if not cash or cash.Value < cost then
		return false, "Need " .. formatMoney(cost)
	end
	cash.Value -= cost
	st.upgrades[kind] = level + 1
	if kind == "Sanity" then
		st.sanityMax += u.perLevel
	else
		st.carryLimit += u.perLevel
	end
	refreshAttrs(player)
	return true, u.label .. " upgraded!"
end

------------------------------------------------------------------ players joining and leaving
local function onCharacter(player, char)
	local st = state[player]
	local hrp = char:WaitForChild("HumanoidRootPart", 10)
	local hum = char:WaitForChild("Humanoid", 10)
	if not st or not hrp or not hum then
		return
	end
	task.wait(0.2)
	if st.plot then
		char:PivotTo(st.plot.home)
	end
	giveBat(player)
	hum.Died:Connect(function()
		if state[player] ~= st then
			return
		end
		for _, c in st.carried do
			c.state = "gone"
			c.model:Destroy()
		end
		st.carried = {}
		st.inCave = false
		st.floor = 0
		if st.stolen then
			returnStolen(st.stolen, player)
		end
		refreshAttrs(player)
	end)
end

local function onPlayerAdded(player)
	if state[player] then
		return
	end
	local ls = Instance.new("Folder")
	ls.Name = "leaderstats"
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 0
	cash.Parent = ls
	ls.Parent = player

	local st = {
		plot = nil, inCave = false, floor = 0,
		sanity = Config.Sanity.max, sanityMax = Config.Sanity.max,
		carryLimit = Config.Carry.baseLimit, carried = {}, stolen = nil,
		surgeUntil = 0, lockedUntil = 0, lockStarted = -math.huge,
		upgrades = { Sanity = 0, Carry = 0 }, lastBat = 0,
	}
	for _, plot in plots do
		if not plot.owner then
			plot.owner = player
			st.plot = plot
			plot.signLabel.Text = player.DisplayName .. "'s Base"
			break
		end
	end
	state[player] = st
	refreshAttrs(player)
	player:SetAttribute("Income", 0)
	if not st.plot then
		task.delay(3, function()
			notify(player, "No free base on this server. Creatures you bring up are auto-sold.", ORANGE)
		end)
	end
	player.CharacterAdded:Connect(function(char)
		onCharacter(player, char)
	end)
	if player.Character then
		task.spawn(onCharacter, player, player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, p in Players:GetPlayers() do
	task.spawn(onPlayerAdded, p)
end

Players.PlayerRemoving:Connect(function(player)
	local st = state[player]
	if not st then
		return
	end
	if st.stolen then
		returnStolen(st.stolen, player)
	end
	for _, c in st.carried do
		c.state = "gone"
		c.model:Destroy()
	end
	for _, other in state do
		if other.stolen and other.stolen.stolenFrom == player then
			other.stolen.stolenFrom = nil
		end
	end
	if st.plot then
		for _, ped in st.plot.pedestals do
			if ped.creature then
				ped.creature.state = "gone"
				ped.creature.model:Destroy()
				ped.creature = nil
			end
		end
		st.plot.owner = nil
		st.plot.signLabel.Text = "Empty plot"
		st.plot.barrier.Transparency = 1
	end
	state[player] = nil
end)

------------------------------------------------------------------ game loops
for _, fl in floors do
	fillFloor(fl)
end

-- wild creatures move every frame so they look smooth
local caveHrps = {} -- [floorIndex] = { HumanoidRootPart }, rebuilt by the slow loop below
RunService.Heartbeat:Connect(function(dt)
	local t = os.clock()
	for f, fl in floors do
		stepWild(fl, dt, t, caveHrps[f] or {})
	end
end)

local function insidePlot(plot, pos)
	return math.abs(pos.X - plot.center.X) <= PLOT_W / 2 and math.abs(pos.Z - plot.center.Z) <= PLOT_D / 2 and pos.Y > -20
end

-- Sanity drain, rot surges, thieves reaching home, income and respawns: 10 times a second.
local last = os.clock()
local incomeTimer, respawnTimer = 0, 0
while true do
	task.wait(0.1)
	local t = os.clock()
	local dt = t - last
	last = t
	local serverNow = now()
	local hrpsByFloor = {}

	for player, st in state do
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if st.inCave then
			if hrp then
				hrpsByFloor[st.floor] = hrpsByFloor[st.floor] or {}
				table.insert(hrpsByFloor[st.floor], hrp)
			end
			local S = Config.Sanity
			if st.floor >= S.surgeFromFloor and serverNow >= st.surgeUntil and rng:NextNumber() < S.surgeChancePerSecond * dt then
				st.surgeUntil = serverNow + S.surgeSeconds
				player:SetAttribute("SurgeUntil", st.surgeUntil)
				notify(player, "ROT SURGE!", PURPLE)
			end
			local mult = if serverNow < st.surgeUntil then S.surgeMultiplier else 1
			st.sanity -= Config.drainForFloor(st.floor) * mult * dt
			if st.sanity <= 0 then
				st.sanity = 0
				task.spawn(finishDive, player, true) -- teleport may wait for streaming; don't stall this loop
			else
				player:SetAttribute("Sanity", st.sanity)
			end
		elseif st.stolen and st.plot and hrp and insidePlot(st.plot, hrp.Position) then
			local c = st.stolen
			local victim = c.stolenFrom
			st.stolen = nil
			c.stolenFrom = nil
			setWalkSpeed(player, 16)
			if bringHome(player, c) then
				announce(player.DisplayName .. " stole " .. c.def.name .. (if victim then " from " .. victim.DisplayName else "") .. "!", ORANGE)
			end
		end
	end
	caveHrps = hrpsByFloor

	incomeTimer += dt
	if incomeTimer >= 1 then
		incomeTimer -= 1
		for player in state do
			addCash(player, player:GetAttribute("Income") or 0)
		end
	end

	respawnTimer += dt
	if respawnTimer >= C.respawnSeconds then
		respawnTimer = 0
		for _, fl in floors do
			fillFloor(fl)
		end
	end
end
