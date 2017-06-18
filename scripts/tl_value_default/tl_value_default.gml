/// tl_value_default(valueid)
/// @arg valueid

switch (argument0)
{
	case XSCA: case YSCA: case ZSCA: return 1
	case ALPHA: return 1
	case RGBMUL: case HSBMUL: return c_white
	case SPAWN: return true
	case ATTRACTOR: return app
	case FORCE: return 1
	case LIGHTCOLOR: return c_white
	case LIGHTRANGE: return 250
	case LIGHTFADESIZE: return 0.5
	case LIGHTSPOTRADIUS: return 50
	case LIGHTSPOTSHARPNESS: return 0.5
	case CAMFOV: return 45
	case CAMROTATEDISTANCE: return 100
	case CAMDOFRANGE: return 200
	case CAMDOFFADESIZE: return 100
	case CAMWIDTH: return 1280
	case CAMHEIGHT: return 720
	case CAMSIZEUSEPROJECT: return true
	case CAMSIZEKEEPASPECTRATIO: return true
	case BGSKYMOONPHASE: return app.background_sky_moon_phase
	case BGSKYTIME: return app.background_sky_time
	case BGSKYROTATION: return app.background_sky_rotation
	case BGSKYCLOUDSSPEED: return app.background_sky_clouds_speed
	case BGSKYCOLOR: return app.background_sky_color
	case BGSKYCLOUDSCOLOR: return app.background_sky_clouds_color
	case BGSUNLIGHTCOLOR: return app.background_sunlight_color
	case BGAMBIENTCOLOR: return app.background_ambient_color
	case BGNIGHTCOLOR: return app.background_night_color
	case BGFOGCOLOR: return app.background_fog_color
	case BGFOGDISTANCE: return app.background_fog_distance
	case BGFOGSIZE: return app.background_fog_size
	case BGFOGHEIGHT: return app.background_fog_height
	case BGWINDSPEED: return app.background_wind_speed
	case BGWINDSTRENGTH: return app.background_wind_strength
	case BGTEXTUREANISPEED: return app.background_texture_animation_speed
	case TEXTUREOBJ: return null
	case SOUNDOBJ: return null
	case SOUNDVOLUME: return 1
	case VISIBLE: return true
}
return 0
