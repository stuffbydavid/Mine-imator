/// @desc Frees resource rendering copies while retaining built-in sprites and resource pack textures.

function res_clear_pack_res_textures()
{
	if (pack_res_texture_map = null)
		return 0
	
	var key = ds_map_find_first(pack_res_texture_map);
	while (!is_undefined(key))
	{
		var tex = pack_res_texture_map[?key];
		if (sprite_exists(tex))
			sprite_delete(tex)
		
		key = ds_map_find_next(pack_res_texture_map, key)
	}
	
	ds_map_clear(pack_res_texture_map)
}
