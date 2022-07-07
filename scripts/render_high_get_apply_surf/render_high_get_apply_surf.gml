/// render_high_get_apply_surf()
/// @desc Updates which target the final surface should be on

function render_high_get_apply_surf()
{
	render_post_index = !render_post_index
	
	// Cursed, but we're not using these surfaces anymore at this point in rendering.
	if (render_post_index)
	{
		render_surface_emissive = surface_require(render_surface_emissive, render_width, render_height)
		return render_surface_emissive
	}
	else
	{
		render_surface_diffuse = surface_require(render_surface_diffuse, render_width, render_height)
		return render_surface_diffuse
	}
}
