/// gzunzip(source, destination)
/// @arg source
/// @arg destination

function gzunzip(src, dest)
{
	return external_call(lib_gzunzip, src, dest)
}
