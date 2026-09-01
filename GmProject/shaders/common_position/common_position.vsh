#pragma shady: skip_compilation
void main() {}

#region WORLD_POSITION_LIB
#pragma shady: macro_begin WORLD_POSITION_LIB

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
#define PI 3.14159265
float getNoise(float v)
{
	return cos(v * PI) * cos(v * 3.0 * PI) * cos(v * 5.0 * PI) * cos(v * 7.0 * PI) + sin(v * 5.0 * PI) * 0.1;
}

vec3 getWind(float time, vec3 pos, vec4 inWave)
{
	return vec3(
		sin((time + pos.x * 10.0 + pos.y + pos.z) * (uWindSpeed / 5.0)) * max(inWave.x * uWindTerrain, uWindEnable) * uWindStrength,
		sin((time + pos.x + pos.y * 10.0 + pos.z) * (uWindSpeed / 7.5)) * max(inWave.x * uWindTerrain, uWindEnable) * uWindStrength,
		sin((time + pos.x + pos.y + pos.z * 10.0) * (uWindSpeed / 10.0)) * max(inWave.y * uWindTerrain, uWindEnable) * uWindStrength
	);
}

vec3 getWindAngle(vec3 pos, vec4 inWave)
{
	float strength = dot(pos.xy/16.0, uWindDirection) / dot(uWindDirection, uWindDirection);
	float diroff = getNoise(((uWindDirectionalSpeed - (strength / 3.0) - (pos.z/64.0)) * .075));
	return vec3(uWindDirection * diroff, 0.0) * (1.0 - step(max(inWave.x * uWindTerrain, uWindEnable), 0.0)) * uWindDirectionalStrength;
}

vec3 getWorldPosition(vec3 pos, vec4 inWave)
{
	if (max((inWave.x + inWave.y) * uWindTerrain, uWindEnable) * uWindStrength > 0.0)
		return (gm_Matrices[MATRIX_WORLD] * vec4(pos + getWind(uTime, pos, inWave), 1.0)).xyz + getWindAngle(pos, inWave);
	else
		return (gm_Matrices[MATRIX_WORLD] * vec4(pos, 1.0)).xyz;
}

#pragma shady: macro_end
#endregion

#region CLIP_POSITION_LIB
#pragma shady: macro_begin CLIP_POSITION_LIB

uniform mat4 uTAAMatrix; // static

vec4 getClipPosition(vec3 worldPos)
{
	return uTAAMatrix * gm_Matrices[MATRIX_PROJECTION] * (gm_Matrices[MATRIX_VIEW] * vec4(worldPos, 1.0));
}

#pragma shady: macro_end
#endregion
