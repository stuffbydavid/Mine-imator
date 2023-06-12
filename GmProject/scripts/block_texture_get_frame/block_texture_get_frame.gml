/// block_texture_get_frame([realtime])
/// @arg [realtime]
/// @desc Current sheet frame for animation.

function block_texture_get_frame(realtime = false)
{
	return floor((realtime ? current_step : app.background_time) * app.background_texture_animation_speed) mod block_sheet_ani_frames
}
