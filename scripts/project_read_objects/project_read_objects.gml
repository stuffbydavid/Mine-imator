/// project_read_objects()

var amount;

amount = buffer_read_int()
log("Templates", amount)
repeat (amount)
	with (new(obj_template))
		project_read_template()
		
amount = buffer_read_int()
log("Timelines", amount)
repeat (amount)
	with (new(obj_timeline))
		project_read_timeline()
		
amount = buffer_read_int()
log("Resources", amount)
repeat (amount)
	with (new(obj_resource))
		project_read_resource()
