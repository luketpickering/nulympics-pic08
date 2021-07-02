kSYN_PAUSE = 0b1
kSYN_RUN = 0b10
kSYN_WIN = 0b100
kSYN_END = 0b1000

function synch_init()
  MAGSPACING=100

  MSPACE_MIN=50
  MSPACE_MAX=256
  MAGSPACING=clamp(MAGSPACING,MSPACE_MIN,MSPACE_MAX)

  FODO_MIN=50
  FODOGAP = FODO_MIN
  FODOGAP=clamp(FODOGAP,FODO_MIN,MAGSPACING)

  WINDIST=10000

  MAGNETS = {}
  add(MAGNETS, create_magnet(vec(64,80),vec(16,30)))
  add(MAGNETS, create_magnet(vec(64+FODOGAP,80),vec(16,30)))
  add(MAGNETS, create_magnet(vec(64+MAGSPACING,80),vec(16,30)))
  add(MAGNETS, create_magnet(vec(64+FODOGAP+MAGSPACING,80),vec(16,30)))
  add(MAGNETS, create_magnet(vec(64+(2*MAGSPACING),80),vec(16,30)))
  add(MAGNETS, create_magnet(vec(64+FODOGAP+(2*MAGSPACING),80),vec(16,30)))
  MAGNETS[1].current = 0

  make_beampipe()

  beam_width = 0
  beam_emittance = 0

  synch_nprotons = 50
  synch_protons = make_particle_list()
  synch_protons:add_parts(generate_particles(vec(5,80),synch_nprotons, 5, true, kRED))
  synch_protons:update(function(p)
      p:kick(vec(100, rnd(20) - 10))
      p:update(0)
      beam_width += abs(p.pos.y - bp.y)
      beam_emittance += abs(p.dpdt.y) 
  end)
  beam_width /= synch_protons:num()
  beam_emittance /= synch_protons:num()

  player_proton = make_particle(vec(5,80), nil, kSPR_PROTON_R)
  player_proton:kick(vec(100,rnd(20) - 10))
  player_proton:update(0)


  SYN_STATE=kSYN_RUN

  GAME_STATES[STATE][2] = false
end

function synch_update()
  if((MAGNETS[3].center.x + MAGNETS[3].hlength - player_proton.pos.x) < 0) then
    MAGNETS[1] = MAGNETS[3]
    MAGNETS[2] = MAGNETS[4]
    MAGNETS[3] = MAGNETS[5]
    MAGNETS[4] = MAGNETS[6]
    MAGNETS[5] = create_magnet(vec(MAGNETS[3].center.x + MAGSPACING,80),vec(16,32))
    MAGNETS[6] = create_magnet(vec(MAGNETS[5].center.x + FODOGAP,80),vec(16,32))
    MAGNETS[5].current = MAGNETS[1].current
    MAGNETS[6].current = MAGNETS[2].current
  end

  if(SYN_STATE == kSYN_RUN) then
    read_input()

    if btn(1) then
      local bf = get_bfield_list(MAGNETS, player_proton.pos)
      player_proton:kick(vec(0, - player_proton.dpdt.x * bf))
      player_proton:update(FSPEED)

      beam_width = 0
      beam_emittance = 0

      synch_protons:update(function(p)
        local bf = get_bfield_list(MAGNETS, p.pos)
        beam_width += p.pos.y - bp.y
        beam_emittance += abs(p.dpdt.y)
        p:kick(vec(0, - p.dpdt.x * bf))
        p:update(FSPEED)
      end)

      beam_width /= synch_protons:num()
      beam_emittance /= synch_protons:num()
    end

    if(abs(player_proton.pos.y - bp.y) > (bp.hwy-2)) then
      printh("beam loss: "..v2s(player_proton.pos)..", "..v2s(bp)..", bhy: "..bp.hwy)
      SYN_STATE = kSYN_END
    end

    if(player_proton.pos.x > WINDIST) then
      SYN_STATE = kSYN_WIN
    end

    synch_protons:remove_if(function(p) return (abs(p.pos.y - bp.y) > (bp.hwy-2)) end)
  end

  camera(player_proton.pos.x - 16, 0)
