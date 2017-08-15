/// block_load_model_file_event_destroy()

if (texture_map != null)
	ds_map_destroy(texture_map)
	
for (var e = 0; e < element_amount; e++)
	with (element[e])
		instance_destroy()