/// tl_value_is_obj(valueid)
/// @arg valueid

function tl_value_is_obj(vid)
{
	return (vid = e_value.SOUND_OBJ ||
			vid = e_value.PATH_OBJ ||
			vid = e_value.IK_TARGET ||
			vid = e_value.IK_TARGET_ANGLE)
}
