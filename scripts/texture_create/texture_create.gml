/// texture_create(filename)
/// @arg filenam
function texture_create(fn)
{
	if (!file_exists_lib(fn))
		return texture_create_missing()
	
	return sprite_add_lib(fn)
}
