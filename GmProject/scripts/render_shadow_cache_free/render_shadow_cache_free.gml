/// render_shadow_cache_free()

function render_shadow_cache_free()
{
	var key = ds_map_find_first(render_shadow_cache)
	while (!is_undefined(key))
	{
		var nextkey = ds_map_find_next(render_shadow_cache, key)
		render_shadow_cache_remove(key)
		key = nextkey
	}
}