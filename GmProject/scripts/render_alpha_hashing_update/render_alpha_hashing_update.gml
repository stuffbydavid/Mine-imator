function render_alpha_hashing_update()
{
	render_alpha_hashed_count = 0
	
	with (obj_timeline)
		if (render_alpha_hashing_used())
			other.render_alpha_hashed_count++
}
