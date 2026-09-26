/// render_surface_pool_load(pool)
/// @arg pool

function render_surface_pool_load(pool)
{
	render_surface = pool.surface
	render_surface_hdr = pool.surface_hdr
	render_surface_hdr_post = pool.surface_hdr_post
	render_surface_blur = pool.surface_blur
	render_surface_blur_temp = pool.surface_blur_temp
	render_surface_post = pool.surface_post
	render_surface_specular_base = pool.surface_specular_base

	render_surface_depth = pool.surface_depth
	render_surface_depth_low = pool.surface_depth_low
	render_surface_normal = pool.surface_normal
	render_surface_material = pool.surface_material
	render_surface_diffuse = pool.surface_diffuse
	render_surface_mask = pool.surface_mask

	render_surface_shadows = pool.surface_shadows
	render_surface_specular = pool.surface_specular
	render_surface_fog = pool.surface_fog
	render_surface_sss = pool.surface_sss
	render_surface_sss_range = pool.surface_sss_range
	render_surface_glow = pool.surface_glow
	render_surface_indirect_raydata = pool.surface_indirect_raydata
	render_surface_reflections_raydata = pool.surface_reflections_raydata
	render_surface_lens = pool.surface_lens
	render_grain_noise = pool.grain_noise
	render_surface_samples = pool.surface_samples
	render_gbuffers_cache_ready = pool.gbuffers_cache_ready

	render_surface_sun_buffer = pool.surface_sun_buffer
	render_surface_spot_buffer = pool.surface_spot_buffer
	render_surface_point_buffer = pool.surface_point_buffer
	render_surface_point_atlas_buffer = pool.surface_point_atlas_buffer
	render_shadow_cache = pool.shadow_cache
	render_shadow_cache_ready = pool.shadow_cache_ready
}
