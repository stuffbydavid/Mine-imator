/// open_url(url)
/// @arg url

function open_url(url)
{
	log("Open URL", url)
	external_call(lib_open_url, url)
}
