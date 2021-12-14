/// find_biome(name)
/// @arg name

var findname;
findname = argument0;

// Convert old biome names to new
while (ds_map_exists(legacy_biomes_map, findname))
	findname = legacy_biomes_map[? findname]

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