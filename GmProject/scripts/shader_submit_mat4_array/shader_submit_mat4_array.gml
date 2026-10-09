/// CppSeparate void shader_submit_mat4_array(IntType, ArrType)
/// @arg index
/// @arg array

function shader_submit_mat4_array(index, arr)
{
	var floats = [ 16 * array_length(arr) ];
	for (var m = 0; m < array_length(arr); m++)
		for (var i = 0; i < 16; i++)
			floats[m * 16 + i] = arr[@m][@i]
	
	shader_set_uniform_f_array(index, floats)
}
