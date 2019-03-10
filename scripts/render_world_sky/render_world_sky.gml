/// render_world_sky()
/// @desc Draws the sky or custom background as either a skybox or skysphere.

if (!render_background)
	return 0

// Choose shader
render_shader_obj = shader_map[?shader_blend]
with (render_shader_obj)
	shader_use()
	
var dis = 15000;
gpu_set_zwriteenable(false)

// Image
if (background_image_show && background_image != null && background_image_type != "image")
{
	var vbuf;
	
	if (background_image_type = "sphere") // Sphere
	{
		if (!background_image_sphere_vbuffer)
			background_image_sphere_vbuffer = vbuffer_create_sphere(dis, point2D(1, 0), point2D(0, 1), 32, true)
		 vbuf = background_image_sphere_vbuffer
	}
	else if (background_image_type = "box") // Box
	{
		if (background_image_box_mapped)
		{
			if (!background_image_cube_mapped_vbuffer)
				background_image_cube_mapped_vbuffer = vbuffer_create_cube(dis, point2D(0, 0), point2D(1, 1), -1, 1, true, true)
			vbuf = background_image_cube_mapped_vbuffer
		}
		else
		{
			if (!background_image_cube_vbuffer)
				background_image_cube_vbuffer = vbuffer_create_cube(dis, point2D(1, 0), point2D(0, 1), 1, 1, true, false)
			vbuf = background_image_cube_vbuffer
		}
	}
	
	render_set_uniform_color("uBlendColor", c_white, 1)
	render_set_texture(background_image.texture)
	vbuffer_render(vbuf, cam_from)
}

// Fog
if (background_fog_show && background_fog_sky)
{
	if (background_fog_vbuffer = null)
		background_fog_vbuffer = vbuffer_create_sphere(dis, point2D(0, 0), point2D(1, 1), 16, true)
		
	gpu_set_texrepeat(false)
	
	//shader_texture_filter_linear = true
	render_set_uniform_color("uBlendColor", background_fog_color_final, 1)
	render_set_texture(background_fog_texture)
	vbuffer_render(background_fog_vbuffer, cam_from, vec3(0), vec3(1, 1, (background_fog_height / 1000) + ((background_fog_height / 1000) * max(background_sunrise_alpha, background_sunset_alpha))))
	//shader_texture_filter_linear = false
	
	gpu_set_texrepeat(true)
}

// Sky
if (!background_image_show)
{
	var skymat = matrix_build(cam_from[X], cam_from[Y], cam_from[Z], -background_sky_time, 0, background_sky_rotation, 1, 1, 1);
	
	// Stars
	if (background_night_alpha > 0)
	{
		if (background_sky_stars_vbuffer = null)
			background_sky_stars_vbuffer = vbuffer_create_cube(dis * 0.8, point2D(0, 0), point2D(2, 2), false, false, true, false)// vbuffer_create_sphere(dis * 0.8, point2D(0, 0), point2D(6, 6), 8, true)
			
		render_set_uniform_color("uBlendColor", c_white, 0.4 * background_night_alpha)
		render_set_texture(background_sky_stars_texture)
		vbuffer_render_matrix(background_sky_stars_vbuffer, skymat)
	}
	
	gpu_set_blendmode(bm_add)
	
	// Sun
	if (background_sky_sun_vbuffer = null)
		background_sky_sun_vbuffer = vbuffer_create_surface(1750, point2D(0, 0), point2D(1, 1), false)
		
	render_set_uniform_color("uBlendColor", c_white, 1 - background_night_alpha)
	if (background_sky_sun_tex.type = e_res_type.PACK)
		render_set_texture(background_sky_sun_tex.sun_texture)
	else
		render_set_texture(background_sky_sun_tex.texture)
	vbuffer_render_matrix(background_sky_sun_vbuffer, matrix_multiply(matrix_build(0, 0, dis * 0.7, 90, 0, 0, 1, 1, 1), skymat))
	
	// Moon
	if (background_sky_moon_vbuffer = null)
		background_sky_moon_vbuffer = vbuffer_create_surface(1000, point2D(0, 0), point2D(1, 1), false)
		
	render_set_uniform_color("uBlendColor", c_white, background_night_alpha)
	if (background_sky_moon_tex.type = e_res_type.PACK && background_sky_moon_tex.ready)
		render_set_texture(background_sky_moon_tex.moon_texture[background_sky_moon_phase])
	else
		render_set_texture(background_sky_moon_tex.texture)
	vbuffer_render_matrix(background_sky_sun_vbuffer, matrix_multiply(matrix_build(0, 0, -dis * 0.7, -90, 0, 0, 1, 1, 1), skymat))
	
	gpu_set_blendmode(bm_normal)
}

// Clear shader
with (render_shader_obj)
	shader_clear()
gpu_set_zwriteenable(true)
