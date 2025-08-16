-- qbx_coords_helper / client.lua

-- ===== Utils =====
local function notify(msg, typ)
  if lib and lib.notify then
    lib.notify({ title = 'Coords', description = msg, type = typ or 'inform' })
  else
    print(('^3[Coords]^7 %s'):format(msg))
  end
end

local function fmtVec(x, y, z)
  return string.format('vec3(%.2f, %.2f, %.2f)', x, y, z)
end

local function copy(text)
  if lib and lib.setClipboard then lib.setClipboard(text) end
end

-- ==== Raycast da câmara ====
local function rotToDir(rot)
  local z = math.rad(rot.z)
  local x = math.rad(rot.x)
  local cosX = math.abs(math.cos(x))
  return vector3(-math.sin(z) * cosX, math.cos(z) * cosX, math.sin(x))
end

local function raycastFromCamera(dist)
  local camPos = GetGameplayCamCoord()
  local camRot = GetGameplayCamRot(2)
  local dir = rotToDir(camRot)
  local dest = camPos + (dir * dist)

  local handle = StartShapeTestRay(camPos.x, camPos.y, camPos.z, dest.x, dest.y, dest.z, -1, -1, 1)
  local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(handle)
  return hit == 1, endCoords, entityHit
end

-- ===== /coords =====
RegisterCommand('coords', function()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local h = GetEntityHeading(ped)
  local msg = string.format('Pos: %s | heading: %.1f', fmtVec(pos.x, pos.y, pos.z), h)
  notify(msg, 'inform')
  print('[coords] '..msg)
  copy(string.format('%s, heading = %.1f', fmtVec(pos.x, pos.y, pos.z), h))
end, false)

-- ===== /olhar =====
RegisterCommand('olhar', function()
  local ok, hitPos, ent = raycastFromCamera((Config.MaxLookDistance or 250.0))
  if not ok then
    notify('Nada detetado à frente.', 'error')
    return
  end

  if ent ~= 0 and DoesEntityExist(ent) then
    local pos = GetEntityCoords(ent)
    local model = GetEntityModel(ent)
    local heading = GetEntityHeading(ent)
    local etype = GetEntityType(ent) -- 0=none,1=ped,2=veh,3=obj
    local kind = (etype == 1 and 'Ped') or (etype == 2 and 'Veículo') or (etype == 3 and 'Objeto') or ('Ent '..tostring(etype))
    local msg = string.format('%s | model: %s | pos: %s | heading: %.1f', kind, tostring(model), fmtVec(pos.x,pos.y,pos.z), heading)
    notify(msg, 'inform')
    print('[olhar] '..msg)
    copy(fmtVec(pos.x,pos.y,pos.z))
  else
    local msg = string.format('Ponto no mundo: %s', fmtVec(hitPos.x, hitPos.y, hitPos.z))
    notify(msg, 'inform')
    print('[olhar] '..msg)
    copy(fmtVec(hitPos.x, hitPos.y, hitPos.z))
  end
end, false)

-- ===== HUD (toggle) =====
local showCoords = false

local function drawTxt(x, y, scale, text)
  SetTextFont(Config.HudFont or 4)
  SetTextScale(scale, scale)
  SetTextColour(255,255,255,200)
  SetTextOutline()
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x, y)
end

RegisterCommand('coords_on', function()
  showCoords = not showCoords
  notify('HUD: '..(showCoords and 'ON' or 'OFF'), showCoords and 'success' or 'error')
end, false)

-- Key mapping (opcional): F6 para alternar HUD
RegisterKeyMapping('coords_on', 'Toggle Coords HUD', 'keyboard', 'F6')

CreateThread(function()
  while true do
    if showCoords then
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)
      local h = GetEntityHeading(ped)
      drawTxt((Config.HudPosX or 0.5), (Config.HudPosY or 0.01), (Config.HudScale or 0.35),
        string.format('%s  h:%.1f', fmtVec(pos.x,pos.y,pos.z), h))
    end
    Wait(0)
  end
end)

-- ===== Integração opcional com ox_target =====
CreateThread(function()
  if not (Config.EnableOxTarget and pcall(function() return exports.ox_target end)) then
    return
  end

  exports.ox_target:addGlobalVehicle({
    {
      icon = 'fa-solid fa-crosshairs',
      label = Config.TargetLabel or 'Ver coordenadas',
      onSelect = function(data)
        local ent = data.entity
        if ent and DoesEntityExist(ent) then
          local pos = GetEntityCoords(ent)
          local model = GetEntityModel(ent)
          local heading = GetEntityHeading(ent)
          local msg = string.format('Veículo | model: %s | pos: %s | heading: %.1f', tostring(model), fmtVec(pos.x,pos.y,pos.z), heading)
          notify(msg, 'inform')
          print('[target] '..msg)
          copy(fmtVec(pos.x,pos.y,pos.z))
        end
      end
    }
  })

  exports.ox_target:addGlobalObject({
    {
      icon = 'fa-solid fa-crosshairs',
      label = Config.TargetLabel or 'Ver coordenadas',
      onSelect = function(data)
        local ent = data.entity
        if ent and DoesEntityExist(ent) then
          local pos = GetEntityCoords(ent)
          local model = GetEntityModel(ent)
          local heading = GetEntityHeading(ent)
          local msg = string.format('Objeto | model: %s | pos: %s | heading: %.1f', tostring(model), fmtVec(pos.x,pos.y,pos.z), heading)
          notify(msg, 'inform')
          print('[target] '..msg)
          copy(fmtVec(pos.x,pos.y,pos.z))
        end
      end
    }
  })

  exports.ox_target:addGlobalPed({
    {
      icon = 'fa-solid fa-crosshairs',
      label = Config.TargetLabel or 'Ver coordenadas',
      onSelect = function(data)
        local ent = data.entity
        if ent and DoesEntityExist(ent) then
          local pos = GetEntityCoords(ent)
          local model = GetEntityModel(ent)
          local heading = GetEntityHeading(ent)
          local msg = string.format('Ped | model: %s | pos: %s | heading: %.1f', tostring(model), fmtVec(pos.x,pos.y,pos.z), heading)
          notify(msg, 'inform')
          print('[target] '..msg)
          copy(fmtVec(pos.x,pos.y,pos.z))
        end
      end
    }
  })
end)
