/// project_read_old_value(valueid, value)
/// @arg valueid
/// @arg value
/// @desc Converts the keyframe parameter from Mine-imator beta to 1.0.0 format.
/*
var vid, val;
vid = argument0
val = argument1

switch (vid)
{
	case ALPHA:			return 1 - val
	case XSCA:
	case YSCA:
	case ZSCA:			return 1 + val
	case LIGHTCOLOR:	return c_white - val
	case BENDANGLE:		return val * 130
	case LIGHTRANGE:	return (1 - val) * 250
	case TRANSITION:
	{
		if (val = 0) // Linear
			return 0
			
		if (val = 1) // Ease in
			return 2
			
		if (val = 2) // Ease out
			return 3
			
		if (val = 3) // Ease out
			return 4
			
		if (val = 4) // Instant
			return 1
		break
	}
		
	case CAMROTATEXYANGLE:	return val - 90
	case CAMFOV:			return 50 + val * 100
}
return val*/
