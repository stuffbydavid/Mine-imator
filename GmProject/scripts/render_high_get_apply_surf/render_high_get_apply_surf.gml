/// render_high_get_apply_surf([hdr])
/// @desc Updates which target the final surface should be on

function render_high_get_apply_surf(hdr = false)
{
	render_post_index = !render_post_index

	if (hdr)
	{
		var index = render_post_index ? 0 : 1;
		render_surface_hdr[index] = surface_require(render_surface_hdr[index], render_width, render_height, true, e_surface_format.rgba16float)
		return render_surface_hdr[index]
	}
	
	// Keep cached G-buffers intact while post effects use separate targets
	if (render_post_index)
	{
		if (render_gbuffers_cache_enabled || renderer_current = e_renderer.QUICK)
		{
			render_surface_post[0] = surface_require(render_surface_post[0], render_width, render_height)
			return render_surface_post[0]
		}
		render_surface_material = surface_require(render_surface_material, render_width, render_height)
		return render_surface_material
	}
	else
	{
		if (render_gbuffers_cache_enabled || renderer_current = e_renderer.QUICK)
		{
			render_surface_post[1] = surface_require(render_surface_post[1], render_width, render_height)
			return render_surface_post[1]
		}
		render_surface_diffuse = surface_require(render_surface_diffuse, render_width, render_height)
		return render_surface_diffuse
	}
}
