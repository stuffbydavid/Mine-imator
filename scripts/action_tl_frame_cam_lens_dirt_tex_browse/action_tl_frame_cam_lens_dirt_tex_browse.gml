/// action_tl_frame_cam_lens_dirt_tex_browse()

var fn = file_dialog_open_image()
if (!file_exists_lib(fn))
	return 0

action_res_image_load(fn, e_res_type.TEXTURE)
