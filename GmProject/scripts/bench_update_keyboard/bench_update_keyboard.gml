/// bench_update_keyboard()
/// @desc Handle workbench shortcuts

function bench_update_keyboard()
{
	if (window_state != "" || textbox_isediting)
		return

	var shortcut = keybinds[e_keybind.WORKBENCH]

	// Open workbench
	if (window_busy = "")
	{
		if (bench_show_ani = 0 && bench_show_ani_type = "" && shortcut.pressed)
			bench_open = true
		return
	}

	if (window_busy != "bench" || bench_show_ani_type != "")
		return

	// Close workbench
	if (keyboard_check_pressed(vk_escape))
	{
		if (bench_tab = e_bench.SOUND && bench_settings.sound_list_current.source = "music" &&
			audio_exists(bench_settings.music_play_index) && audio_is_playing(bench_settings.music_play_index))
			bench_music_mode = true

		bench_sound_stop()
		bench_show_ani_type = "hide"
		window_focus = ""
		return 0
	}

	var selected, projecttemplate, key, edit;
	selected = bench_settings.project_selected
	projecttemplate = (bench_tab = e_bench.PROJECT && selected != null &&
		instance_exists(selected) && selected.object_index = obj_template)

	key = shortcut.keybind[e_keybind_key.CHAR]
	edit = (key != null && keyboard_check_pressed(key) && keyboard_check(vk_shift) &&
		keyboard_check(vk_control) = shortcut.keybind[e_keybind_key.CTRL] &&
		keyboard_check(vk_alt) = shortcut.keybind[e_keybind_key.ALT])

	// Edit or create the selected asset
	if (edit)
	{
		if (projecttemplate || (bench_tab = e_bench.PARTICLE_SPAWNER && setting_advanced_mode))
		{
			action_bench_create(true)
			bench_show_ani_type = "hide"
		}
		return 0
	}

	if (shortcut.pressed)
	{
		if (bench_tab = e_bench.WORLD)
			world_import_begin(false)
		else if (bench_tab != e_bench.PROJECT || projecttemplate)
			bench_click(bench_tab)
		return 0
	}

	if (!keyboard_check_pressed(vk_up) && !keyboard_check_pressed(vk_down))
		return

	// Move to the next available tab
	var count, current, dir, next, tab;
	count = ds_list_size(bench_tab_list.item)
	current = -1
	dir = keyboard_check_pressed(vk_down) ? 1 : -1

	for (var i = 0; i < count; i++)
		if (bench_tab_list.item[|i].value = bench_tab)
		{
			current = i
			break
		}

	if (current < 0)
		return

	for (var i = 1; i < count; i++)
	{
		next = mod_fix(current + dir * i, count)
		tab = bench_tab_list.item[|next].value
		if (setting_advanced_mode || !array_contains(bench_advanced_tabs, tab))
		{
			bench_click(tab, true)
			break
		}
	}
}