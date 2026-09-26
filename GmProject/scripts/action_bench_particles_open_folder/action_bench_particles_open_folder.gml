/// action_bench_particles_open_folder()

function action_bench_particles_open_folder()
{
	open_url(bench_particle_preset_folder = "project" ? project_folder : (particles_directory + bench_particle_preset_folder))
}
