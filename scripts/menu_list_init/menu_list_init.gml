/// menu_list_init()
/// @desc Runs when a list menu is created.

// Model state
if (menu_model_current != null)
{
	for (var i = 0; i < menu_model_state.value_amount; i++)
		menu_add_item(menu_model_state.value_name[i], minecraft_asset_get_name("modelstatevalue", menu_model_state.value_name[i]))
		
	return 0
}

// Block state
if (menu_block_current != null)
{
	for (var i = 0; i < menu_block_state.value_amount; i++)
		menu_add_item(menu_block_state.value_name[i], minecraft_asset_get_name("blockstatevalue", menu_block_state.value_name[i]))
		
	return 0
}
			
switch (menu_name)
{
	// Skin
	case "benchskin":
	case "benchspblocktex":
	case "benchbodypartskin":
	case "libraryskin":
	case "libraryspblocktex":
	case "librarybodypartskin":
	{
		var modelfile, texnamemap;
		if (string_contains(menu_name, "bench"))
		{
			modelfile = bench_settings.model_file
			texnamemap = bench_settings.model_texture_name_map
		}
		else
		{
			modelfile = temp_edit.model_file
			texnamemap = temp_edit.model_texture_name_map
		}
		
		// Import from file
		menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.BROWSE)
		
		// Download from user
		if (modelfile != null && modelfile.player_skin)
			menu_add_item(e_option.DOWNLOAD_SKIN, text_get("libraryskindownload"), null, icons.DOWNLOAD_SKIN)
		
		// Default
		var tex;
		with (mc_res)
			tex = res_get_model_texture(model_part_texture_name(texnamemap, modelfile))
		menu_add_item(mc_res, mc_res.display_name, tex)
		
		// Add existing resources
		for (var i = 0; i < ds_list_size(res_list.list); i++)
		{
			var res = res_list.list[|i];
			if (res = mc_res)
				continue
				
			with (res)
				tex = res_get_model_texture(model_part_texture_name(texnamemap, modelfile))
			
			if (tex != null)
				menu_add_item(res, res.display_name, tex)
		}
			
		break
	}
	
	// Terrain
	case "benchscenery":
	case "libraryscenery":
	{
		// None
		menu_add_item(null, text_get("listnone"))
		
		// Import from world
		menu_add_item(e_option.IMPORT_WORLD, text_get("librarysceneryimport"), null, icons.IMPORT_FROM_WORLD)
		
		// Import from file
		menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.BROWSE)
		
		// Add existing resources
		for (var i = 0; i < ds_list_size(res_list.list); i++)
		{
			var res = res_list.list[|i];
			if (res.type = e_res_type.SCHEMATIC)
				menu_add_item(res, res.display_name)
		}
		
		break
	}
	
	// Block texture
	case "benchblocktex":
	case "libraryblocktex":
	{
		// Import from file
		menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.BROWSE)
		
		// Default
		menu_add_item(mc_res, mc_res.display_name, mc_res.block_preview_texture)
		
		// Add existing resources
		for (var i = 0; i < ds_list_size(res_list.list); i++)
		{
			var res = res_list.list[|i];
			if (res != mc_res && res.block_sheet_texture != null)
				menu_add_item(res, res.display_name, res.block_preview_texture)
		}
		
		break
	}
	
	// Item texture
	case "benchitemtex":
	case "libraryitemtex":
	{
		// Import from file
		menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.BROWSE)
		
		// Default
		menu_add_item(mc_res, mc_res.display_name, mc_res.block_preview_texture)
		
		// Add existing resources
		for (var i = 0; i < ds_list_size(res_list.list); i++)
		{
			var res = res_list.list[|i];
			if (res = mc_res)
				continue
				
			if (res.type = e_res_type.TEXTURE)
				menu_add_item(res, res.display_name, res.texture)
			else if (res.item_sheet_texture != null)
				menu_add_item(res, res.display_name, res.block_preview_texture)
		}
		
		break
	}
	
	// Body part
	case "benchbodypart":
	{
		for (var p = 0; p < ds_list_size(bench_settings.model_file.file_part_list); p++)
		{
			var part = bench_settings.model_file.file_part_list[|p];
			menu_add_item(part.name, minecraft_asset_get_name("modelpart", part.name))
		}
		
		break
	}
		
	// Body part
	case "templateeditorbodypart":
	{
		for (var p = 0; p < ds_list_size(temp_edit.model_file.file_part_list); p++)
		{
			var part = temp_edit.model_file.file_part_list[|p];
			menu_add_item(part.name, minecraft_asset_get_name("modelpart", part.name))
		}
		
		break
	}
		
	// Text font
	case "benchtextfont":
	case "librarytextfont":
	{
		// Import from file
		menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.BROWSE)
		
		// Default
		menu_add_item(mc_res, mc_res.display_name)
		
		// Add existing resources
		for (var i = 0; i < ds_list_size(res_list.list); i++)
		{
			var res = res_list.list[|i];
			if (res != mc_res && font_exists(res.font))
				menu_add_item(res, res.display_name)
		}
		
		break
	}
	
	// Shape texture
	case "benchshapetex":
	case "libraryshapetex":
	{
		// None
		menu_add_item(null, text_get("listnone"))
		
		// Import from file
		menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.BROWSE)
		
		// Add existing resources
		for (var i = 0; i < ds_list_size(res_list.list); i++)
		{
			var res = res_list.list[|i];
			if (res.texture)
				menu_add_item(res, res.display_name, res.texture)
		}
		
		// Add existing cameras
		with (obj_timeline)
			if (type = e_tl_type.CAMERA)
				menu_add_item(id, display_name)
			
		break
	}
	
	// Particle editor spawn region type
	case "particleeditorspawnregiontype":
	{
		menu_add_item("sphere", text_get("particleeditorspawnregiontypesphere"), spr_icons, icons.SPHERE)
		menu_add_item("cube", text_get("particleeditorspawnregiontypecube"), spr_icons, icons.CUBE)
		menu_add_item("box", text_get("particleeditorspawnregiontypebox"), spr_icons, icons.BOX)
		
		break
	}
	
	// Particle editor type library source
	case "particleeditortypetemp":
	{
		menu_add_item(null, text_get("particleeditortypesprite"))
		
		for (var i = 0; i < ds_list_size(lib_list.list); i++)
		{
			var temp = lib_list.list[|i];
			if (temp.type != e_temp_type.PARTICLE_SPAWNER)
				menu_add_item(temp, temp.display_name)
		}
		
		break
	}
	
	// Block texture
	case "particleeditortypespritetex":
	{
		var img = ptype_edit.sprite_tex_image;
		
		// Add from file
		menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.BROWSE)
		
		// Default
		menu_add_item(mc_res, mc_res.display_name, mc_res.particles_texture[img])
		
		// Add existing resources
		for (var i = 0; i < ds_list_size(res_list.list); i++)
		{
			var res = res_list.list[|i];
			if (res != mc_res && res.particles_texture[0])
				menu_add_item(res, res.display_name, res.particles_texture[img])
		}
		
		break
	}
	
	// Background image
	case "backgroundimage":
	{
		// None
		menu_add_item(null, text_get("listnone"))
		
		// Import from file
		menu_add_item(e_option.BROWSE, text_get("listbrowse"), spr_icons, icons.BROWSE)
		
		// Add existing resources
		for (var i = 0; i < ds_list_size(res_list.list); i++)
		{
			var res = res_list.list[|i];
			if (res.texture)
				menu_add_item(res, res.display_name, res.texture)
		}
		
		break
	}
	
	// Background image type
	case "backgroundimagetype":
	{
		menu_add_item("image", text_get("backgroundimagetypeimage"))
		menu_add_item("sphere", text_get("backgroundimagetypesphere"))
		menu_add_item("box", text_get("backgroundimagetypebox"))
		
		break
	}
	
	// Background sky sun texture
	case "backgroundskysuntex":
	{
		// Import from file
		menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.BROWSE)
		
		// Default
		menu_add_item(mc_res, mc_res.display_name, mc_res.sun_texture)
		
		// Add existing resources
		for (var i = 0; i < ds_list_size(res_list.list); i++)
		{
			var res = res_list.list[|i];
			if (res = mc_res)
				continue
			if (res.sun_texture)
				menu_add_item(res, res.display_name, res.sun_texture)
			else if (res.texture)
				menu_add_item(res, res.display_name, res.texture)
		}
		
		break
	}
	
	// Background sky moon texture
	case "backgroundskymoontex":
	{
		// Import from file
		menu_add_item(e_option.BROWSE, text_get("listbrowse"), spr_icons, icons.BROWSE)
		
		// Default
		menu_add_item(mc_res, mc_res.display_name, mc_res.moon_texture[background_sky_moon_phase])
		
		// Add existing resources
		for (var i = 0; i < ds_list_size(res_list.list); i++)
		{
			var res = res_list.list[|i];
			if (res = mc_res)
				continue
			if (res.moon_texture[0])
				menu_add_item(res, res.display_name, res.moon_texture[background_sky_moon_phase])
			else if (res.texture)
				menu_add_item(res, res.display_name, res.texture)
		}
		
		break
	}
	
	// Background sky moon phase
	case "backgroundskymoonphase":
	{
		for (var p = 0; p < 8; p++)
			menu_add_item(p, text_get("backgroundskymoonphase" + string(p + 1)), background_sky_moon_tex.moon_texture[p])
		
		break
	}
	
	// Background sky clouds texture
	case "backgroundskycloudstex":
	{
		// Import from file
		menu_add_item(e_option.BROWSE, text_get("listbrowse"), spr_icons, icons.BROWSE)
		
		// Default
		menu_add_item(mc_res, mc_res.display_name, mc_res.clouds_texture)
		
		// Add existing resources
		for (var i = 0; i < ds_list_size(res_list.list); i++)
		{
			var res = res_list.list[|i];
			if (res = mc_res)
				continue
			if (res.clouds_texture)
				menu_add_item(res, res.display_name, res.clouds_texture)
			else if (res.texture)
				menu_add_item(res, res.display_name, res.texture)
		}
		
		break
	}
	
	// Background ground texture
	case "backgroundgroundtex":
	{
		// Import from file
		menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.BROWSE)
		
		// Default
		menu_add_item(mc_res, mc_res.display_name, mc_res.block_preview_texture)
		
		// Add existing resources
		for (var i = 0; i < ds_list_size(res_list.list); i++)
		{
			var res = res_list.list[|i];
			if (res != mc_res && res.block_sheet_texture != null)
				menu_add_item(res, res.display_name, res.block_preview_texture)
		}
		
		break
	}
	
	// Background biome
	case "backgroundbiome":
	{
		for (var b = 0; b < ds_list_size(biome_list); b++)
			menu_add_item(biome_list[|b], text_get("biome" + biome_list[|b].name))
		
		break
	}
	
	// Resource pack preview image
	case "resourcespackimage":
	{
		menu_add_item("preview", text_get("resourcespackpreview"))
		menu_add_item("modeltextures", text_get("resourcespackmodeltextures"))
		menu_add_item("blocksheet", text_get("resourcespackblocksheet"))
		menu_add_item("colormap", text_get("resourcespackcolormap"))
		menu_add_item("itemsheet", text_get("resourcespackitemsheet"))
		menu_add_item("particlesheet", text_get("resourcespackparticlesheet"))
		menu_add_item("suntexture", text_get("resourcespacksuntexture"))
		menu_add_item("moontexture", text_get("resourcespackmoontexture"))
		menu_add_item("cloudtexture", text_get("resourcespackcloudtexture"))
		
		break
	}
	
	// Resource pack preview skin
	case "resourcespackimagemodeltexture":
	{
		for (var t = 0; t < ds_list_size(mc_assets.model_texture_list); t++)
			menu_add_item(mc_assets.model_texture_list[|t], mc_assets.model_texture_list[|t])
		
		break
	}
	
	// Timeline frame skin
	case "frameeditorchartex":
	case "frameeditorspblocktex":
	case "frameeditorbodyparttex":
	{
		// Default
		var tex;
		with (tl_edit.temp.skin)
			tex = res_get_model_texture(model_part_texture_name(tl_edit.temp.model_texture_name_map, tl_edit.model_part))
		menu_add_item(null, text_get("frameeditortexturedefault", tl_edit.temp.skin.display_name), tex)
		
		// Add existing resources
		for (var i = 0; i < ds_list_size(res_list.list); i++)
		{
			var res = res_list.list[|i];
			if (res != tl_edit.temp.skin)
			{
				with (res)
					tex = res_get_model_texture(model_part_texture_name(tl_edit.temp.model_texture_name_map, tl_edit.model_part))
					
				if (tex != null)
					menu_add_item(res, res.display_name, tex)
			}
		}
		
		break
	}
	
	// Timeline frame block texture
	case "frameeditorblocktex":
	{
		// Default
		menu_add_item(null, text_get("frameeditortexturedefault", tl_edit.temp.block_tex.display_name), tl_edit.temp.block_tex.block_preview_texture)
		
		// Add existing resources
		for (var i = 0; i < ds_list_size(res_list.list); i++)
		{
			var res = res_list.list[|i];
			if (res != tl_edit.temp.block_tex && res.block_sheet_texture != null)
				menu_add_item(res, res.display_name, res.block_preview_texture)
		}
		
		break
	}
	
	// Timeline frame shape texture
	case "frameeditorshapetex":
	{
		if (tl_edit.temp.shape_tex != null)
		{
			if (tl_edit.temp.shape_tex.object_index = obj_timeline)
				menu_add_item(null, text_get("frameeditortexturedefault", tl_edit.temp.shape_tex.display_name))
			else
				menu_add_item(null, text_get("frameeditortexturedefault", tl_edit.temp.shape_tex.display_name), tl_edit.temp.shape_tex.texture)
			menu_add_item(0, text_get("listnone"))
		}
		else
			menu_add_item(null, text_get("frameeditortexturedefault", text_get("listnone")))
		
		for (var i = 0; i < ds_list_size(res_list.list); i++)
		{
			var res = res_list.list[|i];
			if (res != tl_edit.temp.shape_tex && res.texture)
				menu_add_item(res, res.display_name, res.texture)
		}
		
		with (obj_timeline)
			if (id != tl_edit.temp.shape_tex && type = e_tl_type.CAMERA)
				menu_add_item(id, display_name)
			
		break
	}
	 
	// Sound
	case "frameeditorsound":
	{
		// Default
		menu_add_item(null, text_get("listnone"))
		
		// Add existing resources
		for (var i = 0; i < ds_list_size(res_list.list); i++)
		{
			var res = res_list.list[|i];
			if (res.type = e_res_type.SOUND)
				menu_add_item(res, res.display_name)
		}
		
		break
	}
	
	// Font
	case "frameeditortextfont":
	{
		// Default
		menu_add_item(null, text_get("frameeditortexturedefault", tl_edit.temp.text_font.display_name))
		
		// Add existing resources
		for (var i = 0; i < ds_list_size(res_list.list); i++)
		{
			var res = res_list.list[|i];
			if (res != tl_edit.temp.text_font && font_exists(res.font))
				menu_add_item(res, res.display_name)
		}
		break
	}
	
	// Shadow map detail
	case "settingsrendershadowssunbuffersize":
	case "settingsrendershadowsspotbuffersize":
	case "settingsrendershadowspointbuffersize":
	{
		menu_add_item(256, text_get("settingsrendershadowsbuffersize256") + " (256x256)", null, 0)
		menu_add_item(512, text_get("settingsrendershadowsbuffersize512") + " (512x512)", null, 0)
		menu_add_item(1024, text_get("settingsrendershadowsbuffersize1024") + " (1024x1024)", null, 0)
		menu_add_item(2048, text_get("settingsrendershadowsbuffersize2048") + " (2048x2048)", null, 0)
		menu_add_item(4096, text_get("settingsrendershadowsbuffersize4096") + " (4096x4096)", null, 0)
		menu_add_item(8192, text_get("settingsrendershadowsbuffersize8192") + " (8192x8192)", null, 0)
		
		break
	}
	
	// Video size
	case "projectvideosize":
	case "exportmovievideosize":
	case "exportimageimagesize":
	case "frameeditorcameravideosize":
	{
		if (menu_name = "frameeditorcameravideosize")
			menu_add_item(null, text_get("frameeditorcameravideosizeuseproject"))
			
		for (var i = 0; i < ds_list_size(videotemplate_list); i++)
			with (videotemplate_list[|i])
				menu_add_item(id, name + " (" + string(width) + "x" + string(height) + ")")
				
		menu_add_item(0, text_get("projectvideosizecustom"))
		
		break
	}
	
	// Export format
	case "exportmovieformat":
	{
		menu_add_item("mp4", text_get("exportmovieformatmp4"))
		menu_add_item("mov", text_get("exportmovieformatmov"))
		menu_add_item("wmv", text_get("exportmovieformatwmv"))
		menu_add_item("png", text_get("exportmovieformatpng"))
		
		break
	}
	
	// Video quality
	case "exportmovievideoquality":
	{
		for (var i = 0; i < ds_list_size(videoquality_list); i++)
			with (videoquality_list[|i])
				menu_add_item(id, text_get("exportmovievideoquality" + name))
			
		menu_add_item(0, text_get("exportmovievideoqualitycustom"))
		
		break
	}
	
	// Video framerate
	case "exportmovieframerate":
	{
		menu_add_item(24, "24")
		menu_add_item(30, "30")
		menu_add_item(60, "60")
		
		break
	}
}
