/// @desc Returns the rendering copy of a sprite in the current pack.
/// @arg texture

function render_get_pack_texture(tex)
{
	if (render_pack_current = null || render_pack_current.pack_sprite_texture_map = null)
		return tex
	
	var map, packedtex;
	map = render_pack_current.pack_sprite_texture_map
	packedtex = map[?tex]
	if (!is_undefined(packedtex))
		return packedtex
	
	if (!sprite_exists(tex) ||
		(texture_width(tex) > texture_page_res_threshold && texture_height(tex) > texture_page_res_threshold))
		return tex
	
	if (!ds_map_exists(texture_res_map, tex))
		return tex
	
	with (render_pack_current)
		res_add_pack_res_texture(tex)
	
	map = render_pack_current.pack_res_texture_map
	if (map != null)
	{
		packedtex = map[?tex]
		
		if (!is_undefined(packedtex))
			return packedtex
	}
	
	return tex
}
