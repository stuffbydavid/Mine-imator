/// temp_update_model_part()
/// @desc Finds the model part from the given model file and name.
/// If it doesn't exist the first part is selected (or null if none).

function temp_update_model_part()
{
	model_part = null
	
	if (model_file = null || model_part_name = "")
		return 0
	
	// Look for the part with the given name
	for (var p = 0; p < ds_list_size(model_file.file_part_list); p++)
	{
		var part = model_file.file_part_list[|p];
		if (part.name = model_part_name)
		{
			model_part = part
			break
		}
	}
	
	// Look for default model body part to select if no name is found
	if (model_part = null)
	{
		for (var p = 0; p < ds_list_size(model_file.file_part_list); p++)
		{
			var part = model_file.file_part_list[|p];
			if (part.name = default_model_part)
			{
				model_part = part
				model_part_name = default_model_part
				break
			}
		}
	}
	
	// Can't find default part either, set to first part
	if (model_part = null && ds_list_size(model_file.file_part_list) > 0)
	{
		model_part = model_file.file_part_list[|0]
		model_part_name = model_part.name
	}
	
	// Update timelines
	with (obj_timeline)
	{
		if (type != e_tl_type.BODYPART || temp != other.id)
			continue
		
		model_part = other.model_part
		model_part_name = other.model_part_name
		update_matrix = true
		tl_update_value_types()
	}
}
