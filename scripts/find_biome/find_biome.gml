/// find_biome(name)
/// @arg name

var findname;
findname = argument0;

// Convert old biome names to new
if (load_format < e_project.FORMAT_115)
{
	if (ds_map_exists(biome_legacy_map, findname))
		findname = biome_legacy_map[? findname]
}

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

return null