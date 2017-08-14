/// model_unload()

if (!loaded)
	return 0
	
for (var p = 0; p < part_amount; p++)
	with (part[p])
		instance_destroy()

loaded = false