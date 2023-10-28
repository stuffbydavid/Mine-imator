/// keyframes_save()
/// @desc Export the selected keyframes. All selected keyframes must be of the same timeline/model.

function keyframes_save()
{
	// Character animation?
	var ismodel, tllast;
	ismodel = false
	tllast = null
	with (obj_keyframe)
	{
		if (!selected)
			continue
		
		if (tllast != null && timeline != tllast)
			ismodel = true
		tllast = timeline
	}
	
	// Save name
	var name;
	if (ismodel && tl_edit.part_of != null)
		name = tl_edit.part_of.display_name
	else
		name = tl_edit.display_name
	
	var fn = file_dialog_save_keyframes(name);
	if (fn = "")
		return 0
	
	fn = filename_new_ext(fn, ".miframes")
	log("Saving keyframes", fn)
	
	save_folder = filename_dir(fn)
	load_folder = project_folder
	log("load_folder", load_folder)
	log("save_folder", save_folder)
	
	project_save_start(fn, false)
	
	// Get offset and number of keyframes
	var firstpos, lastpos;
	firstpos = null
	lastpos = null
	with (obj_keyframe)
	{
		if (!selected)
			continue
		
		tl_keyframe_save(id)
		if (firstpos = null || position < firstpos)
			firstpos = position
		lastpos = max(position, lastpos)
	}
	
	json_save_var_bool("is_model", ismodel)
	json_save_var("tempo", project_tempo)
	json_save_var("length", lastpos - firstpos)
	
	json_save_array_start("keyframes")
	
	with (obj_keyframe)
	{
		if (!selected)
			continue
		
		json_save_object_start()
		
			json_save_var("position", position - firstpos)
			if (ismodel && timeline.part_of != null)
				json_save_var("part_name", timeline.model_part_name)
			
			keyframe_update_item_name()
			project_save_values("values", value, timeline.value_default)
			
		json_save_object_done()
	}
	
	json_save_array_done()
	
	project_save_objects()
	project_save_done()
	
	log("Keyframes saved")
}
