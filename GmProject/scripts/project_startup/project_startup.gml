/// project_startup()

function project_startup()
{
	// Project
	globalvar load_queue, load_format, load_folder, save_folder,
			  temp_edit, ptype_edit, tl_edit_amount, tl_edit, res_edit, axis_edit,
			  temp_creator, res_creator, save_id_seed, save_id_map, shape_texture;
	globalvar benchmark_mode,
			  benchmark_animate_total_time, benchmark_render_total_time, benchmark_surface_total_time, benchmark_export_total_time;
	
	load_queue = ds_priority_create()
	
	temp_edit = null
	ptype_edit = null
	tl_edit = null
	tl_edit_amount = 0
	res_edit = null
	axis_edit = X
	
	temp_creator = app
	res_creator = app
	save_id = "root"
	save_id_seed = random_get_seed()
	save_id_map = ds_map_create()
	
	shape_texture = texture_sprite(spr_shape)
	
	benchmark_mode = false
	benchmark_animate_total_time = 0
	benchmark_render_total_time = 0
	benchmark_surface_total_time = 0
	benchmark_export_total_time = 0
}
