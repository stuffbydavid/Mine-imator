/// view_event_create()

function view_event_create()
{
	show = true
	location = "full"
	location_last = "full"
	
	surface = null
	surface_select = null
	surface_camera = null
	
	surface_place_id = null
	surface_place_normal = null
	surface_place_depth_gm = null
	surface_place_width = 0
	surface_place_height = 0
	update_place_surfaces = false
	
	mouseon = false
	control_mouseon = null
	control_mouseon_last = null
	render = false
	
	width = 440
	height = 280
	
	toolbar_height = 0
	toolbar_mouseon = false
	toolbar_alpha = 1
	toolbar_alpha_goal = toolbar_alpha
}
