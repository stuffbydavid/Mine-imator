/// @desc Handle workbench shortcuts.

function bench_update_keyboard()
{
	if (window_state != "" || textbox_isediting)
		return 0

	// Open workbench
	if (window_busy = "")
	{
		if (bench_show_ani = 0 && bench_show_ani_type = "" && keybinds[e_keybind.WORKBENCH].pressed)
			bench_open = true
		
		return 0
	}

	if (window_busy != "bench" || bench_show_ani_type != "")
		return 0

	// Close workbench
	if (keyboard_check_pressed(vk_escape) || keybinds[e_keybind.WORKBENCH].pressed)
	{
		if (bench_tab = e_bench_tab.SOUND && bench_settings.sound_list_current.source = "music" &&
			audio_exists(bench_settings.music_play_index) && audio_is_playing(bench_settings.music_play_index))
			bench_music_mode = true

		bench_sound_stop()
		bench_show_ani_type = "hide"
		window_focus = ""
		
		return 0
	}

	if (!keyboard_check_pressed(vk_up) && !keyboard_check_pressed(vk_down))
		return 0

	// Move to the next available tab
	var count, current, dir;
	count = ds_list_size(bench_tab_list.item)
	current = -1
	dir = keyboard_check_pressed(vk_down) ? 1 : -1

	for (var i = 0; i < count; i++)
	{
		if (bench_tab_list.item[|i].value = bench_tab)
		{
			current = i
			break
		}
	}

	if (current < 0)
		return 0

	for (var i = 1; i < count; i++)
	{
		var next, tab;
		next = mod_fix(current + dir * i, count)
		tab = bench_tab_list.item[|next].value
		
		if (setting_advanced_mode || !array_contains(bench_advanced_tabs, tab))
		{
			bench_tab_select(tab, true)
			break
		}
	}
}
