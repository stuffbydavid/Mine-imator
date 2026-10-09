/// @arg part
/// @arg resource
/// @arg texturenamemap
/// @arg shapevertexbuffermap
/// @arg colornamemap
/// @arg shapehidelist
/// @arg shapetexnamemap
/// @arg [istimeline]

function render_world_model_part(part, res, texnamemap, shapevbuffermap, colornamemap, shapehidelist, shapetexnamemap, istl = false)
{
	var shapelist, shapecount;
	shapelist = part.shape_list
	
	if (shapelist = null)
		return 0
	
	shapecount = ds_list_size(shapelist)

	res = res_eval(res)
	render_apply_res(res)
	
	if (!istl && !render_depth_pass && render_material_pass)
	{
		render_set_material_textures_none()
		render_set_uniform_int(e_uniform.MATERIAL_FORMAT, e_material.FORMAT_NONE)
	}
	
	var parttexname, mat;
	parttexname = (istl ? "" : string(model_part_get_texture_name(part, texnamemap)))
	
	if (!istl)
		mat = matrix_get(matrix_world)
	else if (model_part_shape_render_matrix_part != part || array_length(model_part_shape_render_matrix) != shapecount)
		tl_update_model_shape_render()
	
	render_blend_prev = null
	render_alpha_prev = null
	
	var prevx, prevy, offsetset;
	prevx = 0
	prevy = 0
	offsetset = false
	
	var patterntex, custompattern;
	patterntex = null
	if (object_index = obj_preview && select.pattern_type != "" && sprite_exists(select.pattern_skin))
		patterntex = select.pattern_skin
	
	custompattern = istl && sprite_exists(pattern_skin)
	
	if (istl && (custompattern || temp.pattern_type != ""))
	{
		var tempres = null;
		with (temp)
			tempres = temp_get_model_texobj(null)
		
		if (res = tempres)
		{
			if (custompattern)
				patterntex = pattern_skin
			else if (sprite_exists(temp.pattern_skin))
				patterntex = temp.pattern_skin
		}
	}
	
	var previewarmor, tlarmor, previewblend, tlblend, previewcolor, timelinecolor;
	previewarmor = (object_index = obj_preview && select.object_index != obj_resource && select.model_name = "armor")
	tlarmor = (istl && temp.model_name = "armor")
	previewblend = (object_index = obj_preview && select.model_use_blend_color)
	tlblend = (istl && temp.model_use_blend_color)
	
	if (previewblend)
		previewcolor = select.model_blend_color
	
	if (tlblend)
		timelinecolor = temp.model_blend_color

	for (var s = 0; s < shapecount; s++)
	{
		var shape, vbuf, tex, texres;
		shape = shapelist[|s]
		
		// Hidden?
		if (istl)
		{
			if (model_part_shape_hidden[s])
				continue
		}
		else
		{
			if (shapehidelist != null && ds_list_find_index(shapehidelist, shape.description) > -1)
				continue
		}
		
		// Click mode
		if (render_mode = e_render_mode.CLICK && shape.locked)
			continue
		
		// Check alpha if valid to render
		if ((shape.color_alpha * 1000) = 0)
			continue
		
		// Does the part need to move a certain amount for this shape to render?
		if (shape.move_required)
		{
			if (!istl)
				continue
			
			if (!(abs(value[e_value.POS_X]) > shape.move_required_array[X] &&
				abs(value[e_value.POS_Y]) > shape.move_required_array[Y] &&
				abs(value[e_value.POS_Z]) > shape.move_required_array[Z]))
				continue
		}
		
		if (istl)
			vbuf = model_part_shape_vbuffer[s]
		else
		{
			if (shapevbuffermap = null)
				continue
			
			vbuf = shapevbuffermap[?shape]
		}
		
		if (is_undefined(vbuf) || vbuf = null)
			continue

		// Set shape texture
		if (istl)
		{
			if (s > array_length(model_part_shape_tex) - 1)
				continue
			
			tex = model_part_shape_tex[s]
			texres = render_res_diffuse
			
			var offsetx, offsety;
			offsetx = 0
			offsety = 0
			
			if (shape.texture_scroll_speed != 0)
			{
				var scroll = (app.env_time / 60) * shape.texture_scroll_speed;
				offsetx = scroll * sin(degtorad(shape.texture_scroll_direction))
				offsety = scroll * cos(degtorad(shape.texture_scroll_direction))
			}
			
			if (!offsetset || offsetx != prevx || offsety != prevy)
			{
				render_set_uniform_vec2(e_uniform.TEXTURE_OFFSET, offsetx, offsety)
				
				prevx = offsetx
				prevy = offsety
				
				offsetset = true
			}
			
			if (!render_depth_pass && render_material_pass)
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
					render_set_texture(render_res_material, model_part_shape_tex_material[s], e_texture_channel.MATERIAL)

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
					render_set_texture(render_res_normal, model_part_shape_tex_normal[s], e_texture_channel.NORMAL)
			}
		}
		else
		{
			var shapetexname, texobj;
			
			// Get texture (shape texture overrides part texture)
			shapetexname = parttexname
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
				tex = texobj
			}
			texres = res
		}
		
		// Pattern overrides the shape texture, armor overrides the pattern
		if (patterntex != null)
		{
			tex = patterntex
			texres = null
		}
		
		if (previewarmor || tlarmor)
		{
			var armorindex = minecraft_armor_shape_index_map[?shape.description];
			if (is_undefined(armorindex))
				armorindex = -1
			
			if (armorindex >= 0)
			{
				if (previewarmor && sprite_exists(select.armor_skin_array[armorindex]))
				{
					tex = select.armor_skin_array[armorindex]
					texres = null
				}
				
				if (tlarmor && sprite_exists(temp.armor_skin_array[armorindex]))
				{
					tex = temp.armor_skin_array[armorindex]
					texres = null
				}
			}
		}
		
		render_set_texture(texres, tex)
		
		// Blend color
		var blendcolor, alpha;
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
			if (previewblend)
				blendcolor = color_multiply(blendcolor, previewcolor)
			
			if (tlblend)
				blendcolor = color_multiply(blendcolor, timelinecolor)
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
			if (istl)
				render_set_uniform_color(e_uniform.MIX_COLOR, merge_color(shape.color_mix, value_inherit[e_value.MIX_COLOR], value_inherit[e_value.MIX_PERCENT]), lerp(shape.color_mix_percent, value_inherit[e_value.MIX_PERCENT], value_inherit[e_value.MIX_PERCENT]))
			else
				render_set_uniform_color(e_uniform.MIX_COLOR, shape.color_mix, shape.color_mix_percent)
		}
		
		if (istl && !shape.item_bounce && !shape.face_camera && model_part_shape_render_matrix_part = part)
		{
			// Submit cached matrix without array conversion
			matrix_set(matrix_world, model_part_shape_render_matrix[s])
			vertex_submit(vbuf, pr_trianglelist, -1)
			continue
		}

		// Shape matrix
		var rendermatrix;
		if (istl)
			rendermatrix = matrix_multiply(shape.matrix, matrix_render)
		else
			rendermatrix = matrix_multiply(shape.matrix, mat)

		if (shape.item_bounce || shape.face_camera)
			rendermatrix = render_world_item_transform(rendermatrix, shape.face_camera, shape.item_bounce, false, false, false, false)

		matrix_set(matrix_world, rendermatrix)
		vertex_submit(vbuf, pr_trianglelist, -1)
	}
	
	if (!istl)
		matrix_set(matrix_world, mat)
}
