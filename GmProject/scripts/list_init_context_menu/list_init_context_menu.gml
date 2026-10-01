function list_init_context_menu(name)
{
	list_init_start()
	
	// Specific actions for values
	if (context_menu_value_name != "")
	{
		switch (context_menu_value_name)
		{
			case "pathoffset":
			{
				list_item_add(text_get("context_menu/path_set_length"), null, "", null, null, null, action_tl_frame_path_offset_set_length)
				break
			}
		}
	}
	
	switch (name)
	{
		// Component values
		case "context_menu/value":
		case "context_menu/category":
		{		
			// Combine scale (Advanced mode only)
			if (context_menu_group = e_context_group.SCALE && setting_advanced_mode)
			{
				var text = (frame_editor.transform.scale_all ? "context_menu/scale_separate" : "context_menu/scale_combine");
				list_item_add(text_get(text), null, "", null, icons.SCALE, null, action_group_combine_scale, true)
			}
			
			// Single value copy-paste
			if (name = "context_menu/value")
			{
				list_item_add(text_get("context_menu/value/cut"), null, "", null, icons.CUT, null, action_value_cut, true)
				list_item_add(text_get("context_menu/value/copy"), null, "", null, icons.COPY, null, action_value_copy, false)
				
				var caption = "";
				
				if (context_menu_copy_type = e_context_type.NUMBER)
					caption = string(context_menu_copy)
				else if (context_menu_copy_type = e_context_type.COLOR)
					caption = color_to_hex(context_menu_copy)
				else if (context_menu_copy_type = e_context_type.STRING)
					caption = context_menu_copy
				else if (context_menu_copy_type = e_context_type.TIME)
					caption = rotation_get_time(context_menu_copy)
				
				list_item_add(text_get("context_menu/value/paste"), null, caption, null, icons.PASTE, null, action_value_paste, false)
				list_item_last.disabled = (context_menu_value_type = e_context_type.NONE || (context_menu_copy_type != context_menu_value_type))
				
				list_item_add(text_get("context_menu/value/reset"), null, "", null, icons.RESET, null, action_value_reset, false)
			}
			
			if (context_menu_group != null)
			{
				list_item_add(text_get("context_menu/group/copy"), null, "", null, icons.COPY_ALL, null, action_group_copy, true)
				list_item_add(text_get("context_menu/group/paste"), null, "", null, icons.PASTE_ALL, null, action_group_paste, false)
				list_item_last.disabled = (context_group_copy_list[|context_menu_group] = null)
				
				list_item_add(text_get("context_menu/group/reset"), null, "", null, icons.RESET_ALL, null, action_group_reset, false)
				
				if (context_menu_group = e_context_group.POSITION)
					list_item_add(text_get("context_menu/group/copy_global_position"), null, "", null, icons.COPY_ALL, null, action_group_copy_global, true)
			}
			
			// Color options
			if (context_menu_value_type = e_context_type.COLOR)
			{
				list_item_add(text_get("context_menu/set_color"), null, "", null, icons.PALETTE, icons.CHEVRON_RIGHT_TINY, null, true)
				list_item_last.context_menu_script = menu_swatches_draw
				list_item_last.context_menu_name = "context_menu/swatchset"
				list_item_last.context_menu_width = 204
				list_item_last.context_menu_height = 0
				
				list_item_add(text_get("context_menu/mix_color"), null, "", null, icons.PLUS, icons.CHEVRON_RIGHT_TINY)
				list_item_last.context_menu_script = menu_swatches_draw
				list_item_last.context_menu_name = "context_menu/swatchmix"
				list_item_last.context_menu_width = 204
				list_item_last.context_menu_height = 0
			}
			
			break
		}
		
		// Textboxes
		case "context_menu/textbox":
		{
			list_item_add(text_get("context_menu/textbox/cut"), null, text_control_name(keybind_new("X", true)), null, icons.CUT, null, action_textbox_cut, true)
			list_item_last.disabled = (textbox_select_startpos = textbox_select_endpos)
			
			list_item_add(text_get("context_menu/textbox/copy"), null, text_control_name(keybind_new("C", true)), null, icons.COPY, null, action_textbox_copy, false)
			list_item_last.disabled = (textbox_select_startpos = textbox_select_endpos)
			
			list_item_add(text_get("context_menu/textbox/paste"), null, text_control_name(keybind_new("V", true)), null, icons.PASTE, null, action_textbox_paste, false)
			list_item_last.disabled = (clipboard_get_text() = "" || !clipboard_has_text())
			
			list_item_add(text_get("context_menu/textbox/select_all"), null, text_control_name(keybind_new("A", true)), null, icons.SELECT_ALL, null, action_textbox_select_all, false)
			
			break
		}
		
		// Timeline object list
		case "timeline/list":
		{
			list_item_add(text_get("context_menu/tl/add_folder"), null, text_control_name(keybinds[e_keybind.CREATE_FOLDER].keybind), null, icons.FOLDER, null, action_tl_folder, true)
			list_item_add(text_get("context_menu/tl/select_keyframes"), context_menu_value, "", null, icons.KEYFRAME, null, action_tl_select_keyframes)
			list_item_last.disabled = context_menu_value = null
			
			if (setting_advanced_mode)
			{
				list_item_add(text_get("context_menu/tl/color_tag"), null, "", null, icons.TAG, icons.CHEVRON_RIGHT_TINY, null)
				list_item_last.context_menu_name = "colortag"
				list_item_last.disabled = context_menu_value = null
			}
			
			list_item_add(text_get("context_menu/tl/expand_children"), null, "", null, icons.MAXIMIZE, null, action_tl_extend_children)
			list_item_last.disabled = context_menu_value = null
			
			list_item_add(text_get("context_menu/tl/collapse_children"), null, "", null, icons.MINIMIZE, null, action_tl_collapse_children)
			list_item_last.disabled = context_menu_value = null
			
			list_item_add(text_get("context_menu/tl/duplicate"), null, text_control_name(keybinds[e_keybind.TIMELINE_DUPLICATE].keybind), null, icons.DUPLICATE, null, action_tl_duplicate, true)
			list_item_last.disabled = (context_menu_value = null || context_menu_value.part_of != null)
			
			list_item_add(text_get("context_menu/tl/delete"), null, text_control_name(keybinds[e_keybind.TIMELINE_DELETE].keybind), null, icons.DELETE, null, action_tl_remove)
			list_item_last.disabled = (context_menu_value = null || context_menu_value.part_of != null)
			
			list_item_add(text_get("context_menu/tl/export"), null, "", null, icons.ASSET_EXPORT, null, object_save)
			list_item_last.disabled = (context_menu_value = null || (!context_menu_value.selected && context_menu_value.part_of != null)) ? true : !timeline_settings
			
			list_item_add(text_get("context_menu/tl/select_all"), null, text_control_name(keybinds[e_keybind.TIMELINE_SELECT].keybind), null, icons.SELECT_ALL, null, action_tl_select_all, true)
			list_item_add(text_get("context_menu/tl/expand_all"), null, "", null, icons.MAXIMIZE, null, action_tl_extend_all)
			list_item_add(text_get("context_menu/tl/collapse_all"), null, "", null, icons.MINIMIZE, null, action_tl_collapse_all)
			
			break
		}
		
		// Timeline
		case "timeline":
		{
			// Transition
			list_item_add(text_get("context_menu/tl/keyframes/transition"), null, "", null, icons.EASE_IN_OUT, icons.CHEVRON_RIGHT_TINY, null, true)
			list_item_last.disabled = !timeline_settings_keyframes
			list_item_last.context_menu_script = menu_transitions
			list_item_last.context_menu_width = 244
			list_item_last.context_menu_height = 438
			list_item_last.context_menu_name = "timeline/keyframe_transition"
			
			// Keyframes
			list_item_add(text_get("context_menu/tl/keyframes/create"), null, text_control_name(keybinds[e_keybind.KEYFRAMES_CREATE].keybind), null, icons.KEYFRAME, null, action_tl_keyframes_create, true)
			list_item_last.disabled = (tl_edit_amount = 0)

			list_item_add(text_get("context_menu/tl/keyframes/cut"), null, text_control_name(keybinds[e_keybind.KEYFRAMES_CUT].keybind), null, icons.CUT_KEYFRAME, null, action_tl_keyframes_cut)
			list_item_last.disabled = !timeline_settings_keyframes
			
			list_item_add(text_get("context_menu/tl/keyframes/copy"), null, text_control_name(keybinds[e_keybind.KEYFRAMES_COPY].keybind), null, icons.COPY_KEYFRAME, null, tl_keyframes_copy)
			list_item_last.disabled = !timeline_settings_keyframes
			
			list_item_add(text_get("context_menu/tl/keyframes/paste"), timeline_insert_pos, text_control_name(keybinds[e_keybind.KEYFRAMES_PASTE].keybind), null, icons.PASTE_KEYFRAME, null, action_tl_keyframes_paste)
			list_item_last.disabled = (copy_kf_amount = 0)
			
			list_item_add(text_get("context_menu/tl/keyframes/delete"), null, text_control_name(keybinds[e_keybind.KEYFRAMES_DELETE].keybind), null, icons.DELETE_KEYFRAME, null, action_tl_keyframes_remove)
			list_item_last.disabled = !timeline_settings_keyframes
			
			list_item_add(text_get("context_menu/tl/keyframes/export"), null, "", null, icons.SAVE_KEYFRAME, null, keyframes_save)
			list_item_last.disabled = !timeline_settings_keyframes_export
			
			list_item_add(text_get("context_menu/tl/keyframes/select"), null, "", null, icons.SELECT_ALL_KEYFRAME, icons.CHEVRON_RIGHT_TINY, null)
			list_item_last.context_menu_name = "timeline/keyframes_select"
			
			// Walk/run cycles
			list_item_add(text_get("context_menu/tl/keyframes/walk"), timeline_settings_walk_fn, "", null, icons.WALK_CYCLE, null, action_tl_load_loop, true)
			list_item_last.disabled = !file_exists_lib(timeline_settings_walk_fn)
			
			list_item_add(text_get("context_menu/tl/keyframes/run"), timeline_settings_run_fn, "", null, icons.RUN_CYCLE, null, action_tl_load_loop)
			list_item_last.disabled = !file_exists_lib(timeline_settings_run_fn)
			
			// Add marker
			list_item_add(text_get("context_menu/tl/marker/add"), null, "", null, icons.MARKER_ADD, null, action_tl_marker_new, true)
			
			// Check if position is available
			if (setting_timeline_show_markers)
			{
				for (var i = 0; i < ds_list_size(timeline_marker_list); i++)
				{
					if (timeline_marker_list[|i].pos = round(app.timeline_marker))
					{
						list_item_last.disabled = true
						break
					}
				}
			}
			else
				list_item_last.disabled = true
			
			break
		}
		
		// Keyframe select
		case "timeline/keyframes_select":
		{
			list_item_add(text_get("context_menu/tl/keyframes/select/before"), null, "", null, null, null, action_tl_select_keyframes_before_marker)
			list_item_add(text_get("context_menu/tl/keyframes/select/after"), null, "", null, null, null, action_tl_select_keyframes_after_marker)
			list_item_add(text_get("context_menu/tl/keyframes/select/first"), null, "", null, null, null, action_tl_select_keyframes_first)
			list_item_add(text_get("context_menu/tl/keyframes/select/last"), null, "", null, null, null, action_tl_select_keyframes_last)
			
			list_item_add(text_get("context_menu/tl/keyframes/select/region"), null, "", null, null, null, action_tl_select_keyframes_region)
			list_item_last.disabled = (timeline_region_start = null)
			
			break
		}
		
		// Marker
		case "timeline/marker":
		{
			list_item_add(text_get("context_menu/tl/marker/edit"), context_menu_value, "", null, icons.PENCIL, null, action_tl_marker_editor, true)
			list_item_add(text_get("context_menu/tl/marker/delete"), null, "", null, icons.DELETE, null, action_tl_marker_delete)
			break
		}
		
		// Accent color picker
		case "colortag":
		{
			list_item_add(text_get("context_menu/color/none"), null, "", null, icons.CLOSE, null, action_tl_color_tag_remove, true)
			
			for (var i = 0; i <= 8; i++)
			{
				list_item_add(text_get("context_menu/color/" + string(i)), i, "", spr_16, null, null, action_tl_color_tag)
				list_item_last.thumbnail_blend = setting_theme.accent_list[i]
			}
			
			break
		}
		
		// File menu
		case "toolbar/file":
		{
			list_item_add(text_get("toolbar/file/new"), undefined, text_control_name(keybinds[e_keybind.PROJECT_NEW].keybind), null, icons.FILE, null, action_toolbar_new)
			list_item_add(text_get("toolbar/file/open"), undefined, text_control_name(keybinds[e_keybind.PROJECT_OPEN].keybind), null, icons.FOLDER, null, action_toolbar_open)
			list_item_add(text_get("toolbar/file/recent"), undefined, "", null, icons.FOLDER_RECENTS, icons.CHEVRON_RIGHT_TINY, null)
			list_item_last.context_menu_name = "toolbar/file/recent"
			
			list_item_add(text_get("toolbar/file/last_backup"), undefined, "", null, icons.RECENTS, null, action_toolbar_open_last_backup)
			list_item_last.disabled = !file_exists(project_folder + "/" + filename_name(project_folder) + ".backup1")
			
			list_item_add(text_get("toolbar/file/save"), undefined, text_control_name(keybinds[e_keybind.PROJECT_SAVE].keybind), null, icons.SAVE, null, action_toolbar_save, true)
			list_item_add(text_get("toolbar/file/save_as"), undefined, text_control_name(keybinds[e_keybind.PROJECT_SAVE_AS].keybind), null, icons.SAVE_AS, null, action_toolbar_save_as)
			
			if (window_state = "")
			{
				list_item_add(text_get("toolbar/file/import"), undefined, text_control_name(keybinds[e_keybind.IMPORT_ASSET].keybind), null, icons.ASSET_IMPORT, null, action_toolbar_import_asset, true)
				list_item_add(text_get("toolbar/file/world_import"), undefined, "", null, icons.SCENERY, null, world_import_begin, false)
			}
			
			break
		}
		
		case "toolbar/file/recent":
		{
			for (var i = 0; i < min(ds_list_size(recent_list), 10); i++)
			{
				var recent = recent_list[|i];
				list_item_add(recent.name, recent.filename, "", null, null, null, action_toolbar_open)
			}
			
			break
		}
		
		// Edit menu
		case "toolbar/edit":
		{
			list_item_add(text_get("toolbar/edit/undo"), null, text_control_name(keybinds[e_keybind.UNDO].keybind), null, icons.UNDO, null, action_toolbar_undo)
			list_item_last.disabled = (history_pos = history_amount)
			
			list_item_add(text_get("toolbar/edit/redo"), null, text_control_name(keybinds[e_keybind.REDO].keybind), null, icons.REDO, null, action_toolbar_redo)
			list_item_last.disabled = (history_pos = 0)

			list_item_add(text_get("toolbar/edit/select_all"), null, text_control_name(keybinds[e_keybind.TIMELINE_SELECT].keybind), null, icons.SELECT_ALL, null, action_tl_select_all)
			list_item_last.disabled = (ds_list_size(tree_list) = 0)
			
			list_item_add(text_get("toolbar/edit/duplicate"), null, text_control_name(keybinds[e_keybind.TIMELINE_DUPLICATE].keybind), null, icons.DUPLICATE, null, action_tl_duplicate, true)
			list_item_last.disabled = (tl_edit = null)
			
			list_item_add(text_get("toolbar/edit/delete"), null, text_control_name(keybinds[e_keybind.TIMELINE_DELETE].keybind), null, icons.DELETE, null, action_tl_remove)
			list_item_last.disabled = (tl_edit = null)
			
			list_item_add(text_get("toolbar/edit/hide"), true, text_control_name(keybinds[e_keybind.TIMELINE_HIDE].keybind), null, icons.HIDDEN, null, action_tl_hide_select, true)
			list_item_last.disabled = (tl_edit = null)
			
			list_item_add(text_get("toolbar/edit/show_hidden"), false, text_control_name(keybinds[e_keybind.TIMELINE_SHOW_HIDDEN].keybind), null, icons.VISIBLE, null, action_tl_hide_select)
			list_item_last.disabled = (tl_edit = null)
			
			list_item_add(text_get("toolbar/edit/build_tool"), null, text_control_name(keybinds[e_keybind.BUILD_TOOL].keybind), null, icons.BLOCK, null, action_toolbar_build_mode, true)
			list_item_last.toggled = place_build
			
			list_item_add(text_get("toolbar/edit/preferences"), settings, "", null, icons.SETTINGS, null, settings.show ? tab_close : tab_show, true)
			list_item_last.toggled = settings.show
			
			break
		}
		
		// Render menu
		case "toolbar/render":
		{
			list_item_add(text_get("toolbar/render/image"), null, "", null, icons.IMAGE_EXPORT, null, action_toolbar_export_image)
			list_item_add(text_get("toolbar/render/movie"), null, "", null, icons.MOVIE_EXPORT, null, action_toolbar_export_movie)
			break
		}
		
		// View menu
		case "toolbar/view":
		{
			if (window_state = "")
			{
				list_item_add(text_get("toolbar/view/reset"), null, "", null, icons.CAMERA, null, camera_work_reset)
				
				list_item_add(text_get("toolbar/view/secondary_view"), null, text_control_name(keybinds[e_keybind.SECONDARY_VIEW].keybind), null, icons.VIEWPORT_SECONDARY, null, action_setting_secondary_view)
				list_item_last.toggled = view_second.show
				
				list_item_add(text_get("toolbar/view/timeline/show_markers"), null, "", null, icons.MARKER, null, action_setting_timeline_show_markers)
				list_item_last.toggled = setting_timeline_show_markers
				list_item_last.divider = true
				
				list_item_add(text_get("toolbar/view/timeline/playback"), null, "", null, icons.CLOCK, icons.CHEVRON_RIGHT_TINY, null)
				list_item_last.context_menu_name = "toolbar/view/timeline/playback"
			}
			
			list_item_add(text_get("toolbar/view/shortcuts_bar"), null, "", null, icons.KEYBOARD, null, action_setting_shortcuts_bar, true)
			list_item_last.toggled = setting_show_shortcuts_bar
			
			list_item_add(text_get("toolbar/view/home"), null, "", null, icons.HOUSE, null, action_setting_home_screen, true)
			
			break
		}
		
		// View/Timeline menu
		case "toolbar/view/timeline/playback":
		{
			list_item_add(text_get("toolbar/view/timeline/playback/time_seconds"), null, "", null, null, null, action_setting_timeline_display_time)
			list_item_last.toggled = !timeline_show_frames
			list_item_last.divider = true
			
			list_item_add(text_get("toolbar/view/timeline/playback/time_frames"), null, "", null, null, null, action_setting_timeline_display_frames)
			list_item_last.toggled = timeline_show_frames
			
			break
		}
		
		// Help menu
		case "toolbar/help":
		{
			list_item_add(text_get("toolbar/help/about"), popup_about, "", null, icons.INFO, null, popup_show)
			
			if (trial_version)
				list_item_add(text_get("toolbar/help/upgrade"), popup_upgrade, "", null, icons.KEY, null, popup_show)
			
			list_item_add(text_get("toolbar/help/tutorials"), link_tutorials, "", null, icons.TUTORIALS, null, open_url)
			
			list_item_add(text_get("toolbar/help/report"), link_forums_bugs, "", null, icons.BUG, null, open_url, true)
			list_item_add(text_get("toolbar/help/forums"), link_forums, "", null, icons.COMMENTS, null, open_url)
			
			break
		}
		
		// Keybind
		case "keybind":
		{
			list_item_add(text_get("context_menu/clear_keybind"), context_menu_value, "", null, icons.DELETE, null, keybind_clear)
			list_item_add(text_get("context_menu/restore_keybind"), context_menu_value, "", null, icons.RESET, null, keybind_restore)
			break
		}
	}
	
	return list_init_end()
}
