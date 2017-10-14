/// camera_startup()

globalvar cam_from, cam_to, cam_up, cam_fov, cam_near, cam_far, cam_window, cam_render;
cam_from = point3D(0, 0, 0)
cam_window = camera_create()
cam_render = camera_create()
camera_set_view_mat(cam_window, MAT_IDENTITY)
camera_set_proj_mat(cam_window, MAT_IDENTITY)
camera_set_view_mat(cam_render, MAT_IDENTITY)
camera_set_proj_mat(cam_render, MAT_IDENTITY)
view_set_camera(0, cam_window)

camera_work_reset()