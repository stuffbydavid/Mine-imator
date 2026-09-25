/// temp_animate()
/// @desc Adds a new timeline from the template.

function temp_animate()
{
	with (new_obj(obj_timeline))
	{
		type = other.type
		temp = other.id
		has_temp = true
		animated = type_is_animated(type)
		
		if (type = e_tl_type.TEXT)
		{
			value[e_value.TEXT] = text_get("frameeditortextsample")
			value[e_value.TEXT_OUTLINE] = temp.text_outline
			value[e_value.TEXT_OUTLINE_COLOR] = temp.text_outline_color
			value[e_value.TEXT_OUTLINE_SIZE] = temp.text_outline_size
			value[e_value.TEXT_HALIGN] = temp.text_halign
			value[e_value.TEXT_VALIGN] = temp.text_valign
		}
		
		if (type = e_tl_type.EQUIPMENT)
		{
			inherit_pose = true
			glint_mode = e_glint.ARMOR
		}
		
		if (type_is_block(type))
		{
			inherit_rot_point = true
			inherit_alpha = true
			inherit_color = true
			inherit_texture = true
		}
		
		tl_set_parent_root()
		
		switch (type)
		{
			case e_temp_type.CHARACTER:
			case e_temp_type.EQUIPMENT:
			case e_temp_type.SPECIAL_BLOCK:
			case e_temp_type.MODEL:
			{
				part_list = ds_list_create()
				if (temp.model_file != null)
				{
					for (var p = 0; p < ds_list_size(temp.model_file.file_part_list); p++)
					{
						var part = temp.model_file.file_part_list[|p];
						if (temp.model_hide_list = null || ds_list_find_index(temp.model_hide_list, part.name) = -1)
							ds_list_add(part_list, tl_new_part(part))
					}
					tl_update_part_list(temp.model_file, id)
				}
				break
			}
			
			case e_temp_type.BLOCK:
				texture_filtering = true
				break
			
			case e_temp_type.SCENERY:
			{
				texture_filtering = true
				
				if (temp.scenery != null)
				{
					if (temp.scenery.ready)
						tl_animate_scenery()
					else
						scenery_animate = true
				}
				
				break
			}
			
			case e_temp_type.MODEL_PART:
			{
				model_part = temp.model_part 
				if (model_part != null)
					model_part_name = model_part.name
				else
					model_part_name = ""
				break
			}
			
			case e_temp_type.SURFACE:
				backfaces = true
				break
		}
		
		tl_update()
		tl_value_spawn()
		
		return id
	}
}
