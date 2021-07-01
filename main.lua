function menu_init()
  menu_time = 0
  GAME_STATES[STATE][2] = false
  selected = 1
end

function menu_update()
  menu_time += 1/30

  local ch = 0
  if(btnp(2)) ch -= 1
  if(btnp(3)) ch += 1
  if(ch != 0) then
    menu_time = 0 
    selected = clamp(selected + ch, 1, #GAME_STATES-1)
  end

  if(btnp(4)) then 
    STATE = selected + 1
    _update()
  end
end

function menu_draw()
  cls()

  circ(2,2,2,kGREEN)
  circ(2,125,2,kGREEN)
  circ(125,2,2,kGREEN)
  circ(125,125,2,kGREEN)

  line(5, 128-5, 128-5, 128-5, kGREEN)
  line(5, 5, 128-5, 5, kGREEN)

  line(5, 5, 5, 128-5, kGREEN)
  line(128-5, 5, 128-5, 128-5, kGREEN)

  print("neutrino olympics", 28, 16, kSLATE)
  line(30, 22, 92, 22, kSLATE)

  for I = 2, #GAME_STATES do
    local menu_it = (I-1)
    print(menu_it..": "..GAME_STATES[I][1], 24, 24 + 8*menu_it, 
      (menu_it == selected) and 
      (menu_time < 1/2) and kWHITE or kSLATE)
  end

  menu_time = menu_time % 1
  print("\131/\148 : select, \142: choose",8,116,kWHITE)
end

GAME_STATES = {
  {"MENU", true, menu_init, menu_update, menu_draw},
  {"linacCEL"},
  {"synch", true, accelerate_init, accelerate_update, accelerate_draw},
  {"focus", },
  {"decay", true, decay_init, decay_update, decay_draw },
  {"interact"},
  {"oscillate", },
}

function _init()
  STATE = 1
end

function _update()
  if (GAME_STATES[STATE][2]) GAME_STATES[STATE][3]()
  GAME_STATES[STATE][4]()
end

function _draw()
  GAME_STATES[STATE][5]()
  show_vmachine_stats(10, 0, kWHITE)
end