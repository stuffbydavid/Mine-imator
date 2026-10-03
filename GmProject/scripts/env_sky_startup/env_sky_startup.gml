function env_sky_startup()
{
	env_background_image_sphere_vbuffer = null
	env_background_image_cube_vbuffer = null
	env_background_image_cube_mapped_vbuffer = null
	
	env_fog_texture = texture_sprite(spr_fog)
	env_fog_vbuffer = null
	
	env_sky_stars_texture = texture_sprite(spr_stars)
	env_sky_stars_vbuffer = null
	env_sky_sun_moon_vbuffer = null
	env_sky_clouds_vbuffer = null
	env_sky_clouds_vbuffer_pos = []
}
