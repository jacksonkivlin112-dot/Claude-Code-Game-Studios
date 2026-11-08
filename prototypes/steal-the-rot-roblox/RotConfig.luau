-- PROTOTYPE - NOT FOR PRODUCTION
-- Question: Is "dive deeper for rarer creatures while your base is open to thieves" fun on Roblox?
-- Date: 2026-11-07
--
-- ModuleScript. In Roblox Studio put it in ReplicatedStorage and name it exactly: RotConfig
-- Every gameplay number lives here, so balance changes never touch the game scripts.

local Config = {}

-- Rarity tiers. income is $ per second while the creature sits on a base pedestal.
-- holdTime = seconds you must hold the Grab prompt. fleeSpeed = studs/sec it runs from players
-- (player walk speed is 16, so every tier can be caught).
Config.Rarities = {
	{ name = "Common", color = Color3.fromRGB(190, 196, 205), size = 3.0, holdTime = 0.4, fleeSpeed = 0, glow = false },
	{ name = "Rare", color = Color3.fromRGB(70, 170, 255), size = 3.6, holdTime = 0.8, fleeSpeed = 7, glow = false },
	{ name = "Epic", color = Color3.fromRGB(200, 90, 255), size = 4.2, holdTime = 1.3, fleeSpeed = 9, glow = true },
	{ name = "Mythic", color = Color3.fromRGB(255, 200, 40), size = 5.0, holdTime = 1.8, fleeSpeed = 11, glow = true },
	{ name = "Secret", color = Color3.fromRGB(255, 60, 110), size = 6.0, holdTime = 2.5, fleeSpeed = 13, glow = true },
}

-- Original creatures. rarity = index into Config.Rarities.
-- feature = one extra part that gives each creature its silhouette.
Config.Creatures = {
	{ name = "Sockodile", rarity = 1, income = 2, body = Color3.fromRGB(90, 160, 80),
		feature = { shape = "Block", size = Vector3.new(1.2, 0.5, 2.4), color = Color3.fromRGB(240, 240, 240), offset = Vector3.new(0, -0.3, -1.6) } },
	{ name = "Bread Mandrill", rarity = 1, income = 3, body = Color3.fromRGB(214, 160, 90),
		feature = { shape = "Block", size = Vector3.new(2.6, 0.6, 2.6), color = Color3.fromRGB(150, 95, 45), offset = Vector3.new(0, 1.6, 0) } },
	{ name = "Lampwhale", rarity = 1, income = 2, body = Color3.fromRGB(80, 110, 200),
		feature = { shape = "Ball", size = Vector3.new(1, 1, 1), color = Color3.fromRGB(255, 240, 150), offset = Vector3.new(0, 2.2, 0), neon = true } },
	{ name = "Mopgoblin", rarity = 1, income = 3, body = Color3.fromRGB(120, 200, 120),
		feature = { shape = "Cylinder", size = Vector3.new(3, 0.4, 0.4), color = Color3.fromRGB(120, 80, 40), offset = Vector3.new(1.8, 0, 0) } },
	{ name = "Toastrich", rarity = 2, income = 10, body = Color3.fromRGB(230, 190, 120),
		feature = { shape = "Cylinder", size = Vector3.new(2.6, 0.5, 0.5), color = Color3.fromRGB(240, 150, 60), offset = Vector3.new(0, 2.2, 0), rotate = Vector3.new(0, 0, 90) } },
	{ name = "Cappuccino Squid", rarity = 2, income = 12, body = Color3.fromRGB(150, 100, 70),
		feature = { shape = "Ball", size = Vector3.new(2.6, 1, 2.6), color = Color3.fromRGB(250, 245, 235), offset = Vector3.new(0, 1.7, 0) } },
	{ name = "Sir Spoonathan", rarity = 2, income = 9, body = Color3.fromRGB(200, 205, 215),
		feature = { shape = "Block", size = Vector3.new(0.4, 3, 0.4), color = Color3.fromRGB(170, 175, 185), offset = Vector3.new(-1.9, 0.5, 0) } },
	{ name = "Ballerina Cactus", rarity = 3, income = 45, body = Color3.fromRGB(60, 170, 90),
		feature = { shape = "Cylinder", size = Vector3.new(0.3, 4, 4), color = Color3.fromRGB(255, 150, 200), offset = Vector3.new(0, -1.2, 0), rotate = Vector3.new(0, 0, 90) } },
	{ name = "Sharkuterie", rarity = 3, income = 55, body = Color3.fromRGB(120, 130, 150),
		feature = { shape = "Wedge", size = Vector3.new(0.4, 2, 2), color = Color3.fromRGB(110, 120, 140), offset = Vector3.new(0, 2.6, 0) } },
	{ name = "Disco Moth Supreme", rarity = 3, income = 50, body = Color3.fromRGB(170, 120, 230),
		feature = { shape = "Block", size = Vector3.new(6, 2.4, 0.3), color = Color3.fromRGB(240, 230, 255), offset = Vector3.new(0, 0.6, 1.4), neon = true } },
	{ name = "Glitchapus Rex", rarity = 4, income = 220, body = Color3.fromRGB(60, 230, 200),
		feature = { shape = "Block", size = Vector3.new(4, 0.6, 4), color = Color3.fromRGB(255, 0, 140), offset = Vector3.new(0, -2.4, 0), neon = true } },
	{ name = "Eternal Microwave", rarity = 4, income = 260, body = Color3.fromRGB(230, 230, 235),
		feature = { shape = "Block", size = Vector3.new(2.4, 1.6, 0.3), color = Color3.fromRGB(255, 220, 90), offset = Vector3.new(0, 0, -2.4), neon = true } },
	{ name = "The Gorbmother", rarity = 5, income = 1500, body = Color3.fromRGB(255, 80, 120),
		feature = { shape = "Ball", size = Vector3.new(3, 3, 3), color = Color3.fromRGB(255, 220, 240), offset = Vector3.new(0, 3.6, 0), neon = true } },
}

