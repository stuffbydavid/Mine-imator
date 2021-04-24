/// texture_export(texture, filename)
/// @arg texture
/// @arg filename

function texture_export(tex, fn)
{
	return sprite_save_lib(tex, 0, fn)
}
