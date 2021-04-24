/// model_file_matrix_map_create(modelfile, mat, hidelist)
/// @arg modelfile
/// @arg mat
/// @arg hidelist
/// @desc Creates a map for part matrices to use in the world.

function model_file_matrix_map_create(modelfile, mat, hidelist)
{
	var map = ds_map_create();
	
	for (var p = 0; p < ds_list_size(modelfile.part_list); p++)
		model_file_matrix_map_add_part(modelfile.part_list[|p], mat, map, hidelist)
	
	return map
}
