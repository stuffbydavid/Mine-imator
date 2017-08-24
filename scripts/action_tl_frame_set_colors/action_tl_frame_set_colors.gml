/// action_tl_frame_set_colors(alpha, rgbadd, rgbsub, rgbmul, hsbadd, hsbsub, hsbmul, mixcolor, mixpercent, brightness)
/// @arg alpha
/// @arg rgbadd
/// @arg rgbsub
/// @arg rgbmul
/// @arg hsbadd
/// @arg hsbsub
/// @arg hsbmul
/// @arg mixcolor
/// @arg mixpercent
/// @arg brightness

tl_value_set_start(action_tl_frame_set_colors, false)
tl_value_set(e_value.ALPHA, argument0, false)
tl_value_set(e_value.RGB_ADD, argument1, false)
tl_value_set(e_value.RGB_SUB, argument2, false)
tl_value_set(e_value.RGB_MUL, argument3, false)
tl_value_set(e_value.HSB_ADD, argument4, false)
tl_value_set(e_value.HSB_SUB, argument5, false)
tl_value_set(e_value.HSB_MUL, argument6, false)
tl_value_set(e_value.MIX_COLOR, argument7, false)
tl_value_set(e_value.MIX_PERCENT, argument8, false)
tl_value_set(e_value.BRIGHTNESS, argument9, false)
tl_value_set_done()
