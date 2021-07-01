function show_vmachine_stats(x, y, c)
  vpprint("cpu: "..flr(stat(1)*100).."%, mem:"..flr(stat(0)).."/2048", x, y, c)
end