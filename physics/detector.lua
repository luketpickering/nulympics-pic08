function make_material(den, col)
  return { density = den, color = col}
end

function make_volume(pos, halfs, mat)
  return {
    pos = pos,
    halfsides = halfs,
    material = mat 
  }
end

function make_detector(pos)
  return {
    volumes = {},
    pos = pos or vec(),
    addvol = function(self, vol)
      add(self.volumes, vol)
    end,
    draw = function(self)
      for V in all(self.volumes) do
        -- printh(v2s(self.pos)..v2s(V.pos)..v2s(V.halfsides))
        -- printh(V.material.color)
        rectfill(self.pos.x + V.pos.x - V.halfsides.x,
          self.pos.y + V.pos.y - V.halfsides.y,
          self.pos.x + V.pos.x + V.halfsides.x,
          self.pos.y + V.pos.y + V.halfsides.y,
          V.material.color)
      end
    end,
    raytrace = function(self, neutrino)
      
    end
  }
end

function make_nd280(pos)
  local HydroCarbon = make_material(1, kWHITE)
  local Iron = make_material(5, kBROWN)
  local Aluminium = make_material(2, kLGRAY)

  local det = make_detector(pos)

  det:addvol(make_volume(vec(-10,0), vec(2,10), HydroCarbon))
  det:addvol(make_volume(vec(), vec(2,10), HydroCarbon))
  det:addvol(make_volume(vec(0,13), vec(10,2), Iron))
  det:addvol(make_volume(vec(0,-13), vec(10,2), Iron))

  return det
end