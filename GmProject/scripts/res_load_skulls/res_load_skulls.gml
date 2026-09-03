function res_load_skulls()
{
	// Finished
	if (ds_map_size(mc_builder.block_skull_texture_map) = 0 || !mc_builder.block_tl_add)
	{
		with (app)
		{
			popup_loading.text = text_get("loadsceneryblocks")
			popup_loading.progress = 0.2
		}
				
		load_stage = "blocks"
				
		if (mc_builder.block_skull_fail_count = 0)
			scenery_download_skins = false
				
		return 0
	}
			
	app.popup_loading.text = text_get("loadscenerydownload", mc_builder.block_skull_finish_count, mc_builder.block_skull_texture_count, mc_builder.block_skull_fail_count)
	
	// Continue through texture list
	with (mc_builder)
	{
		var nexttex = false;
				
		if (!block_skull_download_wait)
		{
			block_skull_texture_name = ds_map_find_first(block_skull_texture_map)
					
			// Check if the skin already exists in the project
			var exists = false;
					
			with (obj_resource)
			{
				if (type = e_res_type.DOWNLOADED_SKIN && filename = (skins_directory_get() + mc_builder.block_skull_texture_name + ".png"))
				{
					mc_builder.block_skull_res_map[?mc_builder.block_skull_texture_name] = id
					exists = true
					nexttex = true
					break
				}
			}
					
			// Resource doesn't exist, download texture
			if (exists = false && other.scenery_download_skins)
			{
				app.http_downloadskin = http_get_file(ds_map_find_value(block_skull_texture_map, block_skull_texture_name), download_image_file)
				block_skull_download_time = current_time
				block_skull_download_wait = true
			}
		}
				
		// Clear current texture in list (If downloaded or failed.)
		if (block_skull_texture != null || block_skull_texture_fail = true || (current_time - block_skull_download_time > 3000))
		{
			// Create new resource with downloaded texture
			if (block_skull_texture != null)
			{
				var res = null;
						
				// Use existing skin resource
				with (obj_resource)
				{
					if (filename_name(mc_builder.block_skull_texture_name) = filename_change_ext(filename, ""))
					{
						res = id
						break
					}
				}
						
				// Create new skin resource
				if (res = null)
				{
					with (app)
					{
						directory_create_lib(skins_directory_get())
						var fn = skins_directory_get() + mc_builder.block_skull_texture_name + ".png";
						file_copy_lib(download_image_file, fn)
								
						res = new_res(fn, e_res_type.DOWNLOADED_SKIN)
						res.player_skin = true
								
						with (res)
							res_load()
					}
				}
						
				block_skull_res_map[?block_skull_texture_name] = res
			}
			else
			{
				block_skull_res_map[?block_skull_texture_name] = null
				log("Failed to download texture", block_skull_texture_name)
				block_skull_fail_count++
			}
					
			block_skull_finish_count++
			nexttex = true
		}
				
		// Remove current texture and continue
		if (nexttex)
		{
			ds_map_delete(block_skull_texture_map, ds_map_find_first(block_skull_texture_map))
			block_skull_texture = null
			block_skull_texture_fail = false
			block_skull_download_wait = false
		}
	}
}