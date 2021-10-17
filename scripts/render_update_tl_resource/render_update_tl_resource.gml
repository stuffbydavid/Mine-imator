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
			{
				diffuseres = temp_get_model_texobj(other.value_inherit[e_value.TEXTURE_OBJ])
				materialres = temp_get_model_tex_material_obj(other.value_inherit[e_value.TEXTURE_MATERIAL_OBJ])
				normalres = temp_get_model_tex_normal_obj(other.value_inherit[e_value.TEXTURE_NORMAL_OBJ])
			}
			
			if ((diffuseres != null && !res_is_ready(diffuseres)) || (materialres != null && !res_is_ready(materialres)) || (normalres != null && !res_is_ready(normalres)))
				return 0
			
			model_part_tex_name = model_part_get_texture_name(model_part, temp.model_texture_name_map)
			model_part_material_tex_name = model_part_get_material_texture_name(model_part, temp.model_material_texture_name_map)
			model_part_normal_tex_name = model_part_get_normal_texture_name(model_part, temp.model_normal_texture_name_map)
			
			// Look up shape textures
			model_part_shape_tex = []
			model_part_shape_material_tex = []
			model_part_shape_normal_tex = []
			model_part_shape_material_res = []
			var shapetexnamemap, shapemattexnamemap, shapenortexnamemap;
			shapetexnamemap = temp.model_shape_texture_name_map
			shapemattexnamemap = temp.model_shape_material_texture_name_map
			shapenortexnamemap = temp.model_shape_normal_texture_name_map
			
			for (var i = 0; i < ds_list_size(model_part.shape_list); i++)
			{
				var shape = model_part.shape_list[|i];
				
				// Get texture (shape texture overrides part texture)
				var shapetexname = model_part_tex_name;
				if (shape.texture_name != "")
					shapetexname = shape.texture_name
				
				var shapemattexname = model_part_material_tex_name;
				if (shape.texture_material_name != "")
					shapemattexname = shape.texture_material_name
				
				var shapenortexname = model_part_normal_tex_name;
				if (shape.texture_normal_name != "")
					shapenortexname = shape.texture_normal_name
				
				// Change texture if name is in shape texture map
				if (shapetexnamemap != null)
				{
					var maptexname = shapetexnamemap[?shape.description];
					if (!is_undefined(maptexname))
						shapetexname = maptexname
				}
				
				if (shapemattexnamemap != null)
				{
					var mapmattexname = shapemattexnamemap[?shape.description];
					if (!is_undefined(mapmattexname))
						shapemattexname = mapmattexname
				}
				
				if (shapenortexnamemap != null)
				{
					var mapnortexname = shapenortexnamemap[?shape.description];
					if (!is_undefined(mapnortexname))
						shapenortexname = mapnortexname
				}
				
				// Diffuse
				with (diffuseres)
					other.model_part_shape_tex[i] = res_get_model_texture(shapetexname)
				
				// Material
				if (materialres != null)
				{
					model_part_shape_material_res[i] = materialres
					
					with (materialres)
					{
						if (id = mc_res)
							other.model_part_shape_material_tex[i] = null
						else
							other.model_part_shape_material_tex[i] = res_get_model_material_texture(shapemattexname)
					}
				}
				else // No material texture
				{
					model_part_shape_material_tex[i] = null
					model_part_shape_material_res[i] = temp.model
				}
				
				// Normal
				if (normalres != null) 
				{
					with (normalres)
						other.model_part_shape_normal_tex[i] = res_get_model_normal_texture(shapenortexname)
				}
				else // No normal texture
					model_part_shape_normal_tex[i] = null
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
			
			if (!res_is_ready(diffuseres) || !res_is_ready(materialres) || !res_is_ready(normalres))
				return 0
		}
	}
	
	render_res_diffuse = diffuseres
	render_res_material = materialres
	render_res_normal = normalres
}
