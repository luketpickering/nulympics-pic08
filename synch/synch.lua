kSYN_PAUSE = 0b1
kSYN_RUN = 0b10
kSYN_WIN = 0b100
kSYN_END = 0b1000

function synch_init()
  current = 0
  
  beamline_origin = vec(-8,80)

  synch_beamline = make_beamline(beamline_origin)
  synch_beamline:set_elements("_____C_____M_____M_____M_____M_____M_____M_____M_____M_____M_____M_____M_____M_____C_____________")

  bunch_width = 0
  bunch_length = 0
  bunch_emittance = 0
  bunch_mean_pos = vec()

  initial_kick_x = 40
  initial_emittance = 0.1

  bunch_v = initial_kick_x * FSPEED

  synch_turn = 1

  synch_nprotons = 150
  synch_protons = make_particle_list()
  synch_protons:add_parts(generate_particles(vec(5,80),synch_nprotons, 5, true, kRED))
  synch_protons:update(function(p)
      p:kick(vec(initial_kick_x, rnd(2 * initial_kick_x * initial_emittance) - (initial_kick_x * initial_emittance)))
      p:update(0)
      bunch_mean_pos = vadd(bunch_mean_pos, p.pos)
      bunch_width += abs(p.pos.y - beamline_origin.y)
      bunch_length += abs(p.pos.x - 5)
      bunch_emittance += abs(p.dpdt.y) 
  end)
  bunch_width /= synch_protons:num()
  bunch_length /= synch_protons:num()
  bunch_emittance /= synch_protons:num()

  bunch_mean_pos = vscale(1/synch_protons:num(),bunch_mean_pos)
  last_bunch_mean_pos = vcopy(bunch_mean_pos)

  player_proton = make_particle(vec(5,80), nil, kSPR_PROTON_R)
  player_proton:kick(vec(initial_kick_x,rnd(2 * initial_kick_x * initial_emittance) - (initial_kick_x * initial_emittance)))
  player_proton:update(0)
  player_proton:update(0)


  SYN_STATE=kSYN_RUN

  GAME_STATES[STATE][2] = false
end

function synch_update()

  if (btnp(4)) synch_init()

  if(SYN_STATE&kSYN_RUN == kSYN_RUN) then
    read_input()

    --Shift everything back, to do another turn
    local beamline_turn_length = synch_beamline:last_magnet().x + 20
    if((synch_turn < 10) and (player_proton.pos.x > beamline_turn_length)) then
      player_proton.pos.x -= synch_beamline:last_magnet().x + 16
      synch_protons:update(function(p)
        p.pos.x -= synch_beamline:last_magnet().x + 16
      end)
      synch_turn += 1
    end

    if (btnp(1)) SYN_STATE = SYN_STATE^^kSYN_PAUSE
    printh("state: "..SYN_STATE)

    if (SYN_STATE&kSYN_PAUSE != kSYN_PAUSE) then
      local bf = synch_beamline:bfield(player_proton.pos)
      local x_kick = 0
      if((player_proton.pos.x < 52) and (player_proton:next_pos(FSPEED).x > 52)) then
        x_kick = 20
      end
      player_proton:kick(vec(x_kick, - player_proton.dpdt.x * bf))
      player_proton:update(FSPEED)

      bunch_width = 0
      bunch_length = 0
      bunch_emittance = 0

      bunch_mean_pos = vec()
      synch_protons:update(function(p)
        local bf = synch_beamline:bfield(p.pos)
        bunch_width += abs(p.pos.y - beamline_origin.y)
        bunch_length += abs(p.pos.x - last_bunch_mean_pos.x)
        bunch_emittance += abs(p.dpdt.y)

        local x_kick = 0
        if((p.pos.x < 52) and (p:next_pos(FSPEED).x > 52)) then
          x_kick = 20
        end

        p:kick(vec(x_kick, - p.dpdt.x * bf))

        -- p:kick(vscale(0.01 / vmag2(vatob(p.pos,last_bunch_mean_pos)),
        --   vec(sign(p.pos.x -last_bunch_mean_pos.x), 
        --       sign(p.pos.y -last_bunch_mean_pos.y))))
        p:update(FSPEED)
        bunch_mean_pos = vadd(bunch_mean_pos, p.pos)
      end)

      bunch_width /= synch_protons:num()
      bunch_length /= synch_protons:num()
      bunch_emittance /= synch_protons:num()
      bunch_mean_pos = vscale(1/synch_protons:num(),bunch_mean_pos)
      bunch_v = (bunch_mean_pos.x - last_bunch_mean_pos.x) * FSPEED
      last_bunch_mean_pos = vcopy(bunch_mean_pos)
    end

    if(abs(player_proton.pos.y - beamline_origin.y) >= 16) then
      SYN_STATE = kSYN_END
    end

    if(player_proton.pos.x > (synch_beamline:last_magnet().x + 64)) then
      SYN_STATE = kSYN_WIN
    end

    synch_protons:remove_if(function(p) return (abs(p.pos.y - beamline_origin.y) >= 18) end)
  end

  camera(player_proton.pos.x - 16, 0)
