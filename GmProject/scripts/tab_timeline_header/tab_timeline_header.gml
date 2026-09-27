/// @arg headerx
/// @arg headery
/// @arg headerwidth
/// @arg headerheight
/// @arg listwidth

function tab_timeline_header(headerx, headery, headerw, headerh, listw)
{
	var timex, timelabel, maxpos, hrs;
	timex = headerx + 8
	content_mouseon = app_mouse_box(headerx, headery, headerw, headerh, "place") && !popup_mouseon && !toast_mouseon && !context_menu_mouseon
	
	clip_begin(headerx, headery, listw - 8, headerh)
	
	// Current time
	draw_set_font(font_heading)
	timelabel = timeline_show_frames ? text_get("timeline/frame", floor(timeline_marker)) : string_time_seconds(timeline_marker / project_tempo, false)
	draw_label(timelabel, timex, headery + headerh - 6, fa_left, fa_bottom, c_text_secondary, a_text_secondary)
	
	// Advance X
	maxpos = max(timeline_length, timeline_marker)
	hrs = floor((maxpos / project_tempo) / 3600)
	if (timeline_show_frames)
		timex += string_width(text_get("timeline/frame", string_repeat("0", string_length(string(floor(maxpos))))))
	else if (hrs > 0)
		timex += string_width(string(hrs) + ":00:00.000")
	else
		timex += string_width("00:00.000")
	
	// Time length
	draw_set_font(font_subheading)
	timelabel = timeline_show_frames ? " / " + string(timeline_length) : " / " + string_time_seconds(timeline_length / project_tempo, false)
	draw_label(timelabel, timex, headery + headerh - 7, fa_left, fa_bottom, c_text_secondary, a_text_secondary)
	timex += string_width(timelabel)
	
	// Time selected
	if (timeline_region_start != null && (timeline_region_start != timeline_region_end))
	{
		timelabel = " (" + (timeline_show_frames ? string(timeline_region_end - timeline_region_start) : string_time_seconds((timeline_region_end - timeline_region_start) / project_tempo, false)) + ")"
		draw_label(timelabel, timex, headery + headerh - 7, fa_left, fa_bottom, c_accent, a_accent)
		timex += string_width(timelabel)
	}
	
	timex += 8
	clip_end()
	
	// Right click timeline timer
	context_menu_area(headerx, headery, timex, headerh, "toolbar/view/timeline/playback", null, null, null, null)
	
	var buttonsxstart, buttonsx, buttonsy;
	buttonsx = listw + 4
	buttonsy = headery + 4
	
	// Run/Walk cycles
	if (draw_button_icon("timeline/walkcycle", buttonsx, buttonsy, 24, 24, false, icons.WALK_CYCLE, null, !file_exists_lib(timeline_settings_walk_fn), "tooltip/tl/walk"))
		action_tl_load_loop(timeline_settings_walk_fn)
		
	buttonsx += 24 + 6
		
	if (draw_button_icon("timeline/runcycle", buttonsx, buttonsy, 24, 24, false, icons.RUN_CYCLE, null, !file_exists_lib(timeline_settings_run_fn), "tooltip/tl/run"))
		action_tl_load_loop(timeline_settings_run_fn)
		
	buttonsx += 24 + 4
	draw_divide_vertical(buttonsx, buttonsy + 2, 20)
	buttonsx += 6

	// Keyframe actions
	tip_set_keybind(e_keybind.KEYFRAMES_CREATE)
	if (draw_button_icon("timeline/keyframescreate", buttonsx, buttonsy, 24, 24, false, icons.KEYFRAME, null, tl_edit_amount = 0, "context_menu/tl/keyframes/create"))
		action_tl_keyframes_create()
	buttonsx += 24 + 4

	tip_set_keybind(e_keybind.KEYFRAMES_CUT)
	if (draw_button_icon("timeline/keyframescut", buttonsx, buttonsy, 24, 24, false, icons.CUT_KEYFRAME, null, !timeline_settings_keyframes, "context_menu/tl/keyframes/cut"))
		action_tl_keyframes_cut()
	buttonsx += 24 + 4

	tip_set_keybind(e_keybind.KEYFRAMES_COPY)
	if (draw_button_icon("timeline/keyframescopy", buttonsx, buttonsy, 24, 24, false, icons.COPY_KEYFRAME, null, !timeline_settings_keyframes, "context_menu/tl/keyframes/copy"))
		tl_keyframes_copy()
	buttonsx += 24 + 4

	tip_set_keybind(e_keybind.KEYFRAMES_PASTE)
	if (draw_button_icon("timeline/keyframespaste", buttonsx, buttonsy, 24, 24, false, icons.PASTE_KEYFRAME, null, copy_kf_amount = 0, "context_menu/tl/keyframes/paste"))
		action_tl_keyframes_paste(timeline_marker)
	buttonsx += 24 + 4

	tip_set_keybind(e_keybind.KEYFRAMES_DELETE)
	if (draw_button_icon("timeline/keyframesdelete", buttonsx, buttonsy, 24, 24, false, icons.DELETE_KEYFRAME, null, !timeline_settings_keyframes, "context_menu/tl/keyframes/delete"))
		action_tl_keyframes_remove()
	buttonsx += 24 + 4
	
	// Transition shortcuts
	draw_divide_vertical(buttonsx, buttonsy + 2, 20)
	buttonsx += 6
	
	var transitiondisabled, curtransition, buttonmouseon;
	transitiondisabled = !timeline_settings_keyframes && (tl_edit = null || !tl_edit.animated)
	curtransition = (tl_edit != null ? tl_edit.value[e_value.TRANSITION] : "linear")
		
	// Linear
	if (draw_button_icon("timeline/transitionlinear", buttonsx, buttonsy, 24, 24, curtransition = "linear", icons.EASE_LINEAR, null, transitiondisabled, "tooltip/tl/transition/linear"))
		action_tl_frame_transition("linear")
	buttonsx += 24 + 4
		
	// Ease in
	buttonmouseon = app_mouse_box(buttonsx, buttonsy, 24, 24) && !transitiondisabled
	if (draw_button_icon("timeline/transitioneasein", buttonsx, buttonsy, 24, 24, string_contains(curtransition, "easein") && !string_contains(curtransition, "easeinout"), icons.EASE_IN, null, transitiondisabled, "tooltip/tl/transition/ease_in"))
		action_tl_frame_transition(timeline.transition_easein)
	
	if (buttonmouseon && mouse_right_released)
	{
		menu_settings_set(buttonsx, buttonsy + 24, "timeline/transitionquickeasein", 0)
		settings_menu_menu = "easein"
		settings_menu_script = menu_settings_transitions
		settings_menu_w = 244
		settings_menu_h = 150
		settings_menu_quick = true
			
		if (settings_menu_y + settings_menu_h + 32 > window_height)
			settings_menu_y = (window_height - (settings_menu_h + 32))
	}
	buttonsx += 24 + 4
		
	// Ease out
	buttonmouseon = app_mouse_box(buttonsx, buttonsy, 24, 24) && !transitiondisabled
	if (draw_button_icon("timeline/transitioneaseout", buttonsx, buttonsy, 24, 24, string_contains(curtransition, "easeout") && !string_contains(curtransition, "easeinout"), icons.EASE_OUT, null, transitiondisabled, "tooltip/tl/transition/ease_out"))
		action_tl_frame_transition(timeline.transition_easeout)
	
	if (buttonmouseon && mouse_right_released)
	{
		menu_settings_set(buttonsx, buttonsy + 24, "timeline/transitionquickeaseout", 0)
		settings_menu_menu = "easeout"
		settings_menu_script = menu_settings_transitions
		settings_menu_w = 244
		settings_menu_h = 150
		settings_menu_quick = true
			
		if (settings_menu_y + settings_menu_h + 32 > window_height)
			settings_menu_y = (window_height - (settings_menu_h + 32))
	}
	buttonsx += 24 + 4
		
	// Ease in/out
	buttonmouseon = app_mouse_box(buttonsx, buttonsy, 24, 24) && !transitiondisabled
	if (draw_button_icon("timeline/transitioneaseinout", buttonsx, buttonsy, 24, 24, string_contains(curtransition, "easeinout") || string_contains(curtransition, "bezier"), icons.EASE_IN_OUT, null, transitiondisabled, "tooltip/tl/transition/ease_in_out"))
		action_tl_frame_transition(timeline.transition_easeinout)
	
	if (buttonmouseon && mouse_right_released)
	{
		menu_settings_set(buttonsx, buttonsy + 24, "timeline/transitionquickeaseinout", 0)
		settings_menu_menu = "easeinout"
		settings_menu_script = menu_settings_transitions
		settings_menu_w = 244
		settings_menu_h = 150
		settings_menu_quick = true
			
		if (settings_menu_y + settings_menu_h + 32 > window_height)
			settings_menu_y = (window_height - (settings_menu_h + 32))
	}
	buttonsx += 24 + 4
		
	// Instant
	if (draw_button_icon("timeline/transitioninstant", buttonsx, buttonsy, 24, 24, curtransition = "instant", icons.EASE_INSTANT, null, transitiondisabled, "tooltip/tl/transition/instant"))
		action_tl_frame_transition("instant")
	buttonsx += 24 + 4
	
	// Play buttons
	buttonsxstart = listw + (timeline_settings_w = null ? 0 : floor((headerx + (headerw - listw)/2)  - timeline_settings_w/2))
	buttonsxstart = max(timex, buttonsxstart, buttonsx + 8)
	buttonsx = buttonsxstart
	
	// Previous keyframe
	draw_button_icon("timeline/previouskeyframe", buttonsx, buttonsy, 24, 24, false, icons.KEYFRAME_PREVIOUS, action_tl_keyframe_previous, timeline_playing, "tooltip/tl/previous_keyframe")
	buttonsx += 24 + 6
	
	// Previous frame
	tip_set_keybind(e_keybind.FRAME_PREVIOUS)
	draw_button_icon("timeline/previousframe", buttonsx, buttonsy, 24, 24, false, icons.FRAME_PREVIOUS, action_tl_frame_previous, timeline_playing, "tooltip/tl/previous_frame")
	buttonsx += 24 + 6
	
	draw_divide_vertical(buttonsx, buttonsy + 2, 20)
	buttonsx += 6
	
	// Stop
	draw_button_icon("timeline/stop", buttonsx, buttonsy, 24, 24, false, icons.STOP, action_tl_play_stop, false, "tooltip/tl/stop")
	buttonsx += 24 + 6
	
	// Play
	tip_set_keybind(e_keybind.PLAY)
	if (draw_button_icon("timeline/play", buttonsx, buttonsy, 24, 24, false, timeline_playing ? icons.PAUSE : icons.PLAY, null, false, timeline_playing ? "tooltip/tl/pause" : "tooltip/tl/play"))
		action_tl_play()
	buttonsx += 24 + 6
	
	// Skip to region start and play
	if (draw_button_icon("timeline/playregion", buttonsx, buttonsy, 24, 24, false, icons.PLAY_REGION, null, timeline_region_start = null, "tooltip/tl/play_region"))
	{
		timeline_marker = timeline_region_start
		
		if (timeline_playing)
			action_tl_play()
		
		action_tl_play()
	}
	
	buttonsx += 24 + 6
	
	draw_divide_vertical(buttonsx, buttonsy + 2, 20)
	buttonsx += 6
	
	// Next frame
	tip_set_keybind(e_keybind.FRAME_NEXT)
	draw_button_icon("timeline/nextframe", buttonsx, buttonsy, 24, 24, false, icons.FRAME_NEXT, action_tl_frame_next, timeline_playing, "tooltip/tl/next_frame")
	buttonsx += 24 + 6
	
	// Next keyframe
	draw_button_icon("timeline/nextkeyframe", buttonsx, buttonsy, 24, 24, false, icons.KEYFRAME_NEXT, action_tl_keyframe_next, timeline_playing, "tooltip/tl/next_keyframe")
	buttonsx += 24 + 6
	
	timeline_settings_w = (buttonsx - buttonsxstart)
	
	buttonsxstart = (timeline_settings_right_w = null ? 0 : real(headerx + headerw - timeline_settings_right_w - 4))
	buttonsx = max(buttonsx, buttonsxstart)
	buttonsxstart = buttonsx
	
	// Loop
	var simpleseam = (!setting_advanced_mode && timeline_seamless_repeat);
	tooltip = timeline_repeat || simpleseam ? "tooltip/tl/disable_loop" : "tooltip/tl/enable_loop"
	if (draw_button_icon("timeline/loop", buttonsx, buttonsy, 24, 24, timeline_repeat || simpleseam, simpleseam ? icons.REPEAT_SEAMLESS : icons.REPEAT, null, false, tooltip))
		action_tl_play_repeat()
	
	if (setting_advanced_mode)
	{
		buttonsx += 24 + 4
		tooltip = timeline_seamless_repeat ? "tooltip/tl/disable_seamless_loop" : "tooltip/tl/enable_seamless_loop"
		if (draw_button_icon("timeline/seamlessloop", buttonsx, buttonsy, 24, 24, timeline_seamless_repeat, icons.REPEAT_SEAMLESS, null, false, tooltip))
			action_tl_play_repeat(true)
	}
		
	buttonsx += 24 + 6
	draw_divide_vertical(buttonsx, buttonsy, 24)
	buttonsx += 4
	
	// Audio scrubbing
	draw_button_icon("timelineaudioscrub", buttonsx, buttonsy, 24, 24, setting_timeline_audio_scrub, icons.WAVE, action_setting_timeline_audio_scrub, false, setting_timeline_audio_scrub ? "tooltiptldisableaudioscrub" : "tooltiptlenableaudioscrub")

	buttonsx += 24 + 6
	draw_divide_vertical(buttonsx, buttonsy, 24)
	buttonsx += 4

	// Zoom out
	if (draw_button_icon("timeline/zoomout", buttonsx, buttonsy, 24, 24, false, icons.ZOOM_OUT, null, timeline_zoom_goal <= 0.25, "tooltip/tl/zoom_out"))
		timeline_zoom_button = 1
	buttonsx += 24 + 6
	
	// Zoom in
	if (draw_button_icon("timeline/zoomin", buttonsx, buttonsy, 24, 24, false, icons.ZOOM_IN, null, timeline_zoom_goal >= 32, "tooltip/tl/zoom_in"))
		timeline_zoom_button = -1
	
	buttonsx += 24 + 4
	
	// Interval settings
	draw_button_icon("timeline/intervals", buttonsx, buttonsy, 24, 24, timeline_intervals_show, icons.STOPWATCH, action_tl_intervals_show, false, timeline_intervals_show ? "tooltip/tl/intervals_hide" : "tooltip/tl/intervals_show")
	buttonsx += 24
	
	if (draw_button_icon("timeline/intervalsettings", buttonsx, buttonsy, 16, 24, settings_menu_name = "timeline/intervalsettings", icons.CHEVRON_DOWN_TINY, null, false))
	{
		menu_settings_set(buttonsx, buttonsy, "timeline/intervalsettings", 24)
		settings_menu_script = tl_interval_settings_draw
	}
	
	if (settings_menu_name = "timeline/intervalsettings" && settings_menu_ani_type != "hide")
		current_microani.active.value = true
	
	buttonsx += 16 + 4
	draw_divide_vertical(buttonsx, buttonsy, 24)
	buttonsx += 4
	
	// Pop out/back button
	if (window_get_current() = e_window.MAIN)
	{
		if (draw_button_icon("tab/popout", buttonsx, buttonsy, 24, 24, false, icons.EXTERNAL, null, false, "tooltip/tl/pop_out"))
		{
			panel_tab_list_remove(tab.panel, tab)
			window_create(tab.window, content_x, content_y, content_width, content_height)
		}
	}
	else
	{
		if (draw_button_icon("tab/popback", buttonsx, buttonsy, 24, 24, false, icons.INTERNAL, null, false, "tooltip/tl/pop_in"))
			window_close(tab.window)
	}
	buttonsx += 24
	
	timeline_settings_right_w = (buttonsx - buttonsxstart)
}
