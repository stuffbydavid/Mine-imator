/// nbt_debug_tag_compound(name, map)
/// @arg name
/// @arg map

function nbt_debug_tag_compound(name, map)
{
	var key = ds_map_find_first(map);
	
	debug("[TAG_Compound] " + name)
	debug("{")
	debug_indent++
	
	while (!is_undefined(key))
	{
		if (!string_contains(key, "_NBT_"))
		{
			switch (map[?key + "_NBT_type"])
			{
				case e_nbt.TAG_BYTE:
					debug("[TAG_Byte] " + key, map[?key])
					break
				
				case e_nbt.TAG_SHORT:
					debug("[TAG_Short] " + key, map[?key])
					break
				
				case e_nbt.TAG_INT:
					debug("[TAG_Int] " + key, map[?key])
					break
				
				case e_nbt.TAG_LONG:
					debug("[TAG_Long] " + key, map[?key])
					break
				
				case e_nbt.TAG_FLOAT:
					debug("[TAG_Float] " + key, map[?key])
					break
				
				case e_nbt.TAG_DOUBLE:
					debug("[TAG_Double] " + key, map[?key])
					break
				
				case e_nbt.TAG_BYTE_ARRAY:
					debug("[TAG_Byte_Array] " + key)
					debug_indent++
						debug("Length", map[?key + "_NBT_length"])
					debug_indent--
					break
				
				case e_nbt.TAG_STRING:
					debug("[TAG_String] " + key, map[?key])
					break
				
				case e_nbt.TAG_LIST:
					nbt_debug_tag_list(key, map[?key], map[?key + "_NBT_listtype"])
					break
				
				case e_nbt.TAG_COMPOUND:
					nbt_debug_tag_compound(key, map[?key])
					break
				
				case e_nbt.TAG_INT_ARRAY:
					debug("[TAG_Int_Array] " + key)
					debug_indent++
						debug("Length", map[?key + "_NBT_length"])
					debug_indent--
					break
				
				case e_nbt.TAG_LONG_ARRAY:
					debug("[TAG_Long_Array] " + key)
					debug_indent++
						debug("Length", map[?key + "_NBT_length"])
					debug_indent--
					break
				
				default:
					debug("[TAG_Empty] " + key, map[?key])
					break
			}
		}
		key = ds_map_find_next(map, key)
	}
	
	debug_indent--
	debug("}")
}
