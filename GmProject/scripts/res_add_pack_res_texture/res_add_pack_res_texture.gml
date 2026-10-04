/// @desc Copies a small resource sprite into this resource pack without changing the selected page.
/// @arg texture

function res_add_pack_res_texture(tex)
{
	if (pack_texture_page < 0 || pack_res_texture_map = null || ds_map_exists(pack_res_texture_map, tex) || !sprite_exists(tex))
		return 0
	
	if (texture_width(tex) > texture_page_res_threshold && texture_height(tex) > texture_page_res_threshold)
		return 0
	
	var prevpage, packedtex;
	prevpage = texture_page_get_current()
	
	texture_page_set_current(pack_texture_page)
	packedtex = texture_duplicate(tex)
	
	if (sprite_exists(packedtex))
	{
		texture_page_add(packedtex, pack_texture_page)
		pack_res_texture_map[?tex] = packedtex
	}
	
	texture_page_set_current(prevpage)
}
