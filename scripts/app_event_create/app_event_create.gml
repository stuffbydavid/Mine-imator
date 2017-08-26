/// app_event_create()
/// @desc Entry point of the application.

if (!app_startup())
{
	game_end()
	return 0
}

project_reset()

if (dev_mode)
{
	popup_newproject_clear()
	project_create()
}
else
	popup_show(popup_startup)
	

var temp = new(obj_template);
with (temp)
{
	type = "block"
	block_name = "grass"
	block_state = "snowy=false"
	block_tex = res_def
	temp_update()
	repeat (25)
	{
		var tl = temp_animate();
		with (tl)
		{
			for (var i = 0; i < 20; i++)
			{
				var kf = tl_keyframe_add(i);
				kf.value[e_value.POS_X] = 0.125
				kf.value[e_value.POS_Y] = 0.125
				kf.value[e_value.POS_Z] = 0.125
				kf.value[e_value.ROT_X] = 0.125
				kf.value[e_value.ROT_Y] = 0.125
				kf.value[e_value.ROT_Z] = 0.125
				kf.value[e_value.RGB_MUL] = c_orange
				kf.value[e_value.TRANSITION] = 2
				kf.value[e_value.SPAWN] = false
			}
			tl_update_matrix()
		}
	}
}
tl_update_list()