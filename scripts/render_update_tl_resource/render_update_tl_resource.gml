/// render_update_tl_resource()
/// @desc Updates the resource used by a timeline for rendering their 3D model

function render_update_tl_resource()
{
	var diffuseres, materialres, normalres;
	diffuseres = null
	materialres = null
	normalres = null
	
	switch (type)
	{
		case e_tl_type.BODYPART:
		{
			if (model_part = null)
				break
			
			if (model_part.shape_list = null)
				break
			
			with (temp)
				diffuseres = temp_get_model_texobj(other.value_inherit[e_value.TEXTURE_OBJ])
			
			model_part_tex_name = model_part_get_texture_name(model_part, temp.model_texture_name_map)
			
			// Look up shape textures
			model_part_shape_tex = []
			var shapetexnamemap = temp.model_shape_texture_name_map;
			
			for (var i = 0; i < ds_list_size(model_part.shape_list); i++)
			{
				var shape = model_part.shape_list[|i];
				
				// Get texture (shape texture overrides part texture)
				var shapetexname = model_part_tex_name;
				if (shape.texture_name != "")
					shapetexname = shape.texture_name
				
				// Change texture if name is in shape texture map
				if (shapetexnamemap != null)
				{
					var maptexname = shapetexnamemap[?shape.description];
					if (!is_undefined(maptexname))
						shapetexname = maptexname
				}
				
				with (diffuseres)
					other.model_part_shape_tex[i] = res_get_model_texture(shapetexname)
			}
			
			break
		}
		
		case e_tl_type.SCENERY:
		case e_tl_type.BLOCK:
		{
			with (temp)
			{
				diffuseres = temp_get_block_texobj(other.value_inherit[e_value.TEXTURE_OBJ])
				materialres = temp_get_block_tex_material_obj(other.value_inherit[e_value.TEXTURE_MATERIAL_OBJ])
				normalres = temp_get_block_tex_normal_obj(other.value_inherit[e_value.TEXTURE_NORMAL_OBJ])
			}
		}
	}
	
	render_res_diffuse = diffuseres
	render_res_material = materialres
	render_res_normal = normalres
}
