/// render_high_get_apply_surf()
/// @desc Updates which slot the final surface should be on

function render_high_get_apply_surf()
{
	var surf;
	
	if (render_effects_done)
	{
		render_target = surface_require(render_target, render_width, render_height)
		surf = render_target
	}
	else
	{
		render_surface_post[render_post_index] = surface_require(render_surface_post[render_post_index], render_width, render_height)
		surf = render_surface_post[render_post_index]
		render_post_index = !render_post_index
	}
	
	return surf
}
