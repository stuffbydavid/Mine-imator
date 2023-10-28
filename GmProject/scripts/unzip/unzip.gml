/// unzip(filename, [directory])
/// @arg filename
/// @arg [directory]

function unzip(fn, dir = unzip_directory)
{
	var ret = directory_delete_lib(dir);
	directory_create_lib(dir)
	
	log("Unzipping", fn, dir)
	var num = external_call(lib_unzip, fn, dir)
	log(string(num) + " files were extracted")
	return num
}
