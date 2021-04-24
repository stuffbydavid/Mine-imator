/// action_res_preview_pack_particles(particle)
/// @arg particle

function action_res_preview_pack_particles(particle)
{
	res_preview.pack_particles = particle
	res_preview.update = true
	res_preview.reset_view = true
}
