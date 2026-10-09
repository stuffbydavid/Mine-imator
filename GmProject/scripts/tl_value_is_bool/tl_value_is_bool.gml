/// @arg valueid

function tl_value_is_bool(vid)
{
	return (vid = e_value.SPAWN ||
			vid = e_value.FREEZE ||
			vid = e_value.CLEAR ||
			vid = e_value.CUSTOM_SEED ||
			vid = e_value.ENV_IMAGE_SHOW ||
			vid = e_value.ENV_SKY_CLOUDS_SHOW ||
			vid = e_value.ENV_GROUND_SHOW ||
			vid = e_value.ENV_FOG_SHOW ||
			vid = e_value.ENV_WIND ||
			vid = e_value.CAM_SIZE_USE_PROJECT ||
			vid = e_value.CAM_SIZE_KEEP_ASPECT_RATIO ||
			vid = e_value.CAM_ROTATE ||
			vid = e_value.CAM_FX_DOF_FRINGE ||
			vid = e_value.CAM_FX_LENS_DIRT_BLOOM ||
			vid = e_value.CAM_FX_LENS_DIRT_GLOW ||
			vid = e_value.CAM_FX_CA_DISTORT_CHANNELS ||
			vid = e_value.CAM_FX_DISTORT_REPEAT ||
			vid = e_value.TEXT_CUSTOM_ALIGNMENT ||
			vid = e_value.TEXT_OUTLINE ||
			vid = e_value.TEXT_CUSTOM_OUTLINE ||
			vid = e_value.VISIBLE)
}
