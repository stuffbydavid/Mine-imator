/// sortlist_column_get(sortlist, value, column)
/// @arg sortlist
/// @arg value
/// @arg column
/// @desc Returns the string to display at a column for the value.

function sortlist_column_get(slist, value, col)
{
	switch (slist.column_name[col])
	{
		case "buildname":
			if (value[0])
				return minecraft_asset_get_name("model", value[1])
			return minecraft_asset_get_name("block", value[1])

		case "libname":
			if (debug_saveid)
				return string_remove_newline(value.display_name) + " [" + string(value.save_id) + "]"
			return string_remove_newline(value.display_name)
		
		case "libtype":
			return text_get("type" + temp_type_name_list[|value.type])
		
		case "libinstances":
			return value.count = -1 ? "-" : value.count
		
		case "charname":
		case "spblockname":
		case "modelpartmodelname":
			if (is_undefined(mc_assets.model_name_map[?value]))
				return 0
			return minecraft_asset_get_name("model", mc_assets.model_name_map[?value].name)
		
		case "blockname":
			if (is_undefined(mc_assets.block_name_map[?value]))
				return 0
			return minecraft_asset_get_name("block", mc_assets.block_name_map[?value].name)
		
		case "blockfilter":
			return minecraft_asset_get_name("block", mc_assets.block_list[|value].name)
		
		case "sceneryname":
		case "schematicname":
			if (!is_string(value))
				return value.display_name

			var schematicfn = filename_new_ext(filename_name(value), "")
			return text_exists("benchschematic" + schematicfn) ? text_get("benchschematic" + schematicfn) : schematicfn
		
		case "shapename":
			return text_get("type" + tl_type_name_list[|e_tl_type.CUBE + value])
		
		case "particleeditortypename":
			if (debug_saveid)
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
		
		case "projectname":
		case "resname":
			if (debug_saveid)
				return string_remove_newline(value.display_name) + " [" + string(value.save_id) + "]"
			return string_remove_newline(value.display_name)
		
		case "projecttype":
			if (value.object_index = obj_resource)
				return text_get("type" + res_type_name_list[|value.type])
			return text_get("type" + temp_type_name_list[|value.type])

		case "resfilename":
			return string_remove_newline(value.filename)
		
		case "restype":
			return text_get("type" + res_type_name_list[|value.type])
		
		case "projectcount":
		case "rescount":
			return value.count = -1 ? "-" : value.count
		
		case "particlepresetname":
			if (!is_string(value))
				return string_remove_newline(value.display_name)

			var particlefn = filename_new_ext(filename_name(value), "")
			return text_exists("benchparticles" + particlefn) ? text_get("benchparticles" + particlefn) : particlefn
	}
}
