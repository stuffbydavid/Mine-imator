function action_toolbar_import_asset()
{
	var fn, patharray, patharraycount;
	fn = file_dialog_open_asset(true)
	patharray = string_split_escaped(fn, "\n")
	patharraycount = array_length(patharray)

	if (patharraycount <= 0)
		return 0
	
	for (var i = 0; i < patharraycount; i++)
	{
		if (patharray[i] = "")
			continue
			
		show_debug_message("Starting import: " + string(patharray[i]))
		asset_load(patharray[i])
	}
}
