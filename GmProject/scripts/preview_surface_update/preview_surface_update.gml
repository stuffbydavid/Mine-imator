/// @desc Updates the preview surface with 3D or 2D content.
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg is3d
/// @arg mouseon
/// @arg isplaying

function preview_surface_update(xx, yy, width, height, is3d, mouseon, isplaying)
{
	var setplaytime = null;
	
	if (select.object_index != obj_resource || select.type != e_res_type.SOUND)
		sound_play_button = false
	
	if (is3d)
		render_update_text()
	
	update = false
	
	surface_set_target(surface)
	{
		draw_clear_alpha(c_black, 0)
		gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha)
				
		if (is3d) // 3D view
		{
			var prevcamzoom, off, rep;
			prevcamzoom = 32
			off = point3D(0)
			
			// Repeat
			if (select.object_index = obj_template && select.block_repeat_enable)
				rep = select.block_repeat
			else
				rep = vec3(1)
			
			// Set z and zoom for camera
			if (select.object_index = obj_resource) // Resource
			{
				switch (select.type)
				{
					case e_res_type.MODEL:
					{
						if (select.model_format = e_model_format.BLOCK)
						{
							var displaysize = vec3(block_size);
							prevcamzoom = 32
							off = vec3_mul(displaysize, vec3(-0.5))
						}
						else if (select.model_file != null)
						{
							var displaysize = point3D_sub(select.model_file.bounds_parts_end, select.model_file.bounds_parts_start);
							prevcamzoom = max(displaysize[X], displaysize[Y], displaysize[Z]) + 16
							off = point3D_mul(point3D_add(select.model_file.bounds_parts_start, vec3_mul(displaysize, 0.5)), -1)
						}
						break
					}
							
					case e_res_type.SCHEMATIC:
					case e_res_type.FROM_WORLD:
					{
						var displaysize = vec3_mul(vec3_mul(select.scenery_size, rep), vec3(block_size));
						prevcamzoom = max(32, displaysize[X], displaysize[Y], displaysize[Z]) * 1.5
						off = vec3_mul(displaysize, vec3(-0.5))
						break
					}
				}
			}
			else // Template
			{
				switch (select.type)
				{
					case e_temp_type.MODEL:
					{
						if (select.model = null)
							break
								
						if (select.model.model_format = e_model_format.BLOCK)
						{
							var displaysize = vec3(block_size);
							prevcamzoom = 32
							off = vec3_mul(displaysize, vec3(-0.5))
							break
						}
					}
							
					case e_temp_type.CHARACTER:
					case e_temp_type.EQUIPMENT:
					case e_temp_type.SPECIAL_BLOCK:
					{
						if (select.model_file = null)
							break
								
						var displaysize = point3D_sub(select.model_file.bounds_parts_end, select.model_file.bounds_parts_start);
						prevcamzoom = max(displaysize[X], displaysize[Y], displaysize[Z]) + 16
						off = point3D_mul(point3D_add(select.model_file.bounds_parts_start, vec3_mul(displaysize, 0.5)), -1)
						break
					}
							
					case e_temp_type.ITEM:
					{
						prevcamzoom = 36
						off = point3D(-8, -0.5 * bool_to_float(select.item_3d), -8)
						break
					}
							
					case e_temp_type.BLOCK:
					{
						var displaysize = vec3_mul(rep, vec3(block_size));
						prevcamzoom = max(32, displaysize[X], displaysize[Y], displaysize[Z]) * 1.5
						off = vec3_mul(displaysize, vec3(-0.5))
						break
					}
							
					case e_temp_type.SCENERY:
					{
						if (select.scenery = null || !select.scenery.ready)
							break
						
						var displaysize = vec3_mul(vec3_mul(select.scenery.scenery_size, rep), vec3(block_size));
						prevcamzoom = max(32, displaysize[X], displaysize[Y], displaysize[Z]) * 1.5
						off = vec3_mul(displaysize, vec3(-0.5))
						break
					}
							
					case e_temp_type.MODEL_PART:
					{
						if (select.model_part = null)
							break
						
						var displaysize = point3D_sub(select.model_part.bounds_end, select.model_part.bounds_start);
						prevcamzoom = max(displaysize[X], displaysize[Y], displaysize[Z]) + 16
						off = point3D_mul(point3D_add(select.model_part.bounds_start, vec3_mul(displaysize, 0.5)), -1)
						break
					}
							
					case e_temp_type.PARTICLE_SPAWNER:
						prevcamzoom = 80
						break
							
					case e_temp_type.TEXT:
						prevcamzoom = 60
						break
				}
			}
					
			prevcamzoom /= zoom
					
			var projfromprev = proj_from;
					
			proj_from = point3D(
				lengthdir_x(prevcamzoom, xyangle) * lengthdir_x(1, zangle),
				lengthdir_y(prevcamzoom, xyangle) * lengthdir_x(1, zangle),
				lengthdir_z(prevcamzoom, zangle)
			)
			render_ratio = width / height
		
			gpu_set_ztestenable(true)
			camera_apply(cam_render)
			render_set_projection(proj_from, vec3(0, 0, 0), vec3(0, 0, 1), fov, render_ratio, 1, 32000)
			
			render_mode = e_render_mode.PREVIEW
			render_material_pass = true
			render_shader_obj = shader_map[?render_mode_shader_map[?render_mode]]
			with (render_shader_obj)
				shader_use()
			
			// Preview uniforms
			render_set_uniform_int(e_uniform.ALPHA_HASH, 0)
			render_set_uniform_color(e_uniform.BLEND_COLOR, shader_blend_color, shader_blend_alpha)
			render_set_uniform_vec2(e_uniform.TEXTURE_OFFSET, 0, 0)
			render_set_material_none()
			render_set_uniform(e_uniform.SSS, 0)
			render_set_uniform_vec3(e_uniform.SSS_RADIUS, 1, 1, 1)
			render_set_uniform_color(e_uniform.SSS_COLOR, c_white, 1)
			render_set_uniform_int(e_uniform.GLINT_ENABLED, 0)

			render_set_uniform_vec3(e_uniform.SUN_DIRECTION, 0.408, 0.408, 0.816)
			render_set_uniform_int(e_uniform.LIGHT_AMOUNT, 1)
			render_set_uniform(e_uniform.LIGHT_DATA, [ 0, 0, 0, 0, 1, 1, 1, 0 ])
			render_set_uniform_color(e_uniform.AMBIENT_COLOR, c_ambient, 1)
			render_set_uniform_color(e_uniform.FALLBACK_COLOR, c_white, 1)
						
			render_set_uniform_int(e_uniform.FOG_SHOW, 0)
			render_set_uniform_int(e_uniform.IS_SKY, 0)
			render_set_uniform_int(e_uniform.IS_GROUND, 0)
			render_set_uniform(e_uniform.WIND_ENABLE, 0)
			render_set_uniform(e_uniform.WIND_TERRAIN, 0)

			render_set_uniform_int(e_uniform.TONEMAPPER, 0)
			render_set_uniform(e_uniform.EXPOSURE, 1)
			render_set_uniform(e_uniform.GAMMA, 2.2)

			render_set_uniform_int(e_uniform.COLORS_EXT, 1)
			render_set_uniform_color(e_uniform.RGB_ADD, tl_value_default(e_value.RGB_ADD), 1)
			render_set_uniform_color(e_uniform.RGB_SUB, tl_value_default(e_value.RGB_SUB), 1)
			render_set_uniform_color(e_uniform.HSB_ADD, tl_value_default(e_value.HSB_ADD), 1)
			render_set_uniform_color(e_uniform.HSB_SUB, tl_value_default(e_value.HSB_SUB), 1)
			render_set_uniform_color(e_uniform.HSB_MUL, tl_value_default(e_value.HSB_MUL), 1)
			render_set_uniform_color(e_uniform.MIX_COLOR, tl_value_default(e_value.MIX_COLOR), tl_value_default(e_value.MIX_PERCENT))
					
			matrix_set(matrix_world, matrix_create(off, vec3(0), vec3(1)))
					
			if (select.object_index = obj_resource) // Resource
			{
				switch (select.type)
				{
					case e_res_type.SCHEMATIC:
					case e_res_type.FROM_WORLD:
						if (select.ready)
							render_world_block(select, mc_res, project_pack_res, project_pack_res)
						break
							
					case e_res_type.MODEL:
					{
						if (select.model_format = e_model_format.BLOCK)
						{
							render_world_block(select, mc_res, project_pack_res, project_pack_res)
							render_world_block_map(select.model_block_map, select)
						}
						else if (select.model_file != null)
						{
							var res = select;
							if (select.model_texture_map = null)
								res = mc_res
									
							var matmap = model_file_matrix_map_create(select.model_file, matrix_get(matrix_world), null);
							render_world_model_file_parts(select.model_file, res, select.model_texture_name_map, null, select.model_shape_vbuffer_map, select.model_color_map, select.model_shape_hide_list, select.model_shape_texture_name_map, matmap)
							ds_map_destroy(matmap)
						}
						break
					}
				}
			}
			else // Template
			{
				switch (select.type)
				{
					case e_temp_type.MODEL:
					{
						if (select.model = null)
							break
								
						if (select.model.model_format = e_model_format.BLOCK)
						{
							var res = res_eval(select.model_tex);
							if (res = null || res.block_sheet_texture[e_block_sheet.STATIC16] = null)
								res = mc_res
							
							render_world_block(select.model, res, project_pack_res, project_pack_res)
									
							with (select)
								res = temp_get_model_texobj(null)
							
							render_world_block_map(select.model.model_block_map, res)
							break
						}
					}
							
					case e_temp_type.CHARACTER:
					case e_temp_type.EQUIPMENT:
					case e_temp_type.SPECIAL_BLOCK:
					{
						if (select.model_file = null)
							break
								
						var res;
						with (select)
							res = temp_get_model_texobj(null)
								
						var matmap = model_file_matrix_map_create(select.model_file, matrix_get(matrix_world), select.model_hide_list);
						render_world_model_file_parts(select.model_file, res, select.model_texture_name_map, select.model_hide_list, select.model_shape_vbuffer_map, select.model_color_map, select.model_shape_hide_list, select.model_shape_texture_name_map, matmap)
						ds_map_destroy(matmap)
						break
					}
							
					case e_temp_type.SCENERY:
						if (select.scenery != null)
							render_world_scenery(select.scenery, select.block_tex, project_pack_res, project_pack_res, select.block_repeat_enable, select.block_repeat)
						break
							
					case e_temp_type.ITEM:
						render_world_item(select.item_vbuffer, select.item_tex, null, null, select.item_sheet, select.item_3d, select.item_face_camera, select.item_bounce, select.item_spin, true)
						break
							
					case e_temp_type.BLOCK:
						render_world_block(select, select.block_tex, project_pack_res, project_pack_res)
						break
							
					case e_temp_type.MODEL_PART:
					{
						if (select.model_part = null)
							break
								
						var res = res_eval(select.model_tex);
						matrix_set(matrix_world, matrix_multiply(matrix_get(matrix_world), select.model_part.matrix))
						render_world_model_part(select.model_part, res, select.model_texture_name_map, select.model_shape_vbuffer_map, select.model_color_map, select.model_shape_hide_list, select.model_shape_texture_name_map)
						break
					}
							
					case e_temp_type.TEXT:
						render_world_text(text_vbuffer, text_texture, select.text_face_camera, select.text_font, select.text_outline ? select.text_outline_color : null)
						break
							
					case e_temp_type.PARTICLE_SPAWNER:
					{
						for (var p = 0; p < ds_list_size(particle_list); p++)
							with (particle_list[|p])
								render_world_particle()
						break
					}
							
					case e_temp_type.CUBE: 
					case e_temp_type.CONE: 
					case e_temp_type.CYLINDER: 
					case e_temp_type.SPHERE: 
					case e_temp_type.SURFACE: // Shapes
					{
						var tex;
						with (select)
							tex = temp_get_shape_tex(temp_get_shape_texobj(null))
						render_world_shape(select.type, select.shape_vbuffer, select.shape_face_camera, [ tex, 0, 0 ])
						break
					}
				}
			}
					
			with (render_shader_obj)
				shader_clear()
					
			matrix_world_reset()
			gpu_set_ztestenable(false)
			camera_apply(cam_window)
					
			proj_from = projfromprev
		}
		else
		{
			var tex = null;
					
			switch (select.type)
			{
				case e_res_type.FONT:
				{
					if (select.type = e_temp_type.TEXT)
						draw_set_font(res_eval(select.text_font).font_preview)
					else
						draw_set_font(select.font_preview)
							
					var dx, dy, color, alpha;
					dx = width / 2 - xoff * zoom
					dy = height / 2 - yoff * zoom
					color = draw_get_color()
					alpha = draw_get_alpha()
					
					draw_set_color(c_text_main)
					draw_set_alpha(alpha * a_text_main)
					draw_set_halign(fa_center)
					draw_set_valign(fa_middle)
					draw_text_transformed(dx, dy, default_text, zoom, zoom, 0)
					draw_set_valign(fa_top)
					draw_set_halign(fa_left)
					draw_set_color(color)
					draw_set_alpha(alpha)
							
					draw_set_font(app.font_label)
					break
				}
						
				case e_res_type.SOUND:
				{
					sound_play_button = false
					if (!select.ready || !audio_is_ready(select.sound_index))
						break
							
					var wavex, wid, wavehei, prec, alpha, mouseperc;
					wavex = 32
					wid = width - 64
					wavehei = 32
					prec = sample_rate / sample_avg_per_sec
					alpha = draw_get_alpha()
					mouseperc = percent((mouse_x - xx), 32, 32 + wid)
							
					if (mouseon)
					{
						app.mouse_cursor = cr_handpoint
						update = true
					}
							
					draw_primitive_begin(pr_linelist)
					for (var dx = 0; dx < wid; dx++)
					{
						var ind, maxv, minv, length, wavecolor, wavealpha;
						ind = floor((dx / wid) * select.sound_samples) div prec
						maxv = select.sound_max_sample[ind]
						minv = select.sound_min_sample[ind]
						length = select.sound_samples / sample_rate
						wavecolor = c_text_secondary
						wavealpha = alpha * a_text_secondary
								
						if (isplaying)
						{
							// If wave is behind play progress, highlight
							if ((dx / wid) < (audio_sound_get_track_position(sound_play_index) / length))
							{
								wavecolor = c_accent
								wavealpha = alpha
							}
						}
								
						if (mouseon && setplaytime = null)
						{
							if ((dx / wid) < mouseperc)
								wavecolor = merge_color(wavecolor, c_level_middle, .25)
						}
								
						if (dx > 0 && dx mod 500 = 0) // GM bug
						{
							draw_primitive_end()
							draw_primitive_begin(pr_linelist)
						}
								
						// Set play time
						if (mouseon && app.mouse_left)
							setplaytime = (mouseperc * length)
								
						draw_vertex_color(wavex + dx, floor(height / 2 - maxv * wavehei), wavecolor, wavealpha)
						draw_vertex_color(wavex + dx, floor(height / 2 - minv * wavehei + 1), wavecolor, wavealpha)
					}
					draw_primitive_end()
					sound_play_button = true
							
					break
				}
						
				case e_res_type.PACK:
				{
					if (!select.ready)
						break
							
					switch (pack_image)
					{
						case "preview": tex = select.block_preview_texture; break
						
						case "model_textures":
						{
							if (pack_image_material = "diffuse")
								tex = select.model_texture_map[?pack_model_texture]
							else if (pack_image_material = "material")
								tex = select.model_texture_material_map[?pack_model_texture]
							else if (pack_image_material = "normal")
								tex = select.model_texture_normal_map[?pack_model_texture]
									
							break
						}
								
						case "block_sheet":
						{
							if (pack_image_material = "diffuse")
								tex = (pack_block_sheet_ani ? select.block_sheet_texture[e_block_sheet.ANIMATED][block_texture_get_frame(true)] : select.block_sheet_texture[pack_block_sheet_size])
							else if (pack_image_material = "material")
								tex = (pack_block_sheet_ani ? select.block_sheet_texture_material[e_block_sheet.ANIMATED][block_texture_get_frame(true)] : select.block_sheet_texture_material[pack_block_sheet_size])
							else if (pack_image_material = "normal")
								tex = (pack_block_sheet_ani ? select.block_sheet_texture_normal[e_block_sheet.ANIMATED][block_texture_get_frame(true)] : select.block_sheet_texture_normal[pack_block_sheet_size])
									
							break
						}
								
						case "color_map":
						{
							switch (pack_colormap)
							{
								case 0: tex = select.colormap_grass_texture; break
								case 1: tex = select.colormap_foliage_texture; break
								case 2: tex = select.colormap_dry_foliage_texture; break
							}
							break
						}
								
						case "item_sheet":
						{
							if (pack_image_material = "diffuse")
								tex = select.item_sheet_texture[pack_item_sheet_size]
							else if (pack_image_material = "material")
								tex = select.item_sheet_texture_material[pack_item_sheet_size]
							else if (pack_image_material = "normal")
								tex = select.item_sheet_texture_normal[pack_item_sheet_size]
							
							break
						}
								
						case "particle_sheet":	tex = select.particles_texture[pack_particles]; break
						case "sun_texture":		tex = select.sun_texture; break
						case "moon_texture":		tex = select.moon_textures[pack_moon_phase]; break
						case "cloud_texture":	tex = select.clouds_texture; break
					}
					
					break
				}
				
				case e_res_type.SKIN:
				case e_res_type.DOWNLOADED_SKIN: tex = select.model_texture; break
				case e_res_type.ITEM_SHEET:		 tex = select.item_sheet_texture[e_item_sheet.SIZE16]; break
				case e_res_type.BLOCK_SHEET:	 tex = select.block_sheet_texture[e_block_sheet.STATIC16]; break
				case e_res_type.TEXTURE:		 tex = select.texture; break
				case e_res_type.PARTICLE_SHEET:	 tex = select.particles_texture[0]; break
			}
					
			if (tex != null)
			{
				var padding, tw, th, tratio, ratio, dx, dy;
				padding = 16
				tw = texture_width(tex)
				th = texture_height(tex)
				tratio = tw / th
				ratio = width / height
				
				if (reset_view)
				{
					preview_reset_view()
							
					if (tratio > ratio)
						zoom = (max(width, height) - padding * 2) / max(tw, th)
					else
						zoom = (min(width, height) - padding * 2) / max(tw, th)
					
					goalzoom = zoom
					reset_view = false
				}
				
				dx = width / 2 - (tw / 2 + xoff) * zoom
				dy = height / 2 - (th / 2 + yoff) * zoom
				
				draw_texture(tex, dx, dy, zoom, zoom)
			}
			
			texture = tex
		}
		
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	
	return setplaytime
}
