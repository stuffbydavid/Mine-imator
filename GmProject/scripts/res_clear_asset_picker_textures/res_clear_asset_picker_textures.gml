function res_clear_asset_picker_textures()
{
	if (asset_picker_texture_map = null)
		return 0

	var key = ds_map_find_first(asset_picker_texture_map);
	while (!is_undefined(key))
	{
		texture_free(asset_picker_texture_map[?key])
		key = ds_map_find_next(asset_picker_texture_map, key)
	}
	ds_map_destroy(asset_picker_texture_map)
	asset_picker_texture_map = null
}
