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

function zoo_draw()
  cls()
  for I = 1, #zoo_particles do
    local P = zoo_particles[I]
    P[1]:spr(P[2], kDBLUE)
    print(P[3], P[1].pos.x - 4 - (#P[3]), P[1].pos.y-12,
          (I == part_selected) and 
          (zoo_time < 0.5) and kWHITE or kSLATE)

  zoo_time = zoo_time % 1
  print("\131/\148 : select, \142: choose",8,116,kWHITE)
  end
end