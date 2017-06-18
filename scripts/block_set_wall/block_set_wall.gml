/// block_set_wall()

block_set_fence()

vars[?"up"] = "true"
	
if ((vars[?"east"] = "true"  && vars[?"west"] = "true"  && vars[?"south"] = "false" && vars[?"north"] = "false") || 
	(vars[?"east"] = "false" && vars[?"west"] = "false" && vars[?"south"] = "true"  && vars[?"north"] = "true"))
	vars[?"up"] = "false"

return 0