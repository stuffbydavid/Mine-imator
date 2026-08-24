/// block_load_state_file(filename, block, state)
/// @arg filename
/// @arg block
/// @arg state
/// @desc Loads the different block variants from the state file.

function block_load_state_file(fname, block, state)
{
	if (!file_exists_lib(fname))
	{
		log("Could not find state file", filename_name(fname))
		return null
	}
	
	var jsontypemap, map;
	jsontypemap = ds_int_map_create()
	map = json_load(fname, jsontypemap);
	if (!ds_map_valid(map))
	{
		log("Could not parse state file", filename_name(fname))
		ds_map_destroy(jsontypemap)
		return null
	}
	
	var variantsmap, multipartlist;
	variantsmap = map[?"variants"]
	multipartlist = map[?"multipart"]
	
	if (!ds_map_valid(variantsmap) && !ds_list_valid(multipartlist))
	{
		log("No models in the states file", fname)
		ds_map_destroy(map)
		return null
	}
	
	with (new_obj(obj_block_load_state_file))
	{
		name = filename_name(fname)
		state_id_map = ds_map_create()
		state_default_variant_id = 0
		
		model_preview_color_zp = -1
		model_preview_alpha_zp = -1
		model_preview_color_yp = -1
		model_preview_alpha_yp = -1
		
		// Read colors from assets for block JSON (used to modify undesired block colors/alpha)
		if (ds_map_valid(mc_assets.block_texture_preview_map[?name]))
		{
			var blockmap = mc_assets.block_texture_preview_map[?name];
			
			// Top color
			if (blockmap[?"colorY"] != undefined)
			{
				if (is_string(blockmap[?"colorY"]))
					model_preview_color_zp = hex_to_color(blockmap[?"colorY"])
				else
					model_preview_color_zp = null
			}
			
			// Side color
			if (blockmap[?"colorZ"] != undefined)
			{
				if (is_string(blockmap[?"colorZ"]))
					model_preview_color_yp = hex_to_color(blockmap[?"colorZ"])
				else
					model_preview_color_yp = null
			}
			
			// If one side has defined color and the other doesn't, both sides use the one color
			if (model_preview_color_zp < 0 && model_preview_color_yp != -1)
				model_preview_color_zp = model_preview_color_yp
			else if (model_preview_color_yp < 0 && model_preview_color_zp != -1)
				model_preview_color_yp = model_preview_color_zp
			/*
			else if (model_preview_color_zp = null && model_preview_color_yp = null)
			{
				model_preview_color_zp = hex_to_color("000000")
				model_preview_color_yp = hex_to_color("000000")
				model_preview_alpha_zp = 0
				model_preview_alpha_yp = 0
			}*/
			
			if (blockmap[?"alphaY"] != undefined && is_real(blockmap[?"alphaY"]))
				model_preview_alpha_zp = blockmap[?"alphaY"]
			if (blockmap[?"alphaZ"] != undefined && is_real(blockmap[?"alphaZ"]))
				model_preview_alpha_yp = blockmap[?"alphaZ"]
			
			if (model_preview_color_zp >= 0 && model_preview_color_yp >= 0 && model_preview_alpha_zp < 0 && model_preview_alpha_yp < 0)
			{
				model_preview_alpha_zp = 1
				model_preview_alpha_yp = 1
			}
			else if (model_preview_alpha_zp < 0 && model_preview_alpha_yp >= 0)
				model_preview_alpha_zp = model_preview_alpha_yp
			else if (model_preview_alpha_yp < 0 && model_preview_alpha_zp >= 0)
				model_preview_alpha_yp = model_preview_alpha_zp
		}
		
		var first_state = true;
		
		// Load variants
		if (ds_map_valid(variantsmap))
		{
			var variant = ds_map_find_first(variantsmap);
			
			while (!is_undefined(variant))
			{
				with (new_obj(obj_block_load_variant))
				{
					// Find state ID of variant if not "" or "normal" (pre-1.13)
					if (variant != "" && variant != "normal")
					{
						var vars = string_get_state_vars(variant);
						if (vars = null) // Ignore "all"
						{
							instance_destroy()
							break
						}
						state_vars_add(vars, state)
						other.state_id_map[?block_get_state_id(block, vars)] = id
						
						if (first_state)
							other.state_default_variant_id = block_get_state_id(block, vars)
					}
					else
						other.state_id_map[?0] = id
					
					first_state = false
					
					// Load model(s)
					model_amount = 0
					total_weight = 0
					
					// Check if a list of models
					if (ds_map_find_value(jsontypemap[?variantsmap], variant) = e_json_type.ARRAY)
					{
						var modellist = variantsmap[?variant];
						for (var i = 0; i < ds_list_size(modellist); i++)
							if (!block_load_variant_model(modellist[|i], block.type))
								return false
					}
					
					// Single model
					else
						if (!block_load_variant_model(variantsmap[?variant], block.type))
							return null
				}
				
				variant = ds_map_find_next(variantsmap, variant)
			}
		}
		
		// Load multipart
		else if (ds_list_valid(multipartlist))
		{
			for (var c = 0; c < ds_list_size(multipartlist); c++)
			{
				var mcase = multipartlist[|c];
				with (new_obj(obj_block_load_multipart_case))
				{
					// Condition
					var whenmap = mcase[?"when"];
					
					if (ds_map_valid(whenmap) && ds_map_size(whenmap) > 0)
					{
						var orlist = whenmap[?"OR"];
						var andlist = whenmap[?"AND"];
						
						// OR, one of multiple sets of conditions must match
						if (ds_list_valid(orlist))
						{
							for (var oc = 0; oc < ds_list_size(orlist); oc++)
							{
								var curcondmap, condvars, cond;
								curcondmap = orlist[|oc]
								condvars = array()
								cond = ds_map_find_first(curcondmap)
								
								while (!is_undefined(cond))
								{
									var val = curcondmap[?cond];
									if (ds_map_find_value(jsontypemap[?curcondmap], cond) = e_json_type.BOOL) // Booleans must be string
										val = (val ? "true" : "false")
									
									if (string_contains(val, "|")) // OR
										state_vars_set_value(condvars, cond, string_split(val, "|"))
									else
										state_vars_set_value(condvars, cond, val)
									
									cond = ds_map_find_next(curcondmap, cond)
								}
								
								// Apply to matching state IDs
								for (var i = 0; i < block.state_id_amount; i++)
									if (state_vars_match_state_id(condvars, block, i))
										other.state_id_map[?i] = array_add(other.state_id_map[?i], id)
							}
						}
						else if (ds_list_valid(andlist)) // AND, all of multiple sets of conditions must match
						{
							var condarr = [];
							
							for (var oc = 0; oc < ds_list_size(andlist); oc++)
							{
								var curcondmap, condvars, cond;
								curcondmap = andlist[|oc]
								condvars = array()
								cond = ds_map_find_first(curcondmap)
								
								while (!is_undefined(cond))
								{
									var val = curcondmap[?cond];
									if (ds_map_find_value(jsontypemap[?curcondmap], cond) = e_json_type.BOOL) // Booleans must be string
										val = (val ? "true" : "false")
									
									if (string_contains(val, "|")) // OR
										state_vars_set_value(condvars, cond, string_split(val, "|"))
									else
										state_vars_set_value(condvars, cond, val)
									
									cond = ds_map_find_next(curcondmap, cond)
								}
								
								condarr = array_add(condarr, condvars, false)
							}
							
							// Apply to matching state IDs
							for (var i = 0; i < block.state_id_amount; i++)
							{
								var match = true;
								
								for (var j = 0; j < array_length(condarr); j++)
								{
									if (!match)
										continue
									
									if (!state_vars_match_state_id(condarr[j], block, i))
										match = false
								}
								
								if (match)
									other.state_id_map[?i] = array_add(other.state_id_map[?i], id)
							}
						}
						// Single condition
						else
						{
							var condvars, cond;
							condvars = array()
							cond = ds_map_find_first(whenmap)
							
							while (!is_undefined(cond))
							{
								var val = whenmap[?cond];
								if (ds_map_find_value(jsontypemap[?whenmap], cond) = e_json_type.BOOL) // Booleans must be string
									val = (val ? "true" : "false")
								
								if (string_contains(val, "|")) // OR
									state_vars_set_value(condvars, cond, string_split(val, "|"))
								else
									state_vars_set_value(condvars, cond, val)
								
								cond = ds_map_find_next(whenmap, cond)
							}
							
							// Apply to matching state IDs
							for (var i = 0; i < block.state_id_amount; i++)
							{
								if (state_vars_match_state_id(condvars, block, i))
								{
									other.state_id_map[?i] = array_add(other.state_id_map[?i], id)
									
									if (first_state)
									{
										other.state_default_variant_id = i
										first_state = false
									}
								}
							}
						}
					}
					else
					{
						// Always applies
						for (var i = 0; i < block.state_id_amount; i++)
						{
							other.state_id_map[?i] = array_add(other.state_id_map[?i], id)
							
							if (first_state)
							{
								other.state_default_variant_id = i
								first_state = false
							}
						}
					}
					
					// Load model(s)
					model_amount = 0
					total_weight = 0
					
					// Check if a list of models
					if (ds_map_find_value(jsontypemap[?mcase], "apply") = e_json_type.ARRAY)
					{
						var modellist = mcase[?"apply"];
						for (var i = 0; i < ds_list_size(modellist); i++)
							if (!block_load_variant_model(modellist[|i], block.type))
								return false
					}
					
					// Single model
					else
						if (!block_load_variant_model(mcase[?"apply"], block.type))
							return null
				}
			}
		}
		
		load_assets_state_file_map[?filename_name(fname)] = id
		
		//ds_map_destroy(map) // Error
		ds_map_destroy(jsontypemap)
		return id
	}
}
