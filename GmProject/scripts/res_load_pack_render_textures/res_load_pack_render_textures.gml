/// @desc Copies rendering sprites into the resource pack texture page.

function res_load_pack_render_textures()
{
	if (pack_sprite_texture_map != null)
	{
		var key = ds_map_find_first(pack_sprite_texture_map);
		while (!is_undefined(key))
		{
			texture_free(pack_sprite_texture_map[?key])
			key = ds_map_find_next(pack_sprite_texture_map, key)
		}
		
		ds_map_destroy(pack_sprite_texture_map)
	}
	
	pack_sprite_texture_map = ds_int_map_create()
	
	var sprites = [
		spr_default_material,
		spr_default_normal,
		spr_shape,
		spr_fog,
		spr_stars,
		spr_blue_noise
	];
	
	for (var i = 0; i < array_length(sprites); i++)
		pack_sprite_texture_map[?sprites[i]] = texture_duplicate(sprites[i])
	
	res_clear_pack_res_textures()
	
	if (pack_res_texture_map = null)
		pack_res_texture_map = ds_int_map_create()
	
	var key = ds_map_find_first(texture_res_map);
	while (!is_undefined(key))
	{
		res_add_pack_res_texture(key)
		key = ds_map_find_next(texture_res_map, key)
	}
}
