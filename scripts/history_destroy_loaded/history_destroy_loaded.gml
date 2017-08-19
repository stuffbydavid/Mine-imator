/// history_destroy_loaded()
/// @desc Destroy the loaded objects.

for (var i = 0; i < loaded_amount; i++)
	with (save_id_find(loaded_save_id[i]))
		instance_destroy()
