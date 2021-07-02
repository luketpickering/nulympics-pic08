function boost_x(v, frame_vel_pxps)
	local beta = frame_vel_pxps / SPEED_OF_LIGHT_pxps
	local gamma = 1/sqrt(1-(beta*beta))
	return lvect(gamma * (v.x - frame_vel_pxps * v.t), v.y,  
		gamma * ( v.t - (beta * v.x) / SPEED_OF_LIGHT_pxps)
end