/// render_world_sky_clouds()
/// @desc Renders the cloud models.

if (!background_sky_clouds_show || !render_background || render_mode = e_render_mode.HIGH_SSAO_DEPTH_NORMAL)
	return 0

var res = background_sky_clouds_tex;
if (!res.ready)
	res = mc_res

// If using story mode clouds, slowly make them dissapear the closer the camera is to them
var alphay;
if (background_sky_clouds_story_mode)
	alphay = percent(cam_from[Z], background_sky_clouds_z, background_sky_clouds_z - 250)
else
	alphay = 1
	
// Shading
render_set_uniform_int("uIsSky", 1)
render_set_uniform_int("uSSAOEnable", 0)
render_set_uniform_color("uBlendColor", merge_color(background_sky_clouds_color, make_color_rgb(120, 120, 255), background_night_alpha), test(background_sky_clouds_story_mode, 1 - min(background_night_alpha, 0.95), .8 - min(background_night_alpha, 0.75)) * alphay)
render_set_uniform_color("uGlowColor", c_black, 1)
render_set_uniform_int("uGlowTexture", 0)

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
yo = (cam_from[Y] div size) * size - ((background_sky_clouds_speed * (current_step * 0.25 + background_sky_time * 100) + background_sky_clouds_offset) mod size)
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
render_set_uniform_int("uIsSky", 0)
render_set_uniform_int("uSSAOEnable", 1)
if (!background_fog_sky)
	render_set_uniform("uFogShow", (render_lights && app.background_fog_show))