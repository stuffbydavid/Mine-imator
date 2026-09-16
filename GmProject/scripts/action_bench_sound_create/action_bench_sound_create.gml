/// action_bench_sound_create()

function action_bench_sound_create()
{
	if (history_undo)
	{
		// Undo sound action
		var hobj, tl, kf;
		hobj = history_data
		tl = save_id_find(hobj.sound_track_save_id)
		if (instance_exists(tl))
		{
			if (hobj.sound_track_created)
			{
				with (tl)
				{
					tl_remove_clean()
					instance_destroy()
				}
			}
			else if (hobj.sound_keyframe_index < ds_list_size(tl.keyframe_list))
			{
				kf = tl.keyframe_list[|hobj.sound_keyframe_index]
				if (hobj.sound_keyframe_created)
					with (kf)
						instance_destroy()
				else
				{
					kf.value[e_value.SOUND_OBJ] = save_id_find(hobj.sound_keyframe_old_res_save_id)
				}
			}
			if (!hobj.sound_track_created)
				with (tl)
					tl_update_values()
		}

		if (hobj.sound_res_created)
			with (hobj)
				history_destroy_loaded()
	}
	else
	{
		// Create or redo sound action
		var hobj, tl, res, kf;
		hobj = history_data
		tl = null
		res = null
		kf = null

		if (history_redo)
		{
			// Restore audio track
			bench_tab = hobj.bench_tab
			history_restore_bench(hobj.bench_save_obj)
			
			if (hobj.sound_track_created)
				tl = new_tl(e_tl_type.AUDIO_TRACK)
			else
				tl = save_id_find(hobj.sound_track_save_id)
		}
		else
		{
			// Read selected sound
			var sound;
			sound = bench_settings.sound_list_current.select
			if (!is_array(sound))
				return 0

			if (is_string(sound[2]))
			{
				var source = minecraft_java_directory_get() + "/assets/objects/" + string_copy(sound[2], 1, 2) + "/" + sound[2];
				if (!file_exists_lib(source))
					return 0
			}
			else if (!instance_exists(sound[2]) || sound[2].type != e_res_type.SOUND)
				return 0

			if (bench_settings.sound_list_current.source = "music")
			{
				if (!bench_music_mode)
					bench_music_stop()
			}
			else
				bench_sound_stop()

			hobj = history_set(action_bench_create)
			hobj.bench_save_obj = history_save_bench()
			hobj.bench_tab = bench_tab
			hobj.sound_track_created = bench_settings.audio_track == null
			if (hobj.sound_track_created)
				tl = new_tl(e_tl_type.AUDIO_TRACK)
			else
				tl = bench_settings.audio_track
			
			hobj.sound_track_save_id = tl.save_id
			hobj.sound_hash = is_string(sound[2]) ? sound[2] : ""
			hobj.sound_res_save_id = is_string(sound[2]) ? "" : sound[2].save_id
			hobj.sound_res_created = false
			
			if (hobj.sound_hash != "")
			{
				// Reuse matching project resource
				var otherres;
				for (var i = 0; i < ds_list_size(res_list.list); i++)
				{
					otherres = res_list.list[|i]
					if (otherres.type = e_res_type.SOUND && otherres.minecraft_hash = hobj.sound_hash)
					{
						res = otherres
						break
					}
				}
				
				if (res != null)
					hobj.sound_res_save_id = res.save_id
				else
				{
					// Name copied Minecraft sound
					var split, name, filename;
					split = string_split_escaped(sound[1], " / ")
					name = split[array_length(split) - 1]
					filename = filename_name(filename_get_unique(project_folder + "/" + filename_get_valid(name) + ".ogg"))
					hobj.sound_display_name = filename_new_ext(filename, "")
					hobj.sound_filename = filename
				}
			}
		}

		if (!instance_exists(tl))
			return 0

		if (hobj.sound_hash != "")
		{
			if (hobj.sound_res_created || hobj.sound_res_save_id = "")
			{
				// Copy Minecraft sound to project
				var source, destination, filename;
				source = minecraft_java_directory_get() + "/assets/objects/" + string_copy(hobj.sound_hash, 1, 2) + "/" + hobj.sound_hash
				filename = hobj.sound_filename
				destination = project_folder + "/" + filename
				if (!file_exists_lib(source))
					return 0
					
				file_copy_lib(source, destination)
				if (!file_exists_lib(destination))
					return 0
					
				res = new_obj(obj_resource)
				res.type = e_res_type.SOUND
				res.filename = filename
				res.minecraft_hash = hobj.sound_hash
				res.copied = true
				res.loaded = true
				
				load_folder = project_folder
				save_folder = project_folder
				with (res)
					res_load()
				
				res.display_name = hobj.sound_display_name
				sortlist_add(res_list, res)
				
				hobj.sound_res_save_id = res.save_id
				if (!history_redo)
				{
					hobj.sound_res_created = true
					with (hobj)
						history_save_loaded()
				}
			}
			else
				res = save_id_find(hobj.sound_res_save_id)
		}
		else
			res = save_id_find(hobj.sound_res_save_id)

		if (!instance_exists(res))
			return 0

		if (history_redo)
		{
			// Restore sound keyframe
			var pos, kfcreated;
			pos = hobj.sound_keyframe_pos
			kfcreated = hobj.sound_keyframe_created
			if (kfcreated)
			{
				with (tl)
					kf = tl_keyframe_add(pos)
			}
			else if (hobj.sound_keyframe_index < ds_list_size(tl.keyframe_list))
				kf = tl.keyframe_list[|hobj.sound_keyframe_index]
		}
		else
		{
			// Find open keyframe position
			var pos, kfcreated, found;
			pos = round(timeline_marker)
			kfcreated = false
			while (kf = null)
			{
				found = false
				for (var i = 0; i < ds_list_size(tl.keyframe_list); i++)
				{
					var otherkf = tl.keyframe_list[|i]
					if (otherkf.value[e_value.SOUND_OBJ] != null)
					{
						if (pos >= otherkf.position && pos < otherkf.position + tl_keyframe_length(otherkf) + 1)
						{
							pos = otherkf.position + max(0, tl_keyframe_length(otherkf)) + 1
							found = true
							break
						}
						
						if (pos < otherkf.position && pos + ceil(res.sound_samples / sample_rate * project_tempo) + 1 > otherkf.position)
						{
							pos = otherkf.position + max(0, tl_keyframe_length(otherkf)) + 1
							found = true
							break
						}
					}

					if (otherkf.position != pos)
						continue

					if (otherkf.value[e_value.SOUND_OBJ] = null)
					{
						kf = otherkf
						break
					}

				}

				if (!found && kf = null)
				{
					with (tl)
						kf = tl_keyframe_add(pos)
					kfcreated = true
				}
			}
			hobj.sound_keyframe_pos = kf.position
			hobj.sound_keyframe_created = kfcreated
			hobj.sound_keyframe_index = ds_list_find_index(tl.keyframe_list, kf)
			hobj.sound_keyframe_old_res_save_id = save_id_get(kf.value[e_value.SOUND_OBJ])
		}

		if (kf = null)
			return 0

		// Assign sound to keyframe
		kf.value[e_value.SOUND_OBJ] = res
		
		with (tl)
			tl_update_values()
	}

	tl_update_length()
	tl_update_list()
	tl_update_matrix()
	project_update_counts()
	lib_preview.update = true
	project_reset_loaded()
}
