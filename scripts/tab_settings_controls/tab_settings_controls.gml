/// tab_settings_controls()

var capwid, capwid2;
	
// Interface
capwid = text_caption_width("settingskeynew", "settingskeyopen", "settingskeysave", 
						  "settingskeyundo", "settingskeyredo", 
						  "settingskeyselecttimelines", "settingskeyduplicatetimelines", "settingskeyremovetimelines", 
						  "settingskeycopykeyframes", "settingskeycutkeyframes", "settingskeypastekeyframes", "settingskeyremovekeyframes", 
						  "settingskeyspawn", "settingskeyclear", 
						  "settingskeyplay", "settingskeyplaybeginning")

capwid2 = text_caption_width("settingskeycontrol")

tab_control(15)
draw_label(text_get("settingsinterfaceshortcuts") + ":", dx, dy)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeynew", dx, dy, dw - capwid2, setting_key_new, setting_key_new_control, ord("N"), action_setting_key_new, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_new_control, action_setting_key_new_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyimportasset", dx, dy, dw - capwid2, setting_key_import_asset, setting_key_import_asset_control, ord("I"), action_setting_key_import_asset, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_import_asset_control, action_setting_key_import_asset_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyopen", dx, dy, dw - capwid2, setting_key_open, setting_key_open_control, ord("O"), action_setting_key_open, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_open_control, action_setting_key_open_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeysave", dx, dy, dw - capwid2, setting_key_save, setting_key_save_control, ord("S"), action_setting_key_save, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_save_control, action_setting_key_save_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyundo", dx, dy, dw - capwid2, setting_key_undo, setting_key_undo_control, ord("Z"), action_setting_key_undo, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_undo_control, action_setting_key_undo_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyredo", dx, dy, dw - capwid2, setting_key_redo, setting_key_redo_control, ord("Y"), action_setting_key_redo, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_redo_control, action_setting_key_redo_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyplay", dx, dy, dw - capwid2, setting_key_play, setting_key_play_control, vk_space, action_setting_key_play, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_play_control, action_setting_key_play_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyplaybeginning", dx, dy, dw - capwid2, setting_key_play_beginning, setting_key_play_beginning_control, vk_enter, action_setting_key_play_beginning, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_play_beginning_control, action_setting_key_play_beginning_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeymovemarkerright", dx, dy, dw - capwid2, setting_key_move_marker_right, setting_key_move_marker_right_control, vk_right, action_setting_key_move_marker_right, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_move_marker_right_control, action_setting_key_move_marker_right_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeymovemarkerleft", dx, dy, dw - capwid2, setting_key_move_marker_left, setting_key_move_marker_left_control, vk_left, action_setting_key_move_marker_left, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_move_marker_left_control, action_setting_key_move_marker_left_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyrender", dx, dy, dw - capwid2, setting_key_render, setting_key_render_control, vk_f5, action_setting_key_render, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_render_control, action_setting_key_render_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyfolder", dx, dy, dw - capwid2, setting_key_folder, setting_key_folder_control, ord("F"), action_setting_key_folder, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_folder_control, action_setting_key_folder_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyselecttimelines", dx, dy, dw - capwid2, setting_key_select_timelines, setting_key_select_timelines_control, ord("A"), action_setting_key_select_timelines, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_select_timelines_control, action_setting_key_select_timelines_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyduplicatetimelines", dx, dy, dw - capwid2, setting_key_duplicate_timelines, setting_key_duplicate_timelines_control, ord("D"), action_setting_key_duplicate_timelines, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_duplicate_timelines_control, action_setting_key_duplicate_timelines_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyremovetimelines", dx, dy, dw - capwid2, setting_key_remove_timelines, setting_key_remove_timelines_control, ord("R"), action_setting_key_remove_timelines, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_remove_timelines_control, action_setting_key_remove_timelines_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeycopykeyframes", dx, dy, dw - capwid2, setting_key_copy_keyframes, setting_key_copy_keyframes_control, ord("C"), action_setting_key_copy_keyframes, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_copy_keyframes_control, action_setting_key_copy_keyframes_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeycutkeyframes", dx, dy, dw - capwid2, setting_key_cut_keyframes, setting_key_cut_keyframes_control, ord("X"), action_setting_key_cut_keyframes, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_cut_keyframes_control, action_setting_key_cut_keyframes_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeypastekeyframes", dx, dy, dw - capwid2, setting_key_paste_keyframes, setting_key_paste_keyframes_control, ord("V"), action_setting_key_paste_keyframes, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_paste_keyframes_control, action_setting_key_paste_keyframes_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyremovekeyframes", dx, dy, dw - capwid2, setting_key_remove_keyframes, setting_key_remove_keyframes_control, vk_delete, action_setting_key_remove_keyframes, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_remove_keyframes_control, action_setting_key_remove_keyframes_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyspawnparticles", dx, dy, dw - capwid2, setting_key_spawn_particles, setting_key_spawn_particles_control, ord("S"), action_setting_key_spawn_particles, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_spawn_particles_control, action_setting_key_spawn_particles_control)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyclearparticles", dx, dy, dw - capwid2, setting_key_clear_particles, setting_key_clear_particles_control, ord("C"), action_setting_key_clear_particles, capwid)
draw_checkbox("settingskeycontrol", dx + dw - capwid2, dy, setting_key_clear_particles_control, action_setting_key_clear_particles_control)
tab_next()

