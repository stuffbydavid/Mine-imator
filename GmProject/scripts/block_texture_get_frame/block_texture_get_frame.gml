/// block_texture_get_frame([realtime])
/// @arg [realtime]
/// @desc Current sheet frame for animation.

function block_texture_get_frame(realtime = false)
{
	if (app.background_texture_animation_speed = 0)
		return 0
	else
	{
		return floor(
			snap(
				mod_fix(
					(realtime ? current_step : app.background_time) * (app.background_texture_animation_speed / 3),
					minecraft_block_animated_sheet_size[2]
				), 0.001 * abs(app.background_texture_animation_speed) // correct precision errors
			)
		)
	}
}