#pragma shady: skip_compilation
void main() {}

#region WORLD_POSITION_LIB
#pragma shady: macro_begin WORLD_POSITION_LIB

#pragma shady: inline(common_constants.MATH)

uniform vec4 uBlockColors[255]; // static

vec4 getVertexColor(vec4 custom)
{
	// Custom W component is packed subsurface flag and 1-based color index
	int colorIndex = int(floor(custom.w / 2.0));
	
	// Color table lookup
	if (colorIndex > 0)
		return uBlockColors[colorIndex - 1];

	// Zero is untinted
	return vec4(1.0);
}

vec4 getVertexCustom(vec4 custom)
{
	// X/Y: wind flags
	// Z: emissive
	// W: subsurface flag
	return vec4(custom.xyz, mod(custom.w, 2.0));
}

// Wind
uniform float uTime; // static
uniform float uWindEnable;
uniform float uWindTerrain;
uniform float uWindSpeed; // static
uniform float uWindStrength;
uniform vec2 uWindDirection; // static
uniform float uWindDirectionalSpeed; // static
uniform float uWindDirectionalStrength;

// GPU Gems 3: Chapter 6
// https://developer.nvidia.com/gpugems/gpugems3/part-i-geometry/chapter-6-gpu-generated-procedural-wind-animations-trees
float getNoise(float v)
{
	return cos(v * PI) * cos(v * 3.0 * PI) * cos(v * 5.0 * PI) * cos(v * 7.0 * PI) + sin(v * 5.0 * PI) * 0.1;
}

vec3 getWind(float time, vec3 pos, vec4 inCustom)
{
	return vec3(
		sin((time + pos.x * 10.0 + pos.y + pos.z) * (uWindSpeed / 5.0)) * max(inCustom.x * uWindTerrain, uWindEnable) * uWindStrength,
		sin((time + pos.x + pos.y * 10.0 + pos.z) * (uWindSpeed / 7.5)) * max(inCustom.x * uWindTerrain, uWindEnable) * uWindStrength,
		sin((time + pos.x + pos.y + pos.z * 10.0) * (uWindSpeed / 10.0)) * max(inCustom.y * uWindTerrain, uWindEnable) * uWindStrength
	);
}

vec3 getWindAngle(vec3 pos, vec4 inCustom)
{
	float strength = dot(pos.xy/16.0, uWindDirection) / dot(uWindDirection, uWindDirection);
	float diroff = getNoise(((uWindDirectionalSpeed - (strength / 3.0) - (pos.z/64.0)) * .075));
	return vec3(uWindDirection * diroff, 0.0) * (1.0 - step(max(inCustom.x * uWindTerrain, uWindEnable), 0.0)) * uWindDirectionalStrength;
}

vec3 getWorldPosition(vec3 pos, vec4 inCustom)
{
	if (max((inCustom.x + inCustom.y) * uWindTerrain, uWindEnable) * uWindStrength > 0.0)
		return (gm_Matrices[MATRIX_WORLD] * vec4(pos + getWind(uTime, pos, inCustom), 1.0)).xyz + getWindAngle(pos, inCustom);
	else
		return (gm_Matrices[MATRIX_WORLD] * vec4(pos, 1.0)).xyz;
}

#pragma shady: macro_end
#endregion

#region CLIP_POSITION_LIB
#pragma shady: macro_begin CLIP_POSITION_LIB

uniform mat4 uAAMatrix; // static

vec4 getClipPosition(vec3 worldPos)
{
	return uAAMatrix * gm_Matrices[MATRIX_PROJECTION] * (gm_Matrices[MATRIX_VIEW] * vec4(worldPos, 1.0));
}

#pragma shady: macro_end
#endregion
