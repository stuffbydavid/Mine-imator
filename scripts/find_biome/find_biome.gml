/// find_biome(name)
/// @arg name

function find_biome(findname)
{
	// Convert old biome names to new
	//if (load_format < e_project.FORMAT_120_PRE_1)
	//{
		while (ds_map_exists(legacy_biomes_map, findname))
			findname = legacy_biomes_map[? findname]
	//}
	
	instance_activate_object(obj_biome)
	with (obj_biome)
	{
		if (name = findname)
		{
			if(biome_base != null)
			{
				biome_base.selected_variant = ds_list_find_index(biome_base.biome_variants, id)
				return biome_base
			}
			else
				return id
		}
	}
	instance_deactivate_object(obj_biome)
	
	return null
}
