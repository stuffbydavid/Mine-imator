/// render_world_sky()
/// @desc Draws the sky or custom background as either a skybox or skysphere.

var dis = 15000;

if (!render_background)
    return 0

gpu_set_zwriteenable(false)

// Image
if (background_image_show && background_image && background_image_type > 0)
{
    var vbuf;
    
    if (background_image_type = 1) // Sphere
	{
        if (!background_image_sphere_vbuffer)
            background_image_sphere_vbuffer = vbuffer_create_sphere(dis, point2D(1, 0), point2D(0, 1), 32, true)
         vbuf = background_image_sphere_vbuffer
    }
	else if (background_image_type = 2) // Cube
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
    
    shader_blend_color = c_white
    shader_alpha = 1
    shader_texture = background_image.texture
    shader_texture_gm = false
    shader_blend_set()
    vbuffer_render(vbuf, cam_from)
}

// Fog
if (background_fog_show && background_fog_sky)
{
    if (!background_fog_vbuffer)
        background_fog_vbuffer = vbuffer_create_sphere(dis, point2D(0, 0), point2D(1, 1), 16, true)
        
    gpu_set_texrepeat(false)
	shader_texture_filter_linear = true
    shader_blend_color = background_fog_color_final
    shader_alpha = 1
    shader_texture = sprite_get_texture(spr_fog, 0)
    shader_texture_gm = true
    shader_blend_set()
    vbuffer_render(background_fog_vbuffer, cam_from, vec3(0), vec3(1, 1, background_fog_height / 1000))
	shader_texture_filter_linear = false
    gpu_set_texrepeat(true)
}

// Sky
if (!background_image_show)
{
    var skymat = matrix_build(cam_from[X], cam_from[Y], cam_from[Z], -background_sky_time, 0, background_sky_rotation, 1, 1, 1);
    
    // Stars
    if (background_night_alpha > 0)
	{
        if (!background_sky_stars_vbuffer)
            background_sky_stars_vbuffer = vbuffer_create_sphere(dis * 0.8, point2D(0, 0), point2D(6, 6), 8, true)
            
        shader_blend_color = c_white
        shader_alpha = 0.4 * background_night_alpha
        shader_texture = sprite_get_texture(spr_stars, 0)
        shader_texture_gm = true
        shader_blend_set()
        vbuffer_render_matrix(background_sky_stars_vbuffer, skymat)
    }
    
    gpu_set_blendmode(bm_add)
    
    // Sun
    if (!background_sky_sun_vbuffer)
        background_sky_sun_vbuffer = vbuffer_create_surface(1000, point2D(0, 0), point2D(1, 1), false)
        
    shader_blend_color = c_white
    shader_alpha = 1-background_night_alpha
    shader_texture = test(background_sky_sun_tex.type = "pack", background_sky_sun_tex.sun_texture, background_sky_sun_tex.texture)
    shader_texture_gm = false
    shader_blend_set()
    vbuffer_render_matrix(background_sky_sun_vbuffer, matrix_multiply(matrix_build(0, 0, dis * 0.7, 90, 0, 0, 1, 1, 1), skymat))
    
    // Moon
    if (!background_sky_moon_vbuffer)
        background_sky_moon_vbuffer = vbuffer_create_surface(1000, point2D(0, 0), point2D(1, 1), false)
        
    shader_blend_color = c_white
    shader_alpha = background_night_alpha
    shader_texture = test(background_sky_moon_tex.type = "pack", background_sky_moon_tex.moon_texture[background_sky_moon_phase], background_sky_moon_tex.texture)
    shader_texture_gm = false
    shader_blend_set()
    vbuffer_render_matrix(background_sky_sun_vbuffer, matrix_multiply(matrix_build(0, 0, -dis * 0.7, -90, 0, 0, 1, 1, 1), skymat))
    
    gpu_set_blendmode(bm_normal)
}

shader_clear()
gpu_set_zwriteenable(true)
