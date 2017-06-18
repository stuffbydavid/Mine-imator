/// tl_update_type_name()
/// @desc Updates the type name (shown in information window)

if (type = "bodypart" && part_of)
{
	var dname;
	with (bodypart)
		dname = model_display_name()
		
    //if (bodypart < temp.char_model.part_amount)
		type_name = text_get("timelinebodypartof", dname, part_of.display_name)
    /*else
        type_name = text_get("timelinebodypartof", text_get("timelineunusedbodypart"), string_remove_newline(part_of.display_name))*/ // TODO
}
else if (temp)
    type_name = text_get("timelineinstanceof", temp.display_name)
else
    type_name = text_get("type" + type)
