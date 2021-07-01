function clamp(x,l,u)
    return max(l,min(x,u))
end

function sign(x)
    if(x >= 0) then return 1
    else return -1 end
end

function nsin(x)
    return sin(-x)
end

function atan3(x,y)
    return atan2(x,-y)
end