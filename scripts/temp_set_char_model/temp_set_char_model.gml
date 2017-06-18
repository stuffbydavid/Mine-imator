/// temp_set_char_model(model)
/// @arg model
/// @desc Arranges the timelines of the template to a new model.
// TODO!

char_model = argument0
/*
temp_update_display_name()

with (obj_timeline) { // Rearrange hierarchy
	if (temp != other.id || part_of)
		continue
		
	for (var p = 0; p < part_amount; p++) // Set parent to root
		with (part[p])
			tl_parent_set(other.id)
			
	for (var p = 0; p < part_amount; p++) // Remove unused with 0 keyframe_amount
		with (part[p])
			if (p >= temp.char_model.part_amount && keyframe_amount = 0) 
				instance_destroy()
			
	for (var p = part_amount - 1; p >= 0; p--) { // Trim
		if (part[p])
			break
		part_amount--
	}
	
	for (var p = 0; p < temp.char_model.part_amount; p++) { // Add missing
		if (p < part_amount && part[p])
			continue
		with (new(obj_timeline)) {
			type = "bodypart"
			temp = other.temp
			bodypart = p
			part_of = other.id
			inherit_alpha = true
			inherit_color = true
			value_type_show[POSITION] = temp.char_model.part_show_position[p]
			other.part[p] = id
			other.part_amount = max(other.part_amount, p + 1)
			tl_parent_root()
		}
	}
	
	for (var p = temp.char_model.part_amount - 1; p >= 0; p--) { // Set parents
		var par = temp.char_model.part_parent[p];
		with (part[p]) {
			if (par < 0)
				tl_parent_set(other.id)
			else
				tl_parent_set(other.part[par])
			tl_update_type_name()
			tl_update_display_name()
			tl_update_value_types()
			tl_update_depth()
		}
	}
	
	tl_update_type_name()
	update_matrix = true
}*/
