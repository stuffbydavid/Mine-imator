/// render_world(mode)
/// @arg mode

render_mode = argument0

// Render negative depth
var i;
for (i = 0; i < ds_list_size(render_list); i++)
{
	var tl = render_list[|i];
	if (tl.depth >= 0)
		break
	with (tl)
		tl_render()
}

// Neutral depth (0)
if (render_mode != "click" &&
	render_mode != "select" &&
	render_mode != "highlightsundepth" &&
	render_mode != "highlightspotdepth" &&
	render_mode != "highlightpointdepth" &&
	render_mode != "alphatest")
{
	render_world_ground()
	render_world_sky_clouds()
}

// Positive depth
for (; i < ds_list_size(render_list); i++)
	with (render_list[|i])
		tl_render()