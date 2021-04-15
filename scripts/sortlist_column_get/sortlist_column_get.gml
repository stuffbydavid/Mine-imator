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
			return string_remove_newline(value.display_name) + " [" + string(value.save_id) + "]"
		return string_remove_newline(value.display_name)
		
	case "libtype":
		return text_get("type" + temp_type_name_list[|value.type])
		
	case "libinstances":
		return value.count
		
	case "charname":
	case "spblockname":
	case "bodypartmodelname":
		return minecraft_asset_get_name("model", mc_assets.model_name_map[?value].name)
		
	case "blockname":
		return minecraft_asset_get_name("block", mc_assets.block_name_map[?value].name)
		
	case "particleeditortypename":
		if (dev_mode)
			return string_remove_newline(value.name) + " [" + string(value.save_id) + "]"
		return string_remove_newline(value.name)
		
	case "particleeditortypekind":
		if (value.temp = particle_sheet)
			return text_get("particleeditortypespritesheet")
		else if (value.temp = particle_template)
			return text_get("particleeditortypetemplate")
		else
			return string_remove_newline(value.temp.display_name)
			
	case "particleeditortyperate":
		return string(floor(value.spawn_rate * 100)) + "%"
		
	case "resname":
		if (dev_mode)
			return string_remove_newline(value.display_name) + " [" + string(value.save_id) + "]"
		return string_remove_newline(value.display_name)
		
	case "resfilename":
		return string_remove_newline(value.filename)
		
	case "restype":
		return text_get("type" + res_type_name_list[|value.type])
		
	case "rescount":
		return value.count
		
	case "particlepresetname":
	{
		var fn = filename_new_ext(filename_name(value), "");
		return text_exists("particle" + fn) ? text_get("particle" + fn) : fn;
	}
}
