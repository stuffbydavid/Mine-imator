/// builder_combine_threads()
/// Combines the results of all the threads
function builder_combine_threads()
{
	for (var t = 0; t < ds_list_size(thread_list); t++)
	{
		with (thread_list[|t])
		{
			if (block_multithreaded_skip)
				other.block_multithreaded_skip = true
				
			// Create block timeline data
			if (block_tl_map != null)
			{
				var key = ds_map_find_first(block_tl_map);
				while (!is_undefined(key))
				{
					var arr = block_tl_map[?key];
					builder_thread_set_pos(key)
					ds_list_add(other.block_tl_list, block_get_timeline(arr[0], arr[1]))
					key = ds_map_find_next(block_tl_map, key)
				}
				ds_map_destroy(block_tl_map)
			}
			
			// Add multiparts to builder/sections
			var key = ds_map_find_first(block_render_model_multipart_map);
			while (!is_undefined(key))
			{
				builder_thread_set_pos(key)
				builder_add_render_model_multi_part(build_pos_x, build_pos_y, build_pos_z, block_render_model_multipart_map[?key])
				key = ds_map_find_next(block_render_model_multipart_map, key)
			}
			ds_map_destroy(block_render_model_multipart_map)
			instance_destroy()
		}
	}
	if (ds_list_size(thread_list) > 1)
		thread_task_end()
	ds_list_clear(thread_list)
}