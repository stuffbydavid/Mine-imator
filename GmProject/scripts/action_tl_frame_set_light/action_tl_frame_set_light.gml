/// action_tl_frame_set_light(color, strength, specstrength, size, range, fadesize, spotradius, spotsharpness)
/// @arg color
/// @arg strength
/// @arg specstrength
/// @arg size
/// @arg range
/// @arg fadesize
/// @arg spotradius
/// @arg spotsharpness

function action_tl_frame_set_light(color, strength, specstrength, size, range, fadesize, spotradius, spotsharpness)
{
	tl_value_set_start(action_tl_frame_set_light, false)
	tl_value_set(e_value.LIGHT_COLOR, color, false)
	tl_value_set(e_value.LIGHT_STRENGTH, strength, false)
	tl_value_set(e_value.LIGHT_SPECULAR_STRENGTH, specstrength, false)
	tl_value_set(e_value.LIGHT_SIZE, size, false)
	tl_value_set(e_value.LIGHT_RANGE, range, false)
	tl_value_set(e_value.LIGHT_FADE_SIZE, fadesize, false)
	tl_value_set(e_value.LIGHT_SPOT_RADIUS, spotradius, false)
	tl_value_set(e_value.LIGHT_SPOT_SHARPNESS, spotsharpness, false)
	tl_value_set_done()
}
