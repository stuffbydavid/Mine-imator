/// @arg filename

function file_dialog_save_particles(fn)
{
	return file_dialog_save(text_get("file_dialog/save/particles") + " (*.miparticles)|*.miparticles", filename_get_valid(fn), particles_directory, text_get("file_dialog/save/particles_caption"))
}
