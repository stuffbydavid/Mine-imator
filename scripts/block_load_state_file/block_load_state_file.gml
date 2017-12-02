/// block_load_state_file(filename, block, state)
/// @arg filename
/// @arg block
/// @arg state
/// @desc Loads the different block variants from the state file.

var fname, block, state;
fname = argument0
block = argument1
state = argument2

if (!file_exists_lib(fname))
{
	log("Could not find state file", fname)
	return null
}

var jsontypemap, map;
jsontypemap = ds_map_create()
map = json_load(fname, jsontypemap);
if (!ds_map_valid(map))
{
	log("Could not parse state file", fname)
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

with (new(obj_block_load_state_file))
{
	name = filename_name(fname)
	
	state_id_map = ds_map_create()
	
	// Load variants
	if (ds_map_valid(variantsmap))
	{
		var variant = ds_map_find_first(variantsmap);
		while (!is_undefined(variant))
		{
			with (new(obj_block_load_variant))
			{
				// Find state ID of variant if not "normal"
				if (variant != "normal")
				{
					var vars  = string_get_state_vars(variant);
					if (vars = null) // Ignore "all"
					{
						instance_destroy()
						break
					}
					state_vars_add(vars, state)
					other.state_id_map[?block_get_state_id(block, vars)] = id
				}
				else
					other.state_id_map[?0] = id
				
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
			with (new(obj_block_load_multipart_case))
			{
				// Condition
				var whenmap = mcase[?"when"];
				
				if (ds_map_valid(whenmap) && ds_map_size(whenmap) > 0)
				{
					// OR, one of multiple sets of conditions must match
					var orlist = whenmap[?"OR"];
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
									val = val ? "true" : "false"
									
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
								val = val ? "true" : "false"
								
							if (string_contains(val, "|")) // OR
								state_vars_set_value(condvars, cond, string_split(val, "|"))
							else
								state_vars_set_value(condvars, cond, val)
							
							cond = ds_map_find_next(whenmap, cond)
						}
						
						// Apply to matching state IDs
						for (var i = 0; i < block.state_id_amount; i++)
							if (state_vars_match_state_id(condvars, block, i))
								other.state_id_map[?i] = array_add(other.state_id_map[?i], id)
					}
				}
				else
				{
					// Always applies
					for (var i = 0; i < block.state_id_amount; i++)
						other.state_id_map[?i] = array_add(other.state_id_map[?i], id)
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
	
	//ds_map_destroy(map) // Error
	ds_map_destroy(jsontypemap)
	return id
}