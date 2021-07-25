/// app_update_gc()
/// @desc Manually updates garbage collector

function app_update_gc()
{
	if (window_state = "export_movie")
		gc_collect()
}