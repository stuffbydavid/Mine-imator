/// tl_value_interpolate(valueid, percent, valuestart, valueend)
/// @arg valueid
/// @arg percent
/// @arg valuestart
/// @arg valueend

var vid, p, val1, val2;
vid = argument0
p = argument1
val1 = argument2
val2 = argument3

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
	case e_value.LIGHT_COLOR:
	case e_value.CAM_BLOOM_BLEND:
	case e_value.BG_SKY_COLOR:
	case e_value.BG_SKY_CLOUDS_COLOR:
	case e_value.BG_SUNLIGHT_COLOR:
	case e_value.BG_AMBIENT_COLOR:
	case e_value.BG_NIGHT_COLOR:
	case e_value.BG_GRASS_COLOR:
	case e_value.BG_FOLIAGE_COLOR:
	case e_value.BG_WATER_COLOR:
	case e_value.BG_FOG_COLOR:
	case e_value.BG_FOG_OBJECT_COLOR: return merge_color(val1, val2, clamp(p, 0, 1)) // Color mix
	case e_value.CAM_WIDTH:
	case e_value.CAM_HEIGHT: return round(val1 + p * (val2 - val1)) // No decimals
	case e_value.SPAWN:
	case e_value.FREEZE:
	case e_value.CLEAR:
	case e_value.CUSTOM_SEED:
	case e_value.SEED:
	case e_value.ATTRACTOR:
	case e_value.CAM_ROTATE:
	case e_value.CAM_DOF:
	case e_value.CAM_BLOOM:
	case e_value.CAM_COLOR_CORRECTION:
	case e_value.CAM_SIZE_USE_PROJECT:
	case e_value.CAM_SIZE_KEEP_ASPECT_RATIO:
	case e_value.BG_IMAGE_SHOW:
	case e_value.BG_SKY_MOON_PHASE:
	case e_value.BG_SUNLIGHT_FOLLOW:
	case e_value.BG_DESATURATE_NIGHT:
	case e_value.BG_SKY_CLOUDS_SHOW:
	case e_value.BG_GROUND_SHOW:
	case e_value.BG_FOG_SHOW:
	case e_value.BG_WIND:
	case e_value.VISIBLE:
	case e_value.TEXTURE_OBJ:
	case e_value.SOUND_OBJ:
	case e_value.SOUND_VOLUME:
	case e_value.SOUND_START:
	case e_value.SOUND_END:
	case e_value.TEXT:
	case e_value.TEXT_FONT:
	case e_value.TRANSITION: return val1 // No interpolation
}

return val1 + p * (val2 - val1)
