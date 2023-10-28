/// CppSeparate IntType json_load(VarArgs)
/// json_load(filename, [typemap])
/// @arg filename
/// @arg [typemap]
/// @desc Loads a JSON file and stores the structure in a new map.
/// An existing map can be supplied in the second parameter
/// that will be filled with the types of object fields.

function json_load()
{
	buffer_current = buffer_load_lib(argument[0])
	
	if (argument_count > 1)
		json_type_map = argument[1]
	else
		json_type_map = null
	
	json_column = 0
	json_line = 1
	json_error = ""
	
	if (json_load_char())
	{
		if (json_char = e_json_char.CURLY_BEGIN)
			json_load_object(true)
		else
			json_error = "No root object found"
	}
	
	buffer_delete(buffer_current)
	
	if (json_error != "")
	{
		log("JSON ERROR: " + json_error + " on line " + string(json_line) + ", column " + string(json_column))
		return undefined
	}
	
	return json_value
}