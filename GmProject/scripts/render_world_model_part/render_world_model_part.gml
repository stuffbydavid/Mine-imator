/// @arg part
/// @arg resource
/// @arg texturenamemap
/// @arg shapevbuffermap
/// @arg colornamemap
/// @arg shapehidelist
/// @arg shapetexnamemap
/// @arg [timeline]

function render_world_model_part(part, res, texnamemap, shapevbuffermap, colornamemap, shapehidelist, shapetexnamemap, tl = null)
{
	if (part.shape_list = null)
		return 0

	res = res_eval(res)
	render_apply_res(res)
	
	if (!tl && !render_depth_pass)
	{
		render_set_material_textures_none()
		render_set_uniform_int(e_uniform.MATERIAL_FORMAT, e_material.FORMAT_NONE)
	}
	
	var parttexname, mat;
	parttexname = (tl ? "" : string(model_part_get_texture_name(part, texnamemap)))
	
	if (!tl)
		mat = matrix_get(matrix_world)
	else if (tl.model_part_shape_render_matrix_part != part || array_length(tl.model_part_shape_render_matrix) != ds_list_size(part.shape_list))
		with (tl)
			tl_update_model_shape_matrix()
	
	var shape, texobj, blendcolor, alpha;
	texobj = null
	blendcolor = null
	alpha = null
	render_blend_prev = null
	render_alpha_prev = null
	
	for (var s = 0; s < ds_list_size(part.shape_list); s++)
	{
		shape = part.shape_list[|s]
		
		// Hidden?
		if (shapehidelist != null && ds_list_find_index(shapehidelist, shape.description) > -1)
			continue
		
		// Click mode
		if (render_mode = e_render_mode.CLICK && shape.locked)
			continue
		
		// Check alpha if valid to render
		if ((shape.color_alpha * 1000) = 0)
			continue
		
		// Does the part need to move a certain amount for this shape to render?
		if (shape.move_required)
		{
			if (!tl)
				continue
			
			if (!(abs(tl.value[e_value.POS_X]) > shape.move_required_array[X] &&
			abs(tl.value[e_value.POS_Y]) > shape.move_required_array[Y] &&
			abs(tl.value[e_value.POS_Z]) > shape.move_required_array[Z]))
				continue
		}
		
		// Set shape texture
		if (tl)
		{
			if (s > array_length(model_part_shape_tex) - 1)
				continue
			
			render_set_texture(tl.render_res_diffuse, model_part_shape_tex[s])
			
			render_set_uniform_vec2(e_uniform.TEXTURE_OFFSET,
									(app.env_time / 60) * shape.texture_scroll_speed * sin(degtorad(shape.texture_scroll_direction)),
									(app.env_time / 60) * shape.texture_scroll_speed * cos(degtorad(shape.texture_scroll_direction)))
			
			if (!render_depth_pass)
			{
				render_set_uniform_int(e_uniform.MATERIAL_FORMAT, model_part_shape_material_res[s])

				if (model_part_shape_tex_material[s] = null)
				{
					render_set_texture(null, 0, e_texture_channel.MATERIAL)

					if (value_inherit[e_value.EMISSIVE] != shader_uniform_emissive)
					{
						shader_uniform_emissive = value_inherit[e_value.EMISSIVE]
						render_set_uniform(e_uniform.EMISSIVE, shader_uniform_emissive)
					}

					if (value_inherit[e_value.METALLIC] != shader_uniform_metallic)
					{
						shader_uniform_metallic = value_inherit[e_value.METALLIC]
						render_set_uniform(e_uniform.METALLIC, shader_uniform_metallic)
					}

					if (value_inherit[e_value.ROUGHNESS] != shader_uniform_roughness)
					{
						shader_uniform_roughness = value_inherit[e_value.ROUGHNESS]
						render_set_uniform(e_uniform.ROUGHNESS, shader_uniform_roughness)
					}
				}
				else
				{
					render_set_texture(tl.render_res_material, model_part_shape_tex_material[s], e_texture_channel.MATERIAL)

					if (shader_uniform_metallic != 1)
					{
						shader_uniform_metallic = 0
						render_set_uniform(e_uniform.METALLIC, shader_uniform_metallic)
					}

					if (shader_uniform_roughness != 0)
					{
						shader_uniform_roughness = 0
						render_set_uniform(e_uniform.ROUGHNESS, shader_uniform_roughness)
					}

					if (shader_uniform_emissive != 1)
					{
						shader_uniform_emissive = 0
						render_set_uniform(e_uniform.EMISSIVE, shader_uniform_emissive)
					}
				}
				
				if (model_part_shape_tex_normal[s] = null)
					render_set_texture(null, 0, e_texture_channel.NORMAL)
				else
					render_set_texture(tl.render_res_normal, model_part_shape_tex_normal[s], e_texture_channel.NORMAL)
			}
		}
		else
		{
			// Get texture (shape texture overrides part texture)
			var shapetexname = parttexname;
			if (shape.texture_name != "")
				shapetexname = shape.texture_name
			
			// Change texture if name is in shape texture map
			if (shapetexnamemap != null)
			{
				var maptexname = shapetexnamemap[?shape.description];
				if (!is_undefined(maptexname))
					shapetexname = maptexname
			}
			
			with (res)
			{
				texobj = res_get_model_texture(shapetexname)
				render_set_texture(res, texobj)
			}
		}
		
		#region Pattern rendering
		
		// Preview
		if (object_index = obj_preview && select.pattern_type != "")
		{
			if (sprite_exists(select.pattern_skin))
				render_set_texture(null, select.pattern_skin)
		}
		
		if (tl != null)
		{
			// Use skin if provided to timeline, else use skin in template
			if (sprite_exists(tl.pattern_skin))
			{
				// Only use pattern if timeline is using its template's resource
				var tempres = null;
				
				with (tl.temp)
					tempres = temp_get_model_texobj(null)
				
				if (res = tempres)
					if (sprite_exists(tl.pattern_skin))
						render_set_texture(null, tl.pattern_skin)
			}
			else if (tl.temp.pattern_type != "")
			{
				// Only use pattern if timeline is using its template's resource
				var tempres = null;
				
				with (tl.temp)
					tempres = temp_get_model_texobj(null)
				
				if (res = tempres)
					if (sprite_exists(tl.temp.pattern_skin))
						render_set_texture(null, tl.temp.pattern_skin)
			}
		}
		
		#endregion
		
		#region Armor rendering
		
		// Preview
		if (object_index = obj_preview && select.object_index != obj_resource && select.model_name = "armor")
		{
			if (shape.description = "helmet" || shape.description = "helmet_baby")
			{
				if (sprite_exists(select.armor_skin_array[0]))
					render_set_texture(null, select.armor_skin_array[0])
			}
			
			if (shape.description = "chestplate" || shape.description = "chestplate_baby")
			{
				if (sprite_exists(select.armor_skin_array[1]))
					render_set_texture(null, select.armor_skin_array[1])
			}
			
			if (shape.description = "leggings" || shape.description = "leggings_baby")
			{
				if (sprite_exists(select.armor_skin_array[2]))
					render_set_texture(null, select.armor_skin_array[2])
			}
			
			if (shape.description = "boots" || shape.description = "boots_baby")
			{
				if (sprite_exists(select.armor_skin_array[3]))
					render_set_texture(null, select.armor_skin_array[3])
			}
		}
		
		if (tl != null && tl.temp.model_name = "armor")
		{
			if (shape.description = "helmet" || shape.description = "helmet_baby")
			{
				if (sprite_exists(tl.temp.armor_skin_array[0]))
					render_set_texture(null, tl.temp.armor_skin_array[0])
			}
			
			if (shape.description = "chestplate" || shape.description = "chestplate_baby")
			{
				if (sprite_exists(tl.temp.armor_skin_array[1]))
					render_set_texture(null, tl.temp.armor_skin_array[1])
			}
			
			if (shape.description = "leggings" || shape.description = "leggings_baby")
			{
				if (sprite_exists(tl.temp.armor_skin_array[2]))
					render_set_texture(null, tl.temp.armor_skin_array[2])
			}
			
			if (shape.description = "boots" || shape.description = "boots_baby")
			{
				if (sprite_exists(tl.temp.armor_skin_array[3]))
					render_set_texture(null, tl.temp.armor_skin_array[3])
			}
		}
		
		#endregion
		
		// Blend color
		blendcolor = render_depth_pass ? c_white : shape.color_blend
		alpha = shape.color_alpha
		if (!render_depth_pass && colornamemap != null)
		{
			var color = colornamemap[? shape.description];
			if (!is_undefined(color))
				blendcolor = color
		}
		
		// Model blend color
		if (!render_depth_pass && shape.use_model_color)
		{
			if (object_index = obj_preview && select.model_use_blend_color)
				blendcolor = color_multiply(blendcolor, select.model_blend_color)
			
			if (tl != null && tl.temp.model_use_blend_color)
				blendcolor = color_multiply(blendcolor, tl.temp.model_blend_color)
		}
		
		// Blend shape color/alpha
		if (render_depth_pass)
			alpha = shader_blend_alpha * alpha
		else if (blendcolor != c_white || alpha != 1)
		{
			blendcolor = color_multiply(shader_blend_color, blendcolor)
			alpha = shader_blend_alpha * shape.color_alpha
		}
		else
		{
			blendcolor = shader_blend_color
			alpha = shader_blend_alpha
		}
		
		// Set color/alpha
		if (blendcolor != render_blend_prev || alpha != render_alpha_prev)
		{
			render_set_uniform_color(e_uniform.BLEND_COLOR, blendcolor, alpha)
			render_blend_prev = blendcolor
			render_alpha_prev = alpha
		}
		
		// Mix color
		if (!render_depth_pass && shape.color_mix_percent > 0)
		{
			if (tl != null)
				render_set_uniform_color(e_uniform.MIX_COLOR, merge_color(shape.color_mix, value_inherit[e_value.MIX_COLOR], value_inherit[e_value.MIX_PERCENT]), lerp(shape.color_mix_percent, value_inherit[e_value.MIX_PERCENT], value_inherit[e_value.MIX_PERCENT]))
			else
				render_set_uniform_color(e_uniform.MIX_COLOR, shape.color_mix, shape.color_mix_percent)
		}
		
		// Pick vertex buffer from map if available
		if (shapevbuffermap != null && !is_undefined(shapevbuffermap[?shape]))
		{
			var vbuf = shapevbuffermap[?shape];
			if (tl != null && !shape.item_bounce && !shape.face_camera && tl.model_part_shape_render_matrix_part = part)
			{
				// Submit cached matrix without array conversion
				matrix_set(matrix_world, tl.model_part_shape_render_matrix[s])
				vertex_submit(vbuf, pr_trianglelist, -1)
				matrix_world_reset()
				continue
			}

			// Shape matrix
			var rendermatrix;
			if (tl)
				rendermatrix = matrix_multiply(shape.matrix, matrix_render)
			else
				rendermatrix = matrix_multiply(shape.matrix, mat)

			if (shape.item_bounce || shape.face_camera)
				rendermatrix = render_world_item_transform(rendermatrix, shape.face_camera, shape.item_bounce, false, false, false, false)

			vbuffer_render_matrix(vbuf, rendermatrix)
		}
	}
	
	if (!tl)
		matrix_set(matrix_world, mat)
}
