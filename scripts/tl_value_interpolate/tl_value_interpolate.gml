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
	case RGBADD:
	case RGBSUB:
	case RGBMUL:
	case HSBADD:
	case HSBSUB:
	case HSBMUL:
	case MIXCOLOR:
	case LIGHTCOLOR:
	case BGSKYCOLOR:
	case BGSKYCLOUDSCOLOR:
	case BGSUNLIGHTCOLOR:
	case BGAMBIENTCOLOR:
	case BGNIGHTCOLOR:
	case BGFOGCOLOR: return merge_color(val1, val2, clamp(p, 0, 1)) // Color mix
	case CAMWIDTH:
	case CAMHEIGHT: return round(val1 + p * (val2 - val1)) // No decimals
	case SPAWN:
	case ATTRACTOR:
	case CAMROTATE:
	case CAMDOF:
	case CAMSIZEUSEPROJECT:
	case CAMSIZEKEEPASPECTRATIO:
	case BGSKYMOONPHASE:
	case VISIBLE:
	case TEXTUREOBJ:
	case SOUNDOBJ:
	case SOUNDVOLUME:
	case SOUNDSTART:
	case SOUNDEND:
	case TRANSITION: return val1 // No interpolation
}

return val1 + p * (val2 - val1)
