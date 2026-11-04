function block_load(map, typemap)
{
	with (new_obj(obj_block))
	{
		block_id = array_length(block_objs)
		array_add(block_objs, id)
		
		// Name
		if (is_string(map[?"name"]))
			name = map[?"name"]
		else
		{
			log("Missing parameter \"name\"")
			return null
		}
		
		if (debug_names && !text_exists("block/" + name))
			log("block/" + name + mc_unknown_asset_warning)
		
		// Type (overridden by states)
		if (is_string(map[?"type"]))
		{
			type = map[?"type"]
			set_script = asset_get_index("block_set_" + type)
			generate_script = asset_get_index("builder_generate_" + type)
		}
		else
		{
			type = ""
			set_script = null
			generate_script = null
		}

		// File
		if (is_string(map[?"file"]))
			filename = map[?"file"]
		else
			filename = ""
		
		// Emissive (overridden by states)
		if (is_real(map[?"emissive"]))
			emissive = map[?"emissive"]
		else
			emissive = 0
		
		// Random offset (Overridden by states)
		if (is_bool(map[?"random_offset"]))
			random_offset = map[?"random_offset"]
		else
			random_offset = false
		
		// Random offset(X & Y) (Overridden by states)
		if (is_bool(map[?"random_offset_xz"]))
			random_offset_xy = map[?"random_offset_xz"]
		else
			random_offset_xy = false
		
		// Retained timeline cells use an internal visibility state
		var tlmap = map[?"timeline"];
		tl_mesh = (ds_map_valid(tlmap) && value_get_real(tlmap[?"mesh"], false))
		if (tl_mesh)
		{
			var states, visibility;
			states = map[?"states"]
			if (!ds_map_valid(states))
			{
				states = ds_map_create()
				ds_map_add_map(map, "states", states)
			}

			visibility = ds_list_create()
			ds_list_add(visibility, "true", "false")
			ds_map_add_list(states, "visible", visibility)
		}

		// Read states and their possible values
		states_map = null
		state_id_amount = 1
		if (ds_map_valid(map[?"states"]))
		{
			states_map = ds_map_create()
			
			var curstate = ds_map_find_first(map[?"states"]);
			while (!is_undefined(curstate))
			{
				if (debug_names && curstate != "visible" && !text_exists("block/state/" + curstate))
					log("block/state/" + curstate + mc_unknown_asset_warning)
				
				with (new_obj(obj_block_state))
				{
					name = curstate
					
					// Parse values (maps or strings)
					var valuelist = ds_map_find_value(map[?"states"], curstate);
					value_amount = ds_list_size(valuelist)
					value_map = ds_map_create()
					
					// Used for the state ID
					value_id = other.state_id_amount
					other.state_id_amount *= value_amount
					
					for (var v = 0; v < value_amount; v++)
					{
						var curvalue = valuelist[|v];
						value_name[v] = curvalue
						value_filename[v] = ""
						value_file[v] = null
						value_emissive[v] = null
						value_random_offset[v] = null
						value_random_offset_xy[v] = null
						
						if (ds_map_valid(curvalue))
						{
							// Name
							value_name[v] = curvalue[?"value"]
							
							// File
							if (is_string(curvalue[?"file"]))
								value_filename[v] = curvalue[?"file"]
							
							// Emissive
							if (is_real(curvalue[?"emissive"]))
								value_emissive[v] = curvalue[?"emissive"]
							
							// Random offset
							if (is_bool(curvalue[?"random_offset"]))
								value_random_offset[v] = curvalue[?"random_offset"]
							
							// Random offset (XY)
							if (is_bool(curvalue[?"random_offset_xz"]))
								value_random_offset_xy[v] = curvalue[?"random_offset_xz"]
						}
						
						value_map[?value_name[v]] = v
						
						if (debug_names && string_length(value_name[v]) > 3 && !text_exists("block/state/value/" + value_name[v]))
							log("block/state/value/" + value_name[v] + mc_unknown_asset_warning)
					}
					
					other.states_map[?curstate] = id
					curstate = ds_map_find_next(map[?"states"], curstate)
				}
			}
		}
		
		// Block's states describe two connected halves
		has_connect = false
		if (states_map != null)
		{
			var connectstates = [
				[ "half", "lower", "upper" ],
				[ "part", "head", "foot" ],
				[ "type", "left", "right" ]
			];
			for (var i = 0; i < array_length(connectstates); i++)
			{
				var connectstate, state;
				connectstate = connectstates[i]
				state = states_map[?connectstate[0]]
				
				if (!is_undefined(state) && ds_map_exists(state.value_map, connectstate[1]) && ds_map_exists(state.value_map, connectstate[2]))
				{
					has_connect = true
					break
				}
			}
		}

		// Has timeline
		timeline = false
		tl_model_double = false
		tl_hide_model = ""
		tl_position = vec3(block_half_size, block_half_size, 0)
		tl_position_state_amount = 0
		tl_offset = vec3(0)
		tl_offset_state_amount = 0
		
		if (ds_map_valid(tlmap))
			block_load_timeline(tlmap, typemap[?tlmap])

		// Load default file
		if (filename != "")
			file = block_load_state_file(filename, id, [])
		else
			file = null
		
		// Default state
		if (is_string(map[?"default_state"]))
			default_state = string_get_state_vars(map[?"default_state"])
		else
			default_state = []
		
		//default_state_id = block_get_state_id(id, default_state)
		
		// Subsurface
		if (is_real(map[?"subsurface"]))
			subsurface = map[?"subsurface"]
		else
			subsurface = 0
		
		// Wind
		var windmap = map[?"wind"];
		wind_axis = e_vertex_wave.NONE
		wind_zmin = null
		if (ds_map_valid(windmap))
		{
			if (is_string(windmap[?"axis"]))
			{
				if (windmap[?"axis"] = "y")
					wind_axis = e_vertex_wave.Z_ONLY
				else
					wind_axis = e_vertex_wave.ALL
			}
			
			if (is_real(windmap[?"ymin"]))
				wind_zmin = windmap[?"ymin"]
		}
		
		// Is always waterlogged
		if (is_bool(map[?"waterlogged"]))
			waterlogged = map[?"waterlogged"]
		else
			waterlogged = false
		
		// Requires render models
		if (is_bool(map[?"require_models"]))
			require_models = map[?"require_models"]
		else
			require_models = false
		
		// Multi-threaded
		if (is_bool(map[?"multithreaded"]))
			multithreaded = map[?"multithreaded"]
		else
			multithreaded = true
		
		// ID(s)
		var idmap = map[?"id"];
		mc_ids = []
		id_state_vars_map = null
		if (is_string(idmap)) // Single
		{
			mc_ids = [ string_replace(idmap, "minecraft:", "") ]
			mc_assets.block_id_map[?idmap] = id
		}
		else if (ds_map_valid(idmap)) // Map
		{
			id_state_vars_map = ds_map_create()
			var key = ds_map_find_first(idmap);
			while (!is_undefined(key))
			{
				array_add(mc_ids, string_replace(key, "minecraft:", ""))
				id_state_vars_map[?key] = string_get_state_vars(idmap[?key])
				mc_assets.block_id_map[?key] = id
				key = ds_map_find_next(idmap, key)
			}
		}
		
		// Build placement
		build_map = map[?"build"]
		if (!ds_map_valid(build_map))
			build_map = null
		else // Retain build_map in memory
			ds_map_delete(map, "build")

		// Build updates
		build_update = ""
		if (build_map != null)
			build_update = value_get_string(build_map[?"update"], "")
		
		// Pre-calculate the block variant to pick for each (numerical) state ID
		state_id_model_obj = null
		state_id_emissive = null
		state_id_random_offset = null
		state_id_random_offset_xy = null
		//state_id_subsurface = null
		
		for (var sid = 0; sid < state_id_amount; sid++)
		{
			// Get active file and properties
			var curfile, curemissive, curoffset, curoffsetxy;
			curfile = file
			curemissive = emissive
			curoffset = random_offset
			curoffsetxy = random_offset_xy
			
			// Check states
			if (states_map != null)
			{
				var curstate = ds_map_find_first(states_map);
				while (!is_undefined(curstate))
				{
					with (states_map[?curstate])
					{
						// Find chosen value from current state ID
						var valid = (sid div value_id) mod value_amount;
						
						// Get the properties of the chosen value
						if (value_filename[valid] != "")
						{
							if (value_file[valid] = null)
								value_file[valid] = block_load_state_file(value_filename[valid], other.id, [ name, value_name[valid] ])
							curfile = value_file[valid]
						}
						
						if (value_emissive[valid] != null)
							curemissive = value_emissive[valid]
						
						if (value_random_offset[valid] != null)
							curoffset = value_random_offset[valid]
						
						if (value_random_offset_xy[valid] != null)
							curoffsetxy = value_random_offset_xy[valid]
					}
					
					curstate = ds_map_find_next(states_map, curstate)
				}
			}
			
			state_id_model_obj[sid] = null

			// Internal visibility does not select a different model
			var modelstate = sid;
			if (tl_mesh)
				modelstate = block_set_state_id_value(id, sid, "visible", "true")
			
			// Open selected file and look for variant or array of multipart cases
			with (curfile)
			{
				var variant = state_id_map[?modelstate];
				if (is_undefined(variant))
					variant = state_id_map[?0] // Only "normal" is available
				
				other.state_id_model_obj[sid] = variant
				other.state_id_emissive[sid] = curemissive
				other.state_id_random_offset[sid] = curoffset
				other.state_id_random_offset_xy[sid] = curoffsetxy
			}

			// Missing or empty block models require the timeline version
			if (timeline && !ds_map_exists(mc_assets.block_tl_required_map, tl_type))
			{
				var modelvariants, hasmesh;
				modelvariants = state_id_model_obj[sid]
				if (!is_array(modelvariants))
					modelvariants = [ modelvariants ]

				hasmesh = false
				for (var i = 0; i < array_length(modelvariants) && !hasmesh; i++)
				{
					var modelvariant = modelvariants[i];
					if (is_undefined(modelvariant) || modelvariant = null)
						continue

					for (var m = 0; m < modelvariant.model_amount; m++)
						if (modelvariant.model[m].element_amount > 0)
						{
							hasmesh = true
							break
						}
				}

				if (!hasmesh)
					mc_assets.block_tl_required_map[?tl_type] = true
			}
		}
		
		return id
	}
}
