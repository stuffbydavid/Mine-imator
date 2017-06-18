/// render_world_sky_clouds()

if (!background_sky_clouds_show || !render_background)
	return 0
	
if (render_mode = "highfog")// && !background_fog_sky)
	return 0
	
var size, xo, yo, num, res, xx;
size = background_sky_clouds_size * 32
xo = (cam_from[X] div size) * size
yo = (cam_from[Y] div size) * size - (background_sky_clouds_speed * (current_step * 0.25 + background_sky_time * 100) mod size)
num = (ceil(background_fog_distance / size) + 1) * size
res = background_sky_clouds_tex

if (!res.ready)
	res = res_def

shader_blend_color = merge_color(background_sky_clouds_color, make_color_rgb(120, 120, 255), background_night_alpha)
shader_alpha = 0.8 - min(background_night_alpha, 0.75)
shader_texture = test(res.type = "pack", res.clouds_texture, res.texture)

switch (render_mode)
{
	case "highlightsun":
	case "highlightspot":
	case "highlightpoint":
	case "highlightnight": // Fully lit
		shader_replace_color = c_white
		shader_replace_set()
		break
		
	case "highfog": shader_high_fog_set() break
	case "highdofdepth": shader_depth_set() break
		
	default:
		if (background_fog_show && background_fog_sky)
			shader_blend_fog_set()
		else
			shader_blend_set()
		break
}

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

shader_clear()