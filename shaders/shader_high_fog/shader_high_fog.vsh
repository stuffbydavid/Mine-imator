/// shader_high_fog
/// @desc White=fog, Black=no fog

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec3 in_Custom;

varying vec3 vPosition;
varying vec2 vTexCoord;
varying float vDepth;

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
	vec3 off = getWind();
	vTexCoord = in_TextureCoord;
	vPosition = (gm_Matrices[MATRIX_WORLD] * vec4(in_Position + off, 1.0)).xyz;
	vDepth = (gm_Matrices[MATRIX_WORLD_VIEW] * vec4(in_Position + off, 1.0)).z;
	
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position + off, 1.0);
}
