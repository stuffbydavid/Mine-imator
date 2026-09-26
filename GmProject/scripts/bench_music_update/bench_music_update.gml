/// bench_music_update()

function bench_music_update()
{
	// Note animation
	with (obj_note)
	{
		note_age += delta
		x += note_speed_x * delta
		y += note_speed_y * delta
		note_alpha = max(0, 1 - note_age / note_lifetime)
		note_angle += note_angle_speed

		if (note_age >= note_lifetime)
			instance_destroy()
	}

	if (!bench_settings.music_autoplay)
		return 0

	var slist = bench_settings.music_list;
	if (audio_exists(bench_settings.music_play_index) && audio_is_playing(bench_settings.music_play_index))
	{
		// Spawn notes while playing
		if (bench_music_mode)
		{
			if (bench_settings.music_note_next = 0)
				bench_settings.music_note_next = current_time + irandom_range(250, 1500)
			else if (current_time >= bench_settings.music_note_next)
			{
				var note, dir, distance;
				dir = random(360)
				distance = 32
				note = new_obj(obj_note)
				note.note_age = 0.0
				note.note_lifetime = 60.0
				note.x = bench_settings.posx - 51 + lengthdir_x(distance, dir)
				note.y = bench_settings.posy + 43 + lengthdir_y(distance, dir)
				note.note_speed_x = lengthdir_x(random_range(.2, .5), dir)
				note.note_speed_y = lengthdir_y(random_range(.2, .5), dir)
				note.note_scale = random_range(1.5, 2.5)
				note.note_angle = random_range(-15, 15)
				note.note_angle_speed = random_range(-0.5, 0.5)
				note.note_color = make_color_hsv(irandom(255), 200, 255)
				note.note_alpha = 1.0
				bench_settings.music_note_next = current_time + irandom_range(800, 1200)
			}
		}
		return 0
	}

	if (!bench_music_mode)
	{
		bench_settings.music_autoplay = false
		return 0
	}

	if (!instance_exists(bench_settings.music_res))
	{
		bench_music_mode = false
		return 0
	}

	// Shuffle filtered music list
	var history, candidates, row, selected, musicmode, playlist;
	history = bench_settings.music_history
	playlist = slist.display_list
	candidates = ds_list_create()
	for (var i = 0; i < ds_list_size(playlist); i++)
	{
		row = playlist[|i]
		if (ds_list_find_index(history, row[2]) < 0)
			ds_list_add(candidates, row)
	}

	if (ds_list_empty(candidates))
	{
		selected = slist.selected
		for (var i = 0; i < ds_list_size(playlist); i++)
		{
			row = playlist[|i]
			if (ds_list_size(playlist) = 1 || row[2] != selected)
				ds_list_add(candidates, row)
		}
	}

	if (ds_list_empty(candidates))
	{
		ds_list_destroy(candidates)
		bench_settings.music_autoplay = false
		bench_music_mode = false
		return 0
	}

	row = candidates[|irandom(ds_list_size(candidates) - 1)]
	ds_list_destroy(candidates)
	musicmode = bench_music_mode
	
	if (action_bench_sound(row) = 0)
	{
		bench_settings.music_autoplay = false
		bench_music_mode = false
	}
	else
	{
		var scrollvalue = slist.scroll.value;
		if (sortlist_view(slist, row))
			slist.scroll.value = clamp(scrollvalue, slist.scroll.value_goal - list_center_max, slist.scroll.value_goal + list_center_max)
		bench_music_mode = musicmode
	}
}
