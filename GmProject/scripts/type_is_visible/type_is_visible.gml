function type_is_visible(type)
{
	return (type != e_tl_type.CHARACTER &&
			type != e_tl_type.EQUIPMENT &&
			type != e_tl_type.SPECIAL_BLOCK &&
			type != e_tl_type.AUDIO_TRACK &&
			type != e_tl_type.CAMERA_EFFECT &&
			type != e_tl_type.PATH_POINT &&
			type != e_tl_type.ENVIRONMENT &&
			type != e_tl_type.STRUCTURE &&
			type != e_tl_type.FOLDER)
}
