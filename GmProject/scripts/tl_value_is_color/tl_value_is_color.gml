/// tl_value_is_color(valueid)
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
			vid = e_value.BG_SKY_COLOR ||
			vid = e_value.BG_SKY_CLOUDS_COLOR ||
			vid = e_value.BG_SUNLIGHT_COLOR ||
			vid = e_value.BG_AMBIENT_COLOR ||
			vid = e_value.BG_NIGHT_COLOR ||
			vid = e_value.BG_GRASS_COLOR ||
			vid = e_value.BG_FOLIAGE_COLOR ||
			vid = e_value.BG_DRY_FOLIAGE_COLOR ||
			vid = e_value.BG_WATER_COLOR ||
			vid = e_value.BG_LEAVES_OAK_COLOR ||
			vid = e_value.BG_LEAVES_SPRUCE_COLOR ||
			vid = e_value.BG_LEAVES_BIRCH_COLOR ||
			vid = e_value.BG_LEAVES_JUNGLE_COLOR ||
			vid = e_value.BG_LEAVES_ACACIA_COLOR ||
			vid = e_value.BG_LEAVES_DARK_OAK_COLOR ||
			vid = e_value.BG_LEAVES_MANGROVE_COLOR ||
			vid = e_value.BG_FOG_COLOR ||
			vid = e_value.TEXT_OUTLINE_COLOR)
}
