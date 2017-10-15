/// render_world(mode)
/// @arg mode

// Choose shader
render_mode = argument0
render_shader_obj = shader_map[?render_mode_shader_map[?render_mode]]
with (render_shader_obj)
	shader_use()

// Render negative depth
var i;
for (i = 0; i < ds_list_size(render_list); i++)
{
	var tl = render_list[|i];
	if (tl.depth >= 0)
		break
	with (tl)
		render_world_tl()
}

// Neutral depth (0)

if (render_mode != e_render_mode.CLICK &&
	render_mode != e_render_mode.SELECT &&
	render_mode != e_render_mode.HIGH_LIGHT_SUN_DEPTH &&
	render_mode != e_render_mode.HIGH_LIGHT_SPOT_DEPTH &&
	render_mode != e_render_mode.HIGH_LIGHT_POINT_DEPTH &&
	render_mode != e_render_mode.ALPHA_TEST)
{
	render_world_ground()
	render_world_sky_clouds()
}

// Positive depth
for (; i < ds_list_size(render_list); i++)
	with (render_list[|i])
		render_world_tl()
		
with (render_shader_obj)
	shader_clear()