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
				return 0
			
			if (model_part.shape_list = null)
				return 0
			
			with (temp)
			{
				diffuseres = temp_get_model_texobj(other.value_inherit[e_value.TEXTURE_OBJ])
				materialres = temp_get_model_tex_material_obj(other.value_inherit[e_value.TEXTURE_MATERIAL_OBJ])
				normalres = temp_get_model_tex_normal_obj(other.value_inherit[e_value.TEXTURE_NORMAL_OBJ])
			}
			
			if ((diffuseres != null && !res_is_ready(diffuseres)) || (materialres != null && !res_is_ready(materialres)) || (normalres != null && !res_is_ready(normalres)))
				return 0
			
			model_part_tex_name = model_part_get_texture_name(model_part, temp.model_texture_name_map)
			model_part_tex_material_name = model_part_get_texture_material_name(model_part, temp.model_texture_material_name_map)
			model_part_tex_normal_name = model_part_get_tex_normal_name(model_part, temp.model_tex_normal_name_map)
			
			// Look up shape textures
			model_part_shape_tex = []
			model_part_shape_tex_material = []
			model_part_shape_tex_normal = []
			model_part_shape_material_res = []
			var shapetexnamemap, shapetexmatnamemap, shapetexnormnamemap;
			shapetexnamemap = temp.model_shape_texture_name_map
			shapetexmatnamemap = temp.model_shape_texture_material_name_map
			shapetexnormnamemap = temp.model_shape_tex_normal_name_map
			
			for (var i = 0; i < ds_list_size(model_part.shape_list); i++)
			{
				var shape = model_part.shape_list[|i];
				
				// Get texture (shape texture overrides part texture)
				var shapetexname = model_part_tex_name;
				if (shape.texture_name != "")
					shapetexname = shape.texture_name
				
				var shapetexmatname = model_part_tex_material_name;
				if (shape.texture_material_name != "")
					shapetexmatname = shape.texture_material_name
				
				var shapetexnormname = model_part_tex_normal_name;
				if (shape.texture_normal_name != "")
					shapetexnormname = shape.texture_normal_name
				
				// Change texture if name is in shape texture map
				if (shapetexnamemap != null)
				{
					var maptexname = shapetexnamemap[?shape.description];
					if (!is_undefined(maptexname))
						shapetexname = maptexname
				}
				
				if (shapetexmatnamemap != null)
				{
					var maptexmatname = shapetexmatnamemap[?shape.description];
					if (!is_undefined(maptexmatname))
						shapetexmatname = maptexmatname
				}
				
				if (shapetexnormnamemap != null)
				{
					var maptexnormname = shapetexnormnamemap[?shape.description];
					if (!is_undefined(maptexnormname))
						shapetexnormname = maptexnormname
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
							other.model_part_shape_tex_material[i] = null
						else
							other.model_part_shape_tex_material[i] = res_get_model_texture_material(shapetexmatname)
					}
				}
				else // No material texture
				{
					model_part_shape_tex_material[i] = null
					model_part_shape_material_res[i] = temp.model
				}
				
				// Normal
				if (normalres != null) 
				{
					with (normalres)
						other.model_part_shape_tex_normal[i] = res_get_model_tex_normal(shapetexnormname)
				}
				else // No normal texture
					model_part_shape_tex_normal[i] = null
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
	
	return 1
}
