/// @desc Finds a unique world snapshot filename, preserving an existing matching filename
/// @arg name
/// @arg extension
/// @arg [resource]

function res_get_world_filename(name, ext, res = null)
{
	if (res != null && string_lower(filename_ext(res.filename)) = string_lower(ext))
		return res.filename

	var base, num, worldname, fn, exists;
	base = filename_get_valid(name)
	num = 1

	// Reserve names across files and resources whose snapshots may still be writing
	do
	{
		worldname = base
		if (num > 1)
			worldname += " (" + string(num) + ")"

		fn = worldname + ext
		exists = file_exists_lib(project_folder + "/" + fn)
		with (obj_resource)
			if (id != res && (string_lower(filename) = string_lower(fn) ||
				(type = e_res_type.FROM_WORLD && string_lower(world_name) = string_lower(worldname))))
				exists = true

		num++
	}
	until (!exists)

	return fn
}
