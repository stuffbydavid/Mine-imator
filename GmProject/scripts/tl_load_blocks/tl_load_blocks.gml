/// @desc Loads source blocks for build edits and picking.

function tl_load_blocks()
{
	if (type != e_tl_type.SCENERY || temp = null || temp.scenery = null)
		return true

	var res, hasdata;
	res = temp.scenery
	if (!res.ready)
		return false

	// Check for missing data in block meshes
	hasdata = (array_length(res.block_meshes) > 0)
	for (var i = 0; i < array_length(res.block_meshes); i++)
	{
		var mesh = res.block_meshes[i];
		if (mesh != null && (mesh.block_palette_buffer = null || mesh.block_grid_buffer = null))
			hasdata = false
	}

	if (!hasdata)
		with (res)
			return res_load_scenery_file(app.project_folder + "/" + filename, true)

	return true
}
