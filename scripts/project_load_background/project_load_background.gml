/// project_load_background(map)
/// @arg map

var map = argument0;

if (!ds_exists(map, ds_type_map))
	return 0

background_loaded = true
	
background_image_show = json_read_real(map[?"image_show"], background_image_show)
if (background_image != null)
	background_image.count--
background_image = json_read_save_id(map[?"image"], background_image)
background_image_type = json_read_real(map[?"image_type"], background_image_type)
background_image_stretch = json_read_real(map[?"image_stretch"], background_image_stretch)
background_image_box_mapped = json_read_real(map[?"image_box_mapped"], background_image_box_mapped)

background_sky_sun_tex.count--
background_sky_sun_tex = json_read_save_id(map[?"sky_sun_tex"], background_sky_sun_tex)
background_sky_moon_tex.count--
background_sky_moon_tex = json_read_save_id(map[?"sky_moon_tex"], background_sky_moon_tex)
background_sky_moon_phase = json_read_real(map[?"sky_moon_phase"], background_sky_moon_phase)

background_sky_time = json_read_real(map[?"sky_time"], background_sky_time)
background_sky_rotation = json_read_real(map[?"sky_rotation"], background_sky_rotation)
background_sunlight_range = json_read_real(map[?"sunlight_range"], background_sunlight_range)
background_sunlight_follow = json_read_real(map[?"sunlight_follow"], background_sunlight_follow)

background_sky_clouds_show = json_read_real(map[?"sky_clouds_show"], background_sky_clouds_show)
background_sky_clouds_flat = json_read_real(map[?"sky_clouds_flat"], background_sky_clouds_flat)
background_sky_clouds_tex.count--
background_sky_clouds_tex = json_read_save_id(map[?"sky_clouds_tex"], background_sky_clouds_tex)
background_sky_clouds_speed = json_read_real(map[?"sky_clouds_speed"], background_sky_clouds_speed)
background_sky_clouds_z = json_read_real(map[?"sky_clouds_z"], background_sky_clouds_z)
background_sky_clouds_size = json_read_real(map[?"sky_clouds_size"], background_sky_clouds_size)
background_sky_clouds_height = json_read_real(map[?"sky_clouds_height"], background_sky_clouds_height)

background_ground_show = json_read_real(map[?"ground_show"], background_ground_show)
background_ground_name = json_read_string(map[?"ground_name"], background_ground_name)
background_ground_slot = ds_list_find_index(mc_assets.block_texture_list, background_ground_name)
if (background_ground_slot < 0) // Animated
	background_ground_slot = ds_list_size(mc_assets.block_texture_list) + ds_list_find_index(mc_assets.block_texture_ani_list, background_ground_name)
background_ground_tex.count--
background_ground_tex = json_read_save_id(map[?"ground_tex"], background_ground_tex)

background_biome = find_biome(json_read_string(map[?"biome"], background_biome.name))

background_sky_color = json_read_color(map[?"sky_color"], background_sky_color)
background_sky_clouds_color = json_read_color(map[?"sky_clouds_color"], background_sky_clouds_color)
background_sunlight_color = json_read_color(map[?"sunlight_color"], background_sunlight_color)
background_ambient_color = json_read_color(map[?"ambient_color"], background_ambient_color)
background_night_color = json_read_color(map[?"night_color"], background_night_color)

background_fog_show = json_read_real(map[?"fog_show"], background_fog_show)
background_fog_sky = json_read_real(map[?"fog_sky"], background_fog_sky)
background_fog_color_custom = json_read_real(map[?"fog_color_custom"], background_fog_color_custom)
background_fog_color = json_read_color(map[?"fog_color"], background_fog_color)
background_fog_distance = json_read_real(map[?"fog_distance"], background_fog_distance)
background_fog_size = json_read_real(map[?"fog_size"], background_fog_size)
background_fog_height = json_read_real(map[?"fog_height"], background_fog_height)

background_wind = json_read_real(map[?"wind"], background_wind)
background_wind_speed = json_read_real(map[?"wind_speed"], background_wind_speed)
background_wind_strength = json_read_real(map[?"wind_strength"], background_wind_strength)

background_opaque_leaves = json_read_real(map[?"opaque_leaves"], background_opaque_leaves)
background_texture_animation_speed = json_read_real(map[?"texture_animation_speed"], background_texture_animation_speed)