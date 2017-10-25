/// tl_value_is_bool(valueid)
/// @arg valueid

var vid = argument0;

return (vid = e_value.SPAWN ||
		vid = e_value.FREEZE ||
		vid = e_value.CLEAR ||
		vid = e_value.CUSTOM_SEED ||
		vid = e_value.CAM_ROTATE ||
		vid = e_value.CAM_DOF ||
		vid = e_value.CAM_SIZE_USE_PROJECT ||
		vid = e_value.CAM_SIZE_KEEP_ASPECT_RATIO ||
		vid = e_value.VISIBLE)