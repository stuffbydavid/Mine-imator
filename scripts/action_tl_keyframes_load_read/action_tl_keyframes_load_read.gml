/// action_tl_keyframes_load_read(filename, timeline, insertposition, maxlength)
/// @arg filename
/// @arg timeline
/// @arg insertposition
/// @arg maxlength
/*
/// TODO
var fn, tl, insertpos, maxlen;
var tlchar, tempo, temposcale, num, len;
fn = argument0
tl = argument1
insertpos = argument2
maxlen = argument3

// Read
buffer_current = buffer_load_lib(fn)
save_folder = project_folder
load_folder = filename_dir(fn)
load_format = buffer_read_byte()
debug("Loading keyframes " + fn + " with format ", load_format)

if (load_format > project_format)
{
	log("Too new")
	error("erroropenassetnewer")
	buffer_delete(buffer_current)
	return 0
}
else if (load_format < project_05) // Too old
{
	log("Too old")
	error("errorfilecorrupted")
	buffer_delete(buffer_current)
	return 0
}
	
// Start
project_read_start()

// Get info
tlchar = buffer_read_byte()							debug("tlchar", tlchar)
tempo = buffer_read_byte()							debug("tempo", tempo)
temposcale = (project_tempo / tempo)
num = buffer_read_int()								debug("num", num)
len = max(1, round(temposcale * buffer_read_int())) debug("len", len)

if (tlchar && tl.part_of)
	tl = tl.part_of
	
// Read keyframes
repeat (num)
{
	var pos, bp, dummytypes, tladd;
	debug("Keyframe") debug_indent++
	pos = round(temposcale * buffer_read_int())		debug("pos", pos)
	bp = buffer_read_int()							debug("bp", bp)
	
	// Dummy for storing keyframe value types
	dummytypes = new(obj_dummy)
	with (dummytypes)
		project_read_value_types()
	
	// Add to a body part?
	if (tlchar && bp != null)
	{
		if (bp > tl.part_amount)
			tladd = null
		else
			tladd = tl.part[bp]
	}
	else
		tladd = tl
	
	// Off limits
	if (maxlen != null && pos > maxlen - tempo * 0.2)
		tladd = null
	
	if (tladd) // Create
	{
		var newkf = new(obj_keyframe);
		with (newkf)
		{
			select = false
			loaded = true
			for (var v = 0; v < e_value.amount; v++)
				value[v] = tladd.value_default[v]
			project_read_values(dummytypes)
		}
		with (tladd)
			tl_keyframe_add(insertpos + pos, newkf)
		tl_keyframe_select(newkf)
	}
	else // Throw away
	{
		with (new(obj_dummy))
		{
			project_read_values(dummytypes)
			instance_destroy()
		}
	}
	
	with (dummytypes)
		instance_destroy()
	
	debug_indent--
}

project_read_objects()
project_read_get_iids(true)

buffer_delete(buffer_current)

return insertpos + len
*/