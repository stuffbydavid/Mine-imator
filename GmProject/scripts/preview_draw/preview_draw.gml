/// preview_draw(preview, x, y, width, height)
/// @arg preview
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @desc Draws a preview window.

function preview_draw(preview, xx, yy, width, height)
{
	var is3d, mouseon, playbutton, isplaying, setplaytime;
	
	if (xx + width < content_x || xx > content_x + content_width || yy + height < content_y || yy > content_y + content_height)
		return 0
	
	mouseon = app_mouse_box(xx, yy, width, height)
	setplaytime = null
	
	// Background
	draw_box(xx, yy, width, height, false, c_level_bottom, 1)
	
	if (!instance_exists(preview.select))
	{
		preview.texture = null
		return 0
	}
	
	// Show 3D view?
	if (preview.select.object_index = obj_resource)
	{
		playbutton = (preview.select.type = e_res_type.SOUND)
		isplaying = (audio_is_playing(preview.sound_play_index) || audio_is_paused(preview.sound_play_index))
		is3d = (preview.select.type = e_res_type.SCENERY || preview.select.type = e_res_type.FROM_WORLD ||preview.select.type = e_res_type.MODEL)
	}
	else
	{
		playbutton = false
		isplaying = false
		is3d = true
	}
	
	if ((preview.select.type = e_temp_type.PARTICLE_SPAWNER && app_mouse_box(xx + width - 44, yy + height - 44, 36, 36)) ||
		(playbutton && app_mouse_box(xx + width - 44, yy + height - 44, 36, 36)))
		mouseon = false
	
	// Update audio hover
	if (playbutton && mouseon != preview.mouseon_prev)
		preview.update = true
	
	// Dragging controls
	if (mouseon && content_mouseon && !playbutton)
	{
		mouse_cursor = (!is3d ? cr_size_all : (!preview.xy_lock ? cr_size_all : cr_size_we))
		if (mouse_left_pressed)
		{
			window_busy = (is3d ? "previewrotate" : "previewmove")
			window_focus = string(preview)
			preview.clickxyangle = preview.xyangle
			preview.clickzangle = preview.zangle
			preview.clickxoff = preview.xoff
			preview.clickyoff = preview.yoff
		}
	}
	
	if (!mouseon && content_mouseon && mouse_left_pressed && window_focus = string(preview))
		window_focus = ""
	
	if (window_focus = string(preview))
	{
		var zd, m;
		if (window_busy = "previewrotate")
		{
			mouse_cursor = !preview.xy_lock ? cr_size_all : cr_size_we
			preview.xyangle = preview.clickxyangle + (mouse_click_x - mouse_x) * 0.75
			
			if (!preview.xy_lock)
			{
				preview.zangle = preview.clickzangle - (mouse_click_y - mouse_y)
				preview.zangle = clamp(preview.zangle, -89.9, 89.9)
			}
			
			preview.update = true
			if (!mouse_left)
			{
				window_busy = ""
				app_mouse_clear()
			}
		}
		if (window_busy = "previewmove")
		{
			mouse_cursor = cr_size_all
			preview.xoff = preview.clickxoff + (mouse_click_x - mouse_x) / preview.zoom
			preview.yoff = preview.clickyoff + (mouse_click_y - mouse_y) / preview.zoom
			preview.goalxoff = preview.xoff
			preview.goalyoff = preview.yoff
			preview.update = true
			if (!mouse_left)
			{
				window_busy = ""
				app_mouse_clear()
			}
		}
		
		m = (1 - 0.25 * mouse_wheel * !preview.xy_lock)
		if (m != 1)
		{
			preview.goalzoom = clamp(preview.goalzoom * m, 0.1, 100)
			preview.goalxoff = preview.xoff + (mouse_x - (xx + width / 2)) / preview.zoom - (mouse_x - (xx + width / 2)) / preview.goalzoom
			preview.goalyoff = preview.yoff + (mouse_y - (yy + height / 2)) / preview.zoom - (mouse_y - (yy + height / 2)) / preview.goalzoom
		}
		zd = (preview.goalzoom - preview.zoom) / max(1, 5 / delta)
		if (zd != 0)
		{
			preview.update = true
			preview.zoom += zd
			preview.xoff += (preview.goalxoff - preview.xoff) / max(1, 5 / delta)
			preview.yoff += (preview.goalyoff - preview.yoff) / max(1, 5 / delta)
		}
		
		window_scroll_focus = string(preview)
		window_scroll_focus_prev = string(preview)
	}
	
	// Render
	with (preview)
	{
		// Size change
		if (!surface_exists(surface) || surface_get_width(surface) < 0 || surface_get_width(surface) != width || surface_get_height(surface) != height)
			update = true
		
		// Particles
		if (select.type = e_temp_type.PARTICLE_SPAWNER)
			update = true
		
		// Item animation
		if (select.object_index = obj_template && select.type = e_temp_type.ITEM && (select.item_bounce || select.item_spin))
			update = true
		
		// Playing audio
		if (isplaying)
			update = true
		
		// Animated block sheet
		if (select.type = e_res_type.PACK && pack_image = "blocksheet" && pack_block_sheet_ani)
			update = true
		
		surface = surface_require(surface, width, height)
		
		if (update)
		{
			if (is3d)
				render_update_text()
			update = false
			
			surface_set_target(surface)
			{
				draw_clear_alpha(c_black, 0)
				gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
				
				if (is3d) // 3D view
				{
					var prevcam_zoom, rep, off;
					prevcam_zoom = 32
					off = point3D(0, 0, 0)
					
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
									prevcam_zoom = 32
									off = vec3_mul(displaysize, vec3(-0.5))
								}
								else if (select.model_file != null)
								{
									var displaysize = point3D_sub(select.model_file.bounds_parts_end, select.model_file.bounds_parts_start);
									prevcam_zoom = max(displaysize[X], displaysize[Y], displaysize[Z]) + 16
									off = point3D_mul(point3D_add(select.model_file.bounds_parts_start, vec3_mul(displaysize, 0.5)), -1)
								}
								break
							}
							
							case e_res_type.SCENERY:
							case e_res_type.FROM_WORLD:
							{
								var displaysize = vec3_mul(vec3_mul(select.scenery_size, rep), vec3(block_size));
								prevcam_zoom = max(32, displaysize[X], displaysize[Y], displaysize[Z]) * 1.5
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
									prevcam_zoom = 32
									off = vec3_mul(displaysize, vec3(-0.5))
									break
								}
							}
							
							case e_temp_type.CHARACTER:
							case e_temp_type.SPECIAL_BLOCK:
							{
								if (select.model_file = null)
									break
								
								var displaysize = point3D_sub(select.model_file.bounds_parts_end, select.model_file.bounds_parts_start);
								prevcam_zoom = max(displaysize[X], displaysize[Y], displaysize[Z]) + 16
								off = point3D_mul(point3D_add(select.model_file.bounds_parts_start, vec3_mul(displaysize, 0.5)), -1)
								break
							}
							
							case e_temp_type.ITEM:
								off = point3D(-8, -0.5 * bool_to_float(select.item_3d), -8)
								break
							
							case e_temp_type.BLOCK:
							{
								var displaysize = vec3_mul(rep, vec3(block_size));
								prevcam_zoom = max(32, displaysize[X], displaysize[Y], displaysize[Z]) * 1.5
								off = vec3_mul(displaysize, vec3(-0.5))
								break
							}
							
							case e_temp_type.SCENERY:
							{
								if (select.scenery = null || !select.scenery.ready)
									break
								
								var displaysize = vec3_mul(vec3_mul(select.scenery.scenery_size, rep), vec3(block_size));
								prevcam_zoom = max(32, displaysize[X], displaysize[Y], displaysize[Z]) * 1.5
								off = vec3_mul(displaysize, vec3(-0.5))
								break
							}
							
							case e_temp_type.BODYPART:
							{
								if (select.model_part = null)
									break
								
								var displaysize = point3D_sub(select.model_part.bounds_end, select.model_part.bounds_start);
								prevcam_zoom = max(displaysize[X], displaysize[Y], displaysize[Z]) + 16
								off = point3D_mul(point3D_add(select.model_part.bounds_start, vec3_mul(displaysize, 0.5)), -1)
								break
							}
							
							case e_temp_type.PARTICLE_SPAWNER:
								prevcam_zoom = 80
								break
							
							case e_temp_type.TEXT:
								prevcam_zoom = 60
								break
						}
					}
					
					prevcam_zoom /= zoom
					
					var projfromprev = proj_from;
					
					proj_from = point3D(
						lengthdir_x(prevcam_zoom, xyangle) * lengthdir_x(1, zangle),
						lengthdir_y(prevcam_zoom, xyangle) * lengthdir_x(1, zangle),
						lengthdir_z(prevcam_zoom, zangle)
					)
					render_ratio = width / height
					
					gpu_set_ztestenable(true)
					camera_apply(cam_render)
					render_set_projection(proj_from, vec3(0, 0, 0), vec3(0, 0, 1), preview.fov, render_ratio, 1, 32000)
					
					render_mode = e_render_mode.PREVIEW
					render_shader_obj = shader_map[?render_mode_shader_map[?render_mode]]
					with (render_shader_obj)
						shader_use()
					
					// No fog in preview
					render_set_uniform_int("uFogShow", 0)
					
					// Set defaults
					render_set_uniform_int("uColorsExt", 1)
					render_set_uniform_color("uRGBAdd", tl_value_default(e_value.RGB_ADD), 1)
					render_set_uniform_color("uRGBSub", tl_value_default(e_value.RGB_SUB), 1)
					render_set_uniform_color("uHSBAdd", tl_value_default(e_value.HSB_ADD), 1)
					render_set_uniform_color("uHSBSub", tl_value_default(e_value.HSB_SUB), 1)
					render_set_uniform_color("uHSBMul", tl_value_default(e_value.HSB_MUL), 1)
					render_set_uniform_color("uMixColor", tl_value_default(e_value.MIX_COLOR), tl_value_default(e_value.MIX_PERCENT))
					
					matrix_set(matrix_world, matrix_create(off, vec3(0), vec3(1)))
					
					if (select.object_index = obj_resource) // Resource
					{
						switch (select.type)
						{
							case e_res_type.SCENERY:
							case e_res_type.FROM_WORLD:
								if (select.ready)
									render_world_block(select.block_vbuffer, mc_res, true, select.scenery_size)
								break
							
							case e_res_type.MODEL:
							{
								if (select.model_format = e_model_format.BLOCK)
								{
									render_world_block(select.block_vbuffer, mc_res)
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
									var res;
									if (select.model_tex != null && select.model_tex.block_sheet_texture != null)
										res = select.model_tex
									else
										res = mc_res
									render_world_block(select.model.block_vbuffer, res)
									
									with (select)
										res = temp_get_model_texobj(null)
									render_world_block_map(select.model.model_block_map, res)
									break
								}
							}
							
							case e_temp_type.CHARACTER:
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
									render_world_scenery(select.scenery, select.block_tex, select.block_repeat_enable, select.block_repeat)
								break
							
							case e_temp_type.ITEM:
								render_world_item(select.item_vbuffer, select.item_3d, select.item_face_camera, select.item_bounce, select.item_spin, [select.item_tex, null, null])
								break
							
							case e_temp_type.BLOCK:
								render_world_block(select.block_vbuffer, select.block_tex, true, rep)
								break
							
							case e_temp_type.BODYPART:
							{
								if (select.model_part = null)
									break
								
								var res = select.model_tex;
								if (!res_is_ready(res))
									res = mc_res
								
								matrix_set(matrix_world, matrix_multiply(matrix_get(matrix_world), select.model_part.matrix))
								render_world_model_part(select.model_part, res, select.model_texture_name_map, select.model_shape_vbuffer_map, select.model_color_map, select.model_shape_hide_list, select.model_shape_texture_name_map, null)
								break
							}
							
							case e_temp_type.TEXT:
								render_world_text(text_vbuffer, text_texture, select.text_face_camera, select.text_font, null)
								break
							
							case e_temp_type.PARTICLE_SPAWNER:
							{
								for (var p = 0; p < ds_list_size(particle_list); p++)
									with (particle_list[|p])
										render_world_particle()
								break
							}
							
							case e_tl_type.SHAPE:
							case e_temp_type.CUBE: 
							case e_temp_type.CONE: 
							case e_temp_type.CYLINDER: 
							case e_temp_type.SPHERE: 
							case e_temp_type.SURFACE: // Shapes
							{
								var tex;
								with (select)
									tex = temp_get_shape_tex(temp_get_shape_texobj(null))
								render_world_shape(select.type, select.shape_vbuffer, select.shape_face_camera, [tex, spr_default_material, spr_default_normal])
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
								draw_set_font(select.text_font.font_preview)
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
							draw_text_transformed(dx, dy, "AaBbCc", zoom, zoom, 0)
							draw_set_valign(fa_top)
							draw_set_halign(fa_left)
							draw_set_color(color)
							draw_set_alpha(alpha)
							
							draw_set_font(app.font_label)
							break
						}
						
						case e_res_type.SOUND:
						{
							if (!select.ready)
								break
							
							var wid, wavehei, prec, alpha, mouseperc;
							wid = width - 32
							wavehei = 32
							prec = sample_rate / sample_avg_per_sec
							alpha = draw_get_alpha()
							mouseperc = percent((mouse_x - xx), 16, 16 + wid);
							
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
								
								draw_vertex_color(16 + dx, height / 2-maxv * wavehei, wavecolor, wavealpha)
								draw_vertex_color(16 + dx, height / 2-minv * wavehei + 1, wavecolor, wavealpha)
							}
							draw_primitive_end()
							
							break
						}
						
						case e_res_type.PACK:
						{
							if (!select.ready)
								break
							
							switch (pack_image)
							{
								case "preview":
									tex = select.block_preview_texture
									break
								
								case "modeltextures":
								{
									if (pack_image_material = "diffuse")
										tex = select.model_texture_map[?pack_model_texture]
									else if (pack_image_material = "material")
										tex = select.model_texture_material_map[?pack_model_texture]
									else if (pack_image_material = "normal")
										tex = select.model_tex_normal_map[?pack_model_texture]
									
									break
								}
								
								case "blocksheet":
								{
									if (pack_image_material = "diffuse")
										tex = (pack_block_sheet_ani ? select.block_sheet_ani_texture[block_texture_get_frame(true)] : select.block_sheet_texture)
									else if (pack_image_material = "material")
										tex = (pack_block_sheet_ani ? select.block_sheet_ani_texture_material[block_texture_get_frame(true)] : select.block_sheet_texture_material)
									else if (pack_image_material = "normal")
										tex = (pack_block_sheet_ani ? select.block_sheet_ani_tex_normal[block_texture_get_frame(true)] : select.block_sheet_tex_normal)
									
									break
								}
								
								case "colormap":
								{
									switch (pack_colormap)
									{
										case 0:
											tex = select.colormap_grass_texture
											break
										case 1:
											tex = select.colormap_foliage_texture
											break
										case 2:
											tex = select.colormap_dry_foliage_texture
											break
									}
									break
								}
								
								case "itemsheet":
								{
									if (pack_image_material = "diffuse")
										tex = select.item_sheet_texture
									else if (pack_image_material = "material")
										tex = select.item_sheet_texture_material
									else if (pack_image_material = "normal")
										tex = select.item_sheet_tex_normal
									
									break
								}
								
								case "particlesheet":
									tex = select.particles_texture[pack_particles]
									break
								
								case "suntexture":
									tex = select.sun_texture
									break
								
								case "moontexture":
									//tex = select.moonphases_texture
									tex = select.moon_textures[pack_moon_phase]
									break
								
								case "cloudtexture":
									tex = select.clouds_texture
									break
							} 
							break
						}
						
						case e_res_type.SKIN:
						case e_res_type.DOWNLOADED_SKIN:
							tex = select.model_texture
							break
						
						case e_res_type.ITEM_SHEET:
							tex = select.item_sheet_texture
							break
						
						case e_res_type.BLOCK_SHEET:
							tex = select.block_sheet_texture
							break
						
						case e_res_type.TEXTURE:
							tex = select.texture
							break
						
						case e_res_type.PARTICLE_SHEET:
							tex = select.particles_texture[0]
							break
					}
					
					if (tex != null)
					{
						var padding, tw, th, dx, dy;
						padding = 16
						tw = texture_width(tex)
						th = texture_height(tex)
						if (reset_view)
						{
							preview_reset_view()
							
							zoom = (min(width, height) - padding * 2) / min(tw, th)
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
		}
		
		draw_surface_exists(surface, xx, yy)
	}
	
	// Button background
	if ((preview.select.object_index != obj_resource && preview.select.type = e_temp_type.PARTICLE_SPAWNER) || playbutton)
	{
		draw_box(xx + width - 40, yy + height - 40, 32, 32, false, c_level_middle, 1)
		draw_outline(xx + width - 40, yy + height - 40, 32, 32, 1, c_border, a_border, true)
	}
	
	// Particle button
	if (preview.select.object_index != obj_resource && preview.select.type = e_temp_type.PARTICLE_SPAWNER)
	{
		if (preview.select.pc_spawn_constant)
		{
			if (draw_button_icon("previewspawn", xx + width - 36, yy + height - 36, 24, 24, preview.spawn_active, icons.PARTICLES, null, false, "tooltipparticlesspawn"))
				preview.spawn_active = !preview.spawn_active
		}
		else
		{
			if (draw_button_icon("previewspawn", xx + width - 36, yy + height - 36, 24, 24, false, icons.PARTICLES, null, false, "tooltipparticlesspawn"))
				preview.fire = true
		}
	}
	
	// Play button
	if (playbutton)
	{
		if (draw_button_icon("previewplay", xx + width - 36, yy + height - 36, 24, 24, false, isplaying ? icons.STOP : icons.PLAY, null, false, isplaying ? "tooltipstop" : "tooltipplay"))
		{
			if (isplaying)
			{
				audio_stop_sound(preview.sound_play_index)
				preview.update = true
			}
			else
				preview.sound_play_index = audio_play_sound(res_edit.sound_index, 0, false)
		}
	}
	
	// Updating audio
	if (setplaytime != null && mouse_left_pressed)
	{
		// Audio isn't already playing, start it
		if (!isplaying)
			preview.sound_play_index = audio_play_sound(res_edit.sound_index, 0, false)
			
		audio_sound_set_track_position(preview.sound_play_index, setplaytime)
	}
	
	if (preview.sound_playing != isplaying)
		preview.update = true
	
	preview.sound_playing = isplaying
	preview.mouseon_prev = mouseon
	
	// Outline and hover
	microani_set(string(preview), "", mouseon, mouseon && mouse_left, (window_focus = string(preview)) || (mouseon && mouse_left))
	draw_outline(xx, yy, width, height, 1, c_accent, microani_arr[e_microani.ACTIVE], true)
	draw_box_hover(xx, yy, width, height, microani_arr[e_microani.HOVER])
	microani_update(mouseon, mouseon && mouse_left, (window_focus = string(preview)) || (mouseon && mouse_left))
}
