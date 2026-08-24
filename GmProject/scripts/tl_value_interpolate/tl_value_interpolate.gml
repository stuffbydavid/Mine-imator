/// tl_value_interpolate(valueid, percent, valuestart, valueend)
/// @arg valueid
/// @arg percent
/// @arg valuestart
/// @arg valueend

function tl_value_interpolate(vid, p, val1, val2)
{
	switch (vid)
	{
		case e_value.RGB_ADD:
		case e_value.RGB_SUB:
		case e_value.RGB_MUL:
		case e_value.HSB_ADD:
		case e_value.HSB_SUB:
		case e_value.HSB_MUL:
		case e_value.MIX_COLOR:
		case e_value.GLOW_COLOR:
		case e_value.SUBSURFACE_COLOR:
		case e_value.LIGHT_COLOR:
		case e_value.CAM_BLOOM_BLEND:
		case e_value.CAM_COLOR_BURN:
		case e_value.CAM_VIGNETTE_COLOR:
		case e_value.BG_SKY_COLOR:
		case e_value.BG_SKY_CLOUDS_COLOR:
		case e_value.BG_SUNLIGHT_COLOR:
		case e_value.BG_AMBIENT_COLOR:
		case e_value.BG_NIGHT_COLOR:
		case e_value.BG_GRASS_COLOR:
		case e_value.BG_FOLIAGE_COLOR:
		case e_value.BG_DRY_FOLIAGE_COLOR:
		case e_value.BG_WATER_COLOR:
		case e_value.BG_LEAVES_OAK_COLOR:
		case e_value.BG_LEAVES_SPRUCE_COLOR:
		case e_value.BG_LEAVES_BIRCH_COLOR:
		case e_value.BG_LEAVES_JUNGLE_COLOR:
		case e_value.BG_LEAVES_ACACIA_COLOR:
		case e_value.BG_LEAVES_DARK_OAK_COLOR:
		case e_value.BG_LEAVES_MANGROVE_COLOR:
		case e_value.BG_FOG_COLOR:
		case e_value.BG_FOG_OBJECT_COLOR:
		case e_value.TEXT_OUTLINE_COLOR: return merge_color(val1, val2, clamp(p, 0, 1)) // Color mix
		case e_value.CAM_BLADE_AMOUNT:
		case e_value.CAM_WIDTH:
		case e_value.CAM_HEIGHT:
		case e_value.ITEM_SLOT: return floor(val1 + p * (val2 - val1)) // No decimals
		case e_value.SPAWN:
		case e_value.FREEZE:
		case e_value.CLEAR:
		case e_value.CUSTOM_SEED:
		case e_value.SEED:
		case e_value.PATH_OBJ:
		case e_value.IK_TARGET:
		case e_value.IK_TARGET_ANGLE:
		case e_value.ATTRACTOR:
		case e_value.CAM_LIGHT_MANAGEMENT:
		case e_value.CAM_TONEMAPPER:
		case e_value.CAM_ROTATE:
		case e_value.CAM_SHAKE:
		case e_value.CAM_SHAKE_MODE:
		case e_value.CAM_DOF:
		case e_value.CAM_DOF_FRINGE:
		case e_value.CAM_BLOOM:
		case e_value.CAM_LENS_DIRT:
		case e_value.CAM_LENS_DIRT_BLOOM:
		case e_value.CAM_LENS_DIRT_GLOW:
		case e_value.CAM_COLOR_CORRECTION:
		case e_value.CAM_GRAIN:
		case e_value.CAM_VIGNETTE:
		case e_value.CAM_CA:
		case e_value.CAM_CA_DISTORT_CHANNELS:
		case e_value.CAM_DISTORT:
		case e_value.CAM_DISTORT_REPEAT:
		case e_value.CAM_SIZE_USE_PROJECT:
		case e_value.CAM_SIZE_KEEP_ASPECT_RATIO:
		case e_value.BG_IMAGE_SHOW:
		case e_value.BG_SKY_MOON_PHASE:
		case e_value.BG_TWILIGHT:
		case e_value.BG_SKY_CLOUDS_SHOW:
		case e_value.BG_GROUND_SHOW:
		case e_value.BG_GROUND_SLOT:
		case e_value.BG_BIOME:
		case e_value.BG_FOG_SHOW:
		case e_value.BG_WIND:
		case e_value.VISIBLE:
		case e_value.TEXTURE_OBJ:
		case e_value.TEXTURE_MATERIAL_OBJ:
		case e_value.TEXTURE_NORMAL_OBJ:
		case e_value.SOUND_OBJ:
		case e_value.SOUND_VOLUME:
		case e_value.SOUND_PITCH:
		case e_value.SOUND_START:
		case e_value.SOUND_END:
		case e_value.TEXT:
		case e_value.TEXT_FONT:
		case e_value.TEXT_HALIGN:
		case e_value.TEXT_VALIGN:
		case e_value.TEXT_AA:
		case e_value.TEXT_OUTLINE:
		case e_value.CUSTOM_ITEM_SLOT:
		case e_value.TRANSITION:
		case e_value.EASE_IN_X:
		case e_value.EASE_IN_Y:
		case e_value.EASE_OUT_X:
		case e_value.EASE_OUT_Y: return val1 // No interpolation
	}
	
	return val1 + p * (val2 - val1)
}
