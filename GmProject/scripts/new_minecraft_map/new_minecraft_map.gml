/// new_minecraft_map(fn)
/// @arg fn
/// @desc Reads Minecraft map .dat and returns a texture. https://minecraft.wiki/w/Map_item_format

function new_minecraft_map(fn)
{
	var rootmap, data, colors, map;
	rootmap = null
	
	// GZunzip
	file_delete_lib(temp_file)
	gzunzip(fn, temp_file)
	
	if (!file_exists_lib(temp_file))
	{
		log("GZunzip error", "gzunzip")
		return 0
	}
	
	buffer_current = buffer_load(temp_file)
	
	// Read NBT structure
	rootmap = nbt_read_tag_compound();
	if (rootmap = null)
		return 0
	
	if (!ds_map_valid(rootmap))
	{
		log("Minecraft map error", "Not a map file")
		return 0
	}
	
	data = rootmap[?""]
	data = data[?"data"]
	if (is_undefined(data))
	{
		log("Minecraft map error", "Data not available")
		return 0
	}
	
	colors = data[?"colors"]
	if (is_undefined(colors))
	{
		log("Minecraft map error", "Colors not found")
		return 0
	}
	
	var surf = surface_create(128, 128);
	
	surface_set_target(surf)
	{
		draw_clear_alpha(c_black, 0)
		var col;
		
		for (var xx = 0; xx < 128; xx++)
		{
			for (var yy = 0; yy < 128; yy++)
			{
				col = buffer_peek(buffer_current, colors + (xx + yy * 128), buffer_u8)
				
				if (col > 3)
					draw_point_color(xx + (1 * is_cpp()), yy + (1 * is_cpp()), minecraft_map_color_array[col]) // x and y +1, hacky fix for c++
			}
		}
	}
	surface_reset_target()
	
	map = texture_surface(surf)
	surface_free(surf)
	
	ds_map_destroy(rootmap)
	
	return map
}