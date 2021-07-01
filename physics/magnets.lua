function create_magnet(center, hsize)
  return {
    center = center,
    hwidth = hsize.y,
    hlength = hsize.x,
    current = 0
  }
end

-- +ve is into the page
-- +ve makes +ve charge bend up
function get_bfield(mag, test_pos)

  local disp = vatob(mag.center, test_pos)

  if(abs(disp.x) > mag.hlength) then return 0 end

  if(MAGNETS_DEBUG) then
    printh("--mag test: {"..test_pos.x..", "..test_pos.y.."}")
    printh("--mag.center: {"..mag.center.x..", "..mag.center.y.."}")
    printh("--mag disp: {"..disp.x..", "..disp.y.."}")
    printh("--mag force: {"..mag.current.."*"..(disp.y / mag.hwidth).."}")
  end

  return mag.current * (disp.y / mag.hwidth) / 30

end

function draw_magnet(mag, camera_offset)
  rectfill(mag.center.x - mag.hlength, mag.center.y - mag.hwidth - 4, 
    mag.center.x + mag.hlength-1, mag.center.y + mag.hwidth + 4, kDBLUE)
  rectfill(mag.center.x - mag.hlength, mag.center.y - mag.hwidth - 2, 
    mag.center.x + mag.hlength-1, mag.center.y - mag.hwidth + 2, kORANGE)
  rectfill(mag.center.x - mag.hlength, mag.center.y + mag.hwidth - 2, 
    mag.center.x + mag.hlength-1, mag.center.y + mag.hwidth + 2, kORANGE)
  
  if(MAGNETS_DEBUG) then
    line(mag.center.x,mag.center.y-mag.hwidth, mag.center.x,mag.center.y + mag.hwidth, kGREEN)
    line(mag.center.x + mag.hlength,mag.center.y, mag.center.x - mag.hlength,mag.center.y, kGREEN)
  end

  if(abs(mag.current) > 0) then
    -- into is 41, out is 40
    local sprn = {40, 41};
    if(mag.current < 0) then
      sprn[1] = 41
      sprn[2] = 40
      print("D", mag.center.x - 1,mag.center.y - 4, kWHITE)
    else
      print("F", mag.center.x - 1,mag.center.y - 4, kWHITE)
    end

    --bottom is +ve/into
    vspr(sprn[1], mag.center.x, mag.center.y - (mag.hwidth * 0.3))
    vspr(sprn[2], mag.center.x, mag.center.y + (mag.hwidth * 0.3))
  end

end