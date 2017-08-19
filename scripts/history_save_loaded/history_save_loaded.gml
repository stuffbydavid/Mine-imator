/// history_save_loaded()
/// @desc Stores the newly loaded objects.

loaded_amount = 0

with (obj_template)
{
	if (!loaded)
		continue
		
	other.loaded_save_id[other.loaded_amount] = save_id
	other.loaded_amount++
}

with (obj_timeline)
{
	if (!loaded)
		continue
		
	other.loaded_save_id[other.loaded_amount] = save_id
	other.loaded_amount++
}

with (obj_resource)
{
	if (!loaded)
		continue
		
	other.loaded_save_id[other.loaded_amount] = save_id
	other.loaded_amount++
}
