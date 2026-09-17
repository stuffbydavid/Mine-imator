/// action_res_preview_pack_particles(particle)
/// @arg particle

function action_res_preview_pack_particles(particle)
{
	preview_edit.pack_particles = particle
	preview_edit.update = true
	preview_edit.reset_view = true
}