dy += 10

// Cameras
capwid = text_caption_width("settingskeyforward", 
							"settingskeyleft", 
							"settingskeydescend", 
							"settingskeyrollforward", 
							"settingskeyreset", 
							"settingskeyfast") - 10

capwid2 = text_caption_width("settingskeyback", 
							 "settingskeyright", 
							 "settingskeyascend", 
							 "settingskeyrollback", 
							 "settingskeyrollreset", 
							 "settingskeyslow") - 10

tab_control(16)
draw_label(text_get("settingscameracontrols") + ":", dx, dy)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyforward", dx, dy, dw * 0.5, setting_key_forward, 0, ord("W"), action_setting_key_forward, capwid)
draw_keycontrol("settingskeyback", dx + floor(dw * 0.5), dy, dw * 0.5, setting_key_back, 0, ord("S"), action_setting_key_back, capwid2)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyleft", dx, dy, dw * 0.5, setting_key_left, 0, ord("A"), action_setting_key_left, capwid)
draw_keycontrol("settingskeyright", dx + floor(dw * 0.5), dy, dw * 0.5, setting_key_right, 0, ord("D"), action_setting_key_right, capwid2)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyascend", dx, dy, dw * 0.5, setting_key_ascend, false, ord("E"), action_setting_key_ascend, capwid)
draw_keycontrol("settingskeydescend", dx + floor(dw * 0.5), dy, dw * 0.5, setting_key_descend, false, ord("Q"), action_setting_key_descend, capwid2)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyrollforward", dx, dy, dw * 0.5, setting_key_roll_forward, false, ord("Z"), action_setting_key_roll_forward, capwid)
draw_keycontrol("settingskeyrollback", dx + floor(dw * 0.5), dy, dw * 0.5, setting_key_roll_back, false, ord("C"), action_setting_key_roll_back, capwid2)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyreset", dx, dy, dw * 0.5, setting_key_reset, false, ord("R"), action_setting_key_reset, capwid)
draw_keycontrol("settingskeyrollreset", dx + floor(dw * 0.5), dy, dw * 0.5, setting_key_roll_reset, false, ord("X"), action_setting_key_roll_reset, capwid2)
tab_next()

tab_control_keycontrol()
draw_keycontrol("settingskeyfast", dx, dy, dw * 0.5, setting_key_fast, false, vk_space, action_setting_key_fast, capwid)
draw_keycontrol("settingskeyslow", dx + floor(dw * 0.5), dy, dw * 0.5, setting_key_slow, false, vk_lshift, action_setting_key_slow, capwid2)
tab_next()

capwid = text_caption_width("settingsmovespeed", "settingslooksensitivity", "settingsfastmodifier", "settingsslowmodifier")

tab_control_dragger()
draw_dragger("settingsmovespeed", dx, dy, dw, setting_move_speed, 0.01, 0, no_limit, 1, 0, tab.controls.tbx_move_speed, action_setting_move_speed, capwid)
tab_next()

tab_control_dragger()
draw_dragger("settingslooksensitivity", dx, dy, dw, setting_look_sensitivity, 0.01, 0, no_limit, 1, 0, tab.controls.tbx_look_sensitivity, action_setting_look_sensitivity, capwid)
tab_next()

tab_control_dragger()
draw_dragger("settingsfastmodifier", dx, dy, dw, setting_fast_modifier, 0.01, 0, no_limit, 3, 0, tab.controls.tbx_fast_modifier, action_setting_fast_modifier, capwid)
tab_next()

tab_control_dragger()
draw_dragger("settingsslowmodifier", dx, dy, dw, setting_slow_modifier, 0.01, 0, no_limit, 0.25, 0, tab.controls.tbx_slow_modifier, action_setting_slow_modifier, capwid)
tab_next()
