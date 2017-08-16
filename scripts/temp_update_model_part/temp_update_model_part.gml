/// temp_update_model_part()
/// @desc Finds the model part from the given model file and name.

if (model_file = null)
{
	model_part = null
	return 0
}

model_part = null
for (var p = 0; p < ds_list_size(model_file.file_part_list); p++)
{
	var part = model_file.file_part_list[|p];
	if (part.name = model_part_name)
	{
		model_part = part
		break
	}
}