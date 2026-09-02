-- Auto-spawn lootboxes at random map positions when a round starts
-- and Level.ShouldSpawnLoot is true.
if CLIENT then return end

local LOOTBOX_CLASSES = {
    "ent_lootbox_low",
    "ent_lootbox_small",
    "ent_lootbox_medium",
    "ent_lootbox_weapons",
    "ent_lootbox_medical",
    "ent_lootbox_armor",
    "ent_lootbox_rifle",
    "ent_lootbox_attachment",
    "ent_lootbox_explosive",
    "ent_lootbox_granade",
    "ent_lootbox_machines",
    "ent_lootbox_medium_high",
    "ent_lootbox_medium_pnev",
    "ent_lootbox_rifle_high",
    "ent_lootbox_small_ammo",
    "ent_lootbox_low_food",
    "ent_lootbox_armor_water",
}

local DEFAULT_COUNT = 12
local MIN_COUNT = 8
local MAX_COUNT = 16

local spawnedLootboxes = {}

local function FindGroundPosition(origin, radius)
    for _ = 1, 20 do
        local angle = math.random() * math.pi * 2
        local dist = math.random() * radius
        local pos = origin + Vector(math.cos(angle) * dist, math.sin(angle) * dist, 5000)

        local tr = util.TraceLine({
            start = pos,
            endpos = pos - Vector(0, 0, 10000),
            mask = MASK_SOLID,
        })

        if tr.Hit and not tr.StartSolid then
            local groundPos = tr.HitPos + Vector(0, 0, 5)
            -- Check if position is not too close to existing lootboxes
            local tooClose = false
            for _, ent in ipairs(spawnedLootboxes) do
                if IsValid(ent) and ent:GetPos():DistToSqr(groundPos) < 25000 then
                    tooClose = true
                    break
                end
            end
            if not tooClose then
                return groundPos
            end
        end
    end
    return nil
end

local function SpawnLootboxes()
    -- Clean up old lootboxes
    for _, ent in ipairs(spawnedLootboxes) do
        if IsValid(ent) then ent:Remove() end
    end
    spawnedLootboxes = {}

    if not levelActive or not levelActive.ShouldSpawnLoot then return end

    local count = math.random(MIN_COUNT, MAX_COUNT)
    local players = player.GetAll()
    if #players == 0 then return end

    -- Use average player position as center, or map origin
    local center = Vector(0, 0, 0)
    for _, ply in ipairs(players) do
        if IsValid(ply) then
            center = center + ply:GetPos()
        end
    end
    center = center / math.max(#players, 1)

    local spawnRadius = 3000

    for i = 1, count do
        local class = LOOTBOX_CLASSES[math.random(1, #LOOTBOX_CLASSES)]
        local pos = FindGroundPosition(center, spawnRadius)

        if pos then
            local ent = ents.Create(class)
            if IsValid(ent) then
                ent:SetPos(pos)
                ent:SetAngles(Angle(0, math.random(0, 360), 0))
                ent:Spawn()
                ent:Activate()

                local phys = ent:GetPhysicsObject()
                if IsValid(phys) then
                    phys:Wake()
                    phys:EnableMotion(true)
                end

                spawnedLootboxes[#spawnedLootboxes + 1] = ent
            end
        end
    end

    print("[HG Lootbox] Spawned " .. #spawnedLootboxes .. " lootboxes")
end

-- Hook into round start
hook.Add("HG_RoundStarted", "LootboxAutoSpawn", function()
    timer.Simple(2, SpawnLootboxes)
end)

-- Clean up on round end
hook.Add("HG_RoundEnded", "LootboxAutoCleanup", function()
    for _, ent in ipairs(spawnedLootboxes) do
        if IsValid(ent) then ent:Remove() end
    end
    spawnedLootboxes = {}
end)
