/// find_biome(name)
/// @arg name

var findname;

// Convert old biome names to new
switch (argument0)
{
	case "foresthills": findname = "forest_hills"; break;
	case "deserthills": findname = "desert_hills"; break;
	case "junglehills": findname = "jungle_hills"; break;
	case "mushroomisland": findname = "mushroom_island"; break;
	case "mushroomislandshore": findname = "mushroom_island_shore"; break;
	case "extremehills": findname = "extreme_hills"; break;
	case "extremehillsedge": findname = "extreme_hills_edge"; break;
	case "taigahills": findname = "taiga_hills"; break;
	case "iceplains": findname = "ice_plains"; break;
	case "icemountains": findname = "ice_moutains"; break;
	case "frozenocean": findname = "frozen_ocean"; break;
	case "frozenriver": findname = "frozen_river"; break;
	case "thenend": findname = "the_end"; break;
	
	default: findname = argument0;
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