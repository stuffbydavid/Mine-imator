/// preview_draw(preview, x, y, size)
/// @arg preview
/// @arg x
/// @arg y
/// @arg size
/// @desc Draws a preview window.

var preview, xx, yy, size;
var is3d, mouseon, butw, playbutton, isplaying, exportbutton;
preview = argument0
xx = argument1
yy = argument2
size = argument3

if (xx + size < content_x || xx > content_x + content_width || yy + size < content_y || yy > content_y + content_height)
	return 0

mouseon = app_mouse_box(xx, yy, size, size)
butw = text_max_width("previewspawn") + 20

// Background
draw_box(xx, yy, size, size, false, setting_color_background, 1)

if (!instance_exists(preview.select))
{
	preview.texture = null
	return 0
}

// Show 3D view?
if (preview.select.object_index = obj_resource)
{
	playbutton = (preview.select.type = e_res_type.SOUND)
	isplaying = audio_is_playing(preview.sound_play_index)
	exportbutton = true
	is3d = (preview.select.type = e_res_type.SCHEMATIC || preview.select.type = e_res_type.MODEL)
}
else
{
	playbutton = false
	exportbutton = false
	is3d = true
}

if ((preview.select.type = e_temp_type.PARTICLE_SPAWNER && app_mouse_box(xx + size - butw, yy + size - 24, butw, 24)) ||
	(playbutton && app_mouse_box(xx + size - 48, yy + size - 24, 24, 24)) ||
	(exportbutton && app_mouse_box(xx + size - 24, yy + size - 24, 24, 24)))
	mouseon = false

// Dragging controls
if (mouseon && content_mouseon)
{
	mouse_cursor = cr_size_all
	if (mouse_left_pressed)
	{
		window_busy = test(is3d, "previewrotate", "previewmove")
		window_focus = string(preview)
		preview.clickxyangle = preview.xyangle
		preview.clickzangle = preview.zangle
		preview.clickxoff = preview.xoff
		preview.clickyoff = preview.yoff
	}
}

