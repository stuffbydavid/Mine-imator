/// render_surface_pool_event_create()

function render_surface_pool_event_create()
{
	used = true
	owner = null
	owner_label = ""
	width = 0
	height = 0

	surface = array_create(3, null)
	surface_hdr = array_create(2, null)
	surface_hdr_post = array_create(3, null)
	surface_blur = array_create(6, null)
	surface_blur_temp = array_create(6, null)
	surface_post = array_create(2, null)
	surface_specular_base = null

	surface_depth = null
	surface_depth_low = null
	surface_normal = null
	surface_material = null
	surface_diffuse = null
	surface_mask = null

	surface_shadows = null
	surface_specular = null
	surface_fog = null
	surface_sss = null
	surface_sss_range = null
	surface_glow = null
	surface_indirect_raydata = null
	surface_reflections_raydata = null
	surface_lens = null
	grain_noise = null
	surface_samples = null
	gbuffers_cache_ready = false

	surface_sun_buffer = array_create(3, null)
	surface_spot_buffer = null
	surface_point_buffer = null
	surface_point_atlas_buffer = null
	shadow_cache = ds_map_create()
	shadow_cache_ready = ds_map_create()
}
