/// res_load_pack()
/// @desc Unzips an archive and stores the textures in the resource.

function res_load_pack()
{
	var fname = load_folder + "/" + filename;
	
	switch (load_stage)
	{
		// Unzip archive
		case "unzip":
		{
			debug("res_load_pack", "unzip")
			
			if (type != e_res_type.PACK_UNZIPPED)
			{
				if (!unzip(fname))
				{
					log("Error unzipping pack")
					error("errorunzippack")
					with (app)
						load_next()
					return 0
				}
			}
			
			type = e_res_type.PACK
			load_stage = "modeltextures"
			load_assets_dir = unzip_directory
			res_load_pack_version()
			
			with (app)
			{
				popup_loading.text = text_get("loadpackmodeltextures")
				popup_loading.progress = 0.25
			}
			break
		}
		
		// Load model textures
		case "modeltextures":
		{
			debug("res_load_pack", "modeltextures")
			res_load_pack_model_textures()
			
			load_stage = "blocktextures"
			with (app)
			{
				popup_loading.text = text_get("loadpackblocktextures")
				popup_loading.progress = 0.5
			}
			break
		}
		
		// Load block textures
		case "blocktextures":
		{
			debug("res_load_pack", "blocktextures")
			
			// Legacy pack support
			file_rename_lib(load_assets_dir + mc_textures_directory + "blocks", load_assets_dir + mc_textures_directory + "block")
			
			res_load_pack_block_textures()
			
			load_stage = "itemtextures"
			with (app)
			{
				popup_loading.text = text_get("loadpackitemtextures")
				popup_loading.progress = 0.75
			}
			break
		}
		
		// Load item textures and finish
		case "itemtextures":
		{
			debug("res_load_pack", "itemtextures")
			
			// Legacy pack support
			file_rename_lib(load_assets_dir + mc_textures_directory + "items", load_assets_dir + mc_textures_directory + "item")
			
			res_load_pack_item_textures("diffuse", "")
			res_load_pack_item_textures("material", "_s")
			res_load_pack_item_textures("normal", "_n")
			
			res_load_pack_particle_textures()
			res_load_pack_misc()
			res_update_colors()
			
			ready = true
			app.history_resource_update = true
			
			log("Pack loaded")
			move_all_to_texture_page()
			
			// Update project and load next in the queue
			with (obj_template)
				if (item_tex = other.id)
					render_generate_item()
			
			with (obj_particle_type)
				if (sprite_tex = other.id || sprite_template_tex = other.id)
					ptype_update_sprite_vbuffers()
			
			with (app.bench_settings)
				if (item_tex = other.id)
					render_generate_item()
			
			with (app)
			{
				if (background_ground_tex = other.id)
					background_ground_update_texture()
				
				if (background_ground_tex_material = other.id)
					background_ground_update_texture_material()
				
				if (background_ground_tex_normal = other.id)
					background_ground_update_texture_normal()
				
				if (background_sky_clouds_tex = other.id)
					background_sky_update_clouds()
				
				load_next()
			}
			
			break
		}
	}
}
