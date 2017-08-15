/// temp_duplicate()
/// @desc Duplicates the template, returns the new one.

var temp, copy;
temp = new(obj_template)
temp_copy(temp)
copy = id

with (temp)
{
	if (char_skin)
		char_skin.count++
		
	if (item_tex)
		item_tex.count++
		
	if (block_tex)
		block_tex.count++
		
	if (scenery)
		scenery.count++
		
	if (shape_tex && shape_tex.type != "camera")
		shape_tex.count++
		
	if (text_font)
		text_font.count++
		
	if (type = "char" || type = "spblock" || type = "bodypart")
	{
		temp_update_model_state_map()
		temp_update_model()
		if (type = "bodypart")
			temp_update_model_part()
	}
	
	if (type = "item")
		temp_update_item()
		
	if (type = "block")
	{
		temp_update_block_state_map()
		temp_update_block()
	}
		
	if (type_is_shape(type))
		temp_update_shape()
		
	if (type = "particles")
	{
		for (var t = 0; t < pc_types; t++)
		{
			with (copy.pc_type[t])
			{
				var ptype = new(obj_particle_type);
				ptype_copy(ptype)
				ptype.creator = temp
				ptype.sprite_tex.count++
				with (ptype)
					ptype_update_sprite_vbuffers()
				temp.pc_type[t] = ptype
			}
		}
	}
	
	temp_update_rot_point()
	temp_update_display_name()
	
	return id
}
