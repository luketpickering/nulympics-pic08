function normalize_arc(x)
    while x < 0 do
        x += 1
    end
    return x % 1
end

function arc_cross_bound(from, to)
  return normalize_arc(from) > normalize_arc(to)
end

function in_arc(from, to, x)
    if (arc_cross_bound(from, to)) return x >= from or x <= to
    return x >= from and x <= to
end

function gt_arc(from, to, x)
  x = normalize_arc(x)
  if (in_arc(from, to, x)) return false
  return abs(x - to) < abs(x - from)
end

function lt_arc(from, to, x)
  if (in_arc(from, to, x)) return false
  return not gt_arc(from, to, x)
end

function arc_len(from, to)
  if (arc_cross_bound(from, to)) return 1 - from + to
  return to - from
end