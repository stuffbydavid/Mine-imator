/// nbt_read_tag_list(type, length)
/// @arg type
/// @arg length

function nbt_read_tag_list(listtype, listlen)
{
	var list = ds_list_create();
	
	repeat (listlen)
	{
		switch (listtype)
		{
			case e_nbt.TAG_BYTE:
				ds_list_add(list, buffer_read_byte())
				break
			
			case e_nbt.TAG_SHORT:
				ds_list_add(list, buffer_read_short_be())
				break
			
			case e_nbt.TAG_INT:
				ds_list_add(list, buffer_read_int_be())
				break
			
			case e_nbt.TAG_LONG:
				ds_list_add(list, buffer_read_long_be())
				break
			
			case e_nbt.TAG_FLOAT:
				ds_list_add(list, buffer_read_float_be())
				break
			
			case e_nbt.TAG_DOUBLE:
				ds_list_add(list, buffer_read_double_be())
				break
			
			case e_nbt.TAG_BYTE_ARRAY:
				var len = buffer_read_int_be();
				buffer_skip(len)
				break
			
			case e_nbt.TAG_STRING:
				ds_list_add(list, buffer_read_string_short_be())
				break
			
			case e_nbt.TAG_LIST:
			{
				var nlisttype, nlistlen, nlist;
				nlisttype = buffer_read_byte()
				if (nlisttype >= e_nbt.amount)
				{
					log("TAG_List error", "Invalid tag")
					ds_list_destroy(list)
					return null
				}
				nlistlen = buffer_read_int_be()
				nlist = nbt_read_tag_list(nlisttype, nlistlen)
				if (nlist = null)
				{
					ds_list_destroy(list)
					return null
				}
				ds_list_add(list, nlist)
				ds_list_mark_as_list(list, ds_list_size(list) - 1)
				break
			}
			
			case e_nbt.TAG_COMPOUND:
			{
				var nmap = nbt_read_tag_compound();
				if (nmap = null)
				{
					ds_list_destroy(list)
					return null
				}
				ds_list_add(list, nmap)
				ds_list_mark_as_map(list, ds_list_size(list) - 1)
				break
			}
			
			case e_nbt.TAG_INT_ARRAY:
				var len = buffer_read_int_be();
				buffer_skip(len * 4)
				break
			
			case e_nbt.TAG_LONG_ARRAY:
				var len = buffer_read_int_be();
				buffer_skip(len * 8)
				break
		}
	}
	
	return list
}
