/// texture_create(filename)
/// @arg filename

var fname = argument0;

if (!file_exists_lib(fname))
	return texture_create_missing()

return external_call(lib_texture_create, fname)
