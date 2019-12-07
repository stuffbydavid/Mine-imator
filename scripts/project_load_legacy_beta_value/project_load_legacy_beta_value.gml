/// project_load_legacy_beta_value(valueid, value)
/// @arg valueid
/// @arg value

var vid, val;
vid = argument0
val = argument1

switch (vid)
{
	case e_value.ALPHA: return 1 - val
	case e_value.SCA_X:
	case e_value.SCA_Y:
	case e_value.SCA_Z: return 1 + val
	case e_value.LIGHT_COLOR: return c_white - val
	case e_value.BEND_ANGLE_LEGACY: return val * 130 // Pre-1.2.6 bend limit
	case e_value.LIGHT_RANGE: return (1 - val) * 250
	case e_value.TRANSITION:
	{
		switch (val)
		{
			case 0: return "linear"
			case 1: return "easeinquad"
			case 2: return "easeoutquad"
			case 3: return "easeinoutquad"
			case 4: return "instant"
		}
	   
		return "linear"
	}
	case e_value.CAM_ROTATE_ANGLE_XY: return val - 90
	case e_value.CAM_FOV: return 50 + val * 100
}

return val