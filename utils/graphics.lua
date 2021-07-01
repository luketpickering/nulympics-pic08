kBLACK=0
kDBLUE=1
kMAROON=2
kDGREEN=3
kBROWN=4
kDGRAY=5
kLGRAY=6
kWHITE=7
kRED=8
kORANGE=9
kYELLOW=10
kGREEN=11
kLBLUE=12
kSLATE=13
kPINK=14
kFLESH=15

function draw_grid()

  for I = 0, 128,8 do
    for J = 0, 128, 4 do
      pset(I,J,kWHITE)
    end
  end

  for J = 0, 128,8 do
    for I = 0, 128, 4 do
      pset(I,J,kWHITE)
    end
  end

    for I = 0, 128,32 do
    for J = 0, 128, 4 do
      pset(I,J,kLBLUE)
    end
  end

  for J = 0, 128,32 do
    for I = 0, 128, 4 do
      pset(I,J,kLBLUE)
    end
  end

end

function tovpx(x)
  return x + peek2(0x5f28)
end

function tovpy(y)
  return y + peek2(0x5f2a)
end

function vprectfill(x1,y1,x2,y2,c)
  c = c or peek(0x5f25)
  rectfill(tovpx(x1),tovpy(y1),tovpx(x2),tovpy(y2), c)
end

function vpcirc(x,y,r,c)
  c = c or peek(0x5f25)
  circ(tovpx(x),tovpy(y),r, c)
end

function vpprint(s, x, y, c)
  c = c or peek(0x5f25)
  print(s, tovpx(x), tovpy(y), c)
end

function invp(x,y)
  return (tovpx(x) >= 0) and (tovpx(x) < 128) and 
         (tovpy(y) >= 0) and (tovpy(y) < 128)
end


-- function trline(x1, y1, x2, y2, c)
--   local dx = x2 - x1
--   local dy = y2 - y1
--   local d = sqrt(dx*dx + dy*dy)
--   local ang_a_to_b = atan2(dx,dy)

--   pset(x1,y1,c)
--   for I = 0, d+2 do
--     x1 += d/(d+3) * cos(ang_a_to_b)
--     y1 += d/(d+3) * sin(ang_a_to_b)
--     pset(x1,y1,c)
--   end
-- end

function arrow(x1, y1, x2, y2, arm_length, c)

  line(x1, y1, x2, y2, c)

  local ang_a_to_b = atan3(x2 - x1, y2 - y1)

  for I = -0.375, 0.375, 0.75 do
    line(x2, y2, 
      x2 + arm_length * cos(ang_a_to_b + I), 
      y2 + arm_length * nsin(ang_a_to_b + I), c)
  end
end

function arrow_ang(x1, y1, ang, length, arm_length, c)
  local x2 = x1 + length * cos(ang)
  local y2 = y1 + length * nsin(ang)
  arrow(x1,y1,x2,y2,arm_length,c)
end