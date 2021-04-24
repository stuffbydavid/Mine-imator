/// execute(file, parameters, wait)
/// @arg file
/// @arg parameters
/// @arg wait

function execute(file, parameters, wait)
{
	log("execute", file, parameters, wait)
	external_call(lib_execute, file, parameters, wait)
}