end

function synch_draw()
  
  if(SYN_STATE==kSYN_END) then
    print("BEAM LOSS!", 0,24)
    return
  end
  
  if(SYN_STATE==kSYN_WIN) then
    print("You made it to the beam window", 0,24)
    return
  end

  cls() --clear screen


  for M =1, #MAGNETS do
    draw_magnet(MAGNETS[M])
    print("M"..M, MAGNETS[M].center.x - 2,
               MAGNETS[M].center.y - MAGNETS[M].hwidth - 2, kWHITE)
  end

  for M =1, #MAGNETS, 2 do
    local x1 = MAGNETS[M].center.x
    local x2 = MAGNETS[M+1].center.x
    local y1 = MAGNETS[M].center.y - MAGNETS[M].hwidth - 8
    local deltax = x2 - x1
    line(x1, y1, x2, y1, kGREEN)
    line(x1, y1 - 2, x1, y1 + 2, kGREEN)
    line(x2, y1 - 2, x2, y1 + 2, kGREEN)

    print(deltax, 
      deltax/2 + x1 - 3, y1 - 6, kGREEN)
  end

  for M = 1, (#MAGNETS-2), 2 do
    local x1 = MAGNETS[M].center.x
    local x2 = MAGNETS[M+2].center.x
    local y1 = MAGNETS[M].center.y - MAGNETS[M].hwidth - 16
    local deltax = x2 - x1
    line(x1, y1, x2, y1, kRED)
    line(x1, y1 - 2, x1, y1 + 2, kRED)
    line(x2, y1 - 2, x2, y1 + 2, kRED)

    print(deltax, 
      deltax/2 + x1 - 3, y1 - 6, kRED)
  end
  
  synch_protons:draw()

  draw_beampipe()

  player_proton:spr(player_proton.spr_id)

  local testp = make_moveable(player_proton.pos)
  testp.dpdt = player_proton.dpdt

  for Tf = 0, 360 do
    testp:update(FSPEED)

    local bf = get_bfield_list(MAGNETS, testp.pos)
    testp:kick(vec(0, - testp.dpdt.x * bf))

    if((Tf > 0) and (Tf%1)==0) then
      testp:pset(kGREEN)
    end

    if(abs(testp.pos.y - bp.y) > (bp.hwy-2)) then
      break
    end
    if((testp.pos.x - player_proton.pos.x) > 80) then
      break
    end
  end

  if(DEBUG_LEVEL > 0) then
    show_debug()
  end
  -- draw_grid()
end

function make_beampipe()
  bp={}
  bp.y = 80
  bp.x = 0
  bp.hwy = 20 -- y half width in px
end

function draw_beampipe()
  vprectfill(0, bp.y + bp.hwy, 127, bp.y + bp.hwy + 4, kDGRAY)
  vprectfill(0, bp.y - bp.hwy, 127, bp.y - bp.hwy - 4, kDGRAY)
end

function read_input()
  local delta = 1
  local magdelta = 0
  if (btnp(2)) magdelta += delta --up
  if (btnp(3)) magdelta -= delta --down

  for M =1, #MAGNETS do
    if((M%2) == 0) then
      MAGNETS[M].current = clamp(MAGNETS[M].current - (magdelta/5),-5,5)
    else
      MAGNETS[M].current = clamp(MAGNETS[M].current + (magdelta/5),-5,5)
    end
  end
end

function show_debug()
  vpprint("\131/\148: change focussing current",0,117)
  vpprint("\145: progress time",0,123)
  -- vpprint("\142: pair sep.   \151: x5 ",0,123)
  vpprint("beam loss: "..flr(100*(synch_nprotons - synch_protons:num())/(1 + synch_nprotons)).."%",
    0,8, kGREEN)
  vpprint("beam width: "..beam_width, 64, 8, kGREEN)
  vpprint("beam emit: "..beam_emittance,64,16,kGREEN)
  vpprint("foc. curr.: "..MAGNETS[1].current,0,16,kGREEN)

end