// Shaderpack functions implemented in C++ (CppProject/ShaderPack/SpHost.cpp).
// Shaderpacks are Minecraft OptiFine/Iris shaderpacks rendered with the scene's geometry.

/// CppSeparate ArrType shaderpack_list(StringType)
/// Returns the names of the shaderpack folders and zip files in a directory.
function shaderpack_list(dir)
{
	return array()
}

/// CppSeparate BoolType shaderpack_load(StringType, StringType)
/// Loads a shaderpack folder or zip file with option values ("NAME=value;..."), returns whether successful.
function shaderpack_load(path, options)
{
	return false
}

/// CppSeparate void shaderpack_unload()
function shaderpack_unload()
{
}

/// CppSeparate BoolType shaderpack_is_loaded()
function shaderpack_is_loaded()
{
	return false
}

/// CppSeparate StringType shaderpack_get_path()
function shaderpack_get_path()
{
	return ""
}

/// CppSeparate StringType shaderpack_get_error()
/// Returns the errors of the last load or frame.
function shaderpack_get_error()
{
	return ""
}

/// CppSeparate void shaderpack_frame_begin(VecType, VecType, VecType, RealType, RealType, RealType, RealType, RealType, RealType, IntType, IntType)
/// Starts recording the geometry of a frame, submitted vertex buffers are captured until shaderpack_frame_end.
function shaderpack_frame_begin(from, to, up, fov, znear, zfar, skytime, skyrotation, time, width, height)
{
}

/// CppSeparate void shaderpack_set_environment(IntType, IntType, RealType, RealType, IntType)
/// Sets the sky and fog colors, rain and thunder strength and moon phase of the frame.
function shaderpack_set_environment(skycolor, fogcolor, rain, thunder, moonphase)
{
}

/// CppSeparate void shaderpack_set_sky_textures(IntType, IntType, BoolType)
/// Sets the sun and moon textures, the moon either has a single or all 4x2 phases.
function shaderpack_set_sky_textures(sun, moon, moonphasegrid)
{
}

/// CppSeparate void shaderpack_set_phase(IntType)
/// Sets the e_shaderpack_phase of the following vertex buffers.
function shaderpack_set_phase(phase)
{
}

/// CppSeparate void shaderpack_set_shadows(BoolType)
/// Sets whether the following vertex buffers cast shadows.
function shaderpack_set_shadows(shadows)
{
}

/// CppSeparate void shaderpack_set_color(IntType, RealType)
/// Sets the color multiplier of the following vertex buffers.
function shaderpack_set_color(color, alpha)
{
}

/// CppSeparate BoolType shaderpack_frame_end(IntType, IntType)
/// Renders the recorded geometry into a surface, repeating the frame for temporal effects.
function shaderpack_frame_end(surface, iterations)
{
	return false
}
