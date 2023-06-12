/// nbt_debug_tag_list(name, list, listtype)
/// @arg name
/// @arg list
/// @arg listtype

function nbt_debug_tag_list(name, list, listtype)
{
	var listtypestr;
	
	switch (listtype)
	{
		case e_nbt.TAG_BYTE:		listtypestr = "TAG_Byte"		break
		case e_nbt.TAG_SHORT:		listtypestr = "TAG_Short"		break
		case e_nbt.TAG_INT:			listtypestr = "TAG_Int"			break
		case e_nbt.TAG_LONG:		listtypestr = "TAG_Long"		break
		case e_nbt.TAG_FLOAT:		listtypestr = "TAG_Float"		break
		case e_nbt.TAG_DOUBLE:		listtypestr = "TAG_Double"		break
		case e_nbt.TAG_BYTE_ARRAY:	listtypestr = "TAG_Byte_Array"	break
		case e_nbt.TAG_STRING:		listtypestr = "TAG_String"		break
		case e_nbt.TAG_LIST:		listtypestr = "TAG_List"		break
		case e_nbt.TAG_COMPOUND:	listtypestr = "TAG_Compound"	break
		case e_nbt.TAG_INT_ARRAY:	listtypestr = "TAG_Int_Array"	break
		case e_nbt.TAG_LONG_ARRAY:	listtypestr = "TAG_Long_Array"	break
		default:					listtypestr = "TAG_Empty"		break
	}
	
	debug("[TAG_List of " + listtypestr + "] " + name)
	debug("{")
	debug_indent++
	
	for (var i = 0; i < ds_list_size(list); i++)
	{
		switch (listtype)
		{
			case e_nbt.TAG_BYTE:
			case e_nbt.TAG_SHORT:
			case e_nbt.TAG_INT:
			case e_nbt.TAG_LONG:
			case e_nbt.TAG_FLOAT:
			case e_nbt.TAG_DOUBLE:
			case e_nbt.TAG_STRING:
				debug(string(list[|i]) + ",")
				break
			
			case e_nbt.TAG_BYTE_ARRAY:
				break
			
			case e_nbt.TAG_LIST:
				break
			
			case e_nbt.TAG_COMPOUND:
				nbt_debug_tag_compound("", list[|i])
				break
			
			case e_nbt.TAG_INT_ARRAY:
				break
			
			case e_nbt.TAG_LONG_ARRAY:
				break
		}
	}
	
	debug_indent--
	debug("}")
}
