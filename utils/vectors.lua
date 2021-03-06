function vec(x,y)
	return {x = x or 0, y = y or 0}
end

function vcopy(a)
	return {x = a.x or 0, y = a.y or 0}
end

function lvec(x,y,t)
	return {x = x or 0, y = y or 0, t = t or 0}
end

function vadd(a, b)
	return vec(a.x + b.x, a.y + b.y)
end

function vscale(s,a)
	return vec(s*a.x, s*a.y)
end

function vmag2(a)
	return a.x*a.x + a.y*a.y
end

function vmag(a)
	return sqrt(vmag2(a))
end

function vdot(a,b)
	return (a.x*b.x + a.y*b.y)
end

function vunit(a)
	return vscale(1.0/vmag(a),a)
end

function vneg(a)
	return vec(-a.x,-a.y)
end

function vatob(a,b)
	return vadd(b,vneg(a))
end

function vang(a)
	return atan3(a.x,a.y)
end

function v2s(v)
	return ("{ x: "..v.x..", y:"..v.y.." }")
end