/// history_destroy_loaded()
/// @desc Destroy the loaded objects.

for (var i = 0; i < loaded_amount; i++)
	with (iid_find(loaded[i]))
		instance_destroy()
