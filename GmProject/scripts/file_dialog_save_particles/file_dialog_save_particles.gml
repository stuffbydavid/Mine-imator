/// file_dialog_save_particles(filename)
/// @arg filename

function file_dialog_save_particles(fn)
{
	return file_dialog_save(text_get("filedialogsaveparticles") + " (*.miparticles)|*.miparticles", filename_get_valid(fn), particles_directory, text_get("filedialogsaveparticlescaption"))
}
