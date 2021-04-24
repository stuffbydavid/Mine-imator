/// action_tl_frame_set_colors(alpha, rgbadd, rgbsub, rgbmul, hsbadd, hsbsub, hsbmul, mixcolor, glowcolor, mixpercent, brightness)
/// @arg alpha
/// @arg rgbadd
/// @arg rgbsub
/// @arg rgbmul
/// @arg hsbadd
/// @arg hsbsub
/// @arg hsbmul
/// @arg mixcolor
/// @arg glowcolor
/// @arg mixpercent
/// @arg brightness

function action_tl_frame_set_colors(alpha, rgbadd, rgbsub, rgbmul, hsbadd, hsbsub, hsbmul, mixcolor, glowcolor, mixpercent, brightness)
{
	tl_value_set_start(action_tl_frame_set_colors, false)
	tl_value_set(e_value.ALPHA, alpha, false)
	tl_value_set(e_value.RGB_ADD, rgbadd, false)
	tl_value_set(e_value.RGB_SUB, rgbsub, false)
	tl_value_set(e_value.RGB_MUL, rgbmul, false)
	tl_value_set(e_value.HSB_ADD, hsbadd, false)
	tl_value_set(e_value.HSB_SUB, hsbsub, false)
	tl_value_set(e_value.HSB_MUL, hsbmul, false)
	tl_value_set(e_value.MIX_COLOR, mixcolor, false)
	tl_value_set(e_value.GLOW_COLOR, glowcolor, false)
	tl_value_set(e_value.MIX_PERCENT, mixpercent, false)
	tl_value_set(e_value.BRIGHTNESS, brightness, false)
	tl_value_set_done()
}
