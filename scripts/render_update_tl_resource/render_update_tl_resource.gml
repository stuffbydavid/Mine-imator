/// render_update_tl_resource()
/// @desc Updates the resource used by a timeline for rendering their 3D model

function render_update_tl_resource()
{
	var res = null;
	
	switch (type)
	{
		case e_tl_type.BODYPART:
		{
			if (model_part = null)
				break
			
			with (temp)
				res = temp_get_model_texobj(other.value_inherit[e_value.TEXTURE_OBJ])
			
			break
		}
		
		case e_tl_type.SCENERY:
		case e_tl_type.BLOCK:
		{
			with (temp)
				res = temp_get_block_texobj(other.value_inherit[e_value.TEXTURE_OBJ])
		}
	}
	
	render_res = res
}
