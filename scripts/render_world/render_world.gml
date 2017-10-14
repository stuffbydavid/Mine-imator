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
render_world_ground()
render_world_sky_clouds()

// Positive depth
for (; i < ds_list_size(render_list); i++)
	with (render_list[|i])
		render_world_tl()
		
with (render_shader_obj)
	shader_clear()