if (window_focus = string(preview))
{
	var zd, m;
	if (window_busy = "previewrotate")
	{
		mouse_cursor = cr_size_all
		preview.xyangle = preview.clickxyangle + (mouse_click_x - mouse_x) * 0.75
		preview.zangle = preview.clickzangle - (mouse_click_y - mouse_y)
		preview.zangle = clamp(preview.zangle, -89.9, 89.9)
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
	
	m = (1 - 0.25 * mouse_wheel)
	if (m != 1)
	{
		preview.goalzoom = clamp(preview.goalzoom * m, 0.1, 100)
		preview.goalxoff = preview.xoff + (mouse_x - (xx + size / 2)) / preview.zoom - (mouse_x - (xx + size / 2)) / preview.goalzoom
		preview.goalyoff = preview.yoff + (mouse_y - (yy + size / 2)) / preview.zoom - (mouse_y - (yy + size / 2)) / preview.goalzoom
	}
	zd = (preview.goalzoom - preview.zoom) / max(1, 5 / delta)
	if (zd != 0)
	{
		preview.update = true
		preview.zoom += zd
		preview.xoff += (preview.goalxoff - preview.xoff) / max(1, 5 / delta)
		preview.yoff += (preview.goalyoff - preview.yoff) / max(1, 5 / delta)
	}
}

// Render
with (preview)
{
	if (!surface_exists(surface) || surface_get_width(surface) < 0 ||
		select.type = e_temp_type.PARTICLE_SPAWNER ||
		(select.object_index != obj_resource && select.type = e_temp_type.ITEM && select.item_bounce))
		update = true

	surface = surface_require(surface, size, size)

	if (update) 
	{
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
						case e_res_type.SCHEMATIC:
						{
							var displaysize = vec3_mul(vec3_mul(select.scenery_size, rep), vec3(block_size));
							prevcam_zoom = max(32, displaysize[X], displaysize[Y], displaysize[Z]) * 1.5
							off = vec3_mul(displaysize, vec3(-0.5))
							break
						}
						
						case e_res_type.MODEL:
						{
							if (select.model_file = null)
								break
						
							var displaysize = point3D_sub(select.model_file.bounds_parts_end, select.model_file.bounds_parts_start);
							prevcam_zoom = max(displaysize[X], displaysize[Y], displaysize[Z]) + 16
							off = point3D_mul(point3D_add(select.model_file.bounds_parts_start, vec3_mul(displaysize, 0.5)), -1)
							break
						}
					}
				}
				else // Template
				{
					switch (select.type)
					{
						case e_temp_type.CHARACTER:
						case e_temp_type.SPECIAL_BLOCK:
						case e_temp_type.MODEL:
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
			
				proj_from = point3D(
					lengthdir_x(prevcam_zoom, xyangle) * lengthdir_x(1, zangle),
					lengthdir_y(prevcam_zoom, xyangle) * lengthdir_x(1, zangle),
					lengthdir_z(prevcam_zoom, zangle)
				)
			
				render_update_text()
				
				gpu_set_ztestenable(true)
				gpu_set_zwriteenable(true)
				camera_apply(cam_render)
				render_set_projection(proj_from, vec3(0, 0, 0), vec3(0, 0, 1), 60, 1, 1, 32000)
				
				render_mode = e_render_mode.PREVIEW
				render_shader_obj = shader_map[?render_mode_shader_map[?render_mode]]
				with (render_shader_obj)
					shader_use()
	
				matrix_set(matrix_world, matrix_create(off, vec3(0), vec3(1)))
			
				if (select.object_index = obj_resource) // Resource
				{
					switch (select.type)
					{
						case e_res_type.SCHEMATIC:
							if (select.ready)
								render_world_block(select.block_vbuffer, select.scenery_size, mc_res)
							break
							
						case e_res_type.MODEL:
						{
							if (select.model_file = null)
								break
						
							render_world_model_file_parts(select.model_file, mc_res, select.model_texture_name_map, null, select.model_plane_vbuffer_map)
							break
						}
					}
				}
				else // Template
				{
					switch (select.type)
					{
						case e_temp_type.CHARACTER:
						case e_temp_type.SPECIAL_BLOCK:
						case e_temp_type.MODEL:
						{
							if (select.model_file = null)
								break
						
							var res = select.model_tex;
							if (res = null)
								res = select.model
							
							if (!res.ready || (res.model_texture = null && res.model_texture_map = null))
								res = mc_res
						
							render_world_model_file_parts(select.model_file, res, select.model_texture_name_map, select.model_hide_list, select.model_plane_vbuffer_map)
							break
						}
					
						case e_temp_type.SCENERY:
							if (select.scenery != null)
								render_world_scenery(select.scenery, select.block_tex, select.block_repeat_enable, select.block_repeat)
							break
					
						case e_temp_type.ITEM:
							render_world_item(select.item_vbuffer, select.item_3d, select.item_face_camera, select.item_bounce, select.item_tex)
							break
					
						case e_temp_type.BLOCK:
							render_world_block(select.block_vbuffer, rep, select.block_tex)
							break
					
						case e_temp_type.BODYPART:
						{
							if (select.model_part = null)
								break
						
							var res = select.model_tex;
							if (!res.ready)
								res = mc_res
						
							matrix_set(matrix_world, matrix_multiply(matrix_get(matrix_world), select.model_part.matrix))
							render_world_model_part(select.model_part, res, select.model_texture_name_map, 0, null, select.model_plane_vbuffer_map)
							break
						}
					
						case e_temp_type.TEXT:
							render_world_text(text_vbuffer, text_texture, select.text_face_camera, select.text_font)
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
							render_world_shape(select.type, select.shape_vbuffer, select.shape_face_camera, tex)
							break
						}
					}
				}
			
				with (render_shader_obj)
					shader_clear()
				
				matrix_world_reset()
				gpu_set_ztestenable(false)
				gpu_set_zwriteenable(true)
				camera_apply(cam_window)
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
						
						var dx, dy, color;
						dx = size / 2 - xoff * zoom
						dy = size / 2 - yoff * zoom
						color = draw_get_color()
						draw_set_color(c_white)
						draw_set_halign(fa_center)
						draw_set_valign(fa_middle)
						draw_text_transformed(dx, dy, "AaBbCc", zoom, zoom, 0)
						draw_set_valign(fa_top)
						draw_set_halign(fa_left)
						draw_set_color(color)
						draw_set_font(app.setting_font)
						break
					}
				
					case e_res_type.SOUND:
					{
						if (!select.ready)
							break
						
						var wid, wavehei, prec, alpha;
						wid = size - 20
						wavehei = 32
						prec = sample_rate / sample_avg_per_sec
						alpha = draw_get_alpha()
						draw_primitive_begin(pr_linelist)
						for (var dx = 0; dx < wid; dx++)
						{
							var ind, maxv, minv;
							ind = floor((dx / wid) * select.sound_samples) div prec
							maxv = select.sound_max_sample[ind]
							minv = select.sound_min_sample[ind]
							draw_vertex_color(10 + dx, size / 2-maxv * wavehei, app.setting_color_buttons, alpha)
							draw_vertex_color(10 + dx, size / 2-minv * wavehei + 1, app.setting_color_buttons, alpha)
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
								tex = select.model_texture_map[?pack_model_texture]
								break
						
							case "blocksheet":
								tex = test(pack_block_sheet_ani, select.block_sheet_ani_texture[block_texture_get_frame()], select.block_sheet_texture)
								break
						
							case "colormap":
								tex = test(pack_colormap, select.colormap_foliage_texture, select.colormap_grass_texture)
								break
						
							case "itemsheet":
								tex = select.item_sheet_texture
								break
						
							case "particlesheet":
								tex = select.particles_texture[pack_particles]
								break
						
							case "suntexture":
								tex = select.sun_texture
								break
							
							case "moontexture":
								tex = select.moonphases_texture
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
						
						zoom = (size - padding * 2) / max(tw, th)
						goalzoom = zoom
						reset_view = false
					}
					dx = size / 2 - (tw / 2 + xoff) * zoom
					dy = size / 2 - (th / 2 + yoff) * zoom
					draw_texture(tex, dx, dy, zoom, zoom)
				}
			
				texture = tex
			}
			gpu_set_blendmode(bm_normal)
		}
		surface_reset_target()
	
		update = false
	}

	draw_surface_exists(surface, xx, yy)
}

// Particle button
if (preview.select.object_index != obj_resource && preview.select.type = e_temp_type.PARTICLE_SPAWNER)
{
	if (preview.select.pc_spawn_constant)
	{
		if (draw_button_normal("previewspawn", xx + size - butw, yy + size - 24, butw, 24, e_button.TEXT, preview.spawn_active, true, true))
			preview.spawn_active = !preview.spawn_active
	}
	else
	{
		if (draw_button_normal("previewspawn", xx + size - butw, yy + size - 24, butw, 24))
			preview.fire = true
	}
}
		
// Play button
if (playbutton)
{
	if (draw_button_normal(test(isplaying, "previewstop", "previewplay"), xx + size - 50, yy + size - 24, 24, 24, e_button.NO_TEXT, false, true, true, test(isplaying, icons.STOP, icons.PLAY)))
	{
		if (isplaying)
			audio_stop_sound(preview.sound_play_index)
		else
			preview.sound_play_index = audio_play_sound(res_edit.sound_index, 0, false)
	}
}
		
// Save button
if (exportbutton)
	if (draw_button_normal("previewexport", xx + size - 24, yy + size - 24, 24, 24, e_button.NO_TEXT, false, true, true, icons.EXPORT))
		action_res_export()
