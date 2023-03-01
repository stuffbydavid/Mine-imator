/// res_load_pack_version()
/// @desc Reads pack.mcmeta file from a resource pack for legacy support

function res_load_pack_version()
{
	var fn = load_assets_dir + "pack.mcmeta";
	
	if (file_exists_lib(fn))
	{
		var map = json_load(fn);
		
		if (!ds_map_valid(map))
		{
			log("Error loading pack.mcmeta")
			pack_format = e_minecraft_pack.LATEST
			
			return false
		}
		
		if (ds_map_valid(map[?"pack"]))
		{
			var packmap = map[?"pack"];
			pack_format = value_get_real(packmap[?"pack_format"])
		}
	}
	else
		pack_format = e_minecraft_pack.LATEST
}
