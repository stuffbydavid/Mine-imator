#pragma shady: skip_compilation
void main() {}

#region PACK_VALUE_LIB
#pragma shady: macro_begin PACK_VALUE_LIB

vec3 packValue(float f)
{
	return vec3(floor(f * 255.0) / 255.0, fract(f * 255.0), fract(f * 255.0 * 255.0));
}

#pragma shady: macro_end
#endregion

#region UNPACK_VALUE_LIB
#pragma shady: macro_begin UNPACK_VALUE_LIB

float unpackValue(vec4 c)
{
	return c.r + c.g / 255.0 + c.b / (255.0 * 255.0);
}

#pragma shady: macro_end
#endregion

#region NORMAL_BUFFER_LIB
#pragma shady: macro_begin NORMAL_BUFFER_LIB

uniform float uNormalBufferScale;

vec4 packNormal(vec3 n)
{
	return vec4(((n + vec3(1.0)) * 0.5) * uNormalBufferScale, 1.0);
}

vec3 unpackNormal(vec4 c)
{
	return (c.rgb / uNormalBufferScale) * 2.0 - 1.0;
}

#pragma shady: macro_end
#endregion