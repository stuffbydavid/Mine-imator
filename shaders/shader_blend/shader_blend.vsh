/// shader_blend
/// @desc Blends (multiplies) all pixels by the given color factor.

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec3 in_Custom;

uniform vec4 uBlendColor;

varying vec2 vTexCoord;
varying vec4 vColor;

// Wind
uniform float uTime;
uniform float uWindEnabled;
uniform float uWindTerrain;
uniform float uWindSpeed;
uniform float uWindStrength;

vec3 getWind()
{
	return vec3(
		sin((uTime + in_Position.x * 10.0 + in_Position.y + in_Position.z) * (uWindSpeed / 5.0)) * max(in_Custom.x * uWindTerrain, uWindEnabled) * uWindStrength,
		sin((uTime + in_Position.x + in_Position.y * 10.0 + in_Position.z) * (uWindSpeed / 7.5)) * max(in_Custom.x * uWindTerrain, uWindEnabled) * uWindStrength,
		sin((uTime + in_Position.x + in_Position.y + in_Position.z * 10.0) * (uWindSpeed / 10.0)) * max(in_Custom.y * uWindTerrain, uWindEnabled) * uWindStrength
	);
}

void main()
{
	vColor = in_Colour * uBlendColor;
	vTexCoord = in_TextureCoord;
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position + getWind(), 1.0);
}
