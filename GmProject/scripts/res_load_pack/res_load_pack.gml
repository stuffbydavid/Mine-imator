/// @desc Unzips an archive or loads a .packcache file and stores the textures in the resource.

function res_load_pack()
{
	var fn = load_folder + "/" + filename;
	texture_page_set_current(pack_texture_page)
	
	switch (load_stage)
	{
		// Unzip archive
		case "unzip":
		{
			debug("res_load_pack", "unzip")
			
			// Extract source textures
			if (type != e_res_type.PACK_UNZIPPED)
			{
				if (!unzip(fn))
				{
					texture_page_reset()
					log("Error unzipping pack")
					error("error/unzip_pack")
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
				popup_loading.text = text_get("load_pack/model_textures")
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
				popup_loading.text = text_get("load_pack/block_textures")
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
				popup_loading.text = text_get("load_pack/item_textures")
				popup_loading.progress = 0.75
			}
			
			break
		}
		
		// Load remaining texture sheets
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
			res_save_pack_cache(save_folder + "/" + filename + ".packcache")
			
			load_stage = "done"
			
			with (app)
				popup_loading.progress = 0.9
			
			break
		}

		// Finish cached or extracted pack
		case "done":
		{
			res_update_colors()
			
			ready = true
			app.history_resource_update = true
			
			log("Pack loaded")
			move_all_to_texture_page()
			
			texture_page_reset()
			
			// Update dependent resources
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
				if (project_pack = other.id)
					action_project_pack(other.id)

				if (env_ground_tex = other.id)
					env_ground_update_texture()
				
				if (env_ground_tex_material = other.id)
					env_ground_update_texture_material()
				
				if (env_ground_tex_normal = other.id)
					env_ground_update_texture_normal()
				
				if (env_sky_clouds_tex = other.id)
					env_sky_update_clouds()
				
				lib_preview.update = true
				res_preview.update = true
				bench_settings.preview.update = true
				popup_loading.progress = 1
			}
			
			load_stage = "next"
			
			break
		}
		
		// Next resource
		case "next":
		{
			with (app)
				load_next()
			break
		}
	}
	
	texture_page_reset()
}
