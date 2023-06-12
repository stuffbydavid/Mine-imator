/// list_init(name)
/// @arg name
/// @desc Makes a list and returns it based on name

function list_init(name)
{
	list_init_start()
	
	// Model state
	if (menu_model_current != null)
	{
		for (var i = 0; i < menu_model_state.value_amount; i++)
			list_item_add(minecraft_asset_get_name("modelstatevalue", menu_model_state.value_name[i]), menu_model_state.value_name[i])
	}
	
	// Block state
	if (menu_block_current != null)
	{
		for (var i = 0; i < menu_block_state.value_amount; i++)
			list_item_add(minecraft_asset_get_name("blockstatevalue", menu_block_state.value_name[i]), menu_block_state.value_name[i])
	}
	
	if (menu_model_current != null || menu_block_current != null)
		return list_init_end()
	
	switch (name)
	{
		// Skin
		case "benchskin":
		case "benchskinmaterial":
		case "benchskinnormal":
		case "benchspblocktex":
		case "benchspblocktexmaterial":
		case "benchspblocktexnormal":
		case "benchbodypartskin":
		case "benchbodypartskinmaterial":
		case "benchbodypartskinnormal":
		case "libraryskin":
		case "libraryskinmaterial":
		case "libraryskinnormal":
		case "libraryspblocktex":
		case "libraryspblocktexmaterial":
		case "libraryspblocktexnormal":
		case "librarybodypartskin":
		case "librarybodypartskinmaterial":
		case "librarybodypartskinnormal":
		{
			var temp;
			if (string_contains(menu_current.menu_name, "bench"))
				temp = bench_settings
			else
				temp = temp_edit
			
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.FOLDER)
			
			// Download from user
			if (temp.model_file != null && temp.model_file.player_skin && (name = "benchskin" || name = "libraryskin"))
				menu_add_item(e_option.DOWNLOAD_SKIN, text_get("libraryskindownload"), null, icons.DOWNLOAD)
			
			// Default
			var tex;
			with (mc_res)
			{
				if (string_contains(name, "material"))
					tex = res_get_model_texture_material(model_part_get_texture_material_name(temp.model_file, temp.model_texture_material_name_map))
				else if (string_contains(name, "normal"))
					tex = res_get_model_tex_normal(model_part_get_tex_normal_name(temp.model_file, temp.model_tex_normal_name_map))
				else
					tex = res_get_model_texture(model_part_get_texture_name(temp.model_file, temp.model_texture_name_map))
			}
			
			menu_add_item(mc_res, mc_res.display_name, tex)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res = mc_res)
					continue
				
				with (res)
				{
					if (string_contains(name, "material"))
						tex = res_get_model_texture_material(model_part_get_texture_material_name(temp.model_file, temp.model_texture_material_name_map))
					else if (string_contains(name, "normal"))
						tex = res_get_model_tex_normal(model_part_get_tex_normal_name(temp.model_file, temp.model_tex_normal_name_map))
					else
						tex = res_get_model_texture(model_part_get_texture_name(temp.model_file, temp.model_texture_name_map))
				}
				
				if (tex != null)
					menu_add_item(res, res.display_name, tex)
			}
			
			break
		}
		
		// Model texture
		case "benchmodeltex":
		case "librarymodeltex":
		{
			var temp;
			if (string_contains(menu_current.menu_name, "bench"))
				temp = bench_settings
			else
				temp = temp_edit
			
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.FOLDER)
			
			// Download from user
			if (temp.model_file != null && temp.model_file.player_skin)
				menu_add_item(e_option.DOWNLOAD_SKIN, text_get("libraryskindownload"), null, icons.DOWNLOAD)
			
			// Default
			var texobj = temp.model
			if (texobj != null)
			{
				if (texobj.model_format = e_model_format.BLOCK)
				{
					if (texobj.model_texture_map = null && texobj.block_sheet_texture = null) // Model has no texture, use Minecraft
						texobj = mc_res
				}
				else
				{
					if (texobj.model_texture_map = null && texobj.model_texture = null) // Model has no texture, use Minecraft
						texobj = mc_res
				}
			}
			
			if (texobj != null)
			{
				var tex;
				with (temp)
					tex = temp_get_model_tex_preview(texobj, model_file)
				menu_add_item(null, text_get("listdefault", texobj.display_name), tex)
			}
			else
				menu_add_item(null, text_get("listdefault", text_get("listnone")))
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res = temp.model || res = texobj)
					continue
				
				var tex;
				with (temp)
					tex = temp_get_model_tex_preview(res, model_file)
				
				if (tex != null)
					menu_add_item(res, res.display_name, tex)
			}
			
			break
		}
		
		// Model texture (Material)
		case "benchmodeltexmaterial":
		case "librarymodeltexmaterial":
		{
			var temp;
			if (string_contains(menu_current.menu_name, "bench"))
				temp = bench_settings
			else
				temp = temp_edit
			
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.FOLDER)
			
			// Download from user
			if (temp.model_file != null && temp.model_file.player_skin)
				menu_add_item(e_option.DOWNLOAD_SKIN, text_get("libraryskindownload"), null, icons.DOWNLOAD)
			
			// Default
			var texobj = temp.model;
			if (texobj != null)
			{
				if (texobj.model_format = e_model_format.BLOCK)
				{
					if (texobj.model_texture_material_map = null && texobj.block_sheet_texture_material = null) // Model has no texture, use Minecraft
						texobj = mc_res
				}
			}
			
			if (texobj != null)
			{
				if (texobj.model_texture_material_map = null && texobj.model_texture = null)
					menu_add_item(null, text_get("listdefault", text_get("listnone")))
				else
				{
					var tex;
					with (temp)
						tex = temp_get_model_tex_material_preview(texobj, model_file)
					menu_add_item(null, text_get("listdefault", texobj.display_name), tex)
				}
			}
			else
				menu_add_item(null, text_get("listdefault", text_get("listnone")))
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res = temp.model || res = texobj)
					continue
				
				var tex;
				with (temp)
					tex = temp_get_model_tex_material_preview(res, model_file)
				
				if (tex != null)
					menu_add_item(res, res.display_name, tex)
			}
			
			break
		}
		
		// Model texture (Normal)
		case "benchmodeltexnormal":
		case "librarymodeltexnormal":
		{
			var temp;
			if (string_contains(menu_current.menu_name, "bench"))
				temp = bench_settings
			else
				temp = temp_edit
			
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.FOLDER)
			
			// Download from user
			if (temp.model_file != null && temp.model_file.player_skin)
				menu_add_item(e_option.DOWNLOAD_SKIN, text_get("libraryskindownload"), null, icons.DOWNLOAD)
			
			// Default
			var texobj = temp.model
			if (texobj != null)
			{
				if (texobj.model_format = e_model_format.BLOCK)
				{
					if (texobj.model_tex_normal_map = null && texobj.block_sheet_tex_normal = null) // Model has no texture, use Minecraft
						texobj = mc_res
				}
			}
			
			if (texobj != null)
			{
				if (texobj.model_tex_normal_map = null && texobj.model_texture = null)
				{
					menu_add_item(null, text_get("listdefault", text_get("listnone")))
				}
				else
				{
					var tex;
					with (temp)
						tex = temp_get_model_tex_normal_preview(texobj, model_file)
					menu_add_item(null, text_get("listdefault", texobj.display_name), tex)
				}
			}
			else
				menu_add_item(null, text_get("listdefault", text_get("listnone")))
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res = temp.model || res = texobj)
					continue
				
				var tex;
				with (temp)
					tex = temp_get_model_tex_normal_preview(res, model_file)
				
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
			menu_add_item(e_option.IMPORT_WORLD, text_get("librarysceneryimport"), null, icons.SCENERY)
			
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.FOLDER)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res.type = e_res_type.SCENERY || res.type = e_res_type.FROM_WORLD)
					menu_add_item(res, res.display_name)
			}
			
			break
		}
		
		// Block texture
		case "benchblocktex":
		case "benchblocktexmaterial":
		case "benchblocktexnormal":
		case "libraryblocktex":
		case "libraryblocktexmaterial":
		case "libraryblocktexnormal":
		{
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.FOLDER)
			
			// Default
			menu_add_item(mc_res, mc_res.display_name, mc_res.block_preview_texture)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res != mc_res && res.block_sheet_texture != null)
					menu_add_item(res, res.display_name, res.block_preview_texture)
			}
			
			break
		}
		
		// Item texture
		case "benchitemtex":
		case "benchitemtexmaterial":
		case "benchitemtexnormal":
		case "libraryitemtex":
		case "libraryitemtexmaterial":
		case "libraryitemtexnormal":
		{
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.FOLDER)
			
			// Default
			menu_add_item(mc_res, mc_res.display_name, mc_res.block_preview_texture)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
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
			menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.FOLDER)
			
			// Default
			menu_add_item(mc_res, mc_res.display_name)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res != mc_res && font_exists(res.font))
					menu_add_item(res, res.display_name)
			}
			
			break
		}
		
		// Shape type
		case "benchshapetype":
		{
			for (var i = 0; i < e_shape_type.amount; i++)
				menu_add_item(i, text_get("type" + tl_type_name_list[|e_tl_type.CUBE + i]))
			
			break
		}
		
		// Shape texture
		case "benchshapetex":
		case "benchshapetexmaterial":
		case "benchshapetexnormal":
		case "libraryshapetex":
		case "libraryshapetexmaterial":
		case "libraryshapetexnormal":
		{
			// None
			menu_add_item(null, text_get("listnone"))
			
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.FOLDER)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res.texture)
					menu_add_item(res, res.display_name, res.texture)
			}
			
			// Add existing cameras
			if (name = "benchshapetex" || name = "libraryshapetex")
			{
				with (obj_timeline)
					if (type = e_tl_type.CAMERA)
						menu_add_item(id, display_name)
			}
			
			break
		}
		
		// Model
		case "benchmodel":
		case "librarymodel":
		{
			// None
			menu_add_item(null, text_get("listnone"))
			
			// Browse
			menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.FOLDER)
			
			// Add resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res.type = e_res_type.MODEL)
					menu_add_item(res, res.display_name)
			}
			
			break
		}
		
		// Particle editor spawn region type
		case "particleeditorspawnregiontype":
		{
			menu_add_item("sphere", text_get("particleeditorspawnregiontypesphere"), null, icons.BOUNDARY_CIRCLE)
			menu_add_item("cube", text_get("particleeditorspawnregiontypecube"), null, icons.BOUNDARY_CUBE)
			menu_add_item("box", text_get("particleeditorspawnregiontypebox"), null, icons.BOUNDARY_BOX)
			menu_add_item("path", text_get("particleeditorspawnregiontypepath"), null, icons.PATH)
			
			break
		}
		
		// Path timeline for spawn region
		case "particleeditorspawnregionpath":
		{
			menu_add_item(null, text_get("listnone"))
			
			with (obj_timeline)
			{
				if (type = e_tl_type.PATH)
					menu_add_item(id, display_name)
			}
		
			break
		}
		
		// Particle editor bounding box
		case "particleeditorboundingbox":
		{
			menu_add_item("none", text_get("particleeditorboundingboxtypenone"))
			menu_add_item("spawn", text_get("particleeditorboundingboxtypespawn"))
			menu_add_item("ground", text_get("particleeditorboundingboxtypeground"))
			menu_add_item("custom", text_get("particleeditorboundingboxtypecustom"))
			
			break
		}
		
		// Particle editor type library source
		case "particleeditortypetemp":
		{
			menu_add_item(particle_template, text_get("particleeditortypetemplate"))
			menu_add_item(particle_sheet, text_get("particleeditortypespritesheet"))
			
			for (var i = 0; i < ds_list_size(lib_list.display_list); i++)
			{
				var temp = lib_list.display_list[|i];
				if (temp.type != e_temp_type.PARTICLE_SPAWNER)
					menu_add_item(temp, temp.display_name)
			}
			
			break
		}
		
		// Sprite sheet texture
		case "particleeditortypespritetex":
		{
			var img = ptype_edit.sprite_tex_image;
			
			// Add from file
			menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.FOLDER)
			
			// Default
			menu_add_item(mc_res, mc_res.display_name, mc_res.particles_texture[img])
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res != mc_res && res.particles_texture[0])
					menu_add_item(res, res.display_name, res.particles_texture[img])
			}
			
			break
		}
		
		// Sprite template pack
		case "particleeditortypespritetemplatepack":
		{
			var img = ptype_edit.sprite_tex_image;
			
			// Add from file
			menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.FOLDER)
			
			// Default
			menu_add_item(mc_res, mc_res.display_name, mc_res.block_preview_texture)
			
			// Add existing resources (Only packs allowed)
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res != mc_res && res.type = e_res_type.PACK)
					menu_add_item(res, res.display_name, res.block_preview_texture)
			}
			
			break
		}
		
		// Sprite templates
		case "particleeditortypespritetemplate":
		{
			for (var i = 0; i < ds_list_size(particle_template_list); i++)
			{
				var temp = particle_template_list[|i];
				
				if (temp.animated)
					menu_add_item(temp.name, text_get("particleeditortypespritetemplate" + temp.name) + " " + text_get("particleeditortypespritetemplateframes", temp.frames))
				else
					menu_add_item(temp.name, text_get("particleeditortypespritetemplate" + temp.name))
				
			}
			break
		}
		
		// Background image
		case "backgroundimage":
		{
			// None
			menu_add_item(null, text_get("listnone"))
			
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.FOLDER)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
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
			menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.FOLDER)
			
			// Default
			menu_add_item(mc_res, mc_res.display_name, mc_res.sun_texture)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
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
			menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.FOLDER)
			
			// Default
			menu_add_item(mc_res, mc_res.display_name, mc_res.moon_texture[background_sky_moon_phase])
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
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
			menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.FOLDER)
			
			// Default
			menu_add_item(mc_res, mc_res.display_name, mc_res.clouds_texture)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
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
		case "backgroundgroundtexmaterial":
		case "backgroundgroundtexnormal":
		{
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, icons.FOLDER)
			
			// Default
			menu_add_item(mc_res, mc_res.display_name, mc_res.block_preview_texture)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				
				if (name = "backgroundgroundtexmaterial") // Material
				{
					if (res != mc_res && res.block_sheet_texture_material != null)
						menu_add_item(res, res.display_name, res.block_preview_texture)
				}
				else if (name = "backgroundgroundtexnormal") // Normal
				{
					if (res != mc_res && res.block_sheet_tex_normal != null)
						menu_add_item(res, res.display_name, res.block_preview_texture)
				}
				else // Diffuse
				{
					if (res != mc_res && res.block_sheet_texture != null)
						menu_add_item(res, res.display_name, res.block_preview_texture)
				}
			}
			
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
		
		// Resource pack material option
		case "resourcespackmaterial":
		{
			menu_add_item("diffuse", text_get("resourcespackmaterialdiffuse"))
			menu_add_item("material", text_get("resourcespackmaterialmaterial"))
			menu_add_item("normal", text_get("resourcespackmaterialnormal"))
			
			break
		}
		
		// Resource pack preview skin
		case "resourcespackimagemodeltexture":
		{
			for (var t = 0; t < ds_list_size(mc_assets.model_texture_list); t++)
				menu_add_item(mc_assets.model_texture_list[|t], mc_assets.model_texture_list[|t])
			
			break
		}
		
		// Resource pack preview skin
		case "resourcesscenerystructurepalette":
		{
			for (var p = 0; p < res_edit.scenery_palette_size; p++)
				menu_add_item(p, text_get("resourcesscenerystructurepalettenumber", p + 1))
			
			break
		}
		
		// Path objects
		case "frameeditorpath":
		{
			menu_add_item(null, text_get("listnone"))
			
			with (obj_timeline)
			{
				if (type = e_tl_type.PATH)
					menu_add_item(id, display_name)
			}
			
			break
		}
		
		// Timeline frame skin
		case "frameeditorchartex":
		case "frameeditorspblocktex":
		case "frameeditorbodyparttex":
		case "frameeditormodeltex":
		{
			var temp = tl_edit.temp;
			
			// Default
			var texobj = temp.model_tex;
			
			// Animatable special block in scenery
			if ((tl_edit.type = e_tl_type.SPECIAL_BLOCK || tl_edit.type = e_tl_type.BODYPART) && tl_edit.part_root != null)
			{
				if (tl_edit.part_root.type = e_tl_type.SCENERY)
				{
					with (tl_edit.part_root.temp)
					{
						if (block_tex.type = e_res_type.PACK)
							texobj = block_tex
						else
							texobj = model_tex
					}
				}
			}
			
			if (texobj = null)
			{
				texobj = temp.model
				if (texobj != null)
				{
					if (texobj.model_format = e_model_format.BLOCK)
					{
						if (texobj.model_texture_map = null && texobj.block_sheet_texture = null) // Model has no texture, use Minecraft
							texobj = mc_res
					}
					else
					{
						if (texobj.model_texture_map = null && texobj.model_texture = null) // Model has no texture, use Minecraft
							texobj = mc_res
					}
				}
			}
			
			if (texobj != null)
			{
				var modelfile = temp.model_file;
				if (tl_edit.type = e_temp_type.BODYPART)
					modelfile = tl_edit.model_part
				
				var tex;
				with (temp)
					tex = temp_get_model_tex_preview(texobj, modelfile)
				menu_add_item(null, text_get("listdefault", texobj.display_name), tex)
			}
			else
				menu_add_item(null, text_get("listdefault", text_get("listnone")), null)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if ((temp.object_index != obj_timeline && res = temp.model) || res = texobj)
					continue
				
				var tex;
				with (temp)
					tex = temp_get_model_tex_preview(res, model_file)
				if (tex != null)
					menu_add_item(res, res.display_name, tex)
			}
			
			break
		}
		
		// Timeline frame skin (Material map)
		case "frameeditorchartexmaterial":
		case "frameeditorspblocktexmaterial":
		case "frameeditorbodyparttexmaterial":
		case "frameeditormodeltexmaterial":
		{
			var temp = tl_edit.temp;
			
			// Default
			var texobj = temp.model_tex_material;
			
			// Animatable special block in scenery
			if ((tl_edit.type = e_tl_type.SPECIAL_BLOCK || tl_edit.type = e_tl_type.BODYPART) && tl_edit.part_root != null)
			{
				if (tl_edit.part_root.type = e_tl_type.SCENERY)
				{
					with (tl_edit.part_root.temp)
					{
						if (block_tex_material.type = e_res_type.PACK)
							texobj = block_tex_material
						else
							texobj = model_tex_material
					}
				}
			}
			
			if (texobj = null)
				texobj = temp.model
			
			if (texobj != null)
			{
				if (texobj.model_texture_material_map = null && texobj.model_texture = null)
					menu_add_item(null, text_get("listdefault", text_get("listnone")))
				else
				{
					var modelfile = temp.model_file;
					if (tl_edit.type = e_temp_type.BODYPART)
						modelfile = tl_edit.model_part
				
					var tex;
					with (temp)
						tex = temp_get_model_tex_material_preview(texobj, modelfile)
					menu_add_item(null, text_get("listdefault", texobj.display_name), tex)
				}
			}
			else
				menu_add_item(null, text_get("listdefault", text_get("listnone")), null)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if ((temp.object_index != obj_timeline && res = temp.model) || res = texobj)
					continue
				
				var tex;
				with (temp)
					tex = temp_get_model_tex_material_preview(res, model_file)
				if (tex != null)
					menu_add_item(res, res.display_name, tex)
			}
			
			break
		}
		
		// Timeline frame skin (Normal map)
		case "frameeditorchartexnormal":
		case "frameeditorspblocktexnormal":
		case "frameeditorbodyparttexnormal":
		case "frameeditormodeltexnormal":
		{
			var temp = tl_edit.temp;
			
			// Default
			var texobj = temp.model_tex_normal;
			
			// Animatable special block in scenery
			if ((tl_edit.type = e_tl_type.SPECIAL_BLOCK || tl_edit.type = e_tl_type.BODYPART) && tl_edit.part_root != null)
			{
				if (tl_edit.part_root.type = e_tl_type.SCENERY)
				{
					with (tl_edit.part_root.temp)
					{
						if (block_tex_normal.type = e_res_type.PACK)
							texobj = block_tex_normal
						else
							texobj = model_tex_normal
					}
				}
			}
			
			if (texobj = null)
				texobj = temp.model
			
			if (texobj != null)
			{
				if (texobj.model_tex_normal_map = null && texobj.model_texture = null)
					menu_add_item(null, text_get("listdefault", text_get("listnone")))
				else
				{
					var modelfile = temp.model_file;
					if (tl_edit.type = e_temp_type.BODYPART)
						modelfile = tl_edit.model_part
				
					var tex;
					with (temp)
						tex = temp_get_model_tex_normal_preview(texobj, modelfile)
					menu_add_item(null, text_get("listdefault", texobj.display_name), tex)
				}
			}
			else
				menu_add_item(null, text_get("listdefault", text_get("listnone")), null)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if ((temp.object_index != obj_timeline && res = temp.model) || res = texobj)
					continue
				
				var tex;
				with (temp)
					tex = temp_get_model_tex_normal_preview(res, model_file)
				if (tex != null)
					menu_add_item(res, res.display_name, tex)
			}
			
			break
		}
		
		// Timeline frame block texture
		case "frameeditorblocktex":
		case "frameeditorblocktexmaterial":
		case "frameeditorblocktexnormal":
		{	
			var texobj = null;
			
			// Default
			if (name = "frameeditorblocktexmaterial")
				texobj = tl_edit.temp.block_tex_material
			else if (name = "frameeditorblocktexnormal")
				texobj = tl_edit.temp.block_tex_normal
			else if (name = "frameeditorblocktex")
				texobj = tl_edit.temp.block_tex
			
			// Animatable block in scenery
			if (tl_edit.type = e_tl_type.BLOCK && tl_edit.part_of != null)
			{
				if (tl_edit.part_of.type = e_tl_type.SCENERY)
				{
					var temp = tl_edit.part_of.temp;
					
					with (temp)
					{
						if (name = "frameeditorblocktexmaterial")
						{
							if (block_tex_material.type = e_res_type.PACK || block_tex_material.type = e_res_type.BLOCK_SHEET)
								texobj = block_tex_material
						}
						else if (name = "frameeditorblocktexnormal")
						{
							if (block_tex_normal.type = e_res_type.PACK || block_tex_normal.type = e_res_type.BLOCK_SHEET)
								texobj = block_tex_normal
						}
						else if (name = "frameeditorblocktex")
						{
							if (block_tex.type = e_res_type.PACK || block_tex.type = e_res_type.BLOCK_SHEET)
								texobj = block_tex
						}
					}
				}
			}
			
			menu_add_item(null, text_get("listdefault", texobj.display_name), texobj.block_preview_texture)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res != texobj && res.block_sheet_texture != null)
					menu_add_item(res, res.display_name, res.block_preview_texture)
			}
			
			break
		}
		
		// Timeline frame item texture
		case "frameeditoritemtex":
		case "frameeditoritemtexmaterial":
		case "frameeditoritemtexnormal":
		{
			// Default
			var texobj;
			
			if (name = "frameeditoritemtexmaterial")
				texobj = tl_edit.temp.item_tex_material
			else if (name = "frameeditoritemtexnormal")
				texobj = tl_edit.temp.item_tex_normal
			else
				texobj = tl_edit.temp.item_tex
			
			if (texobj.type = e_res_type.TEXTURE)
				menu_add_item(texobj,text_get("listdefault", texobj.display_name), texobj.texture)
			else if (texobj.item_sheet_texture != null)
				menu_add_item(texobj, text_get("listdefault", texobj.display_name), texobj.block_preview_texture)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				
				if (res.type = e_res_type.TEXTURE)
					menu_add_item(res, res.display_name, res.texture)
				else if (res.item_sheet_texture != null)
					menu_add_item(res, res.display_name, res.block_preview_texture)
			}
			break
		}
		
		// Timeline frame shape texture
		case "frameeditorshapetex":
		case "frameeditorshapetexmaterial":
		case "frameeditorshapetexnormal":
		{
			var texobj;
			
			if (tl_edit.temp = null)
				texobj = null
			else if (name = "frameeditorshapetex")
				texobj = tl_edit.temp.shape_tex
			else if (name = "frameeditorshapetexmaterial")
				texobj = tl_edit.temp.shape_tex_material
			else
				texobj = tl_edit.temp.shape_tex_normal
			
			if (texobj != null)
			{
				if (texobj.object_index = obj_timeline)
					menu_add_item(null, text_get("listdefault", texobj.display_name))
				else
					menu_add_item(null, text_get("listdefault", texobj.display_name), texobj.texture)
				menu_add_item(0, text_get("listnone"))
			}
			else
				menu_add_item(null, text_get("listdefault", text_get("listnone")))
			
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res != texobj && res.texture)
					menu_add_item(res, res.display_name, res.texture)
			}
			
			if (name = "frameeditorshapetex" && tl_edit.type != e_tl_type.PATH)
			{
				with (obj_timeline)
					if (id != texobj && type = e_tl_type.CAMERA)
						menu_add_item(id, display_name)
			}
			
			break
		}
		
		// Camera lens dirt texture
		case "frameeditorcameralensdirttexture":
		{
			menu_add_item(null, text_get("listdefault", text_get("listnone")))
			
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("listbrowse"), null, null, action_tl_frame_cam_lens_dirt_tex_browse)
			
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res.texture)
					menu_add_item(res, res.display_name, res.texture)
			}
			
			break
		}
		
		// Sound
		case "frameeditorsoundfile":
		{
			// Default
			menu_add_item(null, text_get("listnone"))
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res.type = e_res_type.SOUND)
					menu_add_item(res, res.display_name)
			}
			
			break
		}
		
		// Font
		case "frameeditortextfont":
		{
			// Default
			menu_add_item(null, text_get("listdefault", tl_edit.temp.text_font.display_name))
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res != tl_edit.temp.text_font && font_exists(res.font))
					menu_add_item(res, res.display_name)
			}
			break
		}
		
		// Minecraft version
		case "settingsminecraftversion":
		{
			var files = file_find(minecraft_directory, ".midata");
			for (var i = 0; i < array_length(files); i++)
			{
				var fn = filename_new_ext(filename_name(files[i]), "");
				menu_add_item(fn, fn)
			}
			break
		}
		
		// Shadow map detail
		case "rendershadowssunbuffersize":
		case "rendershadowsspotbuffersize":
		case "rendershadowspointbuffersize":
		{
			menu_add_item(256, text_get("rendershadowsbuffersize256") + " (256x256)")
			menu_add_item(512, text_get("rendershadowsbuffersize512") + " (512x512)")
			menu_add_item(1024, text_get("rendershadowsbuffersize1024") + " (1024x1024)")
			menu_add_item(2048, text_get("rendershadowsbuffersize2048") + " (2048x2048)")
			menu_add_item(4096, text_get("rendershadowsbuffersize4096") + " (4096x4096)")
			
			// 8192 is too big, creates a 24576*16384 atlas for shadow depth (also buggy anyways?)
			if (name != "rendershadowspointbuffersize")
				menu_add_item(8192, text_get("rendershadowsbuffersize8192") + " (8192x8192)")
			
			break
		}
		
		// Watermark position
		case "settingswatermarkpositionx":
		{
			menu_add_item("left", text_get("settingswatermarkleft"))
			menu_add_item("center", text_get("settingswatermarkcenter"))
			menu_add_item("right", text_get("settingswatermarkright"))
			
			break
		}
		
		case "settingswatermarkpositiony":
		{
			menu_add_item("top", text_get("settingswatermarktop"))
			menu_add_item("center", text_get("settingswatermarkcenter"))
			menu_add_item("bottom", text_get("settingswatermarkbottom"))
			
			break
		}
		
		// Video size
		case "projectvideosize":
		case "exportmovievideosize":
		case "exportimageimagesize":
		case "frameeditorcameravideosize":
		{
			if (menu_current.menu_name = "frameeditorcameravideosize")
				menu_add_item(null, text_get("frameeditorcameravideosizeuseproject"))
			
			for (var i = 0; i < ds_list_size(videotemplate_list); i++)
				with (videotemplate_list[|i])
					menu_add_item(id, text_get("projectvideosizetemplate" + id.name) + " (" + string(width) + "x" + string(height) + ")")
			
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
					menu_add_item(id, text_get("exportmovievideoquality" + id.name))
			
			menu_add_item(0, text_get("exportmovievideoqualitycustom"))
			
			break
		}
		
		// Video framerate
		case "exportmovieframerate":
		{
			menu_add_item(24, "24")
			menu_add_item(30, "30")
			menu_add_item(60, "60")
			menu_add_item(0, text_get("exportmovieframeratecustom"))
			
			break
		}
		
		// Render settings
		case "projectrendersettings":
		{
			menu_add_item("", text_get("projectrendersettingscustom"))
			menu_add_item("performance", text_get("projectrendersettingsperformance"), null)
			menu_add_item("balanced", text_get("projectrendersettingsbalanced"), null)
			menu_add_item("extreme", text_get("projectrendersettingsextreme"), null)
			
			var file = file_find_first(render_directory + "*.mirender", 0);
			
			while (file != "")
			{
				// Add all files but defaults
				if (file != "performance.mirender" && file != "balanced.mirender" && file != "extreme.mirender")
					menu_add_item(filename_change_ext(file, ""), filename_change_ext(file, ""), null)
				
				file = file_find_next()
			}
			
			break
		}
		
		// Blend mode
		case "timelineeditorblendmode":
		{
			for (var i = 0; i < ds_list_size(blend_mode_list); i++)
				menu_add_item(blend_mode_list[|i], text_get("timelineeditorblendmode" + blend_mode_list[|i]))
			
			break
		}
		
		// Project sort
		case "startupsortby":
		{
			list_item_add(text_get("recentsortdatenewest"), e_recent_sort.date_newest, "", null, null, null, action_recent_sort)
			list_item_add(text_get("recentsortdateoldest"), e_recent_sort.date_oldest, "", null, null, null, action_recent_sort)
			list_item_add(text_get("recentsortnameaz"), e_recent_sort.name_az, "", null, null, null, action_recent_sort)
			list_item_add(text_get("recentsortnameza"), e_recent_sort.name_za, "", null, null, null, action_recent_sort)
			
			break
		}
		
		// Accent color
		case "timelinemarkercolor":
		{
			for (var i = 0; i <= 8; i++)
			{
				list_item_add(text_get("timelinemarkercolor" + string(i)), i, "", spr_16, null, null, null)
				list_item_last.thumbnail_blend = setting_theme.accent_list[i]
			}
			
			break
		}
		
		// Language
		case "settingslanguage":
		{
			with (obj_language)
				list_item_add(id.name, languages_directory + id.filename, id.locale, null, null, null, action_setting_language_load)
			
			break
		}
		
		// Render pass
		case "viewmodepass":
		{
			for (var i = 0; i < e_render_pass.amount; i++)
				list_item_add(text_get("viewmodepass" + render_pass_list[|i]), i)
			
			break
		}
		
		// View camera
		case "viewcameramain":
		case "viewcamerasecond":
		{
			list_item_add(text_get("viewcamerawork"), -4)
			
			var tlname = (timeline_camera = -4 ? text_get("viewcamerawork") : timeline_camera.display_name);
			
			list_item_add(text_get("viewcameraactive", tlname), -5)
			//list_item_last.toggled = (settings_menu_view.camera = -5)
			
			with (obj_timeline)
				if (type = e_tl_type.CAMERA)
					list_item_add(display_name, id)
			
			break
		}
		
		// Select Minecraft world
		case "worldimportworld":
		{
			world_import_world_menu_init()
			break
		}
		
		// Select Minecraft dimension
		case "worldimportdimension":
		{
			world_import_dimension_menu_init()
			break
		}
		
		case "settingsinterfacescale":
		{
			menu_add_item(1, "100%")
			if (interface_scale_default_get() >= 2)
				menu_add_item(2, "200%")
			if (interface_scale_default_get() >= 3)
				menu_add_item(3, "300%")
			break
		}
		
		case "renderalphamode":
		case "timelineeditoralphamode":
		{
			if (name = "timelineeditoralphamode")
				menu_add_item(e_alpha_mode.DEFAULT, text_get("renderalphamodedefault"))
			
			menu_add_item(e_alpha_mode.HASHED, text_get("renderalphamodehashed"))
			menu_add_item(e_alpha_mode.BLEND, text_get("renderalphamodeblend"))
			
			break
		}
		
		case "rendertonemapper":
		case "frameeditorcameratonemapper":
		{
			menu_add_item(e_tonemapper.NONE, text_get("rendertonemappernone"))
			menu_add_item(e_tonemapper.REINHARD, text_get("rendertonemapperreinhard"))
			menu_add_item(e_tonemapper.ACES, text_get("rendertonemapperaces"))
		}
	}
	
	return list_init_end()
}
