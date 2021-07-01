function make_lin_chooser(x, y, hlength, hwidth, speed)
  return {
    p = 0, speed = speed or 1,
    cbg = kDGRAY, cfg = kWHITE,
    init = function(self)
      self.speed = rnd(2) >= 1 and speed or -speed
      self.p = rnd(2*hlength) - hlength + x
    end,
    update = function(self, t)
      self.p += self.speed * t
      if(self.p >= (x + hlength)) then
        self.speed *= -1
        self.p = x + hlength
      end
      if(self.p <= (x - hlength)) then
        self.speed *= -1
        self.p = x - hlength
      end
    end,
    choose = function(self)
      self.speed = 0
      return self.p - (x - hlength)
    end,
    draw = function(self)
      vprectfill(x - hlength, y - hwidth, x + hlength, y + hwidth, self.cbg)
      vprectfill(self.p, y - hwidth + 1, self.p, y + hwidth - 1, self.cfg)
    end
  } 
end


function make_arc_chooser(x, y, radius, width, speed)
  return {
    p = 0, speed = speed or 1,
    cbg = kDGRAY, cfg = kWHITE,
    from = 0, to = 1, is_circ = true,
    set_arc = function(self, from, to)
      self.from = normalize_arc(from)
      self.to = normalize_arc(to)
      self.is_circ = ((to%1) == (from%1))
    end,
    init = function(self)
      self.speed = rnd(2) >= 1 and speed or -speed
      self.p = normalize_arc(rnd(arc_len(self.from, self.to)) + self.from)
    end,
    update = function(self, t)
      self.p = normalize_arc(self.p + self.speed * t * 1/radius)

      if (self.is_circ) then 
        self.p = self.p % 1
      else
        if gt_arc(self.from, self.to, self.p) then
          self.p = self.to
          self.speed *= -1
        elseif lt_arc(self.from, self.to, self.p) then
          self.p = self.from
          self.speed *= -1
        end
      end
    end,
    choose = function(self)
      self.speed = 0
      return self.p
    end,
    draw = function(self)

        local NC = radius * 7
        for J = 0, NC do
          if (in_arc(self.from,self.to,J/NC)) then 
            for I = radius, radius + width - 1, 0.5 do
              pset(x + 0.5 + I * cos(J/NC), y + 0.5 + I * nsin(J/NC), self.cbg)
            end
          end
        end

      for I = radius, radius + width - 1, 0.5 do
        pset(x + 0.5 + I * cos(self.p),y + 0.5 + I * nsin(self.p), self.cfg)
      end
    end
  } 
end