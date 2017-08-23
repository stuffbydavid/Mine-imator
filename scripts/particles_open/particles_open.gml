/// particles_open(filename, template)
/// @arg filename
/// @arg template
/// @desc Opens .particles into the given template.

var fn, temp, hobj;
hobj = null

if (history_undo)
{
	temp = iid_find(history_data.temp)
	with (temp)
		temp_particles_type_clear()
	with (history_data)
	{
		history_destroy_loaded()
		temp_particles_copy(temp)
	}
	with (temp)
	{
		pc_types = 0
		for (var t = 0; t < history_data.pc_types; t++)
			history_restore_ptype(history_data.pc_type[t], id)
		temp_particles_restart()
	}
	tab_template_editor_update_ptype_list()
	return 0
}
else if (history_redo)
{
	fn = history_data.filename
	temp = iid_find(history_data.temp)
}
else
{
	fn = argument0
	temp = argument1
}

if (filename_ext(fn) = ".zip") // Unzip
{
	var name = filename_new_ext(filename_name(fn), "");
	zip_import(fn)
	
	fn = file_find_single(unzip_directory, ".particles")
	if (!file_exists_lib(fn))
		fn = file_find_single(unzip_directory + name + "\\", ".particles")
	
	if (!file_exists_lib(fn))
	{
		error("erroropenparticleszip")
		return 0
	}
}

if (!file_exists_lib(fn))
	return 0
	
if (!history_redo && temp != bench_settings)
{
	hobj = history_set(particles_open)
	with (hobj)
	{
		filename = fn
		id.temp = iid_get(temp)
	}
	with (temp)
	{
		temp_particles_copy(hobj)
		for (var t = 0; t < pc_types; t++)
			hobj.pc_type[t] = history_save_ptype(pc_type[t])
	}
}

log("Opening particles", fn)

buffer_current = buffer_import(fn)
save_folder = project_folder
load_folder = filename_dir(fn)
load_format = buffer_read_byte()

log("save_folder", save_folder)
log("load_folder", load_folder)
log("load_format", load_format)

if (load_format > project_format)
{
	log("Too new")
	error("erroropenparticlesnewer")
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

project_read_start()
with (temp)
{
	temp_particles_type_clear()
	project_read_particles()
	temp_particles_restart()
}
project_read_objects()
project_read_get_iids(true)

with (hobj)
	history_save_loaded()

project_read_update()

buffer_delete(buffer_current)
tab_template_editor_update_ptype_list()

log("Particles loaded")
