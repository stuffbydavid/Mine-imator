/// project_read_background()

background_image_show = buffer_read_byte()					debug("background_image_show", background_image_show)
background_image = iid_find(iid_read())						debug("background_image", background_image)
if (background_image)
	background_image.count++
	
background_image_type = buffer_read_byte()					debug("background_image_type", background_image_type)
background_image_stretch = buffer_read_byte()				debug("background_image_stretch", background_image_stretch)
if (load_format >= project_100debug)
	background_image_box_mapped = buffer_read_byte()		debug("background_image_box_mapped", background_image_box_mapped)
	
background_sky_time = buffer_read_double()					debug("background_sky_time", background_sky_time)
background_sky_clouds_show = buffer_read_byte()				debug("background_sky_clouds_show", background_sky_clouds_show)
background_sky_clouds_flat = buffer_read_byte()				debug("background_sky_clouds_flat", background_sky_clouds_flat)
background_sky_clouds_speed = buffer_read_double()			debug("background_sky_clouds_speed", background_sky_clouds_speed)
background_ground_show = buffer_read_byte()					debug("background_ground_show", background_ground_show)
background_ground_n = buffer_read_int()						debug("background_ground_n", background_ground_n)
background_ground.count--
background_ground = iid_find(iid_read())					debug("background_ground", background_ground)
background_ground.count++
background_biome = buffer_read_byte()						debug("background_biome", background_biome)
background_sky_color = buffer_read_int()					debug("background_sky_color", background_sky_color)
background_sky_clouds_color = buffer_read_int()				debug("background_sky_clouds_color", background_sky_clouds_color)
background_sunlight_color = buffer_read_int()				debug("background_sunlight_color", background_sunlight_color)
background_ambient_color = buffer_read_int()				debug("background_ambient_color", background_ambient_color)
background_night_color = buffer_read_int()					debug("background_night_color", background_night_color)
background_fog_show = buffer_read_byte()					debug("background_fog_show", background_fog_show)
if (load_format >= project_100debug)
	background_fog_sky = buffer_read_byte()					debug("background_fog_sky", background_fog_sky)
	
background_fog_color_custom = buffer_read_byte()			debug("background_fog_color_custom", background_fog_color_custom)
background_fog_color = buffer_read_int()					debug("background_fog_color", background_fog_color)
background_fog_distance = buffer_read_int()					debug("background_fog_distance", background_fog_distance)
background_fog_size = buffer_read_int()						debug("background_fog_size", background_fog_size)

if (load_format >= project_100debug)
	background_fog_height = buffer_read_int()				debug("background_fog_height", background_fog_height)
	
background_wind = buffer_read_byte()						debug("background_wind", background_wind)
background_wind_speed = buffer_read_double()				debug("background_wind_speed", background_wind_speed)
background_wind_strength = buffer_read_double()				debug("background_wind_strength", background_wind_strength)
background_opaque_leaves = buffer_read_byte()				debug("background_opaque_leaves", background_opaque_leaves)
background_texture_animation_speed = buffer_read_double()	debug("background_texture_animation_speed", background_texture_animation_speed)
background_sunlight_range = buffer_read_int()				debug("background_sunlight_range", background_sunlight_range)

if (load_format >= project_105)
	background_sunlight_follow = buffer_read_byte()			debug("background_sunlight_follow", background_sunlight_follow)

if (load_format >= project_100demo4)
{
	background_sky_sun_tex.count--
	background_sky_sun_tex = iid_find(iid_read())			debug("background_sky_sun_tex", background_sky_sun_tex)
	background_sky_sun_tex.count++
	background_sky_moon_tex.count--
	background_sky_moon_tex = iid_find(iid_read())			debug("background_sky_moon_tex", background_sky_moon_tex)
	background_sky_moon_tex.count++
	background_sky_moon_phase = buffer_read_int()			debug("background_sky_moon_phase", background_sky_moon_phase)
	background_sky_rotation = buffer_read_double()			debug("background_sky_rotation", background_sky_rotation)
	background_sky_clouds_tex.count--
	background_sky_clouds_tex = iid_find(iid_read())		debug("background_sky_clouds_tex", background_sky_clouds_tex)
	background_sky_clouds_tex.count++
	background_sky_clouds_z = buffer_read_double()			debug("background_sky_clouds_z", background_sky_clouds_z)
	background_sky_clouds_size = buffer_read_double()		debug("background_sky_clouds_size", background_sky_clouds_size)
	background_sky_clouds_height = buffer_read_double()		debug("background_sky_clouds_height", background_sky_clouds_height)
}
