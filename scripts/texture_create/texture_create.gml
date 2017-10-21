/// texture_create(filename)
/// @arg filename

var fname = argument0;

if (!file_exists_lib(fname))
	return texture_create_missing()
	
if (texture_lib)
	return external_call(lib_texture_create, fname)
else
	return sprite_add_lib(fname)