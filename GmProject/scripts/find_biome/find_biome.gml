/// find_biome(name)
/// @arg name

function find_biome(biomename)
{
	var biome = null;
	
	// Convert old biome names to new
	for (var i = 0; i < 5 && ds_map_exists(legacy_biomes_map, biomename); i++)
		biomename = legacy_biomes_map[? biomename]
	
	with (obj_biome)
	{
		if (name = biomename)
		{
			biome = id
			break
		}
	}
	
	return biome
}
