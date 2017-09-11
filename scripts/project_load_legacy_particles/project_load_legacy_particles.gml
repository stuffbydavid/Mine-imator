/// project_load_legacy_particles()

pc_spawn_constant = buffer_read_byte()
pc_spawn_amount = buffer_read_int()

pc_spawn_region_use = buffer_read_byte()
pc_spawn_region_type = buffer_read_string_int()
pc_spawn_region_sphere_radius = buffer_read_double()
pc_spawn_region_cube_size = buffer_read_double()
pc_spawn_region_box_size[X] = buffer_read_double()
pc_spawn_region_box_size[Y] = buffer_read_double()
pc_spawn_region_box_size[Z] = buffer_read_double()

pc_bounding_box_type = buffer_read_byte()
if (load_format >= e_project.FORMAT_100_DEMO_4)
	pc_bounding_box_ground_z = buffer_read_double()
else
	pc_bounding_box_ground_z = 0

pc_bounding_box_custom_start[X] = buffer_read_double()
pc_bounding_box_custom_start[Y] = buffer_read_double()
pc_bounding_box_custom_start[Z] = buffer_read_double()

pc_bounding_box_custom_end[X] = buffer_read_double()
pc_bounding_box_custom_end[Y] = buffer_read_double()
pc_bounding_box_custom_end[Z] = buffer_read_double()

pc_bounding_box_relative = buffer_read_byte()

pc_destroy_at_animation_finish = buffer_read_byte()
pc_destroy_at_amount = buffer_read_byte()
pc_destroy_at_amount_val = buffer_read_int()
pc_destroy_at_time = buffer_read_byte()
pc_destroy_at_time_seconds = buffer_read_double()
pc_destroy_at_time_israndom = buffer_read_byte()
pc_destroy_at_time_random_min = buffer_read_double()
pc_destroy_at_time_random_max = buffer_read_double()

pc_type_list = ds_list_create()
pc_type_amount = buffer_read_int()
for (var p = 0; p < pc_type_amount; p++)
{
	with (new(obj_particle_type))
	{
		loaded = true
		creator = other.id
		ds_list_add(other.pc_type_list, id)
		
		if (load_format >= e_project.FORMAT_100_DEBUG)
		{
			load_id = project_load_legacy_save_id()
			save_id_map[?load_id] = load_id
		} 
		else
			load_id = save_id_create()
		
		name = buffer_read_string_int()
		temp = project_load_legacy_save_id()
		text = buffer_read_string_int()
		if (load_format >= e_project.FORMAT_100_DEMO_3)
				spawn_rate = buffer_read_double()
		sprite_tex = project_load_legacy_save_id()
		sprite_tex_image = buffer_read_byte()
		sprite_frame_width = buffer_read_int()
		sprite_frame_height = buffer_read_int()
		sprite_frame_start = buffer_read_int()
		sprite_frame_end = buffer_read_int()
		sprite_animation_speed = buffer_read_double()
		sprite_animation_speed_israndom = buffer_read_byte()
		sprite_animation_speed_random_min = buffer_read_double()
		sprite_animation_speed_random_max = buffer_read_double()
		sprite_animation_onend = buffer_read_byte()
		rot_extend = buffer_read_byte()
		spd_extend = buffer_read_byte()
		rot_spd_extend = buffer_read_byte()
		
		for (var a = X; a <= Z; a++)
		{
			spd[a] = buffer_read_double()
			spd_israndom[a] = buffer_read_byte()
			spd_random_min[a] = buffer_read_double()
			spd_random_max[a] = buffer_read_double()
			spd_add[a] = buffer_read_double()
			spd_add_israndom[a] = buffer_read_byte()
			spd_add_random_min[a] = buffer_read_double()
			spd_add_random_max[a] = buffer_read_double()
			spd_mul[a] = buffer_read_double()
			spd_mul_israndom[a] = buffer_read_byte()
			spd_mul_random_min[a] = buffer_read_double()
			spd_mul_random_max[a] = buffer_read_double()
			
			rot[a] = buffer_read_double()
			rot_israndom[a] = buffer_read_byte()
			rot_random_min[a] = buffer_read_double()
			rot_random_max[a] = buffer_read_double()
			rot_spd[a] = buffer_read_double()
			rot_spd_israndom[a] = buffer_read_byte()
			rot_spd_random_min[a] = buffer_read_double()
			rot_spd_random_max[a] = buffer_read_double()
			rot_spd_add[a] = buffer_read_double()
			rot_spd_add_israndom[a] = buffer_read_byte()
			rot_spd_add_random_min[a] = buffer_read_double()
			rot_spd_add_random_max[a] = buffer_read_double()
			rot_spd_mul[a] = buffer_read_double()
			rot_spd_mul_israndom[a] = buffer_read_byte()
			rot_spd_mul_random_min[a] = buffer_read_double()
			rot_spd_mul_random_max[a] = buffer_read_double()
		}

		scale = buffer_read_double()
		scale_israndom = buffer_read_byte()
		scale_random_min = buffer_read_double()
		scale_random_max = buffer_read_double()
		scale_add = buffer_read_double()
		scale_add_israndom = buffer_read_byte()
		scale_add_random_min = buffer_read_double()
		scale_add_random_max = buffer_read_double()
		
		alpha = buffer_read_double()
		alpha_israndom = buffer_read_byte()
		alpha_random_min = buffer_read_double()
		alpha_random_max = buffer_read_double()
		alpha_add = buffer_read_double()
		alpha_add_israndom = buffer_read_byte()
		alpha_add_random_min = buffer_read_double()
		alpha_add_random_max = buffer_read_double()
		
		color = buffer_read_int()
		color_israndom = buffer_read_byte()
		color_random_start = buffer_read_int()
		color_random_end = buffer_read_int()
		color_mix_enabled = buffer_read_byte()
		color_mix = buffer_read_int()
		color_mix_israndom = buffer_read_byte()
		color_mix_random_start = buffer_read_int()
		color_mix_random_end = buffer_read_int()
		color_mix_time = buffer_read_double()
		color_mix_time_israndom = buffer_read_byte()
		color_mix_time_random_min = buffer_read_double()
		color_mix_time_random_max = buffer_read_double()
		
		if (load_format >= e_project.FORMAT_100_DEMO_3)
			spawn_region = buffer_read_byte()
			
		bounding_box = buffer_read_byte()
		bounce = buffer_read_byte()
		bounce_factor = buffer_read_double()
		orbit = buffer_read_byte()
	}
}
