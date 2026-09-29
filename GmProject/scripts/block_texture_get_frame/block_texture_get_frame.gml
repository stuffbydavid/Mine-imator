/// @desc Returns the current sheet frame for animation.

function block_texture_get_frame(realtime = false)
{
	if (app.background_texture_animation_speed = 0)
		return 0
	
	return floor(
		mod_fix(snap(
			mod_fix(
				(realtime ? current_step : app.background_time) * (app.background_texture_animation_speed / 3),
				minecraft_block_animated_sheet_frame_count
			), 0.001 * abs(app.background_texture_animation_speed) // correct precision errors
		), minecraft_block_animated_sheet_frame_count)
	)
}
