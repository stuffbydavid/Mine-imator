/// @arg valueid

function tl_value_is_color(vid)
{
	return (vid = e_value.RGB_ADD ||
			vid = e_value.RGB_SUB ||
			vid = e_value.RGB_MUL ||
			vid = e_value.HSB_ADD ||
			vid = e_value.HSB_SUB ||
			vid = e_value.HSB_MUL ||
			vid = e_value.MIX_COLOR ||
			vid = e_value.GLOW_COLOR ||
			vid = e_value.SUBSURFACE_COLOR ||
			vid = e_value.LIGHT_COLOR ||
			vid = e_value.CAM_BLOOM_BLEND ||
			vid = e_value.CAM_COLOR_BURN ||
			vid = e_value.CAM_VIGNETTE_COLOR ||
			vid = e_value.ENV_SKY_COLOR ||
			vid = e_value.ENV_SKY_CLOUDS_COLOR ||
			vid = e_value.ENV_SUNLIGHT_COLOR ||
			vid = e_value.ENV_AMBIENT_COLOR ||
			vid = e_value.ENV_NIGHT_SKY_COLOR ||
			vid = e_value.ENV_NIGHT_SKY_CLOUDS_COLOR ||
			vid = e_value.ENV_NIGHT_SKY_STARS_COLOR ||
			vid = e_value.ENV_NIGHT_COLOR ||
			vid = e_value.ENV_GRASS_COLOR ||
			vid = e_value.ENV_FOLIAGE_COLOR ||
			vid = e_value.ENV_DRY_FOLIAGE_COLOR ||
			vid = e_value.ENV_WATER_COLOR ||
			vid = e_value.ENV_LEAVES_OAK_COLOR ||
			vid = e_value.ENV_LEAVES_SPRUCE_COLOR ||
			vid = e_value.ENV_LEAVES_BIRCH_COLOR ||
			vid = e_value.ENV_LEAVES_JUNGLE_COLOR ||
			vid = e_value.ENV_LEAVES_ACACIA_COLOR ||
			vid = e_value.ENV_LEAVES_DARK_OAK_COLOR ||
			vid = e_value.ENV_LEAVES_MANGROVE_COLOR ||
			vid = e_value.ENV_FOG_COLOR ||
			vid = e_value.TEXT_OUTLINE_COLOR)
}
