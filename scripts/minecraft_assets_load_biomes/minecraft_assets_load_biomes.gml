/// minecraft_assets_load_biomes(list, fn)
/// @desc Loads biomes from Minecraft version

var list, fn;
list = argument0;
fn = argument1;

if (!file_exists_lib(fn))
{
	log("Biomes file doesn't exist.")
	log(fn)
	return null
}

var map = json_load(fn);

// Read all the 'base' biomes
var basebiomes = map[?"biomes"];
for (var b = 0; b < ds_list_size(basebiomes); b++)
{
	var biome = basebiomes[|b]
	var biomeid;
	with (new(obj_biome))
	{
		biomeid = id
		
		// Selected biome
		selected_variant = 0
		
		// Name
		name = biome[?"name"]
		//display_name = minecraft_asset_get_name("biome", name)
		
		// Foliage
		txy = vec2(0)
		if (is_string(biome[?"foliage"]))
		{
			color_foliage = hex_to_color(biome[?"foliage"])
			color_grass = color_foliage
			hardcoded = true
		}
		else
		{
			color_foliage = c_white
			color_grass = c_white
			txy = value_get_point2D(biome[?"foliage"], vec2(0, 0))
			hardcoded = false
		}
		
		// Grass
		if (is_string(biome[?"grass"]))
			color_grass = hex_to_color(biome[?"grass"])
		
		// Water
		color_water = hex_to_color(biome[?"water"])
		
		biome_base = null
		biome_variants = null
		
		// Variants(Optional)
		if (ds_list_valid(biome[?"variant"]))
		{
			biome_variants = ds_list_create()
			var biomevariants = biome[?"variant"]
			for (var v = 0; v < ds_list_size(biomevariants); v++)
			{
				var variant = biomevariants[|v];
				with (new(obj_biome))
				{
					// Name
					name = variant[?"name"]
					//display_name = minecraft_asset_get_name("biome", name)
					
					// Foliage
					txy = array_copy_2d(other.txy)
					hardcoded = other.hardcoded
					color_foliage = other.color_foliage
					
					if (is_string(variant[?"foliage"]))
					{
						color_foliage = hex_to_color(variant[?"foliage"])
						hardcoded = true
					}
					else if (ds_list_valid(variant[?"foliage"]))
					{
						color_foliage = c_white
						txy = value_get_point2D(variant[?"foliage"], vec2(0, 0))
						hardcoded = false
					}
					
					// Grass
					if (is_string(variant[?"grass"]))
						color_grass = hex_to_color(variant[?"grass"])
					else
						color_grass = other.color_grass
					
					// Water
					if (is_string(variant[?"water"]))
						color_water = hex_to_color(variant[?"water"])
					else
						color_water = other.color_water
					
					biome_base = biomeid
					
					ds_list_add(biome_base.biome_variants, id)
				}
			}
		}
			
	}
	
	ds_list_add(biome_list, biomeid)
}

ds_map_destroy(map)