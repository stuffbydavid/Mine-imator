/// project_load_particles(map)
/// @arg map

var map = argument0;

if (!ds_exists(map, ds_type_map))
	return 0
	
temp_particles_init()

pc_spawn_constant = json_read_real(map[?"spawn_constant"], pc_spawn_constant)
pc_spawn_amount = json_read_real(map[?"spawn_amount"], pc_spawn_amount)

pc_spawn_region_use = json_read_real(map[?"spawn_region_use"], pc_spawn_region_use)
pc_spawn_region_type = json_read_string(map[?"spawn_region_type"], pc_spawn_region_type)
pc_spawn_region_sphere_radius = json_read_real(map[?"spawn_region_sphere_radius"], pc_spawn_region_sphere_radius)
pc_spawn_region_cube_size = json_read_real(map[?"spawn_region_cube_size"], pc_spawn_region_cube_size)
pc_spawn_region_box_size = json_read_array(map[?"spawn_region_box_size"], pc_spawn_region_box_size)

pc_bounding_box_type = json_read_real(map[?"bounding_box_type"], pc_bounding_box_type)
pc_bounding_box_ground_z = json_read_real(map[?"bounding_box_ground_z"], pc_bounding_box_ground_z)
pc_bounding_box_custom_start = json_read_array(map[?"bounding_box_custom_start"], pc_bounding_box_custom_start)
pc_bounding_box_custom_end = json_read_array(map[?"bounding_box_custom_end"], pc_bounding_box_custom_end)
pc_bounding_box_relative = json_read_real(map[?"bounding_box_relative"], pc_bounding_box_relative)

pc_destroy_at_animation_finish = json_read_real(map[?"destroy_at_animation_finish"], pc_destroy_at_animation_finish)
pc_destroy_at_amount = json_read_real(map[?"destroy_at_amount"], pc_destroy_at_amount)
pc_destroy_at_amount_val = json_read_real(map[?"destroy_at_amount_val"], pc_destroy_at_amount_val)
pc_destroy_at_time = json_read_real(map[?"destroy_at_time"], pc_destroy_at_time)
pc_destroy_at_time_seconds = json_read_real(map[?"destroy_at_time_seconds"], pc_destroy_at_time_seconds)
pc_destroy_at_time_israndom = json_read_real(map[?"destroy_at_time_israndom"], pc_destroy_at_time_israndom)
pc_destroy_at_time_random_min = json_read_real(map[?"destroy_at_time_random_min"], pc_destroy_at_time_random_min)
pc_destroy_at_time_random_max = json_read_real(map[?"destroy_at_time_random_max"], pc_destroy_at_time_random_max)

