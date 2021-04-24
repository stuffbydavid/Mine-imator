/// model_file_matrix_map_add_part(part, mat, map, hidelist)
/// @arg part
/// @arg mat
/// @arg map
/// @arg hidelist

function model_file_matrix_map_add_part(part, mat, map, hidelist)
{
	var partmat;
	
	if (hidelist != null && ds_list_find_index(hidelist, part.name) > -1)
		return 0
	
	partmat = matrix_multiply(part.default_matrix, mat)
	ds_map_add(map, part.name, partmat)
	
	if (part.part_list != null)
	{
		for (var p = 0; p < ds_list_size(part.part_list); p++)
			model_file_matrix_map_add_part(part.part_list[|p], partmat, map, hidelist)
	}
}
