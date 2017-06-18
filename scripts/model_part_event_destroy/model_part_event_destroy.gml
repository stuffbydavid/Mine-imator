/// model_part_event_destroy()

if (shape_vbuffer != null)
	vbuffer_destroy(shape_vbuffer)
if (shape_bend_vbuffer != null)
	vbuffer_destroy(shape_bend_vbuffer)
			
for (var s = 0; s < shape_amount; s++)
	with (shape[s])
		instance_destroy()
	
for (var p = 0; p < part_amount; p++)
	with (part[p])
		instance_destroy()