var ptypeslist = map[?"types"];
for (var i = 0; i < ds_list_size(ptypeslist); i++)
{
	var ptypemap = ptypeslist[|i];
	with (new(obj_particle_type))
	{
		loaded = true
		creator = other.id
		ds_list_add(other.pc_type_list, id)
		
		load_id = json_read_string(ptypemap[?"id"], save_id)
		save_id_map[?load_id] = load_id
	
		name = json_read_string(ptypemap[?"name"], name)
		temp = json_read_save_id(ptypemap[?"temp"], temp)
		text = json_read_string(ptypemap[?"text"], text)
		spawn_rate = json_read_real(ptypemap[?"spawn_rate"], spawn_rate)
		
		sprite_tex = json_read_save_id(ptypemap[?"sprite_tex"], sprite_tex)
		sprite_tex_image= json_read_real(ptypemap[?"sprite_tex_image"], sprite_tex_image)
		sprite_frame_width = json_read_real(ptypemap[?"sprite_frame_width"], sprite_frame_width)
		sprite_frame_height = json_read_real(ptypemap[?"sprite_frame_height"], sprite_frame_height)
		sprite_frame_start = json_read_real(ptypemap[?"sprite_frame_start"], sprite_frame_start)
		sprite_frame_end = json_read_real(ptypemap[?"sprite_frame_end"], sprite_frame_end)
		sprite_animation_speed = json_read_real(ptypemap[?"sprite_animation_speed"], sprite_animation_speed)
		sprite_animation_speed_israndom = json_read_real(ptypemap[?"sprite_animation_speed_israndom"], sprite_animation_speed_israndom)
		sprite_animation_speed_random_min = json_read_real(ptypemap[?"sprite_animation_speed_random_min"], sprite_animation_speed_random_min)
		sprite_animation_speed_random_max = json_read_real(ptypemap[?"sprite_animation_speed_random_max"], sprite_animation_speed_random_max)
		sprite_animation_onend = json_read_real(ptypemap[?"sprite_animation_onend"], sprite_animation_onend)
		
		spd_extend = json_read_real(ptypemap[?"spd_extend"], spd_extend)
		spd = json_read_array(ptypemap[?"spd"], spd)
		spd_israndom = json_read_array(ptypemap[?"spd_israndom"], spd_israndom)
		spd_random_min = json_read_array(ptypemap[?"spd_random_min"], spd_random_min)
		spd_random_max = json_read_array(ptypemap[?"spd_random_max"], spd_random_max)
		spd_add = json_read_array(ptypemap[?"spd_add"], spd_add)
		spd_add_israndom = json_read_array(ptypemap[?"spd_add_israndom"], spd_add_israndom)
		spd_add_random_min = json_read_array(ptypemap[?"spd_add_random_min"], spd_add_random_min)
		spd_add_random_max = json_read_array(ptypemap[?"spd_add_random_max"], spd_add_random_max)
		spd_mul = json_read_array(ptypemap[?"spd_mul"], spd_mul)
		spd_mul_israndom = json_read_array(ptypemap[?"spd_mul_israndom"], spd_mul_israndom)
		spd_mul_random_min = json_read_array(ptypemap[?"spd_mul_random_min"], spd_mul_random_min)
		spd_mul_random_max = json_read_array(ptypemap[?"spd_mul_random_max"], spd_mul_random_max)
		
		rot_extend = json_read_real(ptypemap[?"rot_extend"], rot_extend)
		rot = json_read_array(ptypemap[?"rot"], rot)
		rot_israndom = json_read_array(ptypemap[?"rot_israndom"], rot_israndom)
		rot_random_min = json_read_array(ptypemap[?"rot_random_min"], rot_random_min)
		rot_random_max = json_read_array(ptypemap[?"rot_random_max"], rot_random_max)
				
		rot_spd_extend = json_read_real(ptypemap[?"rot_spd_extend"], rot_spd_extend)
		rot_spd = json_read_array(ptypemap[?"rot_spd"], rot_spd)
		rot_spd_israndom = json_read_array(ptypemap[?"rot_spd_israndom"], rot_spd_israndom)
		rot_spd_random_min = json_read_array(ptypemap[?"rot_spd_random_min"], rot_spd_random_min)
		rot_spd_random_max= json_read_array(ptypemap[?"rot_spd_random_max"], rot_spd_random_max)
		rot_spd_add = json_read_array(ptypemap[?"rot_spd_add"], rot_spd_add)
		rot_spd_add_israndom = json_read_array(ptypemap[?"rot_spd_add_israndom"], rot_spd_add_israndom)
		rot_spd_add_random_min = json_read_array(ptypemap[?"rot_spd_add_random_min"], rot_spd_add_random_min)
		rot_spd_add_random_max = json_read_array(ptypemap[?"rot_spd_add_random_max"], rot_spd_add_random_max)
		rot_spd_mul = json_read_array(ptypemap[?"rot_spd_mul"], rot_spd_mul)
		rot_spd_mul_israndom = json_read_array(ptypemap[?"rot_spd_mul_israndom"], rot_spd_mul_israndom)
		rot_spd_mul_random_min = json_read_array(ptypemap[?"rot_spd_mul_random_min"], rot_spd_mul_random_min)
		rot_spd_mul_random_max = json_read_array(ptypemap[?"rot_spd_mul_random_max"], rot_spd_mul_random_max)
		
		scale = json_read_real(ptypemap[?"scale"], scale)
		scale_israndom = json_read_real(ptypemap[?"scale_israndom"], scale_israndom)
		scale_random_min = json_read_real(ptypemap[?"scale_random_min"], scale_random_min)
		scale_random_max = json_read_real(ptypemap[?"scale_random_max"], scale_random_max)
		scale_add = json_read_real(ptypemap[?"scale_add"], scale_add)
		scale_add_israndom = json_read_real(ptypemap[?"scale_add_israndom"], scale_add_israndom)
		scale_add_random_min = json_read_real(ptypemap[?"scale_add_random_min"], scale_add_random_min)
		scale_add_random_max = json_read_real(ptypemap[?"scale_add_random_max"], scale_add_random_max)
		
		alpha = json_read_real(ptypemap[?"alpha"], alpha)
		alpha_israndom = json_read_real(ptypemap[?"alpha_israndom"], alpha_israndom)
		alpha_random_min = json_read_real(ptypemap[?"alpha_random_min"], alpha_random_min)
		alpha_random_max = json_read_real(ptypemap[?"alpha_random_max"], alpha_random_max)
		alpha_add = json_read_real(ptypemap[?"alpha_add"], alpha_add)
		alpha_add_israndom = json_read_real(ptypemap[?"alpha_add_israndom"], alpha_add_israndom)
		alpha_add_random_min = json_read_real(ptypemap[?"alpha_add_random_min"], alpha_add_random_min)
		alpha_add_random_max = json_read_real(ptypemap[?"alpha_add_random_max"], alpha_add_random_max)
		
		color = json_read_color(ptypemap[?"color"], color)
		color_israndom = json_read_real(ptypemap[?"color_israndom"], color_israndom)
		color_random_start = json_read_color(ptypemap[?"color_random_start"], color_random_start)
		color_random_end = json_read_color(ptypemap[?"color_random_end"], color_random_end)
		color_mix_enabled = json_read_real(ptypemap[?"color_mix_enabled"], color_mix_enabled)
		color_mix = json_read_color(ptypemap[?"color_mix"], color_mix)
		color_mix_israndom = json_read_real(ptypemap[?"color_mix_israndom"], color_mix_israndom)
		color_mix_random_start = json_read_color(ptypemap[?"color_mix_random_start"], color_mix_random_start)
		color_mix_random_end = json_read_color(ptypemap[?"color_mix_random_end"], color_mix_random_end)
		color_mix_time = json_read_color(ptypemap[?"color_mix_time"], color_mix_time)
		color_mix_time_israndom = json_read_real(ptypemap[?"color_mix_time_israndom"], color_mix_time_israndom)
		color_mix_time_random_min = json_read_color(ptypemap[?"color_mix_time_random_min"], color_mix_time_random_min)
		color_mix_time_random_max = json_read_color(ptypemap[?"color_mix_time_random_max"], color_mix_time_random_max)
		
		spawn_region = json_read_real(ptypemap[?"spawn_region"], spawn_region)
		bounding_box = json_read_real(ptypemap[?"bounding_box"], bounding_box)
		bounce = json_read_real(ptypemap[?"bounce"], bounce)
		bounce_factor = json_read_real(ptypemap[?"bounce_factor"], bounce_factor)
		orbit = json_read_real(ptypemap[?"orbit"], orbit)
	}
}