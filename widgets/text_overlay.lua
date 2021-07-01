function make_overlay(title, text, bc, tc)
  bc = bc or kGREEN
  tc = tc or kSLATE
  return {
    scroll = 0,
    update = function(self)
      if (btnp(3)) self.scroll = clamp(self.scroll + 1, 0, #text - 6) 
      if (btnp(2)) self.scroll = clamp(self.scroll - 1, 0, #text - 6) 
    end,
    draw = function(self)
      rectfill(15,15,128-15,128-15,kBLACK)
      circ(15,15,1,bc)
      circ(15,112,1,bc)
      circ(112,15,1,bc)
      circ(112,112,1,bc)

      line(18, 128-18, 128-18, 128-18, bc)
      line(18, 18, 128-18, 18, bc)

      line(18, 18, 18, 128-18, bc)
      line(128-18, 18, 128-18, 128-18, bc)
        
      print(title,28,24, tc)
      line(27,30,28 + 4*#title - 2, 30, tc)
      local ybottom = 30
      for I = 1 + self.scroll, #text do
        ybottom += 8
        print(text[I], 28, ybottom, tc)
        if ((I - self.scroll) > 6) break
      end

      print("\151 to continue...",24,102,tc)

-- \139/\131: down \145/\148:
      if((6 + self.scroll) < #text) print("\131",101,102, kWHITE)
      if(self.scroll > 0) print("\148",101,30, kWHITE)
    end
  }
end