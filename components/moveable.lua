function make_moveable(pos)
  return { 
    pos = pos or vec(),
    dpdt = vec(), -- velocity
    impulse = vec(), -- force
    kick = function(self, imp)
      -- printh("impulse: "..v2s(self.impulse))
      self.impulse = vadd(self.impulse, imp)
      -- printh("--> impulse: "..v2s(self.impulse))
    end,
    update = function(self, dt)
      -- printh("impulse: "..v2s(self.impulse).." dt: "..dt)
      -- printh("dpdt:"..v2s(self.dpdt))
      self.dpdt = vadd(self.dpdt, self.impulse)
      -- printh("--> dpdt:"..v2s(self.dpdt))
      self.impulse = vec()
      -- printh("pos:"..v2s(self.pos))
      self.pos = vadd(self.pos, vscale(dt, self.dpdt))
      -- printh("--> pos:"..v2s(self.pos))
    end,
    spr = function(self,s)
      spr(s, self.pos.x-4, self.pos.y-4)
    end,
    pset = function(self,c)
      pset(self.pos.x, self.pos.y, c)
    end,
    debug = function(self, id)
      printh(id.."pos: "..v2s(self.pos))
      printh(id.."dpdt: "..v2s(self.dpdt))
    end
  }

end