#pragma shady: skip_compilation
void main() {}

#region MATH
#pragma shady: macro_begin MATH

#ifndef SHADY_MATH_CONSTANTS
#define SHADY_MATH_CONSTANTS

#define PI 3.14159265359
#define TWO_PI 6.28318530718
#define MIN_PERCEPTUAL_ROUGHNESS 0.045
#define DIELECTRIC_F0 0.04

#endif

#pragma shady: macro_end
#endregion
