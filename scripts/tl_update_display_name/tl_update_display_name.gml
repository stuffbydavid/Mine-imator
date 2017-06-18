/// tl_update_display_name()
/// @desc Sets the default name of a timeline (shown in timeline.)

if (name = "")
{
    if (type = "bodypart" && part_of)
	{
		with (bodypart)
			other.display_name = model_display_name()
        //if (bodypart < temp.char_model.part_amount) TODO
        //    display_name = text_get(temp.char_model.part_name[bodypart])
        //else
        //    display_name = text_get("timelineunusedbodypart")
    }
	else if (temp)
        display_name = temp.display_name
    else
        display_name = text_get("type" + type)
}
else
    display_name = name

for (var p = 0; p < part_amount; p++)
    with (part[p])
        tl_update_type_name()
