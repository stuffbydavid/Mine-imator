/// window_exists(window)
/// Returns whether a window with the given e_window value has been created.

function window_exists(window)
{
	return (ds_list_find_index(window_list, window) >= 0)
}