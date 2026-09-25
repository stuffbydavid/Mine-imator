/// render_free()

function render_free()
{
	render_surface_pool_save()

	for (var i = 0; i < ds_list_size(render_surface_pool_list); i++)
		render_surface_pool_free(render_surface_pool_list[|i])
	ds_list_clear(render_surface_pool_list)
	render_surface_pool_current = null
	render_surface_pool_clear()

	// Render passes are transient and are cleared at the start of each render
	surface_free(render_pass_surf)
	render_pass_surf = null
	for (var pass = 0; pass < array_length(render_pass_surfs); pass++)
		surface_free(render_pass_surfs[pass])
	render_pass_surfs = array_create(e_render_pass.amount, null)
}
