/// project_load_legacy_beta_value_id(type, id)
/// @arg type
/// @arg valueid

var type, vid;
type = argument0
vid = argument1

if (type = "camera")
{
    switch (vid)
	{
        case 0: return -1
        case 1: return -1
        case 2: return -1
        case 3: return e_value.POS_X
        case 4: return e_value.POS_Y
        case 5: return e_value.POS_Z
        case 6: return e_value.CAM_ROTATE_DISTANCE
        case 7: return e_value.CAM_ROTATE_ANGLE_XY
        case 8: return e_value.CAM_ROTATE_ANGLE_Z
        case 9: return e_value.MIX_PERCENT
        case 10: return e_value.MIX_COLOR
        case 11: return -1
        case 12: return e_value.CAM_FOV
    }
}
else
{
    switch (vid)
	{
        case 0: return e_value.ALPHA
        case 1: return e_value.MIX_PERCENT
        case 2:
            if (type = "pointlight")
                return e_value.LIGHT_RANGE
            return e_value.MIX_COLOR
        
        case 3: return e_value.SCA_X
        case 4: return e_value.SCA_Y
        case 5: return e_value.SCA_Z
        case 6: return e_value.POS_X
        case 7: return e_value.POS_Y
        case 8: return e_value.POS_Z
        case 9: return e_value.ROT_X
        case 10: return e_value.ROT_Y
        case 11: return e_value.ROT_Z
        case 12: return e_value.BEND_ANGLE
    }
}

return -1