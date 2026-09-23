/// temp_get_save_ids()

function temp_get_save_ids()
{
	switch (type)
	{
		case e_temp_type.CHARACTER:
		case e_temp_type.EQUIPMENT:
		case e_temp_type.MODEL:
		case e_temp_type.MODEL_PART:
		case e_temp_type.SPECIAL_BLOCK:
		{
			model = save_id_get(model)
			model_tex = save_id_get(model_tex)
			model_tex_material = save_id_get(model_tex_material)
			model_tex_normal = save_id_get(model_tex_normal)
			break
		}
		
		case e_temp_type.ITEM:
		{
			item_tex = save_id_get(item_tex)
			item_tex_material = save_id_get(item_tex_material)
			item_tex_normal = save_id_get(item_tex_normal)
			break
		}
		
		case e_temp_type.SCENERY:
		case e_temp_type.BLOCK:
		{
			block_tex = save_id_get(block_tex)
			block_tex_material = save_id_get(block_tex_material)
			block_tex_normal = save_id_get(block_tex_normal)
			if (type = e_temp_type.SCENERY)
				scenery = save_id_get(scenery)
			break
		}
		case e_temp_type.TEXT:
		{
			text_font = save_id_get(text_font)
			break
		}
	}
	
	if (type_is_shape(type))
	{
		shape_tex = save_id_get(shape_tex)
		shape_tex_material = save_id_get(shape_tex_material)
		shape_tex_normal = save_id_get(shape_tex_normal)
	}
}
