/// app_startup_globals()

log("Globals startup")

// Program
globalvar trial_version, current_step, minute_steps, delta,
		  buffer_current, vbuffer_current, load_format, load_folder, save_folder, 
		  debug_indent, debug_timer, history_data;
current_step = 0
minute_steps = 60 * 60
delta = 1

// Assets
globalvar load_queue, temp_edit, ptype_edit, tl_edit_amount, tl_edit, res_edit, axis_edit,
		  temp_creator, res_creator, save_id_seed, save_id_map, shape_texture;
load_queue = ds_priority_create()
temp_edit = null
ptype_edit = null
tl_edit = null
tl_edit_amount = 0
res_edit = null
axis_edit = X
temp_creator = app
res_creator = app
save_id = "root"
save_id_seed = random_get_seed()
save_id_map = ds_map_create()
shape_texture = texture_sprite(spr_shape, 0)

// Camera
globalvar cam_from, cam_to, cam_up, cam_fov, cam_near, cam_far, cam_window, cam_render;
cam_from = point3D(0, 0, 0)
cam_window = camera_create()
cam_render = camera_create()
camera_set_view_mat(cam_window, MAT_IDENTITY)
camera_set_proj_mat(cam_window, MAT_IDENTITY)
camera_set_view_mat(cam_render, MAT_IDENTITY)
camera_set_proj_mat(cam_render, MAT_IDENTITY)
view_set_camera(0, cam_window)