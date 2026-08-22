local Adapter = dofile("scripts/ground/OMW_GroundRoadSpawnAdapter.lua")

Group = { Category = { GROUND = 2, AIRPLANE = 0 } }

local spawnedTemplate = nil
_DATABASE = {
  Spawn = function(_, template)
    spawnedTemplate = template
    return { name = template.name }
  end,
}

local function newCoordinate(x, z)
  local coordinate = { x = x, y = 0, z = z }

  function coordinate:GetVec2()
    return { x = self.x, y = self.z }
  end

  function coordinate:GetClosestPointToRoad()
    return newCoordinate(self.x, self.z)
  end

  function coordinate:Get2DDistance(other)
    local dx = other.x - self.x
    local dz = other.z - self.z
    return math.sqrt(dx * dx + dz * dz)
  end

  function coordinate:GetPathOnRoad()
    return {
      newCoordinate(0, 0),
      newCoordinate(100, 0),
    }, 100, true
  end

  return coordinate
end

COORDINATE = {}
function COORDINATE:NewFromVec2(vec2)
  return newCoordinate(vec2.x, vec2.y)
end

local accessZone = {}
function accessZone:GetCoordinate()
  return newCoordinate(0, 0)
end
function accessZone:IsVec2InZone(vec2)
  return vec2.x >= 0 and vec2.x <= 100 and math.abs(vec2.y) < 0.01
end

local originalCalls = 0
local brigade = {
  ValidateAndRepositionGroundUnits = false,
}

function brigade:_SpawnAssetGroundNaval()
  originalCalls = originalCalls + 1
  return "ORIGINAL"
end

function brigade:_SpawnAssetPrepareTemplate(asset, alias)
  local units = {}
  for index, unit in ipairs(asset.template.units) do
    units[index] = {
      x = unit.x,
      y = unit.y,
      alt = unit.alt,
      heading = unit.heading,
    }
  end
  return {
    name = alias,
    units = units,
    route = { points = { {} } },
  }
end

local logs = {}
local _, installed = Adapter.Install(brigade, {
  resolveRoadSpawn = function(_, _, request)
    if request and request.road == true then
      return {
        accessZone = accessZone,
        forwardCoordinate = newCoordinate(100, 0),
        entityId = "GROUND-TEST-001",
      }
    end
    return nil
  end,
  log = function(message)
    logs[#logs + 1] = message
  end,
})

assert(installed == true)

local asset = {
  category = Group.Category.GROUND,
  template = {
    units = {
      { x = 0, y = 0 },
      { x = -10, y = 0 },
      { x = -25, y = 0 },
    },
  },
}

local result = brigade:_SpawnAssetGroundNaval(
  "ROAD_TEST_GROUP",
  asset,
  { road = true },
  nil,
  false
)

assert(result.name == "ROAD_TEST_GROUP")
assert(spawnedTemplate ~= nil)
assert(#spawnedTemplate.units == 3)

-- Template pair spacing is preserved: 10 m then 15 m.
assert(math.abs(spawnedTemplate.units[1].x - 45) < 0.001)
assert(math.abs(spawnedTemplate.units[2].x - 35) < 0.001)
assert(math.abs(spawnedTemplate.units[3].x - 20) < 0.001)
assert(math.abs(spawnedTemplate.units[1].y) < 0.001)
assert(math.abs(spawnedTemplate.units[2].y) < 0.001)
assert(math.abs(spawnedTemplate.units[3].y) < 0.001)
assert(math.abs(spawnedTemplate.units[1].heading) < 0.001)
assert(#logs == 1)
assert(logs[1]:find("ROAD_ALIGNED_WAREHOUSE_SPAWN", 1, true) ~= nil)

local offroad = brigade:_SpawnAssetGroundNaval(
  "OFFROAD_TEST_GROUP",
  asset,
  { road = false },
  nil,
  false
)
assert(offroad == "ORIGINAL")
assert(originalCalls == 1)

local _, installedAgain = Adapter.Install(brigade, {
  resolveRoadSpawn = function() return nil end,
})
assert(installedAgain == false)

print("GROUND_ROAD_SPAWN_ADAPTER_TEST_PASS")
