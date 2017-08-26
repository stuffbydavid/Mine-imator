/// project_read_values(timeline)
/// @arg timeline
/*
var tl = argument0;

if (tl.value_type[POSITION])
{
	value[XPOS] = buffer_read_double()			if (dev_mode_debug_keyframes) debug("XPOS", value[XPOS])
	value[YPOS] = buffer_read_double()			if (dev_mode_debug_keyframes) debug("YPOS", value[YPOS])
	value[ZPOS] = buffer_read_double()			if (dev_mode_debug_keyframes) debug("ZPOS", value[ZPOS])
}

if (tl.value_type[ROTATION])
{
	value[XROT] = buffer_read_double()			if (dev_mode_debug_keyframes) debug("XROT", value[XROT])
	value[YROT] = buffer_read_double()			if (dev_mode_debug_keyframes) debug("YROT", value[YROT])
	value[ZROT] = buffer_read_double()			if (dev_mode_debug_keyframes) debug("ZROT", value[ZROT])
}

if (tl.value_type[SCALE])
{ 
	value[XSCA] = buffer_read_double()			if (dev_mode_debug_keyframes) debug("XSCA", value[XSCA])
	value[YSCA] = buffer_read_double()			if (dev_mode_debug_keyframes) debug("YSCA", value[YSCA])
	value[ZSCA] = buffer_read_double()			if (dev_mode_debug_keyframes) debug("ZSCA", value[ZSCA])
}

if (tl.value_type[BEND])
{
	value[BENDANGLE] = buffer_read_double()		if (dev_mode_debug_keyframes) debug("BENDANGLE", value[BENDANGLE])
}

if (tl.value_type[COLOR])
{
	value[ALPHA] = buffer_read_double()			if (dev_mode_debug_keyframes) debug("ALPHA", value[ALPHA])
	value[RGBADD] = buffer_read_int()			if (dev_mode_debug_keyframes) debug("RGBADD", value[RGBADD])
	value[RGBSUB] = buffer_read_int()			if (dev_mode_debug_keyframes) debug("RGBSUB", value[RGBSUB])
	value[RGBMUL] = buffer_read_int()			if (dev_mode_debug_keyframes) debug("RGBMUL", value[RGBMUL])
	value[HSBADD] = buffer_read_int()			if (dev_mode_debug_keyframes) debug("HSBADD", value[HSBADD])
	value[HSBSUB] = buffer_read_int()			if (dev_mode_debug_keyframes) debug("HSBSUB", value[HSBSUB])
	value[HSBMUL] = buffer_read_int()			if (dev_mode_debug_keyframes) debug("HSBMUL", value[HSBMUL])
	value[MIXCOLOR] = buffer_read_int()			if (dev_mode_debug_keyframes) debug("MIXCOLOR", value[MIXCOLOR])
	value[MIXPERCENT] = buffer_read_double()	if (dev_mode_debug_keyframes) debug("MIXPERCENT", value[MIXPERCENT])
	value[BRIGHTNESS] = buffer_read_double()	if (dev_mode_debug_keyframes) debug("BRIGHTNESS", value[BRIGHTNESS])
}

if (tl.value_type[PARTICLES])
{
	value[SPAWN] = buffer_read_byte()			if (dev_mode_debug_keyframes) debug("SPAWN", value[SPAWN])
	value[ATTRACTOR] = iid_read()				if (dev_mode_debug_keyframes) debug("ATTRACTOR", value[ATTRACTOR])
	value[FORCE] = buffer_read_double()			if (dev_mode_debug_keyframes) debug("FORCE", value[FORCE])
}

if (tl.value_type[LIGHT])
{
	value[LIGHTCOLOR] = buffer_read_int()		if (dev_mode_debug_keyframes) debug("LIGHTCOLOR", value[LIGHTCOLOR])
	value[LIGHTRANGE] = buffer_read_double()	if (dev_mode_debug_keyframes) debug("LIGHTRANGE", value[LIGHTRANGE])
	value[LIGHTFADESIZE] = buffer_read_double()	if (dev_mode_debug_keyframes) debug("LIGHTFADESIZE", value[LIGHTFADESIZE])
}

if (tl.value_type[SPOTLIGHT])
{
	value[LIGHTSPOTRADIUS] = buffer_read_double()			if (dev_mode_debug_keyframes) debug("LIGHTSPOTRADIUS", value[LIGHTSPOTRADIUS])
	value[LIGHTSPOTSHARPNESS] = buffer_read_double()		if (dev_mode_debug_keyframes) debug("LIGHTSPOTSHARPNESS", value[LIGHTSPOTSHARPNESS])
}

if (tl.value_type[CAMERA])
{
	if (load_format >= project_100demo4)
	{
		value[CAMFOV] = buffer_read_double()				if (dev_mode_debug_keyframes) debug("CAMFOV", value[CAMFOV])
		if (load_format < project_106_2)
			buffer_read_double() // CAM RATIO
		value[CAMROTATE] = buffer_read_byte()				if (dev_mode_debug_keyframes) debug("CAMROTATE", value[CAMROTATE])
		value[CAMROTATEDISTANCE] = buffer_read_double()		if (dev_mode_debug_keyframes) debug("CAMROTATEDISTANCE", value[CAMROTATEDISTANCE])
		value[CAMROTATEXYANGLE] = buffer_read_double()		if (dev_mode_debug_keyframes) debug("CAMROTATEXYANGLE", value[CAMROTATEXYANGLE])
		value[CAMROTATEZANGLE] = buffer_read_double()		if (dev_mode_debug_keyframes) debug("CAMROTATEZANGLE", value[CAMROTATEZANGLE])
	}
	else
	{
		buffer_read_double() // old rotate values
		buffer_read_double()
		buffer_read_double()
		value[CAMFOV] = buffer_read_double()				if (dev_mode_debug_keyframes) debug("CAMFOV", value[CAMFOV])
	}
	
	value[CAMDOF] = buffer_read_byte()						if (dev_mode_debug_keyframes) debug("CAMDOF", value[CAMDOF])
	value[CAMDOFDEPTH] = buffer_read_double()				if (dev_mode_debug_keyframes) debug("CAMDOFDEPTH", value[CAMDOFDEPTH])
	value[CAMDOFRANGE] = buffer_read_double()				if (dev_mode_debug_keyframes) debug("CAMDOFRANGE", value[CAMDOFRANGE])
	value[CAMDOFFADESIZE] = buffer_read_double()			if (dev_mode_debug_keyframes) debug("CAMDOFFADESIZE", value[CAMDOFFADESIZE])
	
	if (load_format >= project_106_2)
	{
		value[CAMWIDTH] = buffer_read_int()					if (dev_mode_debug_keyframes) debug("CAMWIDTH", value[CAMWIDTH])
		value[CAMHEIGHT] = buffer_read_int()				if (dev_mode_debug_keyframes) debug("CAMHEIGHT", value[CAMHEIGHT])
		value[CAMSIZEUSEPROJECT] = buffer_read_byte()		if (dev_mode_debug_keyframes) debug("CAMSIZEUSEPROJECT", value[CAMSIZEUSEPROJECT])
		value[CAMSIZEKEEPASPECTRATIO] = buffer_read_byte()	if (dev_mode_debug_keyframes) debug("CAMSIZEKEEPASPECTRATIO", value[CAMSIZEKEEPASPECTRATIO])
	}
}

if (tl.value_type[BACKGROUND])
{
	value[BGSKYMOONPHASE] = buffer_read_byte()				if (dev_mode_debug_keyframes) debug("BGSKYMOONPHASE", value[BGSKYMOONPHASE])
	value[BGSKYTIME] = buffer_read_double()					if (dev_mode_debug_keyframes) debug("BGSKYTIME", value[BGSKYTIME])
	value[BGSKYROTATION] = buffer_read_double()				if (dev_mode_debug_keyframes) debug("BGSKYROTATION", value[BGSKYROTATION])
	value[BGSKYCLOUDSSPEED] = buffer_read_double()			if (dev_mode_debug_keyframes) debug("BGSKYCLOUDSSPEED", value[BGSKYCLOUDSSPEED])
	value[BGSKYCOLOR] = buffer_read_int()					if (dev_mode_debug_keyframes) debug("BGSKYCOLOR", value[BGSKYCOLOR])
	value[BGSKYCLOUDSCOLOR] = buffer_read_int()				if (dev_mode_debug_keyframes) debug("BGSKYCLOUDSCOLOR", value[BGSKYCLOUDSCOLOR])
	value[BGSUNLIGHTCOLOR] = buffer_read_int()				if (dev_mode_debug_keyframes) debug("BGSUNLIGHTCOLOR", value[BGSUNLIGHTCOLOR])
	value[BGAMBIENTCOLOR] = buffer_read_int()				if (dev_mode_debug_keyframes) debug("BGAMBIENTCOLOR", value[BGAMBIENTCOLOR])
	value[BGNIGHTCOLOR] = buffer_read_int()					if (dev_mode_debug_keyframes) debug("BGNIGHTCOLOR", value[BGNIGHTCOLOR])
	value[BGFOGCOLOR] = buffer_read_int()					if (dev_mode_debug_keyframes) debug("BGFOGCOLOR", value[BGFOGCOLOR])
	value[BGFOGDISTANCE] = buffer_read_double()				if (dev_mode_debug_keyframes) debug("BGFOGDISTANCE", value[BGFOGDISTANCE])
	value[BGFOGSIZE] = buffer_read_double()					if (dev_mode_debug_keyframes) debug("BGFOGSIZE", value[BGFOGSIZE])
	
	if (load_format >= project_100debug)
		value[BGFOGHEIGHT] = buffer_read_double()			if (dev_mode_debug_keyframes) debug("BGFOGHEIGHT", value[BGFOGHEIGHT])
		
	value[BGWINDSPEED] = buffer_read_double()				if (dev_mode_debug_keyframes) debug("BGWINDSPEED", value[BGWINDSPEED])
	value[BGWINDSTRENGTH] = buffer_read_double()			if (dev_mode_debug_keyframes) debug("BGWINDSTRENGTH", value[BGWINDSTRENGTH])
	value[BGTEXTUREANISPEED] = buffer_read_double()			if (dev_mode_debug_keyframes) debug("BGTEXTUREANISPEED", value[BGTEXTUREANISPEED])
}

if (tl.value_type[TEXTURE])
{
	value[TEXTUREOBJ] = iid_read()							if (dev_mode_debug_keyframes) debug("TEXTUREOBJ", value[TEXTUREOBJ])
}

if (tl.value_type[SOUND])
{
	value[SOUNDOBJ] = iid_read()							if (dev_mode_debug_keyframes) debug("SOUNDOBJ", value[SOUNDOBJ])
	value[SOUNDVOLUME] = buffer_read_double()				if (dev_mode_debug_keyframes) debug("SOUNDVOLUME", value[SOUNDVOLUME])
	value[SOUNDSTART] = buffer_read_double()				if (dev_mode_debug_keyframes) debug("SOUNDSTART", value[SOUNDSTART])
	value[SOUNDEND] = buffer_read_double()					if (dev_mode_debug_keyframes) debug("SOUNDEND", value[SOUNDEND])
}

value[VISIBLE] = buffer_read_byte()							if (dev_mode_debug_keyframes) debug("VISIBLE", value[VISIBLE])
value[TRANSITION] = buffer_read_int()						if (dev_mode_debug_keyframes) debug("TRANSITION", value[TRANSITION])
*/