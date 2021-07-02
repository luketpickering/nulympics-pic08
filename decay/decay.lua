kDECAY_PAUSE = 0b1
kDECAY_ANGCH = 0b10
kDECAY_SHOOT = 0b100

function decay_reset()
  decaypi = make_moveable(vec(porigin.x, porigin.y))
  decaypi.nsteps = 0

  particles = make_particle_list()
  particles:set_cull(150)

  circ_choice = -1
  rngr:init()
  DECAY_STATE = kDECAY_ANGCH
  kick = 20
end

function decay_init()
  GAME_STATES[STATE][2] = false


  help_text = make_overlay("decay!", 
    { "here will go",
      "some help text",
      "but for now",
      "is just a place-",
      "holder. see if",
      "you can scroll",
      "to the bottom",
      "",
      "",
      "nothing here"
    })

  porigin = vec(8,60)

  rngr = make_arc_chooser(porigin.x,porigin.y,15, 3, 10)
  rngr:set_arc(-0.1, 0.1)
  
  decay_reset()
  DECAY_STATE += kDECAY_PAUSE
end

function decay_update()
  if (btnp(5)) DECAY_STATE = DECAY_STATE^^kDECAY_PAUSE

  if (DECAY_STATE & kDECAY_PAUSE == kDECAY_PAUSE) then
    help_text:update()
  end

  if (DECAY_STATE == kDECAY_ANGCH) then
      rngr:update(1/30)

      if (btnp(4)) then
        circ_choice = rngr:choose()
        
        kick = 30
        local vkick = vec(kick*cos(circ_choice),kick*nsin(circ_choice))
        printh(v2s(vkick)..": "..vang(vkick))
        decaypi:kick(vkick)

        DECAY_STATE = kDECAY_SHOOT
      end
  end

  if(DECAY_STATE == kDECAY_SHOOT) then
    decaypi:update(1/30)

    particles:update(function(decaypi)
      decaypi:kick(vec(0,1)) 
      decaypi:update(1/30)
    end)


    if(decaypi.nsteps % 5 == 0) then
      particles:add_parts(
        generate_particles(decaypi.pos, 10, 4)
      )
    end

    decaypi.nsteps += 1

    if (not invp(decaypi.pos.x, decaypi.pos.y)) then
      decay_reset()
    end
  end

end

function decay_draw()
  cls()
  if(DECAY_STATE == kDECAY_ANGCH) rngr:draw()
  if(decaypi) then 
    decaypi:spr(kSPR_PION_R)
    draw_vel_arrow(decaypi, 0.5, kGREEN)
  end

  particles:draw()

  if (DECAY_STATE & kDECAY_PAUSE == kDECAY_PAUSE) help_text:draw()

  -- if(circ_choice > -1) print("cir1="..(flr(circ_choice*100)/100), 0, 120, kGREEN)
end