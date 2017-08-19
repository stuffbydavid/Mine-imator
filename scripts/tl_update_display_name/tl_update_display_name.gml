/// tl_update_display_name()
/// @desc Sets the default name of a timeline (shown in timeline).

if (name = "")
{
	if (type = "bodypart" && part_of)
	{
		if (model_part)
		{
			with (model_part)
				other.display_name = minecraft_get_name("model", name)
		}
		else
			display_name = text_get("timelineunusedbodypart")
	}
	else if (temp)
		display_name = temp.display_name
	else
		display_name = text_get("type" + type)
}
else
	display_name = name

for (var p = 0; p < ds_list_size(part_list); p++)
	with (part_list[|p])
		tl_update_type_name()
