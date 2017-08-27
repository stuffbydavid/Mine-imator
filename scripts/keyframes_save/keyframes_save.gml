/// keyframes_save()
/// @desc Export the selected keyframes
/*
var tlchar, tllast, name, fn, num, firstpos, lastpos;

// Character animation?
tlchar = false
tllast = null
with (obj_keyframe)
{
	if (select)
	{
		if (tllast && tl != tllast)  
			tlchar = true
		tllast = tl
	}
}

// Save name
if (tlchar && tl_edit.part_of)
	name = tl_edit.part_of.display_name
else
	name = tl_edit.display_name
	
fn = file_dialog_save_keyframes(name)

if (fn = "")
	return 0
	
log("Saving keyframes")
	
fn = filename_new_ext(fn, ".keyframes")
project_write_start(false)
save_folder = filename_dir(fn)
load_folder = project_folder
log("load_folder", load_folder)
log("save_folder", save_folder)

// Get offset and number of keyframes
num = 0
firstpos = null
lastpos = null
with (obj_keyframe)
{
	if (select)
	{
		tl_keyframe_save(id)
		if (firstpos = null || pos < firstpos)
			firstpos = pos
		lastpos = max(pos, lastpos)
		num++
	}
}

// Write data
buffer_write_byte(tlchar)
buffer_write_byte(project_tempo)
buffer_write_int(num)
buffer_write_int(lastpos - firstpos)

with (obj_keyframe)
{
	if (select)
	{
		buffer_write_int(pos - firstpos)
		buffer_write_int(tl.bodypart)
		project_write_value_types(tl)
		project_write_values(tl)
	}
}
	
project_write_objects()

buffer_save_lib(buffer_current, fn)
buffer_delete(buffer_current)
*/