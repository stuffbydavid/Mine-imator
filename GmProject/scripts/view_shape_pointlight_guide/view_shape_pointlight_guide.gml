/// view_shape_pointlight_guide(timeline)
/// @arg timeline
/// @desc Renders an outline of a pointlight's light.

function view_shape_pointlight_guide(tl)
{
	var range, fadesize;
	range = tl.value[e_value.LIGHT_RANGE]
	fadesize = tl.value[e_value.LIGHT_FADE_SIZE]
	
	//draw_set_alpha(.5)
	
	// Range
	draw_set_color(c_control_red)
	view_shape_circle(point3D_add(tl.world_pos, vec3(0, 0, 0)), max(0, range))
	
	// Fade size
	draw_set_color(c_control_yellow)
	view_shape_circle(point3D_add(tl.world_pos, vec3(0, 0, 0)), max(0, range) * clamp((1 - fadesize), 0, 1))
	
	draw_set_color(c_white)
	//draw_set_alpha(1)
}