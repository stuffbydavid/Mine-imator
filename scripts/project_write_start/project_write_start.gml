/// project_write_start(saveall)
/// @arg saveall

buffer_current = buffer_create(8, buffer_grow, 1)
buffer_write_byte(project_format)

with (obj_template)
	save = argument0
	
with (obj_timeline)
	save = argument0
	
with (obj_resource)
	save = argument0
