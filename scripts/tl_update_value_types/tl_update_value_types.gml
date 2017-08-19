/// tl_update_value_types()
/// @desc Updates the available value types.

for (var v = 0; v < value_types; v++)
	value_type[v] = false

if (type = "audio")
{
	value_type[SOUND] = true
	value_type[AUDIO] = true
	return 0
}

value_type[KEYFRAME] = true

if (type = "background")
{
	value_type[BACKGROUND] = true
	return 0
}

// Info
value_type[HIERARCHY] = true
value_type[GRAPHICS] = true

if (type = "camera")
	value_type[GRAPHICS] = false

// Position
value_type[POSITION] = true

// Rotation
if (type != "particles" && type != "pointlight")
	value_type[ROTATION] = true

// Scale
if (type != "particles" && type != "camera" && type != "pointlight" && type != "spotlight")
	value_type[SCALE] = true

// Bend
if (type = "bodypart" && model_part != null && model_part.bend_part != null)
	value_type[BEND] = true

// Color
if (type != "pointlight" && type != "spotlight")
	value_type[COLOR] = true

// Particles
if (type = "particles")
	value_type[PARTICLES] = true

// Light
if (type = "pointlight" || type = "spotlight")
	value_type[LIGHT] = true

// Spotlight
if (type = "spotlight")
	value_type[SPOTLIGHT] = true

// Camera
if (type = "camera")
	value_type[CAMERA] = true

// Texture
if (type != "item" && type != "particles" && type != "camera" && type != "pointlight" && type != "spotlight" && type != "text" && type != "folder")
	value_type[TEXTURE] = true

// Rotation point
value_type[ROTPOINT] = true
if (type = "char" || type = "bodypart" || type = "particles" || type = "camera" || type = "pointlight" || type = "spotlight" || type = "folder")
	value_type[ROTPOINT] = false
