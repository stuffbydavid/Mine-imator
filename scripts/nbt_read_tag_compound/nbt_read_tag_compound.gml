/// nbt_read_tag_compound()

var map = ds_map_create();

while (!buffer_is_eof())
{
	var type = buffer_read_byte();
	if (type = e_nbt.TAG_END)
		break
		
	if (type >= e_nbt.amount)
	{
		log("TAG_Compound error", "Invalid tag")
		ds_map_destroy(map)
		return null
	}
	
	var name = buffer_read_string_short_be();
	map[?name + "_NBT_type"] = type

	switch (type)
	{
		case e_nbt.TAG_BYTE:
			map[?name] = buffer_read_byte()
			break
		
		case e_nbt.TAG_SHORT:
			map[?name] = buffer_read_short_be()
			break
		
		case e_nbt.TAG_INT:
			map[?name] = buffer_read_int_be()
			break
		
		case e_nbt.TAG_LONG:
			map[?name] = buffer_read_long_be()
			break
		
		case e_nbt.TAG_FLOAT:
			map[?name] = buffer_read_float_be()
			break
		
		case e_nbt.TAG_DOUBLE:
			map[?name] = buffer_read_double_be()
			break
		
		case e_nbt.TAG_BYTE_ARRAY:
			var len = buffer_read_int_be();
			map[?name] = buffer_tell(buffer_current)
			map[?name + "_NBT_length"] = len
	        buffer_skip(len)
			break
		
	    case e_nbt.TAG_STRING:
	        map[?name] = buffer_read_string_short_be()
	        break
		
		case e_nbt.TAG_LIST:
		{
			var listtype, listlen, list;
			listtype = buffer_read_byte()
			listlen = buffer_read_int_be()
			list = nbt_read_tag_list(listtype, listlen)
			if (list = null)
			{
				ds_map_destroy(map)
				return null
			}
			ds_map_add_list(map, name, list)
			map[?name + "_NBT_listtype"] = listtype
			break
		}
		
		case e_nbt.TAG_COMPOUND:
		{
			var nmap = nbt_read_tag_compound();
			if (nmap = null)
			{
				ds_map_destroy(map)
				return null
			}
			ds_map_add_map(map, name, nmap)
			break
		}
		
		case e_nbt.TAG_INT_ARRAY:
		{
			var len = buffer_read_int_be();
			map[?name] = buffer_tell(buffer_current)
			map[?name + "_NBT_length"] = len
	        buffer_skip(len * 4)
			break
		}
	}
}

return map