/// action_toolbar_import_asset()

function action_toolbar_import_asset()
{
	var fn = file_dialog_open_asset(true);
	var path_array = string_split_escaped(fn, "\n");
	var path_array_count = array_length(path_array);

	if (path_array_count <= 0)
		return false
	
	for (var i = 0; i < path_array_count; i += 1)
	{
		show_debug_message("Starting import: " + string(path_array[i]))

		asset_load(path_array[i])
	}
}
