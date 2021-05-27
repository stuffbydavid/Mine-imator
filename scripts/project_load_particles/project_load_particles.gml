/// project_load_particles(map)
/// @arg map

function project_load_particles(map)
{
	if (!ds_map_valid(map))
		return 0
	
	temp_particles_init()
	
	pc_spawn_constant = value_get_real(map[?"spawn_constant"], pc_spawn_constant)
	pc_spawn_amount = value_get_real(map[?"spawn_amount"], pc_spawn_amount)
	
	pc_spawn_region_use = value_get_real(map[?"spawn_region_use"], pc_spawn_region_use)
	pc_spawn_region_type = value_get_string(map[?"spawn_region_type"], pc_spawn_region_type)
	pc_spawn_region_sphere_radius = value_get_real(map[?"spawn_region_sphere_radius"], pc_spawn_region_sphere_radius)
	pc_spawn_region_cube_size = value_get_real(map[?"spawn_region_cube_size"], pc_spawn_region_cube_size)
	pc_spawn_region_box_size = value_get_point3D(map[?"spawn_region_box_size"], pc_spawn_region_box_size)
	
	pc_bounding_box_type = value_get_string(map[?"bounding_box_type"], pc_bounding_box_type)
	pc_bounding_box_ground_z = value_get_real(map[?"bounding_box_ground_z"], pc_bounding_box_ground_z)
	pc_bounding_box_custom_start = value_get_point3D(map[?"bounding_box_custom_start"], pc_bounding_box_custom_start)
	pc_bounding_box_custom_end = value_get_point3D(map[?"bounding_box_custom_end"], pc_bounding_box_custom_end)
	pc_bounding_box_relative = value_get_real(map[?"bounding_box_relative"], pc_bounding_box_relative)
	
	pc_destroy_at_animation_finish = value_get_real(map[?"destroy_at_animation_finish"], pc_destroy_at_animation_finish)
	pc_destroy_at_amount = value_get_real(map[?"destroy_at_amount"], pc_destroy_at_amount)
	pc_destroy_at_amount_val = value_get_real(map[?"destroy_at_amount_val"], pc_destroy_at_amount_val)
	pc_destroy_at_time = value_get_real(map[?"destroy_at_time"], pc_destroy_at_time)
	pc_destroy_at_time_seconds = value_get_real(map[?"destroy_at_time_seconds"], pc_destroy_at_time_seconds)
	pc_destroy_at_time_israndom = value_get_real(map[?"destroy_at_time_israndom"], pc_destroy_at_time_israndom)
	pc_destroy_at_time_random_min = value_get_real(map[?"destroy_at_time_random_min"], pc_destroy_at_time_random_min)
	pc_destroy_at_time_random_max = value_get_real(map[?"destroy_at_time_random_max"], pc_destroy_at_time_random_max)
	pc_destroy_at_bounding_box = value_get_real(map[?"destroy_at_bounding_box"], pc_destroy_at_bounding_box)
	
	var ptypeslist = map[?"types"];
	for (var i = 0; i < ds_list_size(ptypeslist); i++)
	{
		var ptypemap = ptypeslist[|i];
		with (new_obj(obj_particle_type))
		{
			loaded = true
			load_id = value_get_string(ptypemap[?"id"], save_id)
			save_id_map[?load_id] = load_id
			creator = other.id
			
			name = value_get_string(ptypemap[?"name"], name)
			
			// Translate name
			if (other.id = app.bench_settings && text_exists("particletype" + name))
				name = text_get("particletype" + name)
			
			if (load_format < e_project.FORMAT_123_PRE_2)
			{
				temp = value_get_save_id(ptypemap[?"temp"], particle_sheet)
			}
			else
			{
				var temptype = value_get_string(ptypemap[?"temp_type"], "sheet");
				
				if (temptype = "sheet")
					temp = particle_sheet
				else if (temptype = "template")
					temp = particle_template
				else
					temp = value_get_save_id(ptypemap[?"temp"], particle_sheet)
			}
			
			text = value_get_string(ptypemap[?"text"], text)
			spawn_rate = value_get_real(ptypemap[?"spawn_rate"], spawn_rate)
			
			sprite_tex = value_get_save_id(ptypemap[?"sprite_tex"], sprite_tex)
			sprite_tex_image = value_get_real(ptypemap[?"sprite_tex_image"], sprite_tex_image)
			sprite_template_tex = value_get_save_id(ptypemap[?"sprite_template_tex"], sprite_template_tex)
			sprite_template = value_get_string(ptypemap[?"sprite_template"], sprite_template)
			sprite_template_still_frame = value_get_real(ptypemap[?"sprite_template_still_frame"], sprite_template_still_frame)
			sprite_template_random_frame = value_get_real(ptypemap[?"sprite_template_random_frame"], sprite_template_random_frame)
			sprite_template_reverse = value_get_real(ptypemap[?"sprite_template_reverse"], sprite_template_reverse)
			sprite_frame_width = value_get_real(ptypemap[?"sprite_frame_width"], sprite_frame_width)
			sprite_frame_height = value_get_real(ptypemap[?"sprite_frame_height"], sprite_frame_height)
			sprite_frame_start = value_get_real(ptypemap[?"sprite_frame_start"], sprite_frame_start)
			sprite_frame_end = value_get_real(ptypemap[?"sprite_frame_end"], sprite_frame_end)
			sprite_animation_speed = value_get_real(ptypemap[?"sprite_animation_speed"], sprite_animation_speed)
			sprite_animation_speed_israndom = value_get_real(ptypemap[?"sprite_animation_speed_israndom"], sprite_animation_speed_israndom)
			sprite_animation_speed_random_min = value_get_real(ptypemap[?"sprite_animation_speed_random_min"], sprite_animation_speed_random_min)
			sprite_animation_speed_random_max = value_get_real(ptypemap[?"sprite_animation_speed_random_max"], sprite_animation_speed_random_max)
			sprite_animation_onend = value_get_real(ptypemap[?"sprite_animation_onend"], sprite_animation_onend)
			
			angle_extend = value_get_real(ptypemap[?"angle_extend"], angle_extend)
			angle = value_get_point3D(ptypemap[?"angle"], angle)
			angle_israndom = value_get_point3D(ptypemap[?"angle_israndom"], angle_israndom)
			angle_random_min = value_get_point3D(ptypemap[?"angle_random_min"], angle_random_min)
			angle_random_max = value_get_point3D(ptypemap[?"angle_random_max"], angle_random_max)
			angle_speed = value_get_real(ptypemap[?"angle_speed"], angle_speed)
			angle_speed_israndom = value_get_real(ptypemap[?"angle_speed_israndom"], angle_speed_israndom)
			angle_speed_random_min = value_get_real(ptypemap[?"angle_speed_random_min"], angle_speed_random_min)
			angle_speed_random_max = value_get_real(ptypemap[?"angle_speed_random_max"], angle_speed_random_max)
			angle_speed_add = value_get_real(ptypemap[?"angle_speed_add"], angle_speed_add)
			angle_speed_add_israndom = value_get_real(ptypemap[?"angle_speed_add_israndom"], angle_speed_add_israndom)
			angle_speed_add_random_min = value_get_real(ptypemap[?"angle_speed_add_random_min"], angle_speed_add_random_min)
			angle_speed_add_random_max = value_get_real(ptypemap[?"angle_speed_add_random_max"], angle_speed_add_random_max)
			angle_speed_mul = value_get_real(ptypemap[?"angle_speed_mul"], angle_speed_mul)
			angle_speed_mul_israndom = value_get_real(ptypemap[?"angle_speed_mul_israndom"], angle_speed_mul_israndom)
			angle_speed_mul_random_min = value_get_real(ptypemap[?"angle_speed_mul_random_min"], angle_speed_mul_random_min)
			angle_speed_mul_random_max = value_get_real(ptypemap[?"angle_speed_mul_random_max"], angle_speed_mul_random_max)
			
			// Launch angle can mess up old particles, set strength to 0
			if (load_format < e_project.FORMAT_123_PRE_2)
			{
				angle_speed = 0
				angle_speed_israndom = false
			}
			
			spd_extend = value_get_real(ptypemap[?"spd_extend"], spd_extend)
			spd = value_get_point3D(ptypemap[?"spd"], spd)
			spd_israndom = value_get_point3D(ptypemap[?"spd_israndom"], spd_israndom)
			spd_random_min = value_get_point3D(ptypemap[?"spd_random_min"], spd_random_min)
			spd_random_max = value_get_point3D(ptypemap[?"spd_random_max"], spd_random_max)
			spd_add = value_get_point3D(ptypemap[?"spd_add"], spd_add)
			spd_add_israndom = value_get_point3D(ptypemap[?"spd_add_israndom"], spd_add_israndom)
			spd_add_random_min = value_get_point3D(ptypemap[?"spd_add_random_min"], spd_add_random_min)
			spd_add_random_max = value_get_point3D(ptypemap[?"spd_add_random_max"], spd_add_random_max)
			spd_mul = value_get_point3D(ptypemap[?"spd_mul"], spd_mul)
			spd_mul_israndom = value_get_point3D(ptypemap[?"spd_mul_israndom"], spd_mul_israndom)
			spd_mul_random_min = value_get_point3D(ptypemap[?"spd_mul_random_min"], spd_mul_random_min)
			spd_mul_random_max = value_get_point3D(ptypemap[?"spd_mul_random_max"], spd_mul_random_max)
			
			rot_extend = value_get_real(ptypemap[?"rot_extend"], rot_extend)
			rot = value_get_point3D(ptypemap[?"rot"], rot)
			rot_israndom = value_get_point3D(ptypemap[?"rot_israndom"], rot_israndom)
			rot_random_min = value_get_point3D(ptypemap[?"rot_random_min"], rot_random_min)
			rot_random_max = value_get_point3D(ptypemap[?"rot_random_max"], rot_random_max)
			
			rot_spd_extend = value_get_real(ptypemap[?"rot_spd_extend"], rot_spd_extend)
			rot_spd = value_get_point3D(ptypemap[?"rot_spd"], rot_spd)
			rot_spd_israndom = value_get_point3D(ptypemap[?"rot_spd_israndom"], rot_spd_israndom)
			rot_spd_random_min = value_get_point3D(ptypemap[?"rot_spd_random_min"], rot_spd_random_min)
			rot_spd_random_max= value_get_point3D(ptypemap[?"rot_spd_random_max"], rot_spd_random_max)
			rot_spd_add = value_get_point3D(ptypemap[?"rot_spd_add"], rot_spd_add)
			rot_spd_add_israndom = value_get_point3D(ptypemap[?"rot_spd_add_israndom"], rot_spd_add_israndom)
			rot_spd_add_random_min = value_get_point3D(ptypemap[?"rot_spd_add_random_min"], rot_spd_add_random_min)
			rot_spd_add_random_max = value_get_point3D(ptypemap[?"rot_spd_add_random_max"], rot_spd_add_random_max)
			rot_spd_mul = value_get_point3D(ptypemap[?"rot_spd_mul"], rot_spd_mul)
			rot_spd_mul_israndom = value_get_point3D(ptypemap[?"rot_spd_mul_israndom"], rot_spd_mul_israndom)
			rot_spd_mul_random_min = value_get_point3D(ptypemap[?"rot_spd_mul_random_min"], rot_spd_mul_random_min)
			rot_spd_mul_random_max = value_get_point3D(ptypemap[?"rot_spd_mul_random_max"], rot_spd_mul_random_max)
			
			sprite_angle = value_get_real(ptypemap[?"sprite_angle"], sprite_angle)
			sprite_angle_israndom = value_get_real(ptypemap[?"sprite_angle_israndom"], sprite_angle_israndom)
			sprite_angle_random_min = value_get_real(ptypemap[?"sprite_angle_random_min"], sprite_angle_random_min)
			sprite_angle_random_max = value_get_real(ptypemap[?"sprite_angle_random_max"], sprite_angle_random_max)
			sprite_angle_add = value_get_real(ptypemap[?"sprite_angle_add"], sprite_angle_add)
			sprite_angle_add_israndom = value_get_real(ptypemap[?"sprite_angle_add_israndom"], sprite_angle_add_israndom)
			sprite_angle_add_random_min = value_get_real(ptypemap[?"sprite_angle_add_random_min"], sprite_angle_add_random_min)
			sprite_angle_add_random_max = value_get_real(ptypemap[?"sprite_angle_add_random_max"], sprite_angle_add_random_max)
			
			scale = value_get_real(ptypemap[?"scale"], scale)
			scale_israndom = value_get_real(ptypemap[?"scale_israndom"], scale_israndom)
			scale_random_min = value_get_real(ptypemap[?"scale_random_min"], scale_random_min)
			scale_random_max = value_get_real(ptypemap[?"scale_random_max"], scale_random_max)
			scale_add = value_get_real(ptypemap[?"scale_add"], scale_add)
			scale_add_israndom = value_get_real(ptypemap[?"scale_add_israndom"], scale_add_israndom)
			scale_add_random_min = value_get_real(ptypemap[?"scale_add_random_min"], scale_add_random_min)
			scale_add_random_max = value_get_real(ptypemap[?"scale_add_random_max"], scale_add_random_max)
			
			alpha = value_get_real(ptypemap[?"alpha"], alpha)
			alpha_israndom = value_get_real(ptypemap[?"alpha_israndom"], alpha_israndom)
			alpha_random_min = value_get_real(ptypemap[?"alpha_random_min"], alpha_random_min)
			alpha_random_max = value_get_real(ptypemap[?"alpha_random_max"], alpha_random_max)
			alpha_add = value_get_real(ptypemap[?"alpha_add"], alpha_add)
			alpha_add_israndom = value_get_real(ptypemap[?"alpha_add_israndom"], alpha_add_israndom)
			alpha_add_random_min = value_get_real(ptypemap[?"alpha_add_random_min"], alpha_add_random_min)
			alpha_add_random_max = value_get_real(ptypemap[?"alpha_add_random_max"], alpha_add_random_max)
			
			color = value_get_color(ptypemap[?"color"], color)
			color_israndom = value_get_real(ptypemap[?"color_israndom"], color_israndom)
			color_random_start = value_get_color(ptypemap[?"color_random_start"], color_random_start)
			color_random_end = value_get_color(ptypemap[?"color_random_end"], color_random_end)
			color_mix_enabled = value_get_real(ptypemap[?"color_mix_enabled"], color_mix_enabled)
			color_mix = value_get_color(ptypemap[?"color_mix"], color_mix)
			color_mix_israndom = value_get_real(ptypemap[?"color_mix_israndom"], color_mix_israndom)
			color_mix_random_start = value_get_color(ptypemap[?"color_mix_random_start"], color_mix_random_start)
			color_mix_random_end = value_get_color(ptypemap[?"color_mix_random_end"], color_mix_random_end)
			color_mix_time = value_get_real(ptypemap[?"color_mix_time"], color_mix_time)
			color_mix_time_israndom = value_get_real(ptypemap[?"color_mix_time_israndom"], color_mix_time_israndom)
			color_mix_time_random_min = value_get_real(ptypemap[?"color_mix_time_random_min"], color_mix_time_random_min)
			color_mix_time_random_max = value_get_real(ptypemap[?"color_mix_time_random_max"], color_mix_time_random_max)
			
			spawn_region = value_get_real(ptypemap[?"spawn_region"], spawn_region)
			bounding_box = value_get_real(ptypemap[?"bounding_box"], bounding_box)
			bounce = value_get_real(ptypemap[?"bounce"], bounce)
			bounce_factor = value_get_real(ptypemap[?"bounce_factor"], bounce_factor)
			orbit = value_get_real(ptypemap[?"orbit"], orbit)
			
			ds_list_add(other.pc_type_list, id)
		}
	}
}
