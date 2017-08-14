/// temp_update_display_name()
/// @desc Updates the display name of the template.

if (name = "")
{
	display_name = text_get("type" + type)
	
	switch (type)
	{
		case "char":
		case "spblock":
			with (char_model_file)
				other.display_name = minecraft_get_name("model", name)
			break
		
		case "scenery":
			if (scenery)
				display_name = scenery.display_name
			break
		
		case "block":
			display_name = minecraft_get_name("block", mc_version.block_name_map[?block_name].name)
			break
		
		case "bodypart":
			//display_name = text_get("librarybodypartof", text_get(char_model.part_name[char_bodypart]), text_get(char_model.name)) TODO
			break
	}
}
else
	display_name = name

with (obj_timeline)
{
	if (temp = other.id && !part_of)
	{
		tl_update_type_name()
		tl_update_display_name()
	}
}
