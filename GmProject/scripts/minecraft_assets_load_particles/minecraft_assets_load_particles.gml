/// minecraft_assets_load_particles(list)
/// @arg list
/// @desc Loads particle templates from a list

function minecraft_assets_load_particles(particlelist)
{
	for (var i = 0; i < ds_list_size(particlelist); i++)
	{
		var tempmap, ptemp;
		tempmap = particlelist[|i]
		ptemp = new_obj(obj_particle_template)
		
		ptemp.name = tempmap[?"name"]
		ptemp.texture_list = ds_list_create()
		ptemp.size = value_get_real(tempmap[?"size"], 8)
		
		if (!is_undefined(tempmap[?"textures"]))
		{
			// "textures" list
			var texturesmap = tempmap[?"textures"]
			ptemp.frames = ds_list_size(texturesmap)
			ptemp.animated = ptemp.frames > 1
			
			for (var j = 0; j < ptemp.frames; j++)
				ds_list_add(ptemp.texture_list, ds_list_find_value(texturesmap, j))
		}
		else if (!is_undefined(tempmap[?"texture"]))
		{
			// single "texture" name, number suffixes appended if animated
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
		
			if (ptemp.animated)
			{
				for (var j = 0; j < ptemp.frames; j++)
					ds_list_add(ptemp.texture_list, ptemp.texture_name + "_" + string(j))
			}
			else
				ds_list_add(ptemp.texture_list, ptemp.texture_name)
		}
		
		ds_list_add(particle_template_list, ptemp)
		ds_map_add(particle_template_map, ptemp.name, ptemp)
	}
}
