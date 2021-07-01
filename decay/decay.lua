kINT_PAUSE = 0b1
kINT_ANGCH = 0b10
kINT_SHOOT = 0b100

function decay_reset()
  p = make_moveable(vec(porigin.x, porigin.y))
  p.nsteps = 0

  particles = make_particle_list()
  particles:set_cull(150)

  circ_choice = -1
  rngr:init()
  DECAY_STATE = kINT_ANGCH
  kick = 20
end

function decay_init()
  GAME_STATES[STATE][2] = false


  help_text = make_overlay("decay!", 
    { "the aim is to",
      "make the neutrino",
      "decay within the.",
      "detector.",
      "go",
      "wild",
      "young",
      "one"
    })

  porigin = vec(8,60)

  rngr = make_arc_chooser(porigin.x,porigin.y,15, 3, 10)
  rngr:set_arc(-0.1, 0.1)
  
  decay_reset()
  DECAY_STATE += kINT_PAUSE
end

function decay_update()
  if (btnp(5)) DECAY_STATE = DECAY_STATE^^kINT_PAUSE

  if (DECAY_STATE & kINT_PAUSE == kINT_PAUSE) then
    help_text:update()
  end

  if (DECAY_STATE == kINT_ANGCH) then
      rngr:update(1/30)

      if (btnp(4)) then
        circ_choice = rngr:choose()
        
        kick = 30
        local vkick = vec(kick*cos(circ_choice),kick*nsin(circ_choice))
        printh(v2s(vkick)..": "..vang(vkick))
        p:kick(vkick)

        DECAY_STATE = kINT_SHOOT
      end
  end

  if(DECAY_STATE == kINT_SHOOT) then
    p:update(1/30)

    particles:update(function(p)
      p:kick(vec(0,1)) 
      p:update(1/30)
    end)


    if(p.nsteps % 5 == 0) then
      particles:add_parts(
        generate_particles(p.pos, 10, 4)
      )
    end

    p.nsteps += 1

    if (not invp(p.pos.x, p.pos.y)) then
      decay_reset()
    end
  end

end

function decay_draw()
  cls()
  if(DECAY_STATE == kINT_ANGCH) rngr:draw()
  if(p) then 
    p:spr(4)
    draw_vel_arrow(p, 0.5, kLBLUE)
    if (circ_choice > -1) arrow_ang(porigin.x, porigin.y, circ_choice, 5, 3, kWHITE)
  end

  particles:draw()

  if (DECAY_STATE & kINT_PAUSE == kINT_PAUSE) help_text:draw()

  if(circ_choice > -1) print("cir1="..(flr(circ_choice*100)/100), 0, 120, kGREEN)
end