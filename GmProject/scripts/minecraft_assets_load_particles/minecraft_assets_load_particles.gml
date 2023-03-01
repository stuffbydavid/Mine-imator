/// minecraft_assets_load_particles(list)
/// @arg list
/// @desc Loads particle templates from a list

function minecraft_assets_load_particles(particlelist)
{
	var letterlist = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
	
	for (var i = 0; i < ds_list_size(particlelist); i++)
	{
		var tempmap, ptemp;
		tempmap = particlelist[|i]
		ptemp = new_obj(obj_particle_template)
		
		ptemp.name = tempmap[?"name"]
		ptemp.texture_name = tempmap[?"texture"]
		
		// If 'frames' isn't present, assume the particle is static
		if (!is_undefined(tempmap[?"frames"]))
		{
			ptemp.frames = tempmap[?"frames"]
			ptemp.animated = true
		}
		else
		{
			ptemp.frames = 1
			ptemp.animated = false
		}
		
		ptemp.size = value_get_real(tempmap[?"size"], 8)
		ptemp.letter_suffix = value_get_real(tempmap[?"letter_suffix"], false)
		ptemp.texture_list = ds_list_create()
		
		if (ptemp.animated)
		{
			for (var j = 0; j < ptemp.frames; j++)
			{
				if (ptemp.letter_suffix)
					ds_list_add(ptemp.texture_list, ptemp.texture_name + "_" + letterlist[j])
				else
					ds_list_add(ptemp.texture_list, ptemp.texture_name + "_" + string(j))
			}
		}
		else
		{
			ds_list_add(ptemp.texture_list, ptemp.texture_name)
		}
		
		ds_list_add(particle_template_list, ptemp)
		ds_map_add(particle_template_map, ptemp.name, ptemp)
	}
}
