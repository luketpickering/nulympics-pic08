function make_beamline(origin)
  return {
    elements = {},
    magnets = {},
    pipe = {},
    origin = vcopy(origin),
    draw_pipe = function(self)
      for BP in all(self.pipe) do
        BP:draw()
      end
    end,
    draw_elements = function(self)
      for E in all(self.elements) do
        E:draw()
      end
      for M in all(self.magnets) do
        M:draw()
      end
    end,
    set_elements = function(self, descriptor)
      local pos = vcopy(self.origin)
      for I = 1, #descriptor do
        if (sub(descriptor,I,I) == "_") then
          pos = vadd(pos, vec(4))
          add(self.pipe, make_beampipe(pos))
          pos = vadd(pos, vec(4))
        end
     
        if (sub(descriptor,I,I) == "C") then
          pos = vadd(pos, vec(12))
          add(self.elements, make_RFCavity(pos))
          pos = vadd(pos, vec(12))
        end
     
        if (sub(descriptor,I,I) == "M") then
          pos = vadd(pos, vec(8))
          add(self.magnets, make_magnet(pos))
          pos = vadd(pos, vec(8))
        end
     
      end
    end,
    bfield = function(self, pos)
      local bf = 0
      for M in all(self.magnets) do
        bf += M:bfield(pos)
      end
      return bf
    end,
    set_current = function(self, current)
      for I = 1, #self.magnets do
        self.magnets[I].current = (I&1 == 1) and current or -current
      end
    end,
    last_magnet = function(self)
      return self.magnets[#self.magnets]
    end
  }
end

function make_beampipe(center)
  -- +ve is into the page
  -- +ve makes +ve charge bend up
  local kSPR_BP = 48

  return {
    x = center.x,
    y = center.y,
    nsegments = 1,
    draw = function(self)
      vspr(kSPR_BP, self.x, self.y, 1, 5)
      -- pset(self.x, self.y, kGREEN)
    end
  }
end

function make_magnet(center)
  -- +ve is into the page
  -- +ve makes +ve charge bend up
  local kSPR_MAG = 52
  local kSPR_INTO = 51
  local kSPR_OUT = 67

  return {
    x = center.x,
    y = center.y,
    hwidth = 24,
    hlength = 16,
    nsegments = 2,
    current = 0,
    draw = function(self)
      vspr(kSPR_MAG, self.x - 4, self.y, 1, 6)
      vspr(kSPR_MAG, self.x + 4, self.y, 1, 6, true)
      -- pset(self.x, self.y, kGREEN)

      if(self.current == 0) return

      local sprn = {kSPR_INTO, kSPR_OUT};
      if(self.current < 0) then
        sprn[1] = kSPR_OUT
        sprn[2] = kSPR_INTO
        print("D", self.x - 1,self.y - 2, kWHITE)
      else
        print("F", self.x - 1,self.y - 2, kWHITE)
      end
      vspr(sprn[1], self.x, self.y - 10)
      vspr(sprn[2], self.x, self.y + 10)

    end,
    bfield = function(self, pos)
      local disp = vatob(self, pos)
      if(abs(disp.x) > self.hlength) then return 0 end
      return self.current * (disp.y / self.hwidth) / 10
    end
  }
end

function make_RFCavity(center)
  -- +ve is into the page
  -- +ve makes +ve charge bend up
  local kSPR_RF = 53

  return {
    x = center.x,
    y = center.y,
    nsegments = 3,
    kick = 0,
    draw = function(self)
      vspr(kSPR_RF, self.x - 8, self.y, 1, 8)
      vspr(kSPR_RF, self.x, self.y, 1, 8)
      vspr(kSPR_RF, self.x + 8, self.y, 1, 8)
      -- pset(self.x, self.y, kGREEN)
    end
  }
end
