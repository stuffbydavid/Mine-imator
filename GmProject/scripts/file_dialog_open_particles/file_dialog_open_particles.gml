function file_dialog_open_particles()
{
	return file_dialog_open(text_get("file_dialog/open/particles") + " (*.miparticles; *.zip; *.particles)|*miparticles;*.zip;*.particles;", "", particles_directory, text_get("file_dialog/open/particle_caption"))
}
