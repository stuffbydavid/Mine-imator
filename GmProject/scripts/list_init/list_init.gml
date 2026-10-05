/// @desc Makes a list and returns it based on name.

function list_init(name)
{
	list_init_start()
	
	// Armor variant
	if (name = "bench/armor_variant")
	{
		var armor, variant, statelist;
		armor = mc_assets.model_name_map[?"armor"]
		variant = state_vars_get_value(bench_settings.model_state, "helmet")
		
		if (state_vars_get_value(bench_settings.model_state, "chestplate") != variant ||
			state_vars_get_value(bench_settings.model_state, "leggings") != variant ||
			state_vars_get_value(bench_settings.model_state, "boots") != variant)
		{
			menu_add_item("multiple", text_get("list/multiple"))
			list_item_last.disabled = true
		}
		
		statelist = armor.states_map[?"chestplate"]
		for (var i = 0; i < statelist.value_amount; i++)
			menu_add_item(statelist.value_name[i], minecraft_asset_get_name("model/state/value", statelist.value_name[i]))
		
		return list_init_end()
	}
	
	// Model state
	if (menu_model_current != null && !is_undefined(menu_model_state) && menu_model_state != null)
	{
		for (var i = 0; i < menu_model_state.value_amount; i++)
			menu_add_item(menu_model_state.value_name[i], minecraft_asset_get_name("model/state/value", menu_model_state.value_name[i]))
	}
	
	// Block state
	if (menu_block_current != null && !is_undefined(menu_block_state) && menu_block_state != null)
	{
		for (var i = 0; i < menu_block_state.value_amount; i++)
			menu_add_item(menu_block_state.value_name[i], minecraft_asset_get_name("block/state/value", menu_block_state.value_name[i]))
	}
	
	if (menu_model_current != null || menu_block_current != null)
		return list_init_end()
	
	switch (name)
	{
		// Build structure
		case "build_tool/structure":
		{
			menu_add_item(null, text_get("build_tool/create_new"))

			for (var i = 0; i < ds_list_size(project_timeline_list); i++)
			{
				var tl = project_timeline_list[|i];
				if (type_is_structure(tl.type))
					menu_add_item(tl, tl.display_name, null, timeline_icon_list[|tl.type])
			}

			break
		}

		// Skin
		case "bench/skin":
		case "bench/skin_material":
		case "bench/skin_normal":
		case "bench/equipment_tex":
		case "bench/equipment_tex_material":
		case "bench/equipment_tex_normal":
		case "bench/special_block_tex":
		case "bench/special_block_tex_material":
		case "bench/special_block_tex_normal":
		case "bench/model_part_skin":
		case "bench/model_part_skin_material":
		case "bench/model_part_skin_normal":
		case "library/skin":
		case "library/skin_material":
		case "library/skin_normal":
		case "library/armor_tex":
		case "library/armor_tex_material":
		case "library/armor_tex_normal":
		case "library/special_block_tex":
		case "library/special_block_tex_material":
		case "library/special_block_tex_normal":
		case "library/model_part_skin":
		case "library/model_part_skin_material":
		case "library/model_part_skin_normal":
		{
			var temp;
			if (string_contains(menu_current.menu_name, "bench"))
				temp = bench_settings
			else
				temp = temp_edit
			
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("list/browse"), null, icons.FOLDER)
			
			// Download from user
			if (temp.model_file != null && temp.model_file.player_skin && (name = "bench/skin" || name = "library/skin"))
				menu_add_item(e_option.DOWNLOAD_SKIN, text_get("library/skin_download"), null, icons.DOWNLOAD)
			
			// Default
			var tex;
			with (res_eval(project_pack_res))
			{
				if (string_contains(name, "material"))
					tex = res_get_model_texture_material(model_part_get_texture_material_name(temp.model_file, temp.model_texture_material_name_map))
				else if (string_contains(name, "normal"))
					tex = res_get_model_texture_normal(model_part_get_texture_normal_name(temp.model_file, temp.model_texture_normal_name_map))
				else
					tex = res_get_model_texture(model_part_get_texture_name(temp.model_file, temp.model_texture_name_map))
			}
			
			menu_add_item(project_pack_res, text_get("list/default", res_eval(project_pack_res).display_name), tex)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res = res_eval(project_pack_res))
					continue
				
				with (res)
				{
					if (string_contains(name, "material"))
						tex = res_get_model_texture_material(model_part_get_texture_material_name(temp.model_file, temp.model_texture_material_name_map))
					else if (string_contains(name, "normal"))
						tex = res_get_model_texture_normal(model_part_get_texture_normal_name(temp.model_file, temp.model_texture_normal_name_map))
					else
						tex = res_get_model_texture(model_part_get_texture_name(temp.model_file, temp.model_texture_name_map))
				}
				
				if (tex != null)
					menu_add_item(res, res.display_name, tex)
			}
			
			break
		}
		
		// Model texture
		case "bench/model_tex":
		case "library/model_tex":
		{
			var temp;
			if (string_contains(menu_current.menu_name, "bench"))
				temp = bench_settings
			else
				temp = temp_edit
			
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("list/browse"), null, icons.FOLDER)
			
			// Download from user
			if (temp.model_file != null && temp.model_file.player_skin)
				menu_add_item(e_option.DOWNLOAD_SKIN, text_get("library/skin_download"), null, icons.DOWNLOAD)
			
			// Default
			var texobj = temp.model;
			if (texobj != null)
			{
				if (texobj.model_format = e_model_format.BLOCK)
				{
					if (texobj.model_texture_map = null && texobj.block_sheet_texture[e_block_sheet.STATIC16] = null) // Model has no texture, use Minecraft
						texobj = res_eval(project_pack_res)
				}
				else
				{
					if (texobj.model_texture_map = null && texobj.model_texture = null) // Model has no texture, use Minecraft
						texobj = res_eval(project_pack_res)
				}
			}
			
			if (texobj != null)
			{
				var tex;
				with (temp)
					tex = temp_get_model_tex_preview(texobj, model_file)
				
				menu_add_item(null, text_get("list/default", texobj.display_name), tex)
			}
			else
				menu_add_item(null, text_get("list/default", text_get("list/none")))
			
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
		case "bench/model_tex_material":
		case "library/model_tex_material":
		{
			var temp;
			if (string_contains(menu_current.menu_name, "bench"))
				temp = bench_settings
			else
				temp = temp_edit
			
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("list/browse"), null, icons.FOLDER)
			
			// Default
			var texobj = temp.model;
			if (texobj != null)
			{
				if (texobj.model_format = e_model_format.BLOCK)
				{
					if (texobj.model_texture_material_map = null && texobj.block_sheet_texture_material[e_block_sheet.STATIC16] = null) // Model has no texture, use Minecraft
						texobj = res_eval(project_pack_res)
				}
			}
			
			if (texobj != null)
			{
				if (texobj.model_texture_material_map = null && texobj.model_texture = null)
					menu_add_item(null, text_get("list/default", text_get("list/none")))
				else
				{
					var tex;
					with (temp)
						tex = temp_get_model_tex_material_preview(texobj, model_file)
					
					menu_add_item(null, text_get("list/default", texobj.display_name), tex)
				}
			}
			else
				menu_add_item(null, text_get("list/default", text_get("list/none")))
			
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
		case "bench/model_tex_normal":
		case "library/model_tex_normal":
		{
			var temp;
			if (string_contains(menu_current.menu_name, "bench"))
				temp = bench_settings
			else
				temp = temp_edit
			
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("list/browse"), null, icons.FOLDER)
			
			// Default
			var texobj = temp.model;
			if (texobj != null)
			{
				if (texobj.model_format = e_model_format.BLOCK)
				{
					if (texobj.model_texture_normal_map = null && texobj.block_sheet_texture_normal[e_block_sheet.STATIC16] = null) // Model has no texture, use Minecraft
						texobj = res_eval(project_pack_res)
				}
			}
			
			if (texobj != null)
			{
				if (texobj.model_texture_normal_map = null && texobj.model_texture = null)
					menu_add_item(null, text_get("list/default", text_get("list/none")))
				
				else
				{
					var tex;
					with (temp)
						tex = temp_get_model_tex_normal_preview(texobj, model_file)
					menu_add_item(null, text_get("list/default", texobj.display_name), tex)
				}
			}
			else
				menu_add_item(null, text_get("list/default", text_get("list/none")))
			
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
		case "library/scenery":
		{
			// None
			menu_add_item(null, text_get("list/none"))
			
			// Import from world
			menu_add_item(e_option.IMPORT_WORLD, text_get("library/scenery_import"), null, icons.SCENERY)
			
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("list/browse"), null, icons.FOLDER)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res.type = e_res_type.SCHEMATIC || res.type = e_res_type.FROM_WORLD)
					menu_add_item(res, res.display_name)
			}
			
			break
		}
		
		// Block texture
		case "bench/block_tex":
		case "bench/block_tex_material":
		case "bench/block_tex_normal":
		case "library/block_tex":
		case "library/block_tex_material":
		case "library/block_tex_normal":
		{
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("list/browse"), null, icons.FOLDER)
			
			// Default
			menu_add_item(project_pack_res, text_get("list/default", res_eval(project_pack_res).display_name), res_eval(project_pack_res).block_preview_texture)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res != res_eval(project_pack_res) && res.block_sheet_texture[e_block_sheet.STATIC16] != null)
					menu_add_item(res, res.display_name, res.block_preview_texture)
			}
			
			break
		}
		
		// Item texture
		case "bench/item_tex":
		case "bench/item_tex_material":
		case "bench/item_tex_normal":
		case "library/item_tex":
		case "library/item_tex_material":
		case "library/item_tex_normal":
		{
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("list/browse"), null, icons.FOLDER)
			
			// Default
			menu_add_item(project_pack_res, text_get("list/default", res_eval(project_pack_res).display_name), res_eval(project_pack_res).block_preview_texture)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res = res_eval(project_pack_res))
					continue
				
				if (res.type = e_res_type.TEXTURE)
					menu_add_item(res, res.display_name, res.texture)
				else if (res.item_sheet_texture[e_item_sheet.SIZE16] != null)
					menu_add_item(res, res.display_name, res.block_preview_texture)
			}
			
			break
		}
		
		// Body part
		case "bench/model_part":
		{
			for (var p = 0; p < ds_list_size(bench_settings.model_file.file_part_list); p++)
			{
				var part = bench_settings.model_file.file_part_list[|p];
				menu_add_item(part.name, minecraft_asset_get_name("model/part", part.name))
			}
			
			break
		}
		
		// Body part
		case "template_editor/model_part":
		{
			for (var p = 0; p < ds_list_size(temp_edit.model_file.file_part_list); p++)
			{
				var part = temp_edit.model_file.file_part_list[|p];
				menu_add_item(part.name, minecraft_asset_get_name("model/part", part.name))
			}
			
			break
		}
		
		// Text font
		case "bench/text_font":
		case "library/text_font":
		case "frame_editor/text/font":
		{
			if (name = "frame_editor/text/font" && tl_edit.has_temp)
			{
				menu_add_item(null, text_get("list/default", res_eval(tl_edit.temp.text_font).display_name))

				for (var i = 0; i < ds_list_size(res_list.display_list); i++)
				{
					var res = res_list.display_list[|i];
					if (res != tl_edit.temp.text_font && font_exists(res.font))
						menu_add_item(res, res.display_name)
				}
				
				break
			}

			// Import from file
			menu_add_item(e_option.BROWSE, text_get("list/browse"), null, icons.FOLDER)
			
			// Default
			menu_add_item(project_pack_res, text_get("list/default", res_eval(project_pack_res).display_name))
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res != res_eval(project_pack_res) && font_exists(res.font))
					menu_add_item(res, res.display_name)
			}
			
			break
		}
		
		// Shape type
		case "bench/shape_type":
		{
			for (var i = 0; i < e_shape_type.amount; i++)
				menu_add_item(i, text_get("type/" + tl_type_name_list[|e_tl_type.CUBE + i]))
			
			break
		}
		
		case "library/shape/type":
		{
			for (var i = 0; i < e_shape_type.amount; i++)
				menu_add_item(e_temp_type.CUBE + i, text_get("type/" + temp_type_name_list[|e_temp_type.CUBE + i]))

			break
		}

		// Shape texture
		case "bench/shape_tex":
		case "bench/shape_tex_material":
		case "bench/shape_tex_normal":
		case "library/shape/tex":
		case "library/shape/tex_material":
		case "library/shape/tex_normal":
		{
			// None
			menu_add_item(null, text_get("list/none"))
			
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("list/browse"), null, icons.FOLDER)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res.texture)
					menu_add_item(res, res.display_name, res.texture)
			}
			
			// Add existing cameras
			if (name = "bench/shape_tex" || name = "library/shape/tex")
			{
				with (obj_timeline)
					if (type = e_tl_type.CAMERA)
						menu_add_item(id, display_name)
			}
			
			break
		}
		
		// Model
		case "bench/model":
		case "library/model":
		{
			// None
			menu_add_item(null, text_get("list/none"))
			
			// Browse
			menu_add_item(e_option.BROWSE, text_get("list/browse"), null, icons.FOLDER)
			
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
		case "particle_editor/spawn/region/type":
		{
			menu_add_item("sphere", text_get("particle_editor/spawn/region/type_sphere"), null, icons.BOUNDARY_CIRCLE)
			menu_add_item("cube", text_get("particle_editor/spawn/region/type_cube"), null, icons.BOUNDARY_CUBE)
			menu_add_item("box", text_get("particle_editor/spawn/region/type_box"), null, icons.BOUNDARY_BOX)
			menu_add_item("path", text_get("particle_editor/spawn/region/type_path"), null, icons.PATH)
			break
		}
		
		// Path timeline for spawn region
		case "particle_editor/spawn/region/path":
		{
			menu_add_item(null, text_get("list/none"))
			
			with (obj_timeline)
				if (type = e_tl_type.PATH)
					menu_add_item(id, display_name)
		
			break
		}
		
		// Particle editor bounding box
		case "particle_editor/bounding_box":
		{
			menu_add_item("none", text_get("particle_editor/bounding_box/type_none"))
			menu_add_item("spawn", text_get("particle_editor/bounding_box/type_spawn"))
			menu_add_item("ground", text_get("particle_editor/bounding_box/type_ground"))
			menu_add_item("custom", text_get("particle_editor/bounding_box/type_custom"))
			break
		}
		
		// Particle editor type library source
		case "particle_editor/type/temp":
		{
			menu_add_item(particle_template, text_get("particle_editor/type/template"))
			menu_add_item(particle_sheet, text_get("particle_editor/type/sprite_sheet"))
			
			for (var i = 0; i < ds_list_size(lib_list.display_list); i++)
			{
				var temp = lib_list.display_list[|i];
				if (temp.type != e_temp_type.PARTICLE_SPAWNER)
					menu_add_item(temp, temp.display_name)
			}
			
			break
		}
		
		// Sprite sheet texture
		case "particle_editor/type/sprite/tex":
		{
			var img = ptype_edit.sprite_tex_image;
			
			// Add from file
			menu_add_item(e_option.BROWSE, text_get("list/browse"), null, icons.FOLDER)
			
			// Default
			menu_add_item(project_pack_res, text_get("list/default", res_eval(project_pack_res).display_name), res_eval(project_pack_res).particles_texture[img])
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res != res_eval(project_pack_res) && res.particles_texture[0])
					menu_add_item(res, res.display_name, res.particles_texture[img])
			}
			
			break
		}
		
		// Sprite template pack
		case "particle_editor/type/sprite/template_pack":
		{
			var img = ptype_edit.sprite_tex_image;
			
			// Add from file
			menu_add_item(e_option.BROWSE, text_get("list/browse"), null, icons.FOLDER)
			
			// Default
			menu_add_item(project_pack_res, text_get("list/default", res_eval(project_pack_res).display_name), res_eval(project_pack_res).block_preview_texture)
			
			// Add existing resources (Only packs allowed)
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res != res_eval(project_pack_res) && res.type = e_res_type.PACK)
					menu_add_item(res, res.display_name, res.block_preview_texture)
			}
			
			break
		}
		
		// Sprite templates
		case "particle_editor/type/sprite/template":
		{
			for (var i = 0; i < ds_list_size(particle_template_list); i++)
			{
				var temp = particle_template_list[|i];
				
				if (temp.animated)
					menu_add_item(temp.name, text_get("particle_editor/type/sprite/template/" + temp.name) + " " + text_get("particle_editor/type/sprite/template/frames", temp.frames))
				else
					menu_add_item(temp.name, text_get("particle_editor/type/sprite/template/" + temp.name))
				
			}
			
			break
		}
		
		// Background image
		case "environment/image":
		{
			// None
			menu_add_item(null, text_get("list/none"))
			
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("list/browse"), null, icons.FOLDER)
			
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
		case "environment/image/type":
		{
			menu_add_item("image", text_get("environment/image/type_image"))
			menu_add_item("sphere", text_get("environment/image/type_sphere"))
			menu_add_item("box", text_get("environment/image/type_box"))
			break
		}
		
		// Background sky sun texture
		case "environment/sky/sun_tex":
		{
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("list/browse"), null, icons.FOLDER)
			
			// Default
			menu_add_item(project_pack_res, text_get("list/default", res_eval(project_pack_res).display_name), res_eval(project_pack_res).sun_texture)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res = res_eval(project_pack_res))
					continue
				
				if (res.sun_texture)
					menu_add_item(res, res.display_name, res.sun_texture)
				else if (res.texture)
					menu_add_item(res, res.display_name, res.texture)
			}
			
			break
		}
		
		// Background sky moon texture
		case "environment/sky/moon_tex":
		{
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("list/browse"), null, icons.FOLDER)
			
			// Default
			menu_add_item(project_pack_res, text_get("list/default", res_eval(project_pack_res).display_name), res_eval(project_pack_res).moon_textures[env_sky_moon_phase])
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res = res_eval(project_pack_res))
					continue
				
				if (res.moon_textures[0])
					menu_add_item(res, res.display_name, res.moon_textures[env_sky_moon_phase])
				else if (res.texture)
					menu_add_item(res, res.display_name, res.texture)
			}
			
			break
		}
		
		// Background sky moon phase
		case "environment/sky/moon_phase":
		{
			for (var p = 0; p < 8; p++)
				menu_add_item(p, text_get("environment/sky/moon_phase/" + string(p + 1)), res_eval(env_sky_moon_tex).moon_textures[p])
			
			break
		}
		
		// Background sky clouds texture
		case "environment/sky/clouds/tex":
		{
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("list/browse"), null, icons.FOLDER)
			
			// Default
			menu_add_item(project_pack_res, text_get("list/default", res_eval(project_pack_res).display_name), res_eval(project_pack_res).clouds_texture)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res = res_eval(project_pack_res))
					continue
				
				if (res.clouds_texture)
					menu_add_item(res, res.display_name, res.clouds_texture)
				else if (res.texture)
					menu_add_item(res, res.display_name, res.texture)
			}
			
			break
		}
		
		// Background ground texture
		case "environment/ground_tex":
		case "environment/ground_tex_material":
		case "environment/ground_tex_normal":
		{
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("list/browse"), null, icons.FOLDER)
			
			// Default
			menu_add_item(project_pack_res, text_get("list/default", res_eval(project_pack_res).display_name), res_eval(project_pack_res).block_preview_texture)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				
				if (name = "environment/ground_tex_material") // Material
				{
					if (res != res_eval(project_pack_res) && res.block_sheet_texture_material[e_block_sheet.STATIC16] != null)
						menu_add_item(res, res.display_name, res.block_preview_texture)
				}
				else if (name = "environment/ground_tex_normal") // Normal
				{
					if (res != res_eval(project_pack_res) && res.block_sheet_texture_normal[e_block_sheet.STATIC16] != null)
						menu_add_item(res, res.display_name, res.block_preview_texture)
				}
				else // Diffuse
				{
					if (res != res_eval(project_pack_res) && res.block_sheet_texture[e_block_sheet.STATIC16] != null)
						menu_add_item(res, res.display_name, res.block_preview_texture)
				}
			}
			
			break
		}
		
		// Resource pack preview image
		case "resources/pack/image":
		{
			menu_add_item("preview", text_get("resources/pack/preview"))
			menu_add_item("model_textures", text_get("resources/pack/model_textures"))
			menu_add_item("block_sheet", text_get("resources/pack/block_sheet"))
			menu_add_item("color_map", text_get("resources/pack/color_map"))
			menu_add_item("item_sheet", text_get("resources/pack/item_sheet"))
			menu_add_item("particle_sheet", text_get("resources/pack/particle_sheet"))
			menu_add_item("sun_texture", text_get("resources/pack/sun_texture"))
			menu_add_item("moon_texture", text_get("resources/pack/moon_texture"))
			menu_add_item("cloud_texture", text_get("resources/pack/cloud_texture"))
			break
		}
		
		// Resource pack material option
		case "resources/pack/material":
		{
			menu_add_item("diffuse", text_get("resources/pack/material/diffuse"))
			
			if (res_edit.pack_has_materials)
				menu_add_item("material", text_get("resources/pack/material/material"))
			
			if (res_edit.pack_has_normals)
				menu_add_item("normal", text_get("resources/pack/material/normal"))
			
			break
		}

		case "resources/pack/image/block_sheet_size":
		{
			for (var size = 0; size < e_block_sheet.static_amount; size++)
				menu_add_item(size, text_get("resources/pack/image/block_sheet_size_" + string(block_size_list[size])))

			break
		}

		case "resources/pack/image/item_sheet_size":
		{
			for (var size = 0; size < e_item_sheet.amount; size++)
				menu_add_item(size, text_get("resources/pack/image/item_sheet_size_" + string(item_size * (size + 1))))

			break
		}
		
		// Resource pack preview skin
		case "resources/pack/image/model_texture":
		{
			for (var t = 0; t < ds_list_size(mc_assets.model_texture_list); t++)
				menu_add_item(mc_assets.model_texture_list[|t], mc_assets.model_texture_list[|t])
			
			break
		}
		
		// Resource pack preview skin
		case "resources/scenery_structure_palette":
		{
			for (var p = 0; p < res_edit.scenery_palette_size; p++)
				menu_add_item(p, text_get("resources/scenery_structure_palette_number", p + 1))
			
			break
		}
		
		// Resource pack moon phase
		case "resources/pack/moon_phase":
		{
			for (var p = 0; p < 8; p++)
				menu_add_item(p, text_get("resources/pack/moon_phase/" + string(p + 1)))
			
			break
		}
		
		// Path objects
		case "frame_editor/path":
		{
			menu_add_item(null, text_get("list/none"))
			
			with (obj_timeline)
				if (type = e_tl_type.PATH)
					menu_add_item(id, display_name)
			
			break
		}
		
		// Timeline frame skin
		case "frame_editor/char_tex":
		case "frame_editor/special_block_tex":
		case "frame_editor/model_part_tex":
		case "frame_editor/model_tex":
		{
			var temp = tl_edit.temp;
			
			// Default
			var texsource, texobj;
			texsource = temp.model_tex
			texobj = res_eval(texsource)
			
			// Animatable special block in scenery
			if ((tl_edit.type = e_tl_type.SPECIAL_BLOCK || tl_edit.type = e_tl_type.MODEL_PART) && tl_edit.part_root != null)
			{
				if (tl_edit.part_root.type = e_tl_type.SCENERY)
				{
					with (tl_edit.part_root.temp)
					{
						if (res_eval(block_tex).type = e_res_type.PACK)
							texsource = block_tex
						else
							texsource = model_tex
					}
					texobj = res_eval(texsource)
				}
			}
			
			if (texobj = null)
			{
				texobj = temp.model
				if (texobj != null)
				{
					if (texobj.model_format = e_model_format.BLOCK)
					{
						if (texobj.model_texture_map = null && texobj.block_sheet_texture[e_block_sheet.STATIC16] = null) // Model has no texture, use Minecraft
						{
							texsource = project_pack_res
							texobj = res_eval(project_pack_res)
						}
					}
					else
					{
						if (texobj.model_texture_map = null && texobj.model_texture = null) // Model has no texture, use Minecraft
						{
							texsource = project_pack_res
							texobj = res_eval(project_pack_res)
						}
					}
				}
			}
			
			if (texobj != null)
			{
				var modelfile = temp.model_file;
				if (tl_edit.type = e_temp_type.MODEL_PART)
					modelfile = tl_edit.model_part
				
				var tex;
				with (temp)
					tex = temp_get_model_tex_preview(texobj, modelfile)
				
				menu_add_item(texsource, text_get("list/default", texobj.display_name), tex)
			}
			else
				menu_add_item(null, text_get("list/default", text_get("list/none")), null)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (temp.object_index != obj_timeline && res = temp.model)
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
		case "frame_editor/char_tex_material":
		case "frame_editor/special_block_tex_material":
		case "frame_editor/model_part_tex_material":
		case "frame_editor/model_tex_material":
		{
			var temp = tl_edit.temp;
			
			// Default
			var texsource, texobj;
			texsource = temp.model_tex_material
			texobj = res_eval(texsource)
			
			// Animatable special block in scenery
			if ((tl_edit.type = e_tl_type.SPECIAL_BLOCK || tl_edit.type = e_tl_type.MODEL_PART) && tl_edit.part_root != null)
			{
				if (tl_edit.part_root.type = e_tl_type.SCENERY)
				{
					with (tl_edit.part_root.temp)
					{
						if (res_eval(block_tex_material).type = e_res_type.PACK)
							texsource = block_tex_material
						else
							texsource = model_tex_material
					}
					texobj = res_eval(texsource)
				}
			}
			
			if (texobj = null)
				texobj = temp.model
			
			if (texobj != null)
			{
				if (texobj.model_texture_material_map = null && texobj.model_texture = null)
					menu_add_item(texsource, text_get("list/default", text_get("list/none")))
				else
				{
					var modelfile = temp.model_file;
					if (tl_edit.type = e_temp_type.MODEL_PART)
						modelfile = tl_edit.model_part
				
					var tex;
					with (temp)
						tex = temp_get_model_tex_material_preview(texobj, modelfile)
					
					menu_add_item(texsource, text_get("list/default", texobj.display_name), tex)
				}
			}
			else
				menu_add_item(null, text_get("list/default", text_get("list/none")), null)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (temp.object_index != obj_timeline && res = temp.model)
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
		case "frame_editor/char_tex_normal":
		case "frame_editor/special_block_tex_normal":
		case "frame_editor/model_part_tex_normal":
		case "frame_editor/model_tex_normal":
		{
			var temp = tl_edit.temp;
			
			// Default
			var texsource, texobj;
			texsource = temp.model_tex_normal
			texobj = res_eval(texsource)
			
			// Animatable special block in scenery
			if ((tl_edit.type = e_tl_type.SPECIAL_BLOCK || tl_edit.type = e_tl_type.MODEL_PART) && tl_edit.part_root != null)
			{
				if (tl_edit.part_root.type = e_tl_type.SCENERY)
				{
					with (tl_edit.part_root.temp)
					{
						if (res_eval(block_tex_normal).type = e_res_type.PACK)
							texsource = block_tex_normal
						else
							texsource = model_tex_normal
					}
					texobj = res_eval(texsource)
				}
			}
			
			if (texobj = null)
				texobj = temp.model
			
			if (texobj != null)
			{
				if (texobj.model_texture_normal_map = null && texobj.model_texture = null)
					menu_add_item(texsource, text_get("list/default", text_get("list/none")))
				else
				{
					var modelfile = temp.model_file;
					if (tl_edit.type = e_temp_type.MODEL_PART)
						modelfile = tl_edit.model_part
				
					var tex;
					with (temp)
						tex = temp_get_model_tex_normal_preview(texobj, modelfile)
					
					menu_add_item(texsource, text_get("list/default", texobj.display_name), tex)
				}
			}
			else
				menu_add_item(null, text_get("list/default", text_get("list/none")), null)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (temp.object_index != obj_timeline && res = temp.model)
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
		case "frame_editor/block_tex":
		case "frame_editor/block_tex_material":
		case "frame_editor/block_tex_normal":
		{	
			var texsource, texobj;
			
			// Default
			if (tl_edit.type = e_tl_type.STRUCTURE)
				texsource = null
			else if (name = "frame_editor/block_tex_material")
				texsource = tl_edit.temp.block_tex_material
			else if (name = "frame_editor/block_tex_normal")
				texsource = tl_edit.temp.block_tex_normal
			else if (name = "frame_editor/block_tex")
				texsource = tl_edit.temp.block_tex
			
			texobj = res_eval(texsource)
			
			// Animatable block in scenery
			if (tl_edit.type = e_tl_type.BLOCK && tl_edit.part_of != null)
			{
				if (tl_edit.part_of.type = e_tl_type.SCENERY)
				{
					var temp = tl_edit.part_of.temp;
					
					with (temp)
					{
						if (name = "frame_editor/block_tex_material")
						{
							if (res_eval(block_tex_material).type = e_res_type.PACK || res_eval(block_tex_material).type = e_res_type.BLOCK_SHEET)
								texsource = block_tex_material
						}
						else if (name = "frame_editor/block_tex_normal")
						{
							if (res_eval(block_tex_normal).type = e_res_type.PACK || res_eval(block_tex_normal).type = e_res_type.BLOCK_SHEET)
								texsource = block_tex_normal
						}
						else if (name = "frame_editor/block_tex")
						{
							if (res_eval(block_tex).type = e_res_type.PACK || res_eval(block_tex).type = e_res_type.BLOCK_SHEET)
								texsource = block_tex
						}
					}
					
					texobj = res_eval(texsource)
				}
			}
			
			menu_add_item(texsource, text_get("list/default", texobj.display_name), texobj.block_preview_texture)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res.block_sheet_texture[e_block_sheet.STATIC16] != null)
					menu_add_item(res, res.display_name, res.block_preview_texture)
			}
			
			break
		}
		
		// Timeline frame item texture
		case "frame_editor/item_tex":
		case "frame_editor/item_tex_material":
		case "frame_editor/item_tex_normal":
		{
			// Default
			var texobj, texsource;
			
			if (name = "frame_editor/item_tex_material")
				texsource = tl_edit.temp.item_tex_material
			else if (name = "frame_editor/item_tex_normal")
				texsource = tl_edit.temp.item_tex_normal
			else
				texsource = tl_edit.temp.item_tex
			texobj = res_eval(texsource)
			
			if (texobj.type = e_res_type.TEXTURE)
				menu_add_item(null, text_get("list/default", texobj.display_name), texobj.texture)
			else if (texobj.item_sheet_texture[e_item_sheet.SIZE16] != null)
				menu_add_item(null, text_get("list/default", texobj.display_name), texobj.block_preview_texture)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				
				if (res.type = e_res_type.TEXTURE)
					menu_add_item(res, res.display_name, res.texture)
				else if (res.item_sheet_texture[e_item_sheet.SIZE16] != null)
					menu_add_item(res, res.display_name, res.block_preview_texture)
			}
			break
		}
		
		// Timeline frame shape texture
		case "frame_editor/shape_tex":
		case "frame_editor/shape_tex_material":
		case "frame_editor/shape_tex_normal":
		{
			var texobj;
			
			if (tl_edit.temp = null)
				texobj = null
			else if (name = "frame_editor/shape_tex")
				texobj = tl_edit.temp.shape_tex
			else if (name = "frame_editor/shape_tex_material")
				texobj = tl_edit.temp.shape_tex_material
			else
				texobj = tl_edit.temp.shape_tex_normal
			
			if (texobj != null)
			{
				if (texobj.object_index = obj_timeline)
					menu_add_item(null, text_get("list/default", texobj.display_name))
				else
					menu_add_item(null, text_get("list/default", texobj.display_name), texobj.texture)
				
				menu_add_item(0, text_get("list/none"))
			}
			else
				menu_add_item(null, text_get("list/default", text_get("list/none")))
			
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res != texobj && res.texture)
					menu_add_item(res, res.display_name, res.texture)
			}
			
			if (name = "frame_editor/shape_tex" && tl_edit.type != e_tl_type.PATH)
			{
				with (obj_timeline)
					if (id != texobj && type = e_tl_type.CAMERA)
						menu_add_item(id, display_name)
			}
			
			break
		}
		
		// Camera lens dirt texture
		case "frame_editor/camera_effect/lens_dirt/texture":
		{
			menu_add_item(null, text_get("list/default", text_get("list/none")))
			
			// Import from file
			menu_add_item(e_option.BROWSE, text_get("list/browse"), null, icons.FOLDER, action_tl_frame_cam_fx_lens_dirt_tex_browse)
			
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res.texture)
					menu_add_item(res, res.display_name, res.texture)
			}
			
			break
		}
		
		// Camera effect target
		case "bench/camera":
		{
			menu_add_item(app, text_get("bench/all_cameras"))
			for (var i = 0; i < ds_list_size(project_timeline_list); i++)
			{
				var cam = project_timeline_list[|i];
				if (cam.type = e_tl_type.CAMERA)
					menu_add_item(cam, cam.display_name)
			}
			break
		}

		// Audio track
		case "bench/audio_track":
		{
			menu_add_item(null, text_get("bench/audio_track_new"))

			for (var i = 0; i < ds_list_size(project_timeline_list); i++)
			{
				var track = project_timeline_list[|i];
				if (track.type = e_tl_type.AUDIO_TRACK)
					menu_add_item(track, track.display_name)
			}

			break
		}

		case "frame_editor/sound/file":
		{
			// Default
			menu_add_item(null, text_get("list/none"))
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res.type = e_res_type.SOUND)
					menu_add_item(res, res.display_name)
			}
			
			break
		}

		// Minecraft version
		case "settings/minecraft_version":
		{
			var files = file_find(minecraft_directory, ".midata");
			for (var i = 0; i < array_length(files); i++)
			{
				var fn = filename_new_ext(filename_name(files[i]), "");
				menu_add_item(fn, fn)
			}
			break
		}
		
		// Raytrace resolution
		case "render/indirect/resolution":
		case "render/reflections/resolution":
		{
			menu_add_item(1, text_get("render/resolution_full"))
			menu_add_item(.5, text_get("render/resolution_half"))
			menu_add_item(.25, text_get("render/resolution_quarter"))
			menu_add_item(.125, text_get("render/resolution_eighth"))
			break
		}

		// Shadow map detail
		case "render/shadows/sun_buffer_size":
		case "render/shadows/spot_buffer_size":
		case "render/shadows/point_buffer_size":
		{
			menu_add_item(256, text_get("render/shadows/buffer_size_256") + " (256x256)")
			menu_add_item(512, text_get("render/shadows/buffer_size_512") + " (512x512)")
			menu_add_item(1024, text_get("render/shadows/buffer_size_1024") + " (1024x1024)")
			menu_add_item(2048, text_get("render/shadows/buffer_size_2048") + " (2048x2048)")
			menu_add_item(4096, text_get("render/shadows/buffer_size_4096") + " (4096x4096)")
			
			// 8192 is too big, creates a 24576*16384 atlas for shadow depth (also buggy anyways?)
			if (name != "render/shadows/point_buffer_size")
				menu_add_item(8192, text_get("render/shadows/buffer_size_8192") + " (8192x8192)")
			
			break
		}
		
		// Watermark position
		case "settings/watermark/positionx":
		{
			menu_add_item("left", text_get("settings/watermark/left"))
			menu_add_item("center", text_get("settings/watermark/center"))
			menu_add_item("right", text_get("settings/watermark/right"))
			break
		}
		
		case "settings/watermark/positiony":
		{
			menu_add_item("top", text_get("settings/watermark/top"))
			menu_add_item("center", text_get("settings/watermark/center"))
			menu_add_item("bottom", text_get("settings/watermark/bottom"))
			break
		}
		
		// Video size
		case "project/video_size":
		case "export_movie/video_size":
		case "export_image/image_size":
		case "frame_editor/camera/video_size":
		{
			if (menu_current.menu_name = "frame_editor/camera/video_size")
				menu_add_item(null, text_get("frame_editor/camera/video_size/use_project"))
			
			for (var i = 0; i < ds_list_size(videotemplate_list); i++)
				with (videotemplate_list[|i])
					menu_add_item(id, text_get("project/video_size_template/" + self.name) + " (" + string(width) + "x" + string(height) + ")")
			
			menu_add_item(0, text_get("project/video_size_custom"))
			
			break
		}

		// Project resource pack
		case "project/pack":
		case "new_project/pack":
		{
			directory_create_lib(packs_directory_get())
			menu_add_item(e_option.BROWSE, text_get("list/browse"), null, icons.FOLDER)
			menu_add_item("", mc_res.display_name, mc_res.block_preview_texture)

			// List packs under /Packs
			var packfiles = file_find(packs_directory_get(), ".zip");
			for (var i = 0; i < array_length(packfiles); i++)
			{
				var pack = filename_name(packfiles[i]);
				menu_add_item(pack, pack, minecraft_get_pack_image(pack))
			}

			// List project resources packs not found under /Packs
			if (name = "project/pack")
			{
				for (var i = 0; i < ds_list_size(res_list.display_list); i++)
				{
					var res = res_list.display_list[|i];
					if (res.type = e_res_type.PACK && !file_exists_lib(packs_directory_get() + res.filename))
						menu_add_item(res.filename, res.filename, res.block_preview_texture)
				}
			}

			break
		}
		
		// Export format
		case "export_movie/format":
		{
			menu_add_item("mp4", text_get("export_movie/format/mp4"))
			menu_add_item("mov", text_get("export_movie/format/mov"))
			menu_add_item("wmv", text_get("export_movie/format/wmv"))
			menu_add_item("png", text_get("export_movie/format/png"))
			break
		}
		
		// Renderer
		case "export_movie/renderer":
		case "export_image/renderer":
		{
			menu_add_item(e_renderer.QUICK, text_get("render/renderer/quick"))
			menu_add_item(e_renderer.STANDARD, text_get("render/renderer/standard"))
			menu_add_item(e_renderer.REALISTIC, text_get("render/renderer/realistic"))
			break
		}
		
		// Video framerate
		case "export_movie/frame_rate":
		{
			menu_add_item(24, "24")
			menu_add_item(30, "30")
			menu_add_item(60, "60")
			menu_add_item(0, text_get("export_movie/frame_rate/custom"))
			break
		}
		
		// Renderer
		case "render/renderer":
		{
			menu_add_item(e_renderer.STANDARD, text_get("render/renderer/standard"), null)
			menu_add_item(e_renderer.REALISTIC, text_get("render/renderer/realistic"), null)
			break
		}
		
		// Presets
		case "render/preset_standard":
		case "render/preset_realistic":
		{
			var presetlist = render_preset_list[renderer_edit];
			
			for (var i = 0; i < ds_list_size(presetlist); i++)
			{
				var file, presetname, text;
				file = presetlist[|i]
				presetname = render_preset_map[?file].name
				
				if (text_exists("render/preset/" + presetname))
					text = text_get("render/preset/" + presetname)
				else
					text = presetname
				
				menu_add_item(file, text)
			}
			
			break
		}
		
		// Blend mode
		case "timeline_editor/blend_mode":
		{
			for (var i = 0; i < ds_list_size(blend_mode_list); i++)
				menu_add_item(blend_mode_list[|i], text_get("timeline_editor/blend_mode/" + blend_mode_list[|i]))
			
			break
		}
		
		// Project sort
		case "startup/sort_by":
		{
			list_item_add(text_get("recent/sort_date_newest"), e_recent_sort.DATE_NEWEST, "", null, null, null, action_recent_sort)
			list_item_add(text_get("recent/sort_date_oldest"), e_recent_sort.DATE_OLDEST, "", null, null, null, action_recent_sort)
			list_item_add(text_get("recent/sort_name_az"), e_recent_sort.NAME_A_Z, "", null, null, null, action_recent_sort)
			list_item_add(text_get("recent/sort_name_za"), e_recent_sort.NAME_Z_A, "", null, null, null, action_recent_sort)
			
			break
		}
		
		// Accent color
		case "timeline/marker/color":
		{
			for (var i = 0; i <= 8; i++)
			{
				list_item_add(text_get("timeline/marker/color/" + string(i)), i, "", spr_16, null, null, null)
				list_item_last.thumbnail_blend = setting_theme.accent_list[i]
			}
			
			break
		}
		
		// Language
		case "settings/language":
		{
			with (obj_language)
				list_item_add(self.name, languages_directory + self.filename, self.locale, null, null, null, action_setting_language_load)
			
			break
		}
		
		// Render pass
		case "view/renderer/pass":
		{
			for (var i = 0; i < e_render_pass.amount; i++)
				list_item_add(text_get("view/renderer/pass/" + render_pass_list[|i]), i)
			
			break
		}
		
		// View camera
		case "view/camera/main":
		case "view/camera/second":
		{
			list_item_add(text_get("view/camera/work"), view_camera_work)
			
			var tlname = (timeline_camera = view_camera_work ? text_get("view/camera/work") : timeline_camera.display_name);
			
			list_item_add(text_get("view/camera/active", tlname), view_camera_active)
			//list_item_last.toggled = (settings_menu_view.camera = view_camera_active)
			
			with (obj_timeline)
				if (type = e_tl_type.CAMERA)
					list_item_add(display_name, id)
			
			break
		}
		
		// Select Minecraft world
		case "world_import/world":
		{
			world_import_world_menu_init()
			break
		}
		
		// Select Minecraft dimension
		case "world_import/dimension":
		{
			world_import_dimension_menu_init()
			break
		}
		
		// Interface scale
		case "settings/interface_scale":
		{
			menu_add_item(1, "100%")
			
			if (interface_scale_default_get() >= 2)
				menu_add_item(2, "200%")
			
			if (interface_scale_default_get() >= 3)
				menu_add_item(3, "300%")
			
			break
		}
		
		// Camera effect
		case "timeline_editor/effect":
		{
			for (var i = 0; i < e_cam_fx.amount; i++)
				if (setting_advanced_mode || i <= e_cam_fx.LENS_DIRT)
					menu_add_item(i, text_get("frame_editor/camera_effect/" + camera_effect_name_list[|i]))
			
			break
		}
		
		// Alpha mode
		case "render/alpha_mode":
		case "timeline_editor/alpha_mode":
		{
			if (name = "timeline_editor/alpha_mode")
				menu_add_item(e_alpha_mode.DEFAULT, text_get("render/alpha_mode/default"))
			
			menu_add_item(e_alpha_mode.HASHED, text_get("render/alpha_mode/hashed"))
			menu_add_item(e_alpha_mode.BLEND, text_get("render/alpha_mode/blend"))
			break
		}
		
		// AA mode
		case "render/aa_mode":
		{
			menu_add_item(e_aa_mode.PROGRESSIVE, text_get("render/aa_mode_progressive"))
			menu_add_item(e_aa_mode.FXAA, text_get("render/aa_mode_fxaa"))
			break
		}
		
		// Tone mapper
		case "render/tonemapper":
		{
			for (var i = 0; i < array_length(render_tonemapper_names); i++)
				menu_add_item(i, text_get("render/tonemapper/" + render_tonemapper_names[i]))
			
			break
		}
		
		// Armor pattern
		case "armor_editor/pattern_helmet":
		case "armor_editor/pattern_chestplate":
		case "armor_editor/pattern_leggings":
		case "armor_editor/pattern_boots":
		{
			menu_add_item("none", text_get("armor_editor/pattern/none"))
			
			for (var i = 0; i < ds_list_size(minecraft_armor_trim_pattern_list); i++)
				menu_add_item(minecraft_armor_trim_pattern_list[|i], text_get("armor_editor/pattern/" + minecraft_armor_trim_pattern_list[|i]))
			
			break
		}
		
		// Armor material
		case "armor_editor/material_helmet":
		case "armor_editor/material_chestplate":
		case "armor_editor/material_leggings":
		case "armor_editor/material_boots":
		{
			for (var i = 0; i < ds_list_size(minecraft_armor_trim_material_list); i++)
				menu_add_item(minecraft_armor_trim_material_list[|i], text_get("armor_editor/material/" + minecraft_armor_trim_material_list[|i]))
			
			break
		}
		
		// Background sky sun texture
		case "timeline_editor/glint/tex":
		{
			var itemglint = (tl_edit.glint_mode = e_glint.ITEM);
			
			// Default
			menu_add_item(project_pack_res, text_get("list/default", res_eval(project_pack_res).display_name), itemglint ? res_eval(project_pack_res).glint_item_texture : res_eval(project_pack_res).glint_armor_texture)
			
			// Add existing resources
			for (var i = 0; i < ds_list_size(res_list.display_list); i++)
			{
				var res = res_list.display_list[|i];
				if (res = res_eval(project_pack_res))
					continue
				
				if (res.glint_armor_texture || res.glint_item_texture)
					menu_add_item(res, res.display_name, itemglint ? res.glint_item_texture : res.glint_armor_texture)
				else if (res.texture)
					menu_add_item(res, res.display_name, res.texture)
			}
			
			break
		}
		
		// Transitions
		case "frame_editor/transition":
		{
			for (var i = 0; i < ds_list_size(transition_list_order); i++)
				menu_add_item(transition_list_order[|i], text_get("menu" + transition_list_order[|i]))
			
			break
		}
	}
	
	return list_init_end()
}
