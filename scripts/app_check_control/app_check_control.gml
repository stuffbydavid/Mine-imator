/// app_check_control(active)
/// @arg active

if (argument0)
	return keyboard_check(vk_control)
else
	return !keyboard_check(vk_control)
