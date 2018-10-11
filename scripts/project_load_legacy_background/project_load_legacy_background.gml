/// project_load_legacy_background()

background_loaded = true

background_image_show = buffer_read_byte()
if (background_image != null)
	background_image.count--
background_image = buffer_read_int()
if (background_image = 0)
	background_image = null
var imagetype = array("image", "sphere", "box");
background_image_type = imagetype[buffer_read_byte()]
background_image_stretch = buffer_read_byte()
if (load_format >= e_project.FORMAT_100_DEBUG)
	background_image_box_mapped = buffer_read_byte()
	
background_sky_time = buffer_read_double()
background_sky_clouds_show = buffer_read_byte()
background_sky_clouds_flat = buffer_read_byte()
background_sky_clouds_speed = buffer_read_double()

background_ground_show = buffer_read_byte()
background_ground_legacy_name = legacy_block_100_texture_list[|buffer_read_int()]
var newslot = ds_list_find_index(mc_assets.block_texture_list, background_ground_legacy_name)
if (newslot >= 0)
	background_ground_slot = newslot
else // Animated?
{
	newslot = ds_list_find_index(mc_assets.block_texture_ani_list, background_ground_legacy_name)
	if (newslot >= 0)
		background_ground_slot = ds_list_size(mc_assets.block_texture_list) + newslot
}
background_ground_tex.count--
background_ground_tex = project_load_legacy_save_id()
background_biome = biome_list[|buffer_read_byte()]

background_sky_color = buffer_read_int()
background_sky_clouds_color = buffer_read_int()
background_sunlight_color = buffer_read_int()
background_ambient_color = buffer_read_int()
background_night_color = buffer_read_int()

background_fog_show = buffer_read_byte()
if (load_format >= e_project.FORMAT_100_DEBUG)
	background_fog_sky = buffer_read_byte()
background_fog_color_custom = buffer_read_byte()
background_fog_color = buffer_read_int()
background_fog_distance = buffer_read_int()
background_fog_size = buffer_read_int()
if (load_format >= e_project.FORMAT_100_DEBUG)
	background_fog_height = buffer_read_int()
	
background_wind = buffer_read_byte()
background_wind_speed = buffer_read_double()
background_wind_strength = buffer_read_double()

background_opaque_leaves = buffer_read_byte()
background_texture_animation_speed = buffer_read_double()

background_sunlight_range = buffer_read_int()

if (load_format >= e_project.FORMAT_105)
	background_sunlight_follow = buffer_read_byte()

if (load_format >= e_project.FORMAT_100_DEMO_4)
{
	background_sky_sun_tex.count--
	background_sky_sun_tex = project_load_legacy_save_id()
	
	background_sky_moon_tex.count--
	background_sky_moon_tex = project_load_legacy_save_id()
	background_sky_moon_phase = buffer_read_int()
	
	background_sky_rotation = buffer_read_double()
	
	background_sky_clouds_tex.count--
	background_sky_clouds_tex = project_load_legacy_save_id()
	background_sky_clouds_z = buffer_read_double()
	background_sky_clouds_size = buffer_read_double()
	background_sky_clouds_height = buffer_read_double()
}

if (load_format >= e_project.FORMAT_CB_100)
{
	var custombiome;
	custombiome = buffer_read_byte()
	
	if (custombiome)
		background_biome = biome_list[| 0]
		
	background_foliage_color = buffer_read_int()
	background_grass_color = background_foliage_color
}
