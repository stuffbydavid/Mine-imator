#pragma shady: skip_compilation
void main() {}

#region TBN_LIB
#pragma shady: macro_begin TBN_LIB

vec3 packValue(float f)
{
	return vec3(floor(f * 255.0) / 255.0, fract(f * 255.0), fract(f * 255.0 * 255.0));
}

#pragma shady: macro_end
#endregion