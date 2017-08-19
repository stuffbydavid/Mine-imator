/// model_part_event_destroy()

if (shape_vbuffer != null)
	vbuffer_destroy(shape_vbuffer)

if (shape_bend_vbuffer != null)
	vbuffer_destroy(shape_bend_vbuffer)
			
for (var s = 0; s < shape_amount; s++)
	with (shape[s])
		instance_destroy()
	
for (var p = 0; p < ds_list_size(part_list); p++)
	with (part_list[|p])
		instance_destroy()
		
ds_list_destroy(shape_list)
ds_list_destroy(part_list)