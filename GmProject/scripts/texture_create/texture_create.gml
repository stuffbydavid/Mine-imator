/// @arg filename
/// @arg [render]
/// @arg [usepage]

function texture_create(fn, render = true, usepage = true)
{
	if (!file_exists_lib(fn))
		return texture_create_missing(16, render, usepage)
	
	var tex = sprite_add_lib(fn);
	if (!usepage)
	{
		sprite_set_texture_page(tex, false)
		return tex
	}

	return texture_page_add_res(tex, render)
}
