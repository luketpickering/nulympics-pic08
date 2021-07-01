function make_moveable(pos)
  return { 
    pos = pos or vec(),
    dpdt = vec(), -- velocity
    impulse = vec(), -- force
    kick = function(self, imp)
      self.impulse = imp
    end,
    update = function(self, dt)
      self.dpdt = vadd(self.dpdt, self.impulse)
      self.impulse = vec()
      self.pos = vadd(self.pos, vscale(dt, self.dpdt))
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