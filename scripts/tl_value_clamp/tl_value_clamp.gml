/// tl_value_clamp(valueid, value)
/// @arg valueid
/// @arg value

var vid, val;
vid = argument0
val = argument1

switch (vid)
{
    case XPOS:
    case YPOS:
    case ZPOS: return clamp(val, -world_size, world_size)
    case XSCA:
    case YSCA:
    case ZSCA: return max(val, 0.0001)
    case ALPHA:
    case MIXPERCENT:
    case BRIGHTNESS: return clamp(val, 0, 1)
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
    case BGFOGCOLOR: return clamp(val, c_black, c_white)
    case BENDANGLE: return clamp(val, -130, 130)
    case CAMFOV: return clamp(val, 1, 170)
    case CAMROTATEDISTANCE: return max(1, val)
    case CAMROTATEZANGLE: return clamp(val, -89.9, 89.9)
    case CAMWIDTH:
    case CAMHEIGHT: return max(1, val)
    case BGSKYMOONPHASE: return clamp(val, 0, 7)
    case BGFOGDISTANCE: return clamp(val, 10, world_size)
    case BGFOGSIZE: return clamp(val, 10, world_size)
    case BGFOGHEIGHT: return clamp(val, 10, 2000)
    case BGWINDSPEED: return clamp(val, 0, 1)
    case BGWINDSTRENGTH: return clamp(val, 0, 8)
    case BGTEXTUREANISPEED: return max(val, 0)
    case SOUNDVOLUME: return clamp(val, 0, 1)
    case SOUNDSTART: return max(val, 0)
}

return clamp(val, -no_limit, no_limit)
