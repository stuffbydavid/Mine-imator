/// render_surface_pool_clear()

function render_surface_pool_clear()
{
	render_surface = array_create(3, null)
	render_surface_hdr = array_create(2, null)
	render_surface_hdr_post = array_create(3, null)
	render_surface_blur = array_create(6, null)
	render_surface_blur_temp = array_create(6, null)
	render_surface_post = array_create(2, null)
	render_surface_specular_base = null

	render_surface_depth = null
	render_surface_depth_low = null
	render_surface_normal = null
	render_surface_material = null
	render_surface_diffuse = null
	render_surface_mask = null

	render_surface_shadows = null
	render_surface_specular = null
	render_surface_fog = null
	render_surface_sss = null
	render_surface_sss_range = null
	render_surface_glow = null
	render_surface_indirect_raydata = null
	render_surface_reflections_raydata = null
	render_surface_lens = null
	render_grain_noise = null
	render_surface_samples = null
	render_gbuffers_cache_ready = false

	render_surface_sun_buffer = array_create(3, null)
	render_surface_spot_buffer = null
	render_surface_point_buffer = null
	render_surface_point_atlas_buffer = null
	render_shadow_cache = null
	render_shadow_cache_ready = null
}
