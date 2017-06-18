/// render_startup()

globalvar render_mode, render_click_box, render_surface_time, 
		  render_list, render_lights, render_particles, render_hidden, render_background, render_watermark, 
		  proj_from, proj_matrix, view_proj_matrix, proj_depth_near, proj_depth_far;

log("Render init")

render_click_box = vbuffer_create_cube(4, point2D(0, 0), point2D(1, 1), 1, 1, false, false)
render_list = ds_list_create()
render_lights = true
render_particles = true
render_hidden = false
render_background = true
render_watermark = false

render_camera = null
render_camera_dof = false
render_overlay = false
render_width = 1
render_height = 1
render_ratio = render_width / render_height

render_time = 0
render_surface_time = 0

render_target = null
render_surface[0] = null
render_surface[1] = null
render_surface[2] = null
render_surface[3] = null

render_surface_sun_buffer = null
render_surface_spot_buffer = null
for (var d = 0; d < 6; d++)
	render_surface_point_buffer[d] = null
	
render_ssao_kernel = render_generate_sample_kernel(16)
render_ssao_noise = null
	
gpu_set_blendenable(true)
gpu_set_alphatestenable(true)
gpu_set_alphatestref(0)
gpu_set_texfilter(false)
gpu_set_texrepeat(true)
render_set_culling(true)

cam_work_reset()