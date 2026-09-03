/// tl_value_is_bool(valueid)
/// @arg valueid

function tl_value_is_bool(vid)
{
	return (vid = e_value.SPAWN ||
			vid = e_value.FREEZE ||
			vid = e_value.CLEAR ||
			vid = e_value.CUSTOM_SEED ||
			vid = e_value.BG_IMAGE_SHOW ||
			vid = e_value.BG_SKY_CLOUDS_SHOW ||
			vid = e_value.BG_GROUND_SHOW ||
			vid = e_value.BG_FOG_SHOW ||
			vid = e_value.BG_WIND ||
			vid = e_value.CAM_LIGHT_MANAGEMENT ||
			vid = e_value.CAM_ROTATE ||
			vid = e_value.CAM_SHAKE ||
			vid = e_value.CAM_DOF ||
			vid = e_value.CAM_DOF_FRINGE ||
			vid = e_value.CAM_BLOOM ||
			vid = e_value.CAM_LENS_DIRT ||
			vid = e_value.CAM_LENS_DIRT_BLOOM ||
			vid = e_value.CAM_LENS_DIRT_GLOW ||
			vid = e_value.CAM_COLOR_CORRECTION ||
			vid = e_value.CAM_GRAIN ||
			vid = e_value.CAM_VIGNETTE ||
			vid = e_value.CAM_CA ||
			vid = e_value.CAM_CA_DISTORT_CHANNELS ||
			vid = e_value.CAM_DISTORT ||
			vid = e_value.CAM_DISTORT_REPEAT ||
			vid = e_value.CAM_SIZE_USE_PROJECT ||
			vid = e_value.CAM_SIZE_KEEP_ASPECT_RATIO ||
			vid = e_value.TEXT_AA ||
			vid = e_value.TEXT_OUTLINE ||
			vid = e_value.VISIBLE)
}
