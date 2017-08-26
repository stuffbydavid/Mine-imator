/// project_write_values(timeline)
/// @arg timeline
/*
var tl = argument0;

if (tl.value_type[POSITION])
{
	buffer_write_double(value[XPOS])
	buffer_write_double(value[YPOS])
	buffer_write_double(value[ZPOS])
}

if (tl.value_type[ROTATION])
{
	buffer_write_double(value[XROT])
	buffer_write_double(value[YROT])
	buffer_write_double(value[ZROT])
}

if (tl.value_type[SCALE])
{
	buffer_write_double(value[XSCA])
	buffer_write_double(value[YSCA])
	buffer_write_double(value[ZSCA])
}

if (tl.value_type[BEND])
	buffer_write_double(value[BENDANGLE])

if (tl.value_type[COLOR])
{
	buffer_write_double(value[ALPHA])
	buffer_write_int(value[RGBADD])
	buffer_write_int(value[RGBSUB])
	buffer_write_int(value[RGBMUL])
	buffer_write_int(value[HSBADD])
	buffer_write_int(value[HSBSUB])
	buffer_write_int(value[HSBMUL])
	buffer_write_int(value[MIXCOLOR])
	buffer_write_double(value[MIXPERCENT])
	buffer_write_double(value[BRIGHTNESS])
}

if (tl.value_type[PARTICLES])
{
	buffer_write_byte(value[SPAWN])
	buffer_write_int(iid_get(value[ATTRACTOR]))
	buffer_write_double(value[FORCE])
}

if (tl.value_type[LIGHT])
{
	buffer_write_int(value[LIGHTCOLOR])
	buffer_write_double(value[LIGHTRANGE])
	buffer_write_double(value[LIGHTFADESIZE])
}

if (tl.value_type[SPOTLIGHT])
{
	buffer_write_double(value[LIGHTSPOTRADIUS])
	buffer_write_double(value[LIGHTSPOTSHARPNESS])
}

if (tl.value_type[CAMERA])
{
	buffer_write_double(value[CAMFOV])
	buffer_write_byte(value[CAMROTATE])
	buffer_write_double(value[CAMROTATEDISTANCE])
	buffer_write_double(value[CAMROTATEXYANGLE])
	buffer_write_double(value[CAMROTATEZANGLE])
	buffer_write_byte(value[CAMDOF])
	buffer_write_double(value[CAMDOFDEPTH])
	buffer_write_double(value[CAMDOFRANGE])
	buffer_write_double(value[CAMDOFFADESIZE])
	buffer_write_int(value[CAMWIDTH])
	buffer_write_int(value[CAMHEIGHT])
	buffer_write_byte(value[CAMSIZEUSEPROJECT])
	buffer_write_byte(value[CAMSIZEKEEPASPECTRATIO])
}

if (tl.value_type[BACKGROUND])
{
	buffer_write_byte(value[BGSKYMOONPHASE])
	buffer_write_double(value[BGSKYTIME])
	buffer_write_double(value[BGSKYROTATION])
	buffer_write_double(value[BGSKYCLOUDSSPEED])
	buffer_write_int(value[BGSKYCOLOR])
	buffer_write_int(value[BGSKYCLOUDSCOLOR])
	buffer_write_int(value[BGSUNLIGHTCOLOR])
	buffer_write_int(value[BGAMBIENTCOLOR])
	buffer_write_int(value[BGNIGHTCOLOR])
	buffer_write_int(value[BGFOGCOLOR])
	buffer_write_double(value[BGFOGDISTANCE])
	buffer_write_double(value[BGFOGSIZE])
	buffer_write_double(value[BGFOGHEIGHT])
	buffer_write_double(value[BGWINDSPEED])
	buffer_write_double(value[BGWINDSTRENGTH])
	buffer_write_double(value[BGTEXTUREANISPEED])
}

if (tl.value_type[TEXTURE])
	buffer_write_int(iid_get(value[TEXTUREOBJ]))

if (tl.value_type[SOUND])
{
	buffer_write_int(iid_get(value[SOUNDOBJ]))
	buffer_write_double(value[SOUNDVOLUME])
	buffer_write_double(value[SOUNDSTART])
	buffer_write_double(value[SOUNDEND])
}

buffer_write_byte(value[VISIBLE])
buffer_write_int(value[TRANSITION])
*/