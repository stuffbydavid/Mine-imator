/// render_shadow_cache_free()

function render_shadow_cache_free()
{
	var keys = []
	var key = ds_map_find_first(render_shadow_cache)
	while (!is_undefined(key))
	{
		keys = array_add(keys, key)
		key = ds_map_find_next(render_shadow_cache, key)
	}
	for (var i = 0; i < array_length(keys); i++)
		render_shadow_cache_remove(keys[i])
}