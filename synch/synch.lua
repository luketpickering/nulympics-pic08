
function accelerate_init()
  init_debug()

  MAGSPACING=128

  MAGSPACING=clamp(MAGSPACING,MSPACE_MIN,MSPACE_MAX)

  FODOGAP = FODO_MIN
  FODOGAP=clamp(FODOGAP,FODO_MIN,MAGSPACING)

  WINDIST=10000

  ACC_STATE=kSTART

  MAGNETS = {}
  add(MAGNETS, create_magnet(vec(64,80),vec(16,32)))
  add(MAGNETS, create_magnet(vec(64+FODOGAP,80),vec(16,32)))
  add(MAGNETS, create_magnet(vec(64+MAGSPACING,80),vec(16,32)))
  add(MAGNETS, create_magnet(vec(64+FODOGAP+MAGSPACING,80),vec(16,32)))
  add(MAGNETS, create_magnet(vec(64+(2*MAGSPACING),80),vec(16,32)))
  add(MAGNETS, create_magnet(vec(64+FODOGAP+(2*MAGSPACING),80),vec(16,32)))
  MAGNETS[1].current = 0

  PROTONS = {}
  add(PROTONS, create_proton(vec(rnd(16),80 - 16 + rnd(32)), vec(100,rnd(20)-10),5))
  add(PROTONS, create_proton(vec(rnd(16),80 - 16 + rnd(32)), vec(100,rnd(20)-10),5))
  add(PROTONS, create_proton(vec(rnd(16),80 - 16 + rnd(32)), vec(100,rnd(20)-10),5))
  add(PROTONS, create_proton(vec(rnd(16),80 - 16 + rnd(32)), vec(100,rnd(20)-10),5))
  add(PROTONS, create_proton(vec(rnd(16),80 - 16 + rnd(32)), vec(100,rnd(20)-10),5))
  add(PROTONS, create_proton(vec(rnd(16),80 - 16 + rnd(32)), vec(100,rnd(20)-10),5))

  player_proton = create_proton(vec(8,80 - 16 + rnd(32)), vec(100,rnd(20)-10))

  make_beampipe()

  ACC_STATE=kRUN

  GAME_STATES[STATE][2] = false
end

function accelerate_update()

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

  if(ACC_STATE == kRUN) then
    read_input()
    local bf = 0
    for M in all(MAGNETS) do
      bf += get_bfield(M, player_proton.pos)
    end
    force(player_proton, vec(0,-player_proton.dpdt.x * bf))
    advance(player_proton, 1/30)

    for P in all(PROTONS) do
      local bf = 0
      for M in all(MAGNETS) do
        bf += get_bfield(M, P.pos)
      end

      force(P, vec(0,-P.dpdt.x * bf))
      advance(P, 1/30)
    end

    if(abs(player_proton.pos.y - bp.y) > (bp.hwy-2)) then
      ACC_STATE = kEND
    end

    if(player_proton.pos.x > WINDIST) then
      ACC_STATE = kWIN
    end

    for P in all(PROTONS) do
      if(abs(P.pos.y - bp.y) > (bp.hwy-2)) then
        del(PROTONS,P)
      end
    end
  end

  camera(player_proton.pos.x - 16, 0)
end

function accelerate_draw()
  
  if(ACC_STATE==kEND) then
    print("BEAM LOSS!", 0,24)
    return
  end
  
  if(ACC_STATE==kWIN) then
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
  
  for P in all(PROTONS) do
    draw_moveable(P)
  end

  draw_beampipe()
  draw_moveable(player_proton)

  local testp = create_moveable(player_proton.pos, player_proton.dpdt)
  local bf = 0

  for Tf = 0, 360 do
    advance(testp, 1/30)
    bf = 0

    for M in all(MAGNETS) do
      bf += get_bfield(M, testp.pos)
    end

    force(testp, vec(0,-testp.dpdt.x * bf))
    if((Tf > 0) and (Tf%1)==0) then
      pset(testp.pos.x, testp.pos.y, 11)
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
  bp.hwy = 20 -- y half width in px
end

function draw_beampipe()
  vprectfill(0, bp.y + bp.hwy, 127, bp.y + bp.hwy + 4, kDGRAY)
  vprectfill(0, bp.y - bp.hwy, 127, bp.y - bp.hwy - 4, kDGRAY)
end

function read_input()
  local fododelta = 0
  local magspacedelta = 0
  local delta = 1
  if (btn(5)) then
    delta = 5
  end

  if (btn(4)) then
    if (btnp(0)) magspacedelta-=delta --left
    if (btnp(1)) magspacedelta+=delta --right
  else
    if (btnp(0)) fododelta-=delta --left
    if (btnp(1)) fododelta+=delta --right
  end

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

  MAGSPACING = clamp(MAGSPACING + magspacedelta, MSPACE_MIN, MSPACE_MAX)

  FODOGAP = clamp(FODOGAP + fododelta, FODO_MIN, MAGSPACING)

end

function show_debug()
  vpprint("sep/curr: \139/\131: down \145/\148: up. ",0,116)
  vpprint("\142: pair sep.   \151: x5 ",0,123)
  vpprint("game ACC_state:"..ACC_STATE_NAMES[ACC_STATE],0,0)
  vpprint("cpu: "..flr(stat(1)*100).."%, MEM:"..flr(stat(0)).."/2048",0,8)
  vpprint("curr: "..MAGNETS[1].current,90,0)
  vpprint("pair: "..FODOGAP,90,8)
  vpprint("grp: "..MAGSPACING,90,16)
end