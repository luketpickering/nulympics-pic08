function random_slice_pos(from, to, radius, fill)
    fill = fill or true
    local a = normalize_arc(rnd(arc_len(from, to)) + from)
    radius = fill and rnd(radius) or radius
    return vec(radius * cos(a), radius * sin(-a))
end