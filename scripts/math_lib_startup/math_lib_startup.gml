/// math_lib_startup(path)
/// @arg path

/* SimplexNoise1234, Simplex noise with true analytic
 * derivative in 1D to 4D.
 *
 * Author: Stefan Gustavson, 2003-2005
 * Contact: stegu@itn.liu.se
 *
 * This code was GPL licensed until February 2011.
 * As the original author of this code, I hereby
 * release it into the public domain.
 * Please feel free to use it for whatever you want.
 * Credit is appreciated where appropriate, and I also
 * appreciate being told where this code finds any use,
 * but you may do as you like.
 */
 
var path = argument0;

log("External library", path)
globalvar lib_math_simplex1d, lib_math_simplex2d, lib_math_simplex3d, lib_math_simplex4d;
lib_math_simplex1d = external_define(path, "simplex1D", dll_cdecl, ty_real, 1, ty_real)
lib_math_simplex2d = external_define(path, "simplex2D", dll_cdecl, ty_real, 2, ty_real, ty_real)
lib_math_simplex3d = external_define(path, "simplex3D", dll_cdecl, ty_real, 3, ty_real, ty_real, ty_real)
lib_math_simplex4d = external_define(path, "simplex4D", dll_cdecl, ty_real, 4, ty_real, ty_real, ty_real, ty_real)
