/// temp_update()

if (type = "char" || type = "spblock" || type = "bodypart")
{
	temp_update_model_state_map()
	temp_update_model()
	if (type = "bodypart")
		temp_update_model_part()
}
else if (type = "item")
	temp_update_item()
else if (type = "block")
{
	temp_update_block_state_map()
	temp_update_block()
}
else if (type_is_shape(type))
	temp_update_shape()

temp_update_rot_point()
temp_update_display_name()