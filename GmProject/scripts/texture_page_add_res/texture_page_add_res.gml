/// @desc Tracks custom sprites and creates pack-local rendering copies unless the dimensions exceed the threshold.
/// @arg texture
/// @arg [render]

function texture_page_add_res(tex, render = true)
{
	if (!sprite_exists(tex))
		return tex
	
	if (!render)
	{
		texture_page_add(tex, texture_page_ui)
		return tex
	}
	
	if (texture_page_get_current() > texture_page_res)
		return tex
		
	var large = (texture_width(tex) > texture_page_res_threshold && texture_height(tex) > texture_page_res_threshold);
	texture_page_add(tex, large ? texture_page_res : texture_page_ui)
	
	texture_res_map[?tex] = true
	
	if (!large)
		with (obj_resource)
			res_add_pack_res_texture(tex)
	
	return tex
}
