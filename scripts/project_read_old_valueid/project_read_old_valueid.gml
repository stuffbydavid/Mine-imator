/// project_read_old_valueid(type, valueid)
/// @arg type
/// @arg valueid
/// @dec Converts the value id from Mine-imator beta to 1.0.0 format.
/*
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
		case 3: return XPOS
		case 4: return YPOS
		case 5: return ZPOS
		case 6: return CAMROTATEDISTANCE
		case 7: return CAMROTATEXYANGLE
		case 8: return CAMROTATEZANGLE
		case 9: return MIXPERCENT
		case 10: return MIXCOLOR
		case 11: return -1
		case 12: return CAMFOV
	}
}
else
{
	switch (vid)
	{
		case 0: return ALPHA
		case 1: return MIXPERCENT
		case 2:
			if (type = "pointlight")
				return LIGHTRANGE
			return MIXCOLOR
		
		case 3: return XSCA
		case 4: return YSCA
		case 5: return ZSCA
		case 6: return XPOS
		case 7: return YPOS
		case 8: return ZPOS
		case 9: return XROT
		case 10: return YROT
		case 11: return ZROT
		case 12: return BENDANGLE
	}
}

return -1*/