/// @desc Returns a cached orthographic asset preview using the resource's textures.
/// @arg asset
/// @arg [state]

function res_get_asset_picker_texture(asset, state = [])
{
	if (!ready)
		return null

	if (is_string(asset))
	{
		// Prefer a model when its name also identifies a block
		var name = asset;
		asset = mc_assets.model_name_map[?name]
		if (is_undefined(asset))
			asset = mc_assets.block_name_map[?name]
	}
	
	if (is_undefined(asset) || asset = null)
		return null

	// Resolve a complete state so equivalent requests share the same image
	var stateid, vars, key, ismodel;
	ismodel = (asset.object_index = obj_model)
	if (!ismodel && type != e_res_type.BLOCK_SHEET && type != e_res_type.PACK)
		return null
	
	if (is_string(state))
		state = string_get_state_vars(state)
	
	if (state = null || (ismodel && !is_array(state)))
		return null
	
	if (is_array(state))
	{
		vars = array_copy_1d(asset.default_state)
		state_vars_add(vars, state)
		
		if (!ismodel)
			stateid = block_get_state_id(asset, vars)
	}
	else
		stateid = state

	if (ismodel)
		vars = minecraft_asset_get_state(asset, vars)
	else
		vars = block_get_state_id_state_vars(asset, stateid)
	
	key = asset.name
	for (var i = 0; i < array_length(vars); i += 2)
		key += "," + vars[i] + "=" + vars[i + 1]

	if (asset_picker_texture_map = null)
		asset_picker_texture_map = ds_map_create()
	
	var tex = asset_picker_texture_map[?key];
	if (!is_undefined(tex) && sprite_exists(tex))
		return tex

	var oldworld, oldview, oldproj, oldfrom, oldcamfrom, oldpack, oldclip;
	oldworld = matrix_get(matrix_world)
	oldview = matrix_get(matrix_view)
	oldproj = matrix_get(matrix_projection)
	oldfrom = proj_from
	oldcamfrom = cam_from
	oldpack = render_pack_current
	oldclip = shader_clip_active

	// Undo the native projection flip before restoring through matrix_set
	if (is_cpp())
		oldproj = matrix_multiply(oldproj, matrix_create(vec3(0), vec3(0), vec3(1, -1, 1)))

	// Standalone double blocks render both halves from their main half
	var connected = null;
	if (!ismodel)
		connected = block_get_connect(asset, stateid)
	
	if (connected != null &&
		(block_get_state_id_value(asset, stateid, "half") = "upper" ||
		 block_get_state_id_value(asset, stateid, "part") = "foot" ||
		 block_get_state_id_value(asset, stateid, "type") = "left"))
		stateid = connected[1]
	
	if (connected != null)
		stateid = block_set_state_id_value(asset, stateid, "double", "true")

	// Generate meshes using the shared picker preview
	var model, modelmat, modelres;
	model = asset_picker_preview
	modelmat = MAT_IDENTITY
	modelres = (type = e_res_type.PACK ? id : mc_res)
	if (ismodel && (model_texture_map != null || model_texture != null))
		modelres = id
	
	with (model)
	{
		// Use model files for characters, equipment, special blocks and block timelines
		if (ismodel || (asset.timeline && asset.tl_model_name != ""))
		{
			type = e_temp_type.SPECIAL_BLOCK
			
			if (ismodel)
			{
				if (ds_list_find_index(mc_assets.char_list, asset) >= 0)
					type = e_temp_type.CHARACTER
				else if (ds_list_find_index(mc_assets.equipment_list, asset) >= 0)
					type = e_temp_type.EQUIPMENT

				model_name = asset.name
				model_state = vars
			}
			else
			{
				model_name = asset.tl_model_name
				model_state = block_get_timeline_model_state(asset, stateid)
				modelmat = block_get_timeline_matrix(asset, stateid)
			}

			model_tex = modelres
			
			temp_update_model(false, false)
			temp_update_model_shape()

			// Patterned models use generated textures when rendering a texture pack
			if (pattern_type != "" && modelres.model_texture_map != null)
			{
				var color = state_vars_get_value(vars, "color");
				if (color = "")
					color = "white"
				
				pattern_skin = minecraft_update_pattern_generate(model_name, minecraft_get_color("dye:" + color), [], [], modelres)
			}

			// Generate armor textures now rather than queuing the shared preview
			if (model_name = "armor" && model_file != null)
				armor_skin_array = minecraft_update_armor_generate(model_file.name, armor_array, modelres)
		}
		else
		{
			block_name = asset.name
			block_state = block_get_state_id_state_vars(asset, stateid)
			temp_update_block()
		}
	}

	// Include geometry outside the first cell, such as the other half of a door or bed
	var minpos, maxpos, hasbounds;
	minpos = vec3(no_limit)
	maxpos = vec3(-no_limit)
	hasbounds = false
	
	var boxes, matrices;
	boxes = []
	matrices = null
	
	if (model.model_file != null)
	{
		matrices = model_file_matrix_map_create(model.model_file, modelmat, model.model_hide_list)

		// Apply state-driven part transforms without changing the shared model file
		if (!ismodel && asset.tl_parts != null)
		{
			for (var p = 0; p < ds_list_size(model.model_file.file_part_list); p++)
			{
				var part, rules, rule;
				part = model.model_file.file_part_list[|p]
				rules = asset.tl_parts[?part.name]
				if (!ds_map_valid(rules) || !ds_map_exists(matrices, part.name))
					continue

				rule = ds_map_find_first(rules)
				while (!is_undefined(rule))
				{
					if (state_vars_match_state_id(string_get_state_vars(rule), asset, stateid))
					{
						var values, transform, original, parts;
						values = rules[?rule]
						transform = matrix_create(value_get_point3D(values[?"position"], vec3(0)), value_get_point3D(values[?"rotation"], vec3(0)), vec3(1))
						original = matrices[?part.name]
						transform = matrix_multiply(matrix_multiply(matrix_inverse_ext(original), transform), original)
						parts = [part]
						
						for (var c = 0; c < array_length(parts); c++)
						{
							var child = parts[c];
							if (ds_map_exists(matrices, child.name))
								matrices[?child.name] = matrix_multiply(matrices[?child.name], transform)
							
							if (child.part_list != null)
								for (var i = 0; i < ds_list_size(child.part_list); i++)
									array_add(parts, child.part_list[|i])
						}
						
						break
					}
					
					rule = ds_map_find_next(rules, rule)
				}
			}
		}

		for (var p = 0; p < ds_list_size(model.model_file.file_part_list); p++)
		{
			var part = model.model_file.file_part_list[|p];
			if (!ds_map_exists(matrices, part.name) || part.shape_list = null)
				continue

			for (var s = 0; s < ds_list_size(part.shape_list); s++)
			{
				var shape = part.shape_list[|s];
				if (ds_list_find_index(model.model_shape_hide_list, shape.description) >= 0)
					continue
				
				array_add(boxes, vbuffer_get_bounds(model.model_shape_vbuffer_map[?shape], matrix_multiply(shape.matrix, matrices[?part.name])), false)
			}
		}
	}
	
	for (var m = 0; m < array_length(model.block_meshes); m++)
	{
		var mesh = model.block_meshes[m];
		if (mesh = null)
			continue

		for (var i = 0; i < array_length(mesh.block_vbuffer_render_order); i++)
			array_add(boxes, vbuffer_get_bounds(mesh.block_vbuffer[mesh.block_vbuffer_render_order[i]], MAT_IDENTITY), false)
	}
	
	for (var i = 0; i < array_length(boxes); i++)
	{
		var bounds = boxes[i];
		if (bounds = null)
			continue

		hasbounds = true
		for (var a = X; a <= Z; a++)
		{
			minpos[a] = min(minpos[a], bounds[0][a])
			maxpos[a] = max(maxpos[a], bounds[1][a])
		}
	}
	
	if (!hasbounds)
	{
		minpos = vec3(0)
		maxpos = vec3(block_size)
	}

	// Fit the full bounds at a 45 degree azimuth and 30 degree camz
	var center, size, dis, fit, from, camz;
	center = vec3_mul(vec3_add(minpos, maxpos), 0.5)
	size = vec3_sub(maxpos, minpos)
	for (var a = X; a <= Z; a++)
		size[a] = max(block_half_size, size[a])
	
	dis = max(size[X], size[Y], size[Z]) * 4
	camz = degtorad(30)
	fit = max(1, (size[X] + size[Y]) / sqrt(2), (size[X] + size[Y]) * sin(camz) / sqrt(2) + size[Z] * cos(camz)) * 1.125
	from = vec3(dis * cos(camz) / sqrt(2), dis * cos(camz) / sqrt(2), dis * sin(camz))

	var surf = surface_create(64, 64);
	surface_set_target(surf)
	{
		gpu_set_zwriteenable(true)
		draw_clear_alpha(c_black, 0)
		gpu_set_ztestenable(true)
		
		gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha)
		matrix_set(matrix_world, matrix_create(vec3_mul(center, -1), vec3(0), vec3(1)))
		matrix_set(matrix_view, matrix_create_lookat(from, vec3(0), vec3(0, 0, 1)))
		matrix_set(matrix_projection, matrix_create_ortho(-fit / 2, fit / 2, fit / 2, -fit / 2, dis * 2, -dis * 2))
		
		render_update_frustum()
		proj_from = from
		cam_from = from
		render_fast_pass = false
		render_depth_pass = false
		render_world_blocks_transparent = null
		render_pack_current = null
		shader_clip_active = false
		
		render_preview_start()
		render_set_uniform_vec3(e_uniform.SUN_DIRECTION, -0.408, 0.408, 0.816)
		render_set_uniform(e_uniform.DEFAULT_EMISSIVE, 1)
		
		if (model.model_file != null)
		{
			var name = ds_map_find_first(matrices);
			while (!is_undefined(name))
			{
				matrices[?name] = matrix_multiply(matrices[?name], matrix_get(matrix_world))
				name = ds_map_find_next(matrices, name)
			}
			
			with (model)
				render_world_model_file_parts(model_file, modelres, model_texture_name_map, model_hide_list, model_shape_vbuffer_map, model_color_map, model_shape_hide_list, model_shape_texture_name_map, matrices)
		}
		else
			render_world_block_meshes(model, id, id, id)
		
		with (render_shader_obj)
			shader_clear()
	}
	
	surface_reset_target()
	
	if (matrices != null)
		ds_map_destroy(matrices)

	// Keep picker images on the owning resource page
	if (pack_texture_page < 0)
		pack_texture_page = texture_page_create()
	
	var oldpage = texture_page_get_current();
	texture_page_set_current(pack_texture_page)
	tex = texture_surface(surf)
	texture_page_add(tex, pack_texture_page)
	texture_page_set_current(oldpage)
	surface_free(surf)
	
	asset_picker_texture_map[?key] = tex

	// Release generated geometry and temporary textures
	with (model)
	{
		block_meshes_destroy()
		model_file = null
		
		temp_update_model_shape()
		
		if (sprite_exists(pattern_skin))
			texture_free(pattern_skin)

		for (var i = 0; i < array_length(armor_skin_array); i++)
		{
			if (sprite_exists(armor_skin_array[i]))
				texture_free(armor_skin_array[i])
			armor_skin_array[i] = null
		}
		
		pattern_skin = null
		pattern_type = ""
		model_tex = null
		model_use_blend_color = false
		type = e_temp_type.BLOCK
	}

	// Restore render state
	matrix_set(matrix_world, oldworld)
	matrix_set(matrix_view, oldview)
	matrix_set(matrix_projection, oldproj)
	render_update_frustum()
	
	proj_from = oldfrom
	cam_from = oldcamfrom
	
	gpu_set_ztestenable(false)
	gpu_set_blendmode(bm_normal)
	
	render_pack_current = oldpack
	shader_clip_active = oldclip
	
	return tex
}
