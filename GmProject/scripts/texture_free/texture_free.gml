/// @arg texture

function texture_free(tex)
{
	ds_map_delete(texture_res_map, tex)
	
	// Remove per-pack references to texture
	with (obj_resource)
	{
		if (pack_res_texture_map != null)
		{
			var packedtex = pack_res_texture_map[?tex];
			if (!is_undefined(packedtex))
			{
				ds_map_delete(pack_res_texture_map, tex)
				
				if (sprite_exists(packedtex))
					sprite_delete(packedtex)
			}
		}
	}
	
	if (sprite_exists(tex))
		sprite_delete(tex)
}
