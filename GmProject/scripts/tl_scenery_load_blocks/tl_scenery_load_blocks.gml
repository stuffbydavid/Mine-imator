/// @desc Loads source blocks and optionally source timeline data.
/// @arg [timelines]

function tl_scenery_load_blocks(timelines = false)
{
	if (type != e_tl_type.SCENERY || temp = null || temp.scenery = null)
		return true

	var res, hasdata;
	res = temp.scenery
	if (!res.ready)
		return false

	// Load block timeline data
	if (timelines && !ds_list_valid(res.scenery_tl_list))
	{
		with (res)
		{
			var instant, downloadskins;
			instant = scenery_instant
			downloadskins = scenery_download_skins
			load_folder = app.project_folder
			save_folder = app.project_folder
			scenery_instant = true
			ready = false
			load_stage = "open"

			while (!ready && load_stage != "")
				res_load_scenery()

			scenery_instant = instant
			scenery_download_skins = downloadskins
		}

		return res.ready && ds_list_valid(res.scenery_tl_list)
	}

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
