/// temp_duplicate()
/// @desc Duplicates the template, returns the new one.

var temp, copy;
temp = new(obj_template)
temp_copy(temp)
copy = id

with (temp)
{
	if (skin)
		skin.count++
		
	if (item_tex)
		item_tex.count++
		
	if (block_tex)
		block_tex.count++
		
	if (scenery)
		scenery.count++
		
	if (shape_tex && shape_tex.type != e_tl_type.CAMERA)
		shape_tex.count++
		
	if (text_font)
		text_font.count++
		
	temp_update()
	
	if (type = e_temp_type.PARTICLE_SPAWNER)
	{
		pc_type_list = ds_list_create()
	
		for (var t = 0; t < ds_list_size(other.pc_type_list); t++)
		{
			with (other.pc_type_list[|t])
			{
				var ptype = new(obj_particle_type);
				ptype_copy(ptype)
				ptype.creator = temp
				ptype.sprite_tex.count++
				with (ptype)
					ptype_update_sprite_vbuffers()
				ds_list_add(temp.pc_type_list, ptype)
			}
		}
	}
	
	return id
}
