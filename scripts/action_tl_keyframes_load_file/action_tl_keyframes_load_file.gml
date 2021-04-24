 /// action_tl_keyframes_load_file(filename, timeline, insertposition, maxlength)
/// @arg filename
/// @arg timeline
/// @arg insertposition
/// @arg maxlength

function action_tl_keyframes_load_file(fn, tl, insertpos, maxlen)
{
	// Post 1.1.0 (JSON)
	var rootmap, legacy;
	if (string_contains(filename_ext(fn), ".miframes"))
	{
		log("Opening keyframes", fn)
		rootmap = project_load_start(fn)
		if (rootmap = null)
			return false
		
		legacy = false
	}
	
	// Pre 1.1.0 (buffer)
	else
	{
		log("Opening legacy keyframes", fn)
		if (!project_load_legacy_start(fn))
			return false
		
		legacy = true
	}
	
	project_reset_loaded()
	
	save_folder = project_folder
	load_folder = filename_dir(fn)
	
	// Get info
	var ismodel, tempo, temposcale, num, len, kflist, dummy;
	
	if (!legacy)
	{
		ismodel = value_get_real(rootmap[?"is_model"], false)
		tempo = value_get_real(rootmap[?"tempo"], project_tempo)
		temposcale = (project_tempo / tempo)
		kflist = rootmap[?"keyframes"]
		if (ds_list_valid(kflist))
			num = ds_list_size(kflist)
		else
			num = 0
		
		len = value_get_real(rootmap[?"length"], 0)
	}
	else
	{
		ismodel = buffer_read_byte()
		tempo = buffer_read_byte()
		temposcale = (project_tempo / tempo)
		num = buffer_read_int()
		len = buffer_read_int()
		dummy = new_obj(obj_data) // Create dummy for storing keyframe value types
	}
	
	len = max(1, round(temposcale * len))
	
	if (ismodel && tl.part_of != null)
		tl = tl.part_of
	
	// Read keyframes
	for (var k = 0; k < num; k++)
	{
		var pos, partname, kfcurmap, tladd;
		partname = ""
		tladd = tl
		
		if (!legacy)
		{
			kfcurmap = kflist[|k]
			pos = round(temposcale * value_get_real(kfcurmap[?"position"], 0))
			
			// Add to a body part?
			if (!is_undefined(kfcurmap[?"part_name"]))
				partname = kfcurmap[?"part_name"]
		}
		else
		{
			pos = round(temposcale * buffer_read_int())
			var bp = buffer_read_int();
			with (dummy)
				project_load_legacy_value_types()
			
			// Add to a body part?
			if (bp != null)
			{
				// Convert legacy bodypart ID to name and find part's timeline
				var modelpartlist = legacy_model_part_map[?tl.temp.model_name];
				if (!is_undefined(modelpartlist) && bp < ds_list_size(modelpartlist))
					partname = modelpartlist[|bp]
				else
					tladd = null // Throw away if not found
			}
		}
		
		// Find part's timeline
		if (ismodel && partname != "")
			with (tl)
				tladd = tl_part_find(partname)
		
		// Off limits
		if (maxlen != null && pos > maxlen - tempo * 0.2)
			tladd = null
		
		// Create
		if (tladd != null)
		{
			var newkf = new_obj(obj_keyframe);
			with (newkf)
			{
				loaded = true
				selected = false
				for (var v = 0; v < e_value.amount; v++)
					value[v] = tladd.value_default[v]
				
				if (!legacy)
					project_load_values(kfcurmap[?"values"], value)
				else
					project_load_legacy_values(dummy)
				
				// Convert legacy bending
				if (load_format < e_project.FORMAT_113 && tladd.model_part != null && tladd.model_part.bend_part != null)
				{
					var legacyaxis;
					for (legacyaxis = X; legacyaxis <= Z; legacyaxis++)
						if (tladd.model_part.bend_axis[legacyaxis])
							break
					
					value[e_value.BEND_ANGLE_X + legacyaxis] = value[e_value.BEND_ANGLE_LEGACY]
					value[e_value.BEND_ANGLE_LEGACY] = 0
				}
			
				// Set item slot if item name is set
				if (value[e_value.ITEM_NAME] != "")
					value[e_value.ITEM_SLOT] = ds_list_find_index(mc_assets.item_texture_list, value[e_value.ITEM_NAME])
				
				if (value[e_value.ITEM_SLOT] < 0)
					value[e_value.ITEM_SLOT] = ds_list_find_index(mc_assets.item_texture_list, default_item)
			}
			
			with (tladd)
				tl_keyframe_add(insertpos + pos, newkf)
			
			tl_keyframe_select(newkf)
		}
		
		// Throw away
		else if (legacy)
			with (dummy)
				project_load_legacy_values(id)
	}
	
	// Load associated objects (texture or particle attractor references)
	if (!legacy)
		project_load_objects(rootmap)
	else
	{
		project_load_legacy_objects()
		with (dummy)
			instance_destroy()
		buffer_delete(buffer_current)
	}
	
	// Update
	project_load_find_save_ids()
	
	log("Loaded " + string(num) + " keyframes")
	
	return insertpos + len
}
