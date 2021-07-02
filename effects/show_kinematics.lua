function draw_vel_arrow(moveable, scale, color)
	if (scale*vmag(moveable.dpdt) < 1) return
	arrow_ang(moveable.pos.x, moveable.pos.y, 
		vang(moveable.dpdt), scale*vmag(moveable.dpdt), 3, color)
end

function draw_impulse_arrow(moveable, scale, color)
	if (scale*vmag(moveable.last_impulse) < 1) return
	arrow_ang(moveable.pos.x, moveable.pos.y, 
		vang(moveable.last_impulse), scale*vmag(moveable.last_impulse), 3, color)
end