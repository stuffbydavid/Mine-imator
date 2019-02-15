/// tl_update_value_types()
/// @desc Updates the available value types.

for (var v = 0; v < e_value_type.amount; v++)
	value_type[v] = false

if (type = e_tl_type.AUDIO)
{
	value_type[e_value_type.SOUND] = true
	value_type[e_value_type.AUDIO] = true
	return 0
}

value_type[e_value_type.KEYFRAME] = true

if (type = e_tl_type.BACKGROUND)
{
	value_type[e_value_type.BACKGROUND] = true
	return 0
}

// Info
value_type[e_value_type.HIERARCHY] = true
value_type[e_value_type.GRAPHICS] = true

if (type = e_tl_type.CAMERA)
	value_type[e_value_type.GRAPHICS] = false

// Position
value_type[e_value_type.POSITION] = true

// Rotation
if (type != e_tl_type.PARTICLE_SPAWNER && type != e_tl_type.POINT_LIGHT)
	value_type[e_value_type.ROTATION] = true

// Scale
if (type != e_tl_type.PARTICLE_SPAWNER &&
	type != e_tl_type.CAMERA &&
	type != e_tl_type.POINT_LIGHT &&
	type != e_tl_type.SPOT_LIGHT)
	value_type[e_value_type.SCALE] = true

// Bend
if (type = e_tl_type.BODYPART && model_part != null && model_part.bend_part != null)
	value_type[e_value_type.BEND] = true

// Color
if (type != e_tl_type.POINT_LIGHT && type != e_tl_type.SPOT_LIGHT)
	value_type[e_value_type.COLOR] = true

// Particles
if (type = e_tl_type.PARTICLE_SPAWNER)
	value_type[e_value_type.PARTICLES] = true

// Light
if (type = e_tl_type.POINT_LIGHT || type = e_tl_type.SPOT_LIGHT)
	value_type[e_value_type.LIGHT] = true

// Spotlight
if (type = e_tl_type.SPOT_LIGHT)
	value_type[e_value_type.SPOTLIGHT] = true

// Camera
if (type = e_tl_type.CAMERA)
	value_type[e_value_type.CAMERA] = true

// Texture
if (type != e_tl_type.ITEM &&
	type != e_tl_type.PARTICLE_SPAWNER &&
	type != e_tl_type.CAMERA &&
	type != e_tl_type.POINT_LIGHT &&
	type != e_tl_type.SPOT_LIGHT &&
	type != e_tl_type.TEXT &&
	type != e_tl_type.FOLDER)
	value_type[e_value_type.TEXTURE] = true
	
// Text
if (type = e_tl_type.TEXT)
	value_type[e_value_type.TEXT] = true

// Item
if (type = e_tl_type.ITEM)
	value_type[e_value_type.ITEM] = true
	
// Rotation point
value_type[e_value_type.ROT_POINT] = true
if (type = e_tl_type.PARTICLE_SPAWNER ||
	type = e_tl_type.CAMERA ||
	type = e_tl_type.POINT_LIGHT ||
	type = e_tl_type.SPOT_LIGHT)
	value_type[e_value_type.ROT_POINT] = false
