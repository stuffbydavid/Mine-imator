/// render_start(target, camera, [width, height])
/// @arg target
/// @arg camera
/// @arg [width
/// @arg height]

render_target = argument[0]
render_camera = argument[1]

if (render_camera)
{
    if (render_camera.value[CAMSIZEUSEPROJECT])
	{
        render_width = project_video_width
        render_height = project_video_height
    }
	else
	{
        render_width = render_camera.value[CAMWIDTH]
        render_height = render_camera.value[CAMHEIGHT]
    }
}
else if (argument_count > 2)
{
    render_width = argument[2]
    render_height = argument[3]
}

if (render_camera)
{
    render_camera_colors = (render_camera.value[ALPHA] < 1 || 
                            render_camera.value[BRIGHTNESS] > 0 || 
                            render_camera.value[RGBADD] - render_camera.value[RGBSUB] != c_black || 
                            render_camera.value[RGBMUL] < c_white || 
                            render_camera.value[HSBADD] - render_camera.value[HSBSUB] != c_black || 
                            render_camera.value[HSBMUL] < c_white || 
                            render_camera.value[MIXPERCENT] > 0)
    
    render_camera_dof = (setting_render_dof && render_camera.value[CAMDOF])
}
else
{
    render_camera_colors = false
    render_camera_dof = false
}

render_ratio = render_width / render_height
render_overlay = (render_camera_colors || render_watermark)

render_color = draw_get_color()
render_alpha = draw_get_alpha()
draw_set_color(c_white)
draw_set_alpha(1)

render_update_text()

camera_apply(cam_render)