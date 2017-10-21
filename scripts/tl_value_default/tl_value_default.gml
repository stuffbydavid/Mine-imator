/// tl_value_default(valueid)
/// @arg valueid

switch (argument0)
{
	case e_value.SCA_X:
	case e_value.SCA_Y:
	case e_value.SCA_Z: return 1
	case e_value.ALPHA: return 1
	case e_value.RGB_MUL:
	case e_value.HSB_MUL: return c_white
	case e_value.SPAWN: return true
	case e_value.CLEAR: return false
	case e_value.CUSTOM_SEED: return false
	case e_value.SEED: return ceil(random(32000))
	case e_value.FORCE: return 1
	case e_value.LIGHT_COLOR: return c_white
	case e_value.LIGHT_RANGE: return 250
	case e_value.LIGHT_FADE_SIZE: return 0.5
	case e_value.LIGHT_SPOT_RADIUS: return 50
	case e_value.LIGHT_SPOT_SHARPNESS: return 0.5
	case e_value.CAM_FOV: return 45
	case e_value.CAM_ROTATE_DISTANCE: return 100
	case e_value.CAM_DOF_RANGE: return 200
	case e_value.CAM_DOF_FADE_SIZE: return 100
	case e_value.CAM_WIDTH: return 1280
	case e_value.CAM_HEIGHT: return 720
	case e_value.CAM_SIZE_USE_PROJECT: return true
	case e_value.CAM_SIZE_KEEP_ASPECT_RATIO: return true
	case e_value.BG_SKY_MOON_PHASE: return app.background_sky_moon_phase
	case e_value.BG_SKY_TIME: return app.background_sky_time
	case e_value.BG_SKY_ROTATION: return app.background_sky_rotation
	case e_value.BG_SKY_CLOUDS_SPEED: return app.background_sky_clouds_speed
	case e_value.BG_SKY_COLOR: return app.background_sky_color
	case e_value.BG_SKY_CLOUDS_COLOR: return app.background_sky_clouds_color
	case e_value.BG_SUNLIGHT_COLOR: return app.background_sunlight_color
	case e_value.BG_AMBIENT_COLOR: return app.background_ambient_color
	case e_value.BG_NIGHT_COLOR: return app.background_night_color
	case e_value.BG_FOG_COLOR: return app.background_fog_color
	case e_value.BG_FOG_DISTANCE: return app.background_fog_distance
	case e_value.BG_FOG_SIZE: return app.background_fog_size
	case e_value.BG_FOG_HEIGHT: return app.background_fog_height
	case e_value.BG_WIND_SPEED: return app.background_wind_speed
	case e_value.BG_WIND_STRENGTH: return app.background_wind_strength
	case e_value.BG_TEXTURE_ANI_SPEED: return app.background_texture_animation_speed
	case e_value.ATTRACTOR:
	case e_value.TEXTURE_OBJ:
	case e_value.SOUND_OBJ:
	case e_value.TEXT_FONT: return null
	case e_value.SOUND_VOLUME: return 1
	case e_value.VISIBLE: return true
	case e_value.TEXT: return ""
	case e_value.TRANSITION: return "linear"
}

return 0