-- Chance (relative weights) of each rarity spawning on each cave floor: { Common, Rare, Epic, Mythic, Secret }.
-- Deeper floors shift toward rarer creatures (pillar: Weirder the Deeper).
Config.FloorWeights = {
	{ 85, 15, 0, 0, 0 },
	{ 60, 32, 8, 0, 0 },
	{ 40, 38, 18, 4, 0 },
	{ 25, 35, 28, 11, 1 },
	{ 12, 30, 33, 21, 4 },
}

Config.Cave = {
	floors = 5, -- must match the number of rows in FloorWeights
	creaturesPerFloor = 10,
	respawnSeconds = 8, -- a floor tops itself back up to creaturesPerFloor this often
	roomSize = 140, -- studs, square
	-- Roblox deletes anything below Workspace.FallenPartsDestroyHeight (default -500),
	-- so keep firstFloorY - (floors - 1) * depthStep above about -450.
	depthStep = 70, -- vertical distance between floors (each room is 44 studs tall)
	firstFloorY = -100,
	-- floor colors get stranger with depth
	floorColors = {
		Color3.fromRGB(70, 75, 85), Color3.fromRGB(70, 60, 95), Color3.fromRGB(95, 50, 105),
		Color3.fromRGB(120, 40, 80), Color3.fromRGB(140, 30, 40),
	},
}

-- Sanity drains only while you are in the cave.
-- drain per second on floor f = drainBase + drainPerFloor * (f - 1)
-- Example: floor 1 = 1.5/s (100 Sanity lasts ~67 s), floor 5 = 1.5 + 0.9*4 = 5.1/s (~20 s).
Config.Sanity = {
	max = 100,
	drainBase = 1.5,
	drainPerFloor = 0.9,
	surgeFromFloor = 3, -- rot surges can start on this floor and below
	surgeChancePerSecond = 0.03,
	surgeMultiplier = 3,
	surgeSeconds = 3,
}

Config.Carry = {
	baseLimit = 3, -- creatures you can carry out of the cave
}

Config.Base = {
	plots = 6,
	pedestals = 10,
	lockSeconds = 60,
	lockCooldownSeconds = 120, -- counted from when the lock started
	stealHoldTime = 2.0,
	sellMultiplier = 20, -- selling pays income * this
	overflowSellMultiplier = 20, -- creature brought home with no free pedestal is auto-sold for this
}

Config.Bat = {
	range = 8,
	cooldown = 1.0,
	knockback = 60,
}

-- Upgrades bought from the Shop button. cost for next level = baseCost * growth ^ currentLevel
Config.Upgrades = {
	Sanity = { label = "Sanity Tank", perLevel = 25, baseCost = 150, growth = 3, maxLevel = 6 },
	Carry = { label = "Carry Slot", perLevel = 1, baseCost = 400, growth = 4, maxLevel = 4 },
}

function Config.upgradeCost(kind: string, level: number): number
	local u = Config.Upgrades[kind]
	return math.floor(u.baseCost * u.growth ^ level)
end

function Config.drainForFloor(floor: number): number
	return Config.Sanity.drainBase + Config.Sanity.drainPerFloor * (floor - 1)
end

return Config
