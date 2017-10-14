/// render_world_sky_clouds()
/// @desc Renders the cloud models.

if (render_mode = e_render_mode.CLICK ||
	render_mode = e_render_mode.SELECT ||
	render_mode = e_render_mode.HIGH_LIGHT_SUN_DEPTH ||
	render_mode = e_render_mode.HIGH_LIGHT_SPOT_DEPTH ||
	render_mode = e_render_mode.HIGH_LIGHT_POINT_DEPTH ||
	render_mode = e_render_mode.ALPHA_TEST ||
	render_mode = e_render_mode.HIGH_FOG)
	return 0

if (!background_sky_clouds_show || !render_background)
	return 0

var res = background_sky_clouds_tex;
if (!res.ready)
	res = mc_res

// Shading
render_set_uniform_int("uIsSky", true)
render_set_uniform_color("uBlendColor", merge_color(background_sky_clouds_color, make_color_rgb(120, 120, 255), background_night_alpha), 0.8 - min(background_night_alpha, 0.75))

// Texture
if (res.type = e_res_type.PACK)
	render_set_texture(res.clouds_texture)
else
	render_set_texture(res.texture)
	
// Disable fog
if (!background_fog_sky)
	render_set_uniform("uFogShow", 0)

var size, xo, yo, num, xx
size = background_sky_clouds_size * 32
xo = (cam_from[X] div size) * size
yo = (cam_from[Y] div size) * size - (background_sky_clouds_speed * (current_step * 0.25 + background_sky_time * 100) mod size)
num = (ceil(background_fog_distance / size) + 1) * size
xx = -num
while (xx < num)
{
	var yy = -num;
	while (yy < num)
	{
		vbuffer_render(background_sky_clouds_vbuffer, point3D(xx + xo, yy + yo, background_sky_clouds_z))
		yy += size
	}
	xx += size
}

// Reset
render_set_uniform_int("uIsSky", false)
if (!background_fog_sky)
	render_set_uniform("uFogShow", (render_lights && app.background_fog_show))