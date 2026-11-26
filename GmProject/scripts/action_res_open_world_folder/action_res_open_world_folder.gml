/// @desc Opens the resource world's folder.

function action_res_open_world_folder()
{
	if (res_edit = null || res_edit.type != e_res_type.FROM_WORLD)
		return 0

	var dir = res_edit.world_regions_dir;

	// Find the world root above the dimension's region directory
	while (dir != "")
	{
		if (directory_exists_lib(dir) && file_exists_lib(dir + "/level.dat"))
		{
			open_url(dir)
			return 0
		}

		var parentdir = filename_dir(dir);
		if (parentdir = dir)
			break

		dir = parentdir
	}

	error("error/open_world_folder")
}
