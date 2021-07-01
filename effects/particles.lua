function make_particle(pos, col, spr_id)
	local p = make_moveable(pos)
	p.col = col
	p.spr_id = spr_id
	return p
end

function make_particle_list()
	return {
		particles = {}, cull_every = -1, cull_ctr = -1,
		add_parts = function(self, L)
			extend(self.particles, L)

      local overparts = #self.particles - NMAXPARTICLES
      for I = 1, overparts do
        deli(self.particles, I)
      end
		end,
		update = function(self, particle_updater)
			foreach(self.particles, particle_updater)
		end,
		draw = function(self)
      if(self.cull_ctr > 0) self.cull_ctr -= 1
      if(self.cull_ctr == 0) self:cull()

			for P in all(self.particles) do
				if P.spr_id then
					P:spr(P.spr_id)
				else
	    			P:pset(P.col or rnd(14) + 1)
	    		end
  			end
		end,
    set_cull = function(self, ce)
      self.cull_every = ce
      self.cull_ctr = ce
    end,
    cull = function(self)
      for P in all(self.particles) do
        if( not invp(P.pos.x, P.pos.y) ) then
          del(self.particles,P)
        end
      end
      self.cull_ctr = self.cull_every
    end
	};
end

function generate_particles(pos, num, radius, fill, col)
	fill = fill or true
	local plist = {}
	for I = 1, num do
		add(plist, make_particle(
			vadd(pos, random_slice_pos(0, 1, radius, fill)),
			col))
	end
	return plist
end

    