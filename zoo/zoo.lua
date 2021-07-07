function zoo_init()
  zoo_particles = {
    {make_moveable(vec(20,30)), kSPR_PROTON_R, "proton"},
    {make_moveable(vec(60,30)), kSPR_PIP_R, "pion+"},
    {make_moveable(vec(100,30)), kSPR_PIM_R, "pion-"},
    {make_moveable(vec(20,60)), kSPR_MU_R, "muon"},
    {make_moveable(vec(60,60)), kSPR_NU_R, "neutrino"},
  }
  GAME_STATES[STATE][2] = false
  part_selected = 1

  zoo_time = 0
end

function zoo_update(transitioning)
  zoo_time += FSPEED

  if (btnp(4) and not transitioning) STATE = 1

  local ch = 0
  if(btnp(2)) ch -= 1
  if(btnp(3)) ch += 1

  if(ch != 0) then
    part_selected = clamp(part_selected + ch, 1, #zoo_particles)
    zoo_time = 0
  end

end

function draw_card(spr_id, facts)
  local kSPR_CRNR = 55
  local kSPR_EDGET = 56
  local kSPR_EDGEL = 71

  vspr(kSPR_CRNR, 30, 16, 1, 1)
  vspr(kSPR_CRNR, 98, 16, 1, 1, true)
  vspr(kSPR_CRNR, 30,104, 1, 1, false,true)
  vspr(kSPR_CRNR, 98,104, 1, 1, true, true)

  for i = 1, 12 do
    vspr(kSPR_EDGET, 33 + 5 * i, 16)
    vspr(kSPR_EDGET, 33 + 5 * i, 104,1,1,false,true)
  end

  for i = 1, 16 do
    vspr(kSPR_EDGEL, 30, 19 + 5*i)
    vspr(kSPR_EDGEL, 98, 19 + 5*i,1,1,true)
  end
  rectfill(34,20,94,100,kLGRAY)

  palt(kBLACK, false)
  palt(kDBLUE, true)
  vspr(60,68, 36, 3,3)
  vspr(spr_id, 64, 36, 3,3)
  palt()

  rectfill(34,50,94,96,kDGRAY)

  print(facts.name, 50, 18, kBLACK)

  print("mASS:", 37, 54, kWHITE)
  print(facts.mass, 44, 60, kYELLOW)
  -- print(facts.charge, 37, 60, kWHITE)
  -- print(facts.discovered, 37, 66, kWHITE)

  print("id: "..facts.pid, 64, 98, kBLACK)

end

function zoo_draw()
  cls()
  local spr_id = 57
  local facts = {
    name = "proton",
    mass = "938 mEv/C^2",
    charge = "+1",
    discovered = "~1917",
    pid = 2212
  }
  draw_card(spr_id,facts)
  -- draw_grid()
  
  -- for I = 1, #zoo_particles do
  --   local P = zoo_particles[I]
  --   P[1]:spr(P[2], kDBLUE)
  --   print(P[3], P[1].pos.x - 4 - (#P[3]), P[1].pos.y-12,
  --         (I == part_selected) and 
  --         (zoo_time < 0.5) and kWHITE or kSLATE)

  -- zoo_time = zoo_time % 1
  -- print("\131/\148 : select, \142: choose",8,116,kWHITE)
  -- end
end