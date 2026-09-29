/// @desc Draws a preview window.
/// @arg preview
/// @arg x
/// @arg y
/// @arg width
/// @arg height

function preview_draw(preview, xx, yy, width, height)
{
	var is3d, mouseon, playbutton, isplaying, setplaytime, particlebutton, triggerkey;
	
	if (xx + width < content_x || xx > content_x + content_width || yy + height < content_y || yy > content_y + content_height)
		return 0
	
	mouseon = app_mouse_box(xx, yy, width, height)
	setplaytime = null
	triggerkey = (preview.space_trigger && !app.textbox_isediting && keyboard_check_pressed(vk_space))
	
	preview.view_width = width
	preview.view_height = height
	
	// Background
	draw_box(xx, yy, width, height, false, c_level_bottom, 1)
	
	if (!instance_exists(preview.select))
	{
		preview.texture = null
		preview.sound_play_button = false
		return 0
	}
	
	// Particle button
	if (preview.select.object_index = obj_bench_settings)
		particlebutton = (bench_tab = e_bench_tab.PARTICLE_SPAWNER && preview.select.particle_preset != null)
	else
		particlebutton = (preview.select.object_index != obj_resource && preview.select.type = e_temp_type.PARTICLE_SPAWNER)

	// Determine 3D/2D view
	if (preview.select.object_index = obj_resource)
	{
		playbutton = (preview.select.type = e_res_type.SOUND && preview.sound_play_button)
		isplaying = (audio_exists(preview.sound_play_index) && (audio_is_playing(preview.sound_play_index) || audio_is_paused(preview.sound_play_index)))
		is3d = (preview.select.type = e_res_type.SCHEMATIC || preview.select.type = e_res_type.FROM_WORLD ||preview.select.type = e_res_type.MODEL)
	}
	else
	{
		playbutton = false
		isplaying = false
		is3d = true
	}
	
	if ((particlebutton && app_mouse_box(xx + 4, yy + height - 44, 36, 36)) ||
		(playbutton && app_mouse_box(xx + 4, yy + height - 44, 36, 36)))
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
		if ((select.object_index = obj_template || select.object_index = obj_bench_settings)
			&& select.type = e_temp_type.ITEM && (select.item_bounce || select.item_spin))
			update = true
		
		// Playing audio
		if (isplaying)
			update = true
		
		// Animated block sheet
		if (select.type = e_res_type.PACK && pack_image = "blocksheet" && pack_block_sheet_ani)
			update = true
		
		// Sound waveforms have been processed
		var soundready = (select.object_index != obj_resource || select.type != e_res_type.SOUND ||
						  (select.ready && audio_is_ready(select.sound_index)));
						  
		surface = surface_require(surface, width, height)
		
		if (update && soundready)
			setplaytime = preview_surface_update(xx, yy, width, height, is3d, mouseon, isplaying)
		
		// Fix alpha
		var surfalpha = draw_get_alpha();
		gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
		if (surface_exists(surface))
			draw_surface_ext(surface, xx, yy, 1, 1, 0, merge_color(c_black, c_white, surfalpha), surfalpha)
		gpu_set_blendmode(bm_normal)
	}
	
	// Button background
	if (particlebutton || playbutton)
	{
		draw_box(xx + 8, yy + height - 40, 32, 32, false, c_level_middle, 1)
		draw_outline(xx + 8, yy + height - 40, 32, 32, 1, c_border, a_border, true)
	}
	
	// Particle button
	if (particlebutton)
	{
		if (preview.select.pc_spawn_constant)
		{
			if (draw_button_icon("previewspawn" + string(preview), xx + 12, yy + height - 36, 24, 24, preview.particle_spawn_active, icons.PARTICLES, null, false, "tooltipparticlesspawn") || triggerkey)
			{
				preview.particle_spawn_active = !preview.particle_spawn_active
				with (preview)
				{
					particle_spawner_clear()
					update = true
				}
			}
		}
		else
		{
			if (draw_button_icon("previewspawn" + string(preview), xx + 12, yy + height - 36, 24, 24, false, icons.PARTICLES, null, false, "tooltipparticlesspawn") || triggerkey)
				preview.fire = true
		}
	}
	
	// Play button
	if (playbutton)
	{
		if (draw_button_icon("previewplay" + string(preview), xx + 12, yy + height - 36, 24, 24, false, isplaying ? icons.STOP : icons.PLAY, null, false, isplaying ? "tooltipstop" : "tooltipplay") || triggerkey)
		{
			if (isplaying)
			{
				if (preview = app.bench_settings.preview && preview.select = app.bench_settings.music_res)
				{
					bench_music_stop(false)
					isplaying = false
				}
				else
				{
					audio_stop_sound(preview.sound_play_index)
					preview.update = true
				}
			}
			else
			{
				preview.sound_play_index = audio_play_sound(preview.select.sound_index, 0, false)
				if (preview = app.bench_settings.preview && preview.select = app.bench_settings.music_res)
				{
					app.bench_settings.music_play_index = preview.sound_play_index
					app.bench_settings.music_autoplay = true
				}
			}
		}
	}
	
	// Updating audio
	if (setplaytime != null && mouse_left_pressed)
	{
		// Audio isn't already playing, start it
		if (!isplaying)
		{
			preview.sound_play_index = audio_play_sound(preview.select.sound_index, 0, false)
			if (preview = app.bench_settings.preview && preview.select = app.bench_settings.music_res)
			{
				app.bench_settings.music_play_index = preview.sound_play_index
				app.bench_settings.music_autoplay = true
			}
		}
			
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
