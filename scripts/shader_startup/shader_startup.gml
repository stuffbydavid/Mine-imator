/// shader_startup()

globalvar shader_tl, shader_texture, shader_texture_gm, shader_blend_color, shader_alpha, shader_replace_color, shader_is_ground;
globalvar shader_colors_ext, shader_mixcolor, shader_mixpercent, shader_brightness;
globalvar shader_rgbadd, shader_rgbsub, shader_rgbmul;
globalvar shader_hsbadd, shader_hsbsub, shader_hsbmul;
globalvar shader_lights;
globalvar shader_light_from, shader_light_to;
globalvar shader_light_near, shader_light_far, shader_light_fov;
globalvar shader_light_color, shader_light_fadesize, shader_light_spotsharpness;
globalvar shader_light_matrix;
globalvar shader_texture_filter_linear, shader_texture_filter_mipmap, shader_wind, shader_wind_terrain, shader_ssao, shader_fog;

var err = false;

new_shader("shader_border", shader_border)
new_shader("shader_blend", shader_blend)
new_shader("shader_blend_fog", shader_blend_fog)
new_shader("shader_color_fog", shader_color_fog)
new_shader("shader_color_fog_lights", shader_color_fog_lights)
new_shader("shader_depth", shader_depth)
new_shader("shader_draw_texture", shader_draw_texture)
new_shader("shader_replace", shader_replace)
new_shader("shader_high_aa", shader_high_aa)
new_shader("shader_high_dof", shader_high_dof)
new_shader("shader_high_fog", shader_high_fog)
new_shader("shader_high_fog_apply", shader_high_fog_apply)
new_shader("shader_high_light_sun", shader_high_light_sun)
new_shader("shader_high_light_spot", shader_high_light_spot)
new_shader("shader_high_light_point", shader_high_light_point)
new_shader("shader_high_light_night", shader_high_light_night)
new_shader("shader_high_light_apply", shader_high_light_apply)
new_shader("shader_high_ssao_depth_normal", shader_high_ssao_depth_normal)
new_shader("shader_high_ssao", shader_high_ssao)
new_shader("shader_high_ssao_blur", shader_high_ssao_blur)

shader_clear()
log("Shader init")

// Supported?
log("shaders_are_supported", yesno(shaders_are_supported()))
if (!shaders_are_supported())
	err = true

// Compiled?
if (!err)
{
	with (obj_shader)
	{
		log(name + " compiled", yesno(shader_is_compiled(shader)))
		
		if (!shader_is_compiled(shader))
		{
			err = true
			break
		}
	}
}

if (err)
{
	log("Shader compilation failed")
	log("Download DirectX runtime", link_directx)
	if (show_question("Some shaders failed to compile.\nYour graphics drivers are outdated or DirectX runtime is missing. Download DirectX runtime now?"))
		open_url(link_directx)
		
	game_end()
	return 0
}

return 1
