/// cam_control_move(camera, lockx, locky)
/// @arg camera
/// @arg lockx
/// @arg locky

var cam, lockx, locky, mx, my;
cam = argument0
lockx = argument1
locky = argument2

mx = -((display_mouse_get_x() - lockx) / 8) * setting_look_sensitivity
my = -((display_mouse_get_y() - locky) / 8) * setting_look_sensitivity
display_mouse_set(lockx, locky)

if (!cam)
{
	var move, spd, spdm, xd, yd, zd;
	
	cam_work_angle_look_xy += mx
	cam_work_angle_look_z += my
	cam_work_angle_look_z = clamp(cam_work_angle_look_z, -89.9, 89.9)
	
	if (!cam_work_focus_tl)
	{
		cam_work_set_focus()
		cam_work_set_angle()
	}
	
	// Move
	move = 4 * setting_move_speed
	spd = (keyboard_check(setting_key_forward) - keyboard_check(setting_key_back)) * move
	spdm = 1
	if (keyboard_check(setting_key_fast))
		spdm = setting_fast_modifier
	if (keyboard_check(setting_key_slow))
		spdm = setting_slow_modifier
	
	if (keyboard_check(setting_key_right))
	{
		xd = -sin(degtorad(cam_work_angle_look_xy)) * move
		yd = -cos(degtorad(cam_work_angle_look_xy)) * move
	}
	else if (keyboard_check(setting_key_left))
	{
		xd = sin(degtorad(cam_work_angle_look_xy)) * move
		yd = cos(degtorad(cam_work_angle_look_xy)) * move
	}
	else
	{
		xd = 0
		yd = 0
	}
	
	xd += -lengthdir_x(spd, cam_work_angle_look_xy)
	yd += -lengthdir_y(spd, cam_work_angle_look_xy)
	zd = (keyboard_check(setting_key_ascend) - keyboard_check(setting_key_descend)) * move
	zd += (dsin(cam_work_angle_look_z)) * (keyboard_check(setting_key_forward) - keyboard_check(setting_key_back)) * move
	
	
	cam_work_from[X] += xd * spdm
	cam_work_from[Y] += yd * spdm
	cam_work_from[Z] += zd * spdm
	
	if (!cam_work_focus_tl)
	{
		cam_work_focus[X] += xd * spdm
		cam_work_focus[Y] += yd * spdm
		cam_work_focus[Z] += zd * spdm
	}
	
	// Roll
	cam_work_roll += (keyboard_check(setting_key_roll_forward) - keyboard_check(setting_key_roll_back)) * 4*spdm
	if (keyboard_check_pressed(setting_key_roll_reset))
		cam_work_roll = 0
	
	// Reset
	if (keyboard_check_pressed(setting_key_reset))
		cam_work_reset()
		
	cam_work_set_angle()
}
else
{
	var move, roll, spd, spdm, xd, yd, zd;
	
	// Move
	move = 4 * setting_move_speed
	spd = (keyboard_check(setting_key_forward) - keyboard_check(setting_key_back)) * move
	spdm = 1
	if (keyboard_check(setting_key_fast))
		spdm = setting_fast_modifier
	if (keyboard_check(setting_key_slow)) 
		spdm = setting_slow_modifier
		
	if (keyboard_check(setting_key_right))
	{
		xd = -sin(degtorad(cam.value[e_value.ROT_Z] + 90)) * move
		yd = -cos(degtorad(cam.value[e_value.ROT_Z] + 90)) * move
	}
	else if (keyboard_check(setting_key_left))
	{
		xd = sin(degtorad(cam.value[e_value.ROT_Z] + 90)) * move
		yd = cos(degtorad(cam.value[e_value.ROT_Z] + 90)) * move
	}
	else
	{
		xd = 0
		yd = 0
	}
	
	xd += -lengthdir_x(spd, cam.value[e_value.ROT_Z] + 90)
	yd += -lengthdir_y(spd, cam.value[e_value.ROT_Z] + 90)
	zd = (keyboard_check(setting_key_ascend) - keyboard_check(setting_key_descend)) * move
	zd += (-dsin(cam.value[e_value.ROT_X])) * (keyboard_check(setting_key_forward) - keyboard_check(setting_key_back)) * move
	
	// Roll
	roll = (keyboard_check(setting_key_roll_forward) - keyboard_check(setting_key_roll_back)) * 4 * spdm
	
	// Set
	tl_value_set_start(cam_control_move, true)
	tl_value_set(e_value.POS_X, xd * spdm, true)
	tl_value_set(e_value.POS_Y, yd * spdm, true)
	tl_value_set(e_value.POS_Z, zd * spdm, true)
	tl_value_set(e_value.ROT_X, -my, true)
	tl_value_set(e_value.ROT_Y, roll, true)
	tl_value_set(e_value.ROT_Z, mx, true)
	if (keyboard_check_pressed(setting_key_roll_reset))
		tl_value_set(e_value.ROT_Y, 0, false)
	tl_value_set_done()
}
