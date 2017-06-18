/// block_load_states(filename, type)
/// @arg filename
/// @arg type
/// @desc Loads the different block variants from the state file

var fname, type, fpath;
fname = argument0
type = argument1
fpath = blockstates_directory + fname

if (!is_undefined(mc_block_states_map[?fname])) // Previously loaded
	return mc_block_states_map[?fname]
	
if (!file_exists_lib(fpath))
{
	log("Could not find states file", fname)
	return null
}

var json = json_escape_bool(file_text_contents(fpath));
var statesmap = json_decode(json);
if (statesmap < 0)
{
	log("Could not parse states file", fname)
	return null
}

var variantsmap, multipartlist;
variantsmap = statesmap[?"variants"]
multipartlist = statesmap[?"multipart"]

if (is_undefined(variantsmap) && is_undefined(multipartlist))
{
	log("No models in the states file", fname)
	return null
}

with (new(obj_block_load_states))
{
	// Filename
	name = fname
	mc_block_states_map[?fname] = id
	
	variant_amount = 0
	multipart_case_amount = 0
	
	// Load variants
	if (!is_undefined(variantsmap))
	{
		var variant = ds_map_find_first(variantsmap);
		while (!is_undefined(variant))
		{
			with (new(obj_block_load_variant))
			{
				// Name
				name = variant
				vars = ds_map_create()
				block_load_vars(vars, name)
			
				var variantlist, list;
				variantlist = variantsmap[?name]
				list = ds_list_create()
			
				// Check if a list of models
				if (string_contains(json, "\"" + name + "\": ["))
					ds_list_copy(list, variantlist)
				else
					ds_list_add(list, variantlist)

				// Load models
				if (!block_load_states_models(list, type))
					return null
				ds_list_destroy(list)
			
				other.variant[other.variant_amount++] = id
			}
			variant = ds_map_find_next(variantsmap, variant)
		}
	
		ds_map_destroy(statesmap)
	}
	
	// Load multipart
	else if (!is_undefined(multipartlist))
	{
		for (var c = 0; c < ds_list_size(multipartlist); c++)
		{
			var mcase = multipartlist[|c];
			with (new(obj_block_load_multipart_case))
			{
				// When
				var whenmap = mcase[?"when"];
				condition_amount = 0
				
				if (!is_undefined(whenmap) && ds_map_size(whenmap) > 0)
				{
					// OR, one of multiple sets of conditions must match
					var orlist = whenmap[?"OR"];
					if (is_real(orlist) && ds_exists(orlist, ds_type_list))
					{
						for (var oc = 0; oc < ds_list_size(orlist); oc++)
						{
							var curcondmap, condmap, cond;
							curcondmap = orlist[|oc]
							condmap = ds_map_create()
							cond = ds_map_find_first(curcondmap)
							while (!is_undefined(cond))
							{
								condmap[?cond] = string_split(curcondmap[?cond], "|")
								cond = ds_map_find_next(curcondmap, cond)
							}
							condition[condition_amount++] = condmap
						}
					}
					
					// Single condition
					else
					{
						var condmap, cond;
						condmap = ds_map_create()
						cond = ds_map_find_first(whenmap)
						while (!is_undefined(cond))
						{
							condmap[?cond] = string_split(whenmap[?cond], "|")
							cond = ds_map_find_next(whenmap, cond)
						}
						condition[condition_amount++] = condmap
					}
				}
				
				// Apply
				var applylist, list, match, spos;
				applylist = mcase[?"apply"]
				list = ds_list_create()
				
				// Check if a list of models
				var match = "\"apply\":";
				if (string_copy(json, string_pos(match, json), string_length(match + " [")) = match + " [")
					ds_list_copy(list, applylist)
				else
					ds_list_add(list, applylist)
				json = string_replace(json, match, "")
				
				if (!block_load_states_models(list, type))
					return null
				
				ds_list_destroy(list)
				
				other.multipart_case[other.multipart_case_amount++] = id
			}
		}
	}
	
	return id
}