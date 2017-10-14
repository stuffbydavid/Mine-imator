/// shader_high_light_sun
/// @desc Add shadows from the sun

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec3 in_Wave;

uniform float uBrightness;
uniform float uBlockBrightness;
uniform int uIsGround;
uniform vec3 uSunAt;

uniform mat4 uLightMatrix;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec2 vTexCoord;
varying vec4 vScreenCoord;
varying float vBrightness;

// Wind
uniform float uTime;
uniform float uWindEnable;
uniform float uWindTerrain;
uniform float uWindSpeed;
uniform float uWindStrength;

vec3 getWind()
{
	return vec3(
		sin((uTime + in_Position.x * 10.0 + in_Position.y + in_Position.z) * (uWindSpeed / 5.0)) * max(in_Wave.x * uWindTerrain, uWindEnable) * uWindStrength,
		sin((uTime + in_Position.x + in_Position.y * 10.0 + in_Position.z) * (uWindSpeed / 7.5)) * max(in_Wave.x * uWindTerrain, uWindEnable) * uWindStrength,
		sin((uTime + in_Position.x + in_Position.y + in_Position.z * 10.0) * (uWindSpeed / 10.0)) * max(in_Wave.y * uWindTerrain, uWindEnable) * uWindStrength
	);
}

void main()
{
	vec3 off = getWind();
	vPosition = (gm_Matrices[MATRIX_WORLD] * vec4(in_Position + off, 1.0)).xyz;
	vNormal = (gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0)).xyz;
	vTexCoord = in_TextureCoord;
	vScreenCoord = uLightMatrix * vec4(vPosition, 1.0);
	vBrightness = in_Wave.z * uBlockBrightness + uBrightness;
	
	// Single normal for ground
	if (uIsGround > 0)
		vPosition = uSunAt;
	
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position + off, 1.0);
}
