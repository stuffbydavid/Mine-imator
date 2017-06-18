/// block_load_model_event_destroy()

if (textures)
	ds_map_destroy(textures)
	
for (var e = 0; e < element_amount; e++)
	with (element[e])
		instance_destroy()