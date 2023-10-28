/// temp_update_armor(temp)
/// @arg temp

function temp_update_armor(temp)
{
	if (temp.model_name != "armor")
		return 0
	
	// Copy states into armor data array
	var state, type;
	state = ""
	type = ""
	
	for (var i = 0; i < array_length(temp.model_state); i += 2)
	{
		state = temp.model_state[i]
		type = temp.model_state[i + 1]
		
		if (state = "helmet")
			temp.armor_array[0] = type
		else if (state = "chestplate")
			temp.armor_array[4] = type
		else if (state = "leggings")
			temp.armor_array[8] = type
		else if (state = "boots")
			temp.armor_array[12] = type
	}
	
	array_add(armor_update, temp)
}