/// block_texture_get_frame([realtime])
/// @arg [realtime]
/// @desc Current sheet frame for animation.

function block_texture_get_frame()
{
	var realtime = false;
	
	if (argument_count > 0)
		realtime = argument[0]
	
	return floor((realtime ? current_step : app.background_time) * app.background_texture_animation_speed) mod block_sheet_ani_frames
}
