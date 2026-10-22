/// @desc Create a sign text timeline.

function block_animate_text(text, textpos, textrot, textscale, textcolor, textglowcolor, textemissive, textparent)
{
	if (string_replace_all(string_remove_newline(text), " ", "") = "")
		return 0

	if (textparent.type = e_tl_type.MODEL_PART)
		textpos = point3D_sub(textpos, textparent.model_part.position)

	with (new_obj(obj_timeline))
	{
		type = e_tl_type.TEXT
		temp = id
		has_temp = false
		animated = false

		// Keep text in the block's part list while parenting it to the sign part
		inherit_rot_point = true
		part_of = other.id
		ds_list_add(other.part_list, id)
		tl_set_parent(textparent)

		value_default[e_value.TEXT] = text
		value[e_value.TEXT] = text
		tl_update_scenery_part()

		tl_value_set_vec3(e_value.POS_X, textpos, true)
		tl_value_set_vec3(e_value.ROT_X, textrot, true)
		tl_value_set_vec3(e_value.SCA_X, vec3(textscale), true)
		value_default[e_value.RGB_MUL] = textcolor
		value_default[e_value.EMISSIVE] = textemissive

		if (textemissive > 0)
		{
			value_default[e_value.TEXT_OUTLINE] = true
			value_default[e_value.TEXT_OUTLINE_COLOR] = textglowcolor
		}

		// Static text renders from value without evaluating defaults
		value = array_copy_1d(value_default)
		
		tl_update()
		tl_update_values()
	}
}
