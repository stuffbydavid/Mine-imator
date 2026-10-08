function view_event_create()
{
	show = true
	update = true
	update_gizmos = true
	
	location = "full"
	location_last = "full"
	
	surface = null
	surface_select = null
	surface_gizmos = null
	surface_camera = null
	
	surface_width = 0
	surface_height = 0
	surface_renderer = -1
	surface_camera_last = null
	surface_particles = false
	surface_effects = false
	surface_gizmos_enabled = false
	surface_transparent_background = false
	surface_watermark = false
	surface_tool_move = false
	surface_tool_rotate = false
	surface_tool_scale = false
	surface_tool_bend = false
	surface_tool_transform = false
	surface_work_from = point3D(0)
	surface_work_angle = vec3(0)
	
	surface_cam_from = point3D(0)
	surface_cam_to = point3D(0)
	surface_cam_up = point3D(0)
	surface_cam_fov = 45
	surface_cam_near = 0
	surface_cam_far = 0
	surface_proj_matrix = array_copy_1d(MAT_IDENTITY)
	surface_view_matrix = array_copy_1d(MAT_IDENTITY)
	surface_view_proj_matrix = array_copy_1d(MAT_IDENTITY)
	surface_mouse_x = 0
	surface_mouse_y = 0
	surface_mouseon = false
	surface_control_edit = null
	
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
	transparent_background = false
	
	width = 440
	height = 280
	
	toolbar_height = 0
	toolbar_mouseon = false
	toolbar_alpha = 1
	toolbar_alpha_goal = toolbar_alpha
}