end

function synch_draw()
  
  if(SYN_STATE==kSYN_END) then
    print("BEAM LOSS!", 0,24)
    return
  end
  
  if(SYN_STATE==kSYN_WIN) then
    cls()
    print("Success!", 12, 64, kGREEN)
    show_debug()
    return
  end

  cls() --clear screen

  synch_beamline:draw_pipe()
  
  synch_protons:draw()
  player_proton:spr(player_proton.spr_id, kDBLUE)
  synch_beamline:draw_elements()

  --lets just show the focussing forces
  player_proton.last_impulse.x = 0
  draw_impulse_arrow(player_proton, 5, kYELLOW)

  local testp = make_moveable(player_proton.pos)
  testp.dpdt = vcopy(player_proton.dpdt)

  if(SYN_STATE&kSYN_PAUSE == kSYN_PAUSE) then
    for Tf = 0, 200 do
      testp:update(FSPEED/2)

      local bf = synch_beamline:bfield(testp.pos)
      testp:kick(vec(0, - testp.dpdt.x * bf))

      testp:pset(kGREEN)

      if(abs(testp.pos.y - beamline_origin.y) >= 18) then
        break
      end
      if((testp.pos.x - player_proton.pos.x) > 100) then
        break
      end
    end
  end

  if(DEBUG_LEVEL > 0) then
    show_debug()
  end
  -- draw_grid()
end

function read_input()
  local delta = 0.1
  local magdelta = 0
  if (btnp(2)) magdelta += delta --up
  if (btnp(3)) magdelta -= delta --down

  current = clamp(current + magdelta,-5,5)
  synch_beamline:set_current(current)

end

function show_debug()
  vpprint("\131/\148: change focussing current",0,117,kSLATE)
  -- vpprint("restart: \142",0,32,kGREEN)
  vpprint("\145: toggle time \142: restart",0,123,kSLATE)
  vpprint("beam loss: "..flr(100*(synch_nprotons - synch_protons:num())/(1 + synch_nprotons)).."%",
    0,8, kGREEN)
  vpprint("foc.cur.: "..current,0,16,kGREEN)

  vpprint("bch width: "..(flr(bunch_width*10)/10), 68, 8, kGREEN)
  vpprint("bch length: "..(flr(bunch_length*10)/10), 68, 16, kGREEN)
  vpprint("bch emit: "..(flr(bunch_emittance*10)/10),68,24,kGREEN)
  vpprint("bch vx: "..(flr(bunch_v*10)/10),68,32,kGREEN)

  vpprint("pv: "..v2s(player_proton.dpdt), 0,40)
  vpprint("turn: "..synch_turn, 0,24)
end