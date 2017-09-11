/// keyframes_save()
/// @desc Export the selected keyframes. All selected keyframes must be of the same timeline/model.

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

json_export_var_bool("is_model", ismodel)
json_export_var("tempo", project_tempo)
json_export_var("length", lastpos - firstpos)

json_export_array_start("keyframes")

with (obj_keyframe)
{
	if (!selected)
		continue
	
	json_export_object_start()
	
		json_export_var("position", position - firstpos)
		if (ismodel && timeline.part_of != null)
			json_export_var("part_name", timeline.model_part_name)
			
		project_save_values("values", value, timeline.value_default)
	
	json_export_object_done()
}

json_export_array_done()
	
project_save_objects()
project_save_done()

log("Keyframes saved")