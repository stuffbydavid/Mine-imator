/// tab_timeline_header(headerx, headery, headerw, headerh, listw)

function tab_timeline_header(headerx, headery, headerw, headerh, listw)
{
	var timex, timelabel, maxpos, hrs, buttonsxstart, buttonsx, buttonsy, tooltip;
	timex = headerx + 8
	content_mouseon = app_mouse_box(headerx, headery, headerw, headerh, "place") && !popup_mouseon && !toast_mouseon && !context_menu_mouseon
	
	clip_begin(headerx, headery, listw - 8, headerh)
	
	// Current time
	draw_set_font(font_heading)
	timelabel = timeline_show_frames ? text_get("timelineframe", floor(timeline_marker)) : string_time_seconds(timeline_marker / project_tempo, false)
	draw_label(timelabel, timex, headery + headerh - 6, fa_left, fa_bottom, c_text_secondary, a_text_secondary)
	
	// Advance X
	maxpos = max(timeline_length, timeline_marker)
	hrs = floor((maxpos / project_tempo) / 3600);
	if (timeline_show_frames)
		timex += string_width(text_get("timelineframe", string_repeat("0", string_length(string(floor(maxpos))))))
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
	context_menu_area(headerx, headery, timex, headerh, "toolbarviewtimelineplayback", null, null, null, null)
	
	// Transition quick buttons
	buttonsx = listw + 4
	buttonsy = headery + 4
	
	// Run/Walk cycles
	if (draw_button_icon("timelinewalkcycle", buttonsx, buttonsy, 24, 24, false, icons.WALK_CYCLE, null, !file_exists_lib(timeline_settings_walk_fn), "tooltiptlwalk"))
		action_tl_load_loop(timeline_settings_walk_fn)
		
	buttonsx += 24 + 6
		
	if (draw_button_icon("timelineruncycle", buttonsx, buttonsy, 24, 24, false, icons.RUN_CYCLE, null, !file_exists_lib(timeline_settings_run_fn), "tooltiptlrun"))
		action_tl_load_loop(timeline_settings_run_fn)
		
	buttonsx += 24 + 4
	draw_divide_vertical(buttonsx, buttonsy + 2, 20)
	buttonsx += 6

	// Keyframe actions
	tip_set_keybind(e_keybind.KEYFRAMES_CREATE)
	if (draw_button_icon("timelinekeyframescreate", buttonsx, buttonsy, 24, 24, false, icons.KEYFRAME, null, tl_edit_amount = 0, "contextmenutlkeyframescreate"))
		action_tl_keyframes_create()
	buttonsx += 24 + 4

	tip_set_keybind(e_keybind.KEYFRAMES_CUT)
	if (draw_button_icon("timelinekeyframescut", buttonsx, buttonsy, 24, 24, false, icons.CUT_KEYFRAME, null, !timeline_settings_keyframes, "contextmenutlkeyframescut"))
		action_tl_keyframes_cut()
	buttonsx += 24 + 4

	tip_set_keybind(e_keybind.KEYFRAMES_COPY)
	if (draw_button_icon("timelinekeyframescopy", buttonsx, buttonsy, 24, 24, false, icons.COPY_KEYFRAME, null, !timeline_settings_keyframes, "contextmenutlkeyframescopy"))
		tl_keyframes_copy()
	buttonsx += 24 + 4

	tip_set_keybind(e_keybind.KEYFRAMES_PASTE)
	if (draw_button_icon("timelinekeyframespaste", buttonsx, buttonsy, 24, 24, false, icons.PASTE_KEYFRAME, null, copy_kf_amount = 0, "contextmenutlkeyframespaste"))
		action_tl_keyframes_paste(timeline_marker)
	buttonsx += 24 + 4

	tip_set_keybind(e_keybind.KEYFRAMES_DELETE)
	if (draw_button_icon("timelinekeyframesdelete", buttonsx, buttonsy, 24, 24, false, icons.DELETE_KEYFRAME, null, !timeline_settings_keyframes, "contextmenutlkeyframesdelete"))
		action_tl_keyframes_remove()
	buttonsx += 24 + 4
	
	// Transition shortcuts
	draw_divide_vertical(buttonsx, buttonsy + 2, 20)
	buttonsx += 6
	
	var transitiondisabled, curtransition, buttonmouseon;
	transitiondisabled = !timeline_settings_keyframes && tl_edit == null
	curtransition = (tl_edit != null ? tl_edit.value[e_value.TRANSITION] : "linear")
		
	// Linear
	if (draw_button_icon("timelinetransitionlinear", buttonsx, buttonsy, 24, 24, curtransition = "linear", icons.EASE_LINEAR, null, transitiondisabled, "tooltiptltransitionlinear"))
		action_tl_frame_transition("linear")
	buttonsx += 24 + 4
		
	// Ease in
	buttonmouseon = app_mouse_box(buttonsx, buttonsy, 24, 24) && !transitiondisabled
	if (draw_button_icon("timelinetransitioneasein", buttonsx, buttonsy, 24, 24, string_contains(curtransition, "easein") && !string_contains(curtransition, "easeinout"), icons.EASE_IN, null, transitiondisabled, "tooltiptltransitioneasein"))
		action_tl_frame_transition(timeline.transition_easein)
	
	if (buttonmouseon && mouse_right_released)
	{
		menu_settings_set(buttonsx, buttonsy + 24, "timelinetransitionquickeasein", 0)
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
	if (draw_button_icon("timelinetransitioneaseout", buttonsx, buttonsy, 24, 24, string_contains(curtransition, "easeout") && !string_contains(curtransition, "easeinout"), icons.EASE_OUT, null, transitiondisabled, "tooltiptltransitioneaseout"))
		action_tl_frame_transition(timeline.transition_easeout)
	
	if (buttonmouseon && mouse_right_released)
	{
		menu_settings_set(buttonsx, buttonsy + 24, "timelinetransitionquickeaseout", 0)
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
	if (draw_button_icon("timelinetransitioneaseinout", buttonsx, buttonsy, 24, 24, string_contains(curtransition, "easeinout") || string_contains(curtransition, "bezier"), icons.EASE_IN_OUT, null, transitiondisabled, "tooltiptltransitioneaseinout"))
		action_tl_frame_transition(timeline.transition_easeinout)
	
	if (buttonmouseon && mouse_right_released)
	{
		menu_settings_set(buttonsx, buttonsy + 24, "timelinetransitionquickeaseinout", 0)
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
	if (draw_button_icon("timelinetransitioninstant", buttonsx, buttonsy, 24, 24, curtransition = "instant", icons.EASE_INSTANT, null, transitiondisabled, "tooltiptltransitioninstant"))
		action_tl_frame_transition("instant")
	buttonsx += 24 + 4
	
	// Play buttons
	buttonsxstart = listw + (timeline_settings_w = null ? 0 : floor((headerx + (headerw - listw)/2)  - timeline_settings_w/2))
	buttonsxstart = max(timex, buttonsxstart, buttonsx + 8)
	buttonsx = buttonsxstart
	
	// Previous keyframe
	draw_button_icon("timelinepreviouskeyframe", buttonsx, buttonsy, 24, 24, false, icons.KEYFRAME_PREVIOUS, action_tl_keyframe_previous, timeline_playing, "tooltiptlpreviouskeyframe")
	buttonsx += 24 + 6
	
	// Previous frame
	tip_set_keybind(e_keybind.FRAME_PREVIOUS)
	draw_button_icon("timelinepreviousframe", buttonsx, buttonsy, 24, 24, false, icons.FRAME_PREVIOUS, action_tl_frame_previous, timeline_playing, "tooltiptlpreviousframe")
	buttonsx += 24 + 6
	
	draw_divide_vertical(buttonsx, buttonsy + 2, 20)
	buttonsx += 6
	
	// Stop
	draw_button_icon("timelinestop", buttonsx, buttonsy, 24, 24, false, icons.STOP, action_tl_play_stop, false, "tooltiptlstop")
	buttonsx += 24 + 6
	
	// Play
	tip_set_keybind(e_keybind.PLAY)
	if (draw_button_icon("timelineplay", buttonsx, buttonsy, 24, 24, false, timeline_playing ? icons.PAUSE : icons.PLAY, null, false, timeline_playing ? "tooltiptlpause" : "tooltiptlplay"))
		action_tl_play()
	buttonsx += 24 + 6
	
	// Skip to region start and play
	if (draw_button_icon("timelineplayregion", buttonsx, buttonsy, 24, 24, false, icons.PLAY_REGION, null, timeline_region_start = null, "tooltiptlplayregion"))
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
	draw_button_icon("timelinenextframe", buttonsx, buttonsy, 24, 24, false, icons.FRAME_NEXT, action_tl_frame_next, timeline_playing, "tooltiptlnextframe")
	buttonsx += 24 + 6
	
	// Next keyframe
	draw_button_icon("timelinenextkeyframe", buttonsx, buttonsy, 24, 24, false, icons.KEYFRAME_NEXT, action_tl_keyframe_next, timeline_playing, "tooltiptlnextkeyframe")
	buttonsx += 24 + 6
	
	timeline_settings_w = (buttonsx - buttonsxstart)
	
	buttonsxstart = (timeline_settings_right_w = null ? 0 : real(headerx + headerw - timeline_settings_right_w - 4))
	buttonsx = max(buttonsx, buttonsxstart)
	buttonsxstart = buttonsx
	
	// Loop
	var simpleseam = (!setting_advanced_mode && timeline_seamless_repeat);
	tooltip = timeline_repeat || simpleseam ? "tooltiptldisableloop" : "tooltiptlenableloop"
	if (draw_button_icon("timelineloop", buttonsx, buttonsy, 24, 24, timeline_repeat || simpleseam, simpleseam ? icons.REPEAT_SEAMLESS : icons.REPEAT, null, false, tooltip))
		action_tl_play_repeat()
	
	if (setting_advanced_mode)
	{
		buttonsx += 24 + 4
		tooltip = timeline_seamless_repeat ? "tooltiptldisableseamlessloop" : "tooltiptlenableseamlessloop"
		if (draw_button_icon("timelineseamlessloop", buttonsx, buttonsy, 24, 24, timeline_seamless_repeat, icons.REPEAT_SEAMLESS, null, false, tooltip))
			action_tl_play_repeat(true)
	}
		
	buttonsx += 24 + 6
	draw_divide_vertical(buttonsx, buttonsy, 24)
	buttonsx += 4
	
	// Zoom out
 	if (draw_button_icon("timelinezoomout", buttonsx, buttonsy, 24, 24, false, icons.ZOOM_OUT, null, timeline_zoom_goal <= 0.25, "tooltiptlzoomout"))
		timeline_zoom_button = 1
	buttonsx += 24 + 6
	
	// Zoom in
 	if (draw_button_icon("timelinezoomin", buttonsx, buttonsy, 24, 24, false, icons.ZOOM_IN, null, timeline_zoom_goal >= 32, "tooltiptlzoomin"))
		timeline_zoom_button = -1
	
	buttonsx += 24 + 4
	
	// Interval settings
	draw_button_icon("timelineintervals", buttonsx, buttonsy, 24, 24, timeline_intervals_show, icons.STOPWATCH, action_tl_intervals_show, false, timeline_intervals_show ? "tooltiptlintervalshide" : "tooltiptlintervalsshow")
	buttonsx += 24
	
	if (draw_button_icon("timelineintervalsettings", buttonsx, buttonsy, 16, 24, settings_menu_name = "timelineintervalsettings", icons.CHEVRON_DOWN_TINY, null, false))
	{
		menu_settings_set(buttonsx, buttonsy, "timelineintervalsettings", 24)
		settings_menu_script = tl_interval_settings_draw
	}
	
	if (settings_menu_name = "timelineintervalsettings" && settings_menu_ani_type != "hide")
		current_microani.active.value = true
	
	buttonsx += 16 + 4
	draw_divide_vertical(buttonsx, buttonsy, 24)
	buttonsx += 4
	
	// Pop out/back button
	if (window_get_current() = e_window.MAIN)
	{
		if (draw_button_icon("tabpopout", buttonsx, buttonsy, 24, 24, false, icons.EXTERNAL, null, false, "tooltiptlpopout"))
		{
			panel_tab_list_remove(tab.panel, tab)
			window_create(tab.window, content_x, content_y, content_width, content_height)
		}
	}
	else
	{
		if (draw_button_icon("tabpopback", buttonsx, buttonsy, 24, 24, false, icons.INTERNAL, null, false, "tooltiptlpopin"))
			window_close(tab.window)
	}
	buttonsx += 24
	
	timeline_settings_right_w = (buttonsx - buttonsxstart)
}
