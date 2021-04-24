/// file_dialog_open_particles()

function file_dialog_open_particles()
{
	return file_dialog_open(text_get("filedialogopenparticles") + " (*.miparticles; *.zip; *.particles)|*miparticles;*.zip;*.particles;", "", particles_directory, text_get("filedialogopenparticlecaption"))
}
