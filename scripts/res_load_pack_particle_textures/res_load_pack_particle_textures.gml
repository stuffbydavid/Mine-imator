/// res_load_pack_particle_textures()

function res_load_pack_particle_textures()
{
	var particlesize, explosionsize, particlelist, explosionlist, surf;
	particlesize = null
	explosionsize = null
	particlelist = ds_list_create()
	explosionlist = ds_list_create()
	surf = null
	
	// Free old
	if (particle_texture_map != null)
	{
		var key = ds_map_find_first(particle_texture_map);
		while (!is_undefined(key))
		{
			texture_free(particle_texture_map[?key])
			key = ds_map_find_next(particle_texture_map, key)
		}
		ds_map_destroy(particle_texture_map)
	}
	
	if (particles_texture[0] != null)
	{
		texture_free(particles_texture[0])
		particles_texture[0] = null
	}
	
	if (particles_texture[1] != null)
	{
		texture_free(particles_texture[1])
		particles_texture[1] = null
	}
	
	// Create new
	debug_timer_start()
	
	log("Particle textures", "load")
	particle_texture_map = ds_map_create()
	for (var t = 0; t < ds_list_size(mc_assets.particle_texture_list); t++)
	{
		var name, fname, tex;
		name = mc_assets.particle_texture_list[|t]
		fname = load_assets_dir + mc_textures_directory + name + ".png"
		
		if (file_exists_lib(fname))
		{
			tex = texture_create_square(fname)
		}
		else if (id != mc_res)
			tex = texture_duplicate(mc_res.particle_texture_map[?name])
		else
		{
			log("Particle texture not found", mc_assets.particle_texture_list[|t])
			tex = texture_create_missing()
		}
		
		if (legacy_particles_map[?name] != undefined)
		{
			if (string_contains(name, "explosion"))
			{
				explosionsize = max(explosionsize, texture_width(tex))
				ds_list_add(explosionlist, t)
			}
			else
			{
				particlesize = max(particlesize, texture_width(tex))
				ds_list_add(particlelist, t)
			}
		}
		
		particle_texture_map[?name] = tex
	}
	
	log("Particle textures", "legacy sheets")
	
	// Create legacy particle and explosion sheet(if they don't exist in the pack)
	
	// Particles
	if (file_exists_lib(load_assets_dir + mc_particles_image_file))
		particles_texture[0] = texture_create(load_assets_dir + mc_particles_image_file)
	
	// Explosion
	if (file_exists_lib(load_assets_dir + mc_explosion_image_file))
		particles_texture[1] = texture_create(load_assets_dir + mc_explosion_image_file)
	
	// Particle sheet 1
	if (particles_texture[0] = null)
	{
		draw_texture_start()
		surf = surface_create(16 * particlesize, 16 * particlesize)
		surface_set_target(surf)
		{
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
			draw_clear_alpha(c_black, 0)
			
			for (var i = 0; i < ds_list_size(particlelist); i++)
			{
				var texindex = particlelist[|i];
				var texname = mc_assets.particle_texture_list[|texindex];
				var texcoord = legacy_particles_map[?texname];
				
				if (texcoord != undefined)
				{
					var tex, wid, hei, scale;
					tex = particle_texture_map[?texname]
					wid = texture_width(tex)
					hei = texture_height(tex)
					scale = particlesize / wid
					draw_texture_part(tex, texcoord[|X] * particlesize, texcoord[|Y] * particlesize, 0, 0, wid, hei, scale, scale)
				}
			}
			gpu_set_blendmode(bm_normal)
		}
		surface_reset_target()
		draw_texture_done()
	}
	
	if (surface_exists(surf))
	{
		particles_texture[0] = texture_surface(surf)
		surface_free(surf)
		surf = null
	}
	
	// Particle sheet 2(Explosion)
	if (particles_texture[1] = null)
	{
		draw_texture_start()
		surf = surface_create(4 * explosionsize, 4 * explosionsize)
		surface_set_target(surf)
		{
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
			draw_clear_alpha(c_black, 0)
			
			for (var i = 0; i < ds_list_size(explosionlist); i++)
			{
				var texindex = explosionlist[|i];
				var texname = mc_assets.particle_texture_list[|texindex];
				var texcoord = legacy_particles_map[?texname];
				
				if (texcoord != undefined)
				{
					var tex, wid, hei, scale;
					tex = particle_texture_map[?texname]
					wid = texture_width(tex)
					hei = texture_height(tex)
					scale = explosionsize / wid
					draw_texture_part(tex, texcoord[|X] * explosionsize, texcoord[|Y] * explosionsize, 0, 0, wid, hei, scale, scale)
				}
			}
			gpu_set_blendmode(bm_normal)
		}
		surface_reset_target()
		draw_texture_done()
	}
	
	if (surface_exists(surf))
	{
		particles_texture[1] = texture_surface(surf)
		surface_free(surf)
	}
	
	log("Particle textures", "done")
	debug_timer_stop("Particle textures")
}
