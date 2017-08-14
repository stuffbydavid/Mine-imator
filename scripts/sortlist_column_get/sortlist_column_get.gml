/// sortlist_column_get(sortlist, value, column)
/// @arg sortlist
/// @arg value
/// @arg column
/// @desc Returns the string to display at a column for the value.

var slist, value, col;
slist = argument0
value = argument1
col = argument2

switch (slist.column_name[col])
{
	case "libname":
		if (dev_mode)
			return string_remove_newline(value.display_name) + ", iid = "+string(value.iid)
		return string_remove_newline(value.display_name)
		
	case "libtype":
		return text_get("type" + value.type)
		
	case "libcount":
		return value.count
		
	case "charname":
	case "spblockname":
		return minecraft_get_name("model", mc_version.model_name_map[?value].name)
		
	case "blockname":
		return minecraft_get_name("block", mc_version.block_name_map[?value].name)
		
	case "bodypartcharname":
		return text_get(value.name)
		
	case "particleeditortypename":
		if (dev_mode)
			return string_remove_newline(value.name) + ", iid = " + string(value.iid)
		return string_remove_newline(value.name)
		
	case "particleeditortypekind":
		if (value.temp < 0)
			return text_get("particleeditortypesprite")
		else
			return string_remove_newline(value.temp.display_name)
			
	case "particleeditortyperate":
		return string(floor(value.spawn_rate * 100)) + "%"
		
	case "resname":
		if (dev_mode)
			return string_remove_newline(value.display_name) + ", iid = " + string(value.iid)
		return string_remove_newline(value.display_name)
		
	case "resfilename":
		return string_remove_newline(value.filename)
		
	case "restype":
		return text_get("type" + value.type)
		
	case "rescount":
		return value.count
		
	case "particlepresetname":
		return filename_new_ext(filename_name(value), "")
}
