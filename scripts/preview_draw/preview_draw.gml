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
	preview.last_tex = null
	return 0
}

// Show 3D view?
if (preview.select.object_index = obj_resource)
{
	playbutton = (preview.select.type = "sound")
	isplaying = audio_is_playing(preview.sound_play_index)
	exportbutton = true
	is3d = (preview.select.type = "schematic")
}
else
{
	playbutton = false
	exportbutton = false
	is3d = true
}

if ((preview.select.type = "particles" && app_mouse_box(xx + size - butw, yy + size - 24, butw, 24)) ||
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

if (!surface_exists(preview.surface) || surface_get_width(preview.surface) < 0 ||
	preview.select.type = "particles" || (preview.select.type = "item" && preview.select.item_bounce))
	preview.update = true

preview.surface = surface_require(preview.surface, size, size)

if (preview.update) 
{
	surface_set_target(preview.surface)
	{
		draw_clear_alpha(c_black, 0)
		gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
		
		if (is3d) // 3D view
		{
			var prevcam_z, prevcam_zoom, rep;
			var model, bodypart, sch;
			prevcam_z = 0
			prevcam_zoom = 32
			
			matrix_reset_offset()
			
			// Repeat
			if (preview.select.object_index = obj_template && preview.select.block_repeat_enable)
				rep = preview.select.block_repeat
			else
				rep = vec3(1)
			
			// Set z and zoom for camera
			switch (preview.select.type)
			{
				case "char":
				case "spblock":
					model = preview.select.char_model
					var displaysize = point3D_sub(model.bounds_end, model.bounds_start);
					prevcam_z = displaysize[Z] / 2
					prevcam_zoom = max(displaysize[X], displaysize[Y], displaysize[Z]) + 16
					break
					
				case "item":
					matrix_offset = point3D(-8, -0.5 * bool_to_float(preview.select.item_3d), -8)
					break
					
				case "block":
					var displaysize = vec3_mul(rep, vec3(block_size));
					prevcam_zoom = max(32, displaysize[X], displaysize[Y], displaysize[Z]) * 1.5
					matrix_offset = vec3_mul(displaysize, vec3(-1 / 2))
					break
					
				case "scenery":
				case "schematic":
					if (preview.select.type = "schematic")
						sch = preview.select
					else
						sch = preview.select.scenery
						
					if (sch && !sch.ready)
						sch = null
						
					if (!sch)
						break
						
					var displaysize = vec3_mul(vec3_mul(sch.scenery_size, rep), point3D(block_size, block_size, block_size));
					prevcam_zoom = max(32, displaysize[X], displaysize[Y], displaysize[Z]) * 1.5
					matrix_offset = vec3_mul(displaysize, vec3(-0.5))
					break
					
				case "bodypart":
					model = preview.select.char_model
					bodypart = preview.select.char_bodypart
					prevcam_zoom = 48
					break
					
				case "particles":
					prevcam_zoom = 80
					break
					
				case "text":
					prevcam_zoom = 60
					break
			}
			
			prevcam_zoom /= preview.zoom
			
			proj_from = point3D(
				lengthdir_x(prevcam_zoom, preview.xyangle) * lengthdir_x(1, preview.zangle),
				lengthdir_y(prevcam_zoom, preview.xyangle) * lengthdir_x(1, preview.zangle),
				prevcam_z + lengthdir_z(prevcam_zoom, preview.zangle)
			)
			
			render_update_text()
			
			gpu_set_ztestenable(true)
			gpu_set_zwriteenable(true)
			camera_apply(cam_render)
			render_set_projection(proj_from, vec3(0, 0, prevcam_z), vec3(0, 0, 1), 60, 1, 1, 32000)
			render_mode = "preview"
			
			switch (preview.select.type)
			{
				case "char":
				case "spblock":
					var res = preview.select.char_skin;
					if (!res.ready)
						res = res_def
						
					render_world_model_parts(model, res)
					break
					
				case "scenery":
				case "schematic":
					if (!sch)
						break
					
					if (preview.select.type = "scenery")
						render_world_scenery(sch, preview.select.block_tex, preview.select.block_repeat_enable, preview.select.block_repeat)
					else
						render_world_block(sch.block_vbuffer, res_def)
					
					break
					
				case "item":
					render_world_item(preview.select.item_vbuffer, preview.select.item_bounce, preview.select.item_face_camera, preview.select.item_tex)
					break
					
				case "block":
					render_world_block(preview.select.block_vbuffer, preview.select.block_tex)
					break
					
				case "bodypart":
					/*var res;
					
					if (!char.part_vbuffer[bodypart])
						break
						
					res = preview.select.char_skin
					if (!res.ready)
						res = res_def
					
					shader_texture = res.mob_texture[char.index]
					shader_use()
					vbuffer_render(char.part_vbuffer[bodypart])
					if (char.part_hasbend[bodypart])
					{ // Draw bend half
						matrix_set(matrix_world, tl_bend_matrix(0, char, bodypart))
						vbuffer_render(char.part_bendvbuffer[bodypart])
					}*/
					break
					
				case "text":
					render_world_text(preview.text_vbuffer, preview.text_texture, preview.select.text_face_camera, preview.select.text_font)
					break
					
				case "particles":
					for (var p = 0; p < ds_list_size(preview.particles); p++)
						with (preview.particles[|p])
							particle_draw()
					break
					
				default: // Shapes
					var tex;
					with (preview.select)
						tex = temp_get_shape_tex(temp_get_shape_texobj(null))
					render_world_shape(preview.select.type, preview.select.shape_vbuffer, preview.select.shape_face_camera, tex)
					break
			}
			
			matrix_world_reset()
			shader_clear()
			gpu_set_ztestenable(false)
			gpu_set_zwriteenable(true)
			camera_apply(cam_window)
		}
		else
		{
			var tex = null;
			
			switch (preview.select.type)
			{
				case "font":
				{
					if (preview.select.type = "text")
						draw_set_font(preview.select.text_font.font_preview)
					else
						draw_set_font(preview.select.font_preview)
						
					var dx, dy;
					dx = size / 2-preview.xoff * preview.zoom
					dy = size / 2-preview.yoff * preview.zoom
					draw_set_halign(fa_center)
					draw_set_valign(fa_middle)
					draw_text_transformed(dx, dy, "AaBbCc", preview.zoom, preview.zoom, 0)
					draw_set_valign(fa_top)
					draw_set_halign(fa_left)
					draw_set_font(setting_font)
					break
				}
				
				case "sound":
				{
					if (!preview.select.ready)
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
						ind = floor((dx / wid) * preview.select.sound_samples) div prec
						maxv = preview.select.sound_max_sample[ind]
						minv = preview.select.sound_min_sample[ind]
						draw_vertex_color(10 + dx, size / 2-maxv * wavehei, setting_color_buttons, alpha)
						draw_vertex_color(10 + dx, size / 2-minv * wavehei + 1, setting_color_buttons, alpha)
					}
					draw_primitive_end()
					break
				}
				
				case "pack":
				{
					if (!preview.select.ready)
						break
						
					switch (preview.pack_image)
					{
						case "previewimage":
							tex = preview.select.block_preview_texture
							break
						
						case "mobtextures":
						   // tex = preview.select.mob_texture[preview.pack_char.index]
							break
						
						case "blocksheet":
							tex = preview.select.block_texture[0]
							break
						
						case "colormap":
							tex = test(preview.pack_colormap, preview.select.colormap_foliage_texture, preview.select.colormap_grass_texture)
							break
						
						case "itemsheet":
							tex = preview.select.item_sheet_texture
							break
						
						case "particlesheet":
							tex = preview.select.particles_texture[preview.pack_particles]
							break
						
						case "suntexture":
							tex = preview.select.sun_texture
							break
							
						case "moontexture":
							tex = preview.select.moonphases_texture
							break
							
						case "cloudtexture":
							tex = preview.select.clouds_texture
							break
					} 
					break
				}
				
				case "skin":
				case "downloadskin":
					tex = preview.select.model_texture
					break
					
				case "itemsheet":
					tex = preview.select.item_sheet_texture
					break
					
				case "blocksheet":
					tex = preview.select.block_texture[0]
					break
					
				case "texture":
					tex = preview.select.texture
					break
					
				case "particlesheet":
					tex = preview.select.particles_texture[0]
					break
			}
			
			if (tex != null)
			{
				var padding, tw, th, dx, dy;
				padding = 16
				tw = texture_width(tex)
				th = texture_height(tex)
				if (preview.last_tex != tex)
				{
					with (preview)
						preview_reset_view()
					preview.zoom = (size - padding * 2) / max(tw, th)
					preview.goalzoom = preview.zoom
				}
				dx = size / 2-(tw / 2+preview.xoff) * preview.zoom
				dy = size / 2-(th / 2+preview.yoff) * preview.zoom
				draw_texture(tex, dx, dy, preview.zoom, preview.zoom)
			}
			preview.last_tex = tex
		}
		
	}
	
	gpu_set_blendmode(bm_normal)
	surface_reset_target()
	preview.update = false
}

draw_surface_exists(preview.surface, xx, yy)

// Particle button
if (preview.select.type = "particles")
{
	if (preview.select.pc_spawn_constant)
	{
		if (draw_button_normal("previewspawn", xx + size - butw, yy + size - 24, butw, 24, e_button.TEXT, preview.spawn_active, true, true))
			preview.spawn_active=!preview.spawn_active
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
	if (draw_button_normal(test(isplaying, "previewstop", "previewplay"), xx + size - 50, yy + size - 24, 24, 24, e_button.NO_TEXT, false, true, true, test(isplaying, icons.stop, icons.play)))
	{
		if (isplaying)
			audio_stop_sound(preview.sound_play_index)
		else
			preview.sound_play_index = audio_play_sound(res_edit.sound_index, 0, false)
	}
}
		
// Save button
if (exportbutton)
	if (draw_button_normal("previewexport", xx + size - 24, yy + size - 24, 24, 24, e_button.NO_TEXT, false, true, true, icons.export))
		action_res_export()
