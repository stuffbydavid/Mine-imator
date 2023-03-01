/// builder_spawn_threads(number)
/// Creates a number of threads for generating a block mesh.
function builder_spawn_threads(number)
{
	for (var t = 0; t < number; t++)
	{
		var thread = new_obj(obj_builder_thread);
		thread.threadid = t;
		thread.block_obj = block_obj;
		thread.block_state_id = block_state_id;
		thread.block_waterlogged = block_waterlogged;
		thread.build_size_x = build_size_x;
		thread.build_size_y = build_size_y;
		thread.build_size_z = build_size_z;
		thread.build_size_xy = build_size_xy;
		thread.build_size_total = build_size_total;
		thread.build_size_sqrt = build_size_sqrt;
		thread.block_render_model = block_render_model;
		thread.block_render_model_multipart_map = ds_int_map_create()
		thread.block_multithreaded_skip = false
		
		thread.builder_scenery = builder_scenery
		thread.builder_scenery_legacy = builder_scenery_legacy
		
		if (block_tl_list != null)
			thread.block_tl_map = ds_int_map_create()

		ds_list_add(thread_list, thread)
	}
	
	if (number > 1)
		thread_task_begin()
}