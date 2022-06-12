/// render_high_get_apply_surf()
/// @desc Updates which slot the final surface should be on

function render_high_get_apply_surf()
{
	render_post_index = !render_post_index
	render_surface_post[!render_post_index] = surface_require(render_surface_post[!render_post_index], render_width, render_height)
	return render_surface_post[!render_post_index]
}
