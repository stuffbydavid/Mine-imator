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
tl_value_set(ALPHA, argument0, false)
tl_value_set(RGBADD, argument1, false)
tl_value_set(RGBSUB, argument2, false)
tl_value_set(RGBMUL, argument3, false)
tl_value_set(HSBADD, argument4, false)
tl_value_set(HSBSUB, argument5, false)
tl_value_set(HSBMUL, argument6, false)
tl_value_set(MIXCOLOR, argument7, false)
tl_value_set(MIXPERCENT, argument8, false)
tl_value_set(BRIGHTNESS, argument9, false)
tl_value_set_done()
