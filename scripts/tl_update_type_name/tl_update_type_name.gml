/// tl_update_type_name()
/// @desc Updates the type name (shown in information window)

if (type = "bodypart" && part_of != null)
{
	var dname;
	with (model_part)
		dname = minecraft_get_name("model", name)
		
	if (model_part != null)
		type_name = text_get("timelinebodypartof", dname, part_of.display_name)
	else
		type_name = text_get("timelinebodypartof", text_get("timelineunusedbodypart"), string_remove_newline(part_of.display_name))
}
else if (temp != null)
	type_name = text_get("timelineinstanceof", temp.display_name)
else
	type_name = text_get("type" + type)
