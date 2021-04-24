/// load_next()
/// @desc Loads the next resource in the queue.

function load_next()
{
	ds_priority_delete_max(load_queue)
	
	if (ds_priority_size(load_queue) > 0)
		load_start(ds_priority_find_max(load_queue), res_load_start)
	else
	{
		popup_loading.load_object = null
		popup_loading.load_script = null
		popup_close()
		lib_preview.update = true
		res_preview.update = true
		bench_settings.preview.update = true
	}
}
