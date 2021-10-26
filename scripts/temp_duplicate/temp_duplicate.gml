/// temp_duplicate()
/// @desc Duplicates the template, returns the new one.

function temp_duplicate()
{
	var temp, copy;
	temp = new_obj(obj_template)
	temp_copy(temp)
	copy = id
	
	with (temp)
	{
		if (model != null)
			model.count++
		
		if (model_tex != null)
			model_tex.count++
		
		if (item_tex != null)
			item_tex.count++
		
		if (item_tex_material != null)
			item_tex_material.count++
		
		if (item_tex_normal != null)
			item_tex_normal.count++
		
		if (block_tex != null)
			block_tex.count++
		
		if (block_tex_material != null)
			block_tex_material.count++
		
		if (block_tex_normal != null)
			block_tex_normal.count++
		
		if (scenery != null)
			scenery.count++
		
		if (shape_tex != null && shape_tex.type != e_tl_type.CAMERA)
			shape_tex.count++
		
		if (shape_tex_material != null)
			shape_tex_material.count++
		
		if (shape_tex_normal != null)
			shape_tex_normal.count++
		
		if (text_font != null)
			text_font.count++
		
		temp_update()
		
		if (type = e_temp_type.PARTICLE_SPAWNER)
		{
			pc_type_list = ds_list_create()
			
			for (var t = 0; t < ds_list_size(other.pc_type_list); t++)
			{
				with (other.pc_type_list[|t])
				{
					var ptype = new_obj(obj_particle_type);
					ptype_copy(ptype)
					ptype.creator = temp
					ptype.sprite_tex.count++
					ptype.sprite_template_tex.count++
					with (ptype)
						ptype_update_sprite_vbuffers()
					ds_list_add(temp.pc_type_list, ptype)
				}
			}
		}
		
		return id
	}
}
