/// shader_high_material

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec4 in_Wave;
attribute vec3 in_Tangent;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vTangent;
varying vec4 vColor;
varying vec4 vCustom;
varying vec2 vTexCoord;
varying float vTime;
varying float vWindDirection;

uniform vec4 uBlendColor;

// Wind
uniform float uTime;
uniform float uWindEnable;
uniform float uWindTerrain;
uniform float uWindSpeed;
uniform float uWindStrength;
uniform float uWindDirection;
uniform float uWindDirectionalSpeed;
uniform float uWindDirectionalStrength;

// TAA
uniform mat4 uTAAMatrix;

// GPU Gems 3: Chapter 6
#define PI 3.14159265
float getNoise(float v)
{
	return cos(v * PI) * cos(v * 3.0 * PI) * cos(v * 5.0 * PI) * cos(v * 7.0 * PI) + sin(v * 5.0 * PI) * 0.1;
}

vec3 getWind()
{
	return vec3(
		sin((uTime + in_Position.x * 10.0 + in_Position.y + in_Position.z) * (uWindSpeed / 5.0)) * max(in_Wave.x * uWindTerrain, uWindEnable) * uWindStrength,
		sin((uTime + in_Position.x + in_Position.y * 10.0 + in_Position.z) * (uWindSpeed / 7.5)) * max(in_Wave.x * uWindTerrain, uWindEnable) * uWindStrength,
		sin((uTime + in_Position.x + in_Position.y + in_Position.z * 10.0) * (uWindSpeed / 10.0)) * max(in_Wave.y * uWindTerrain, uWindEnable) * uWindStrength
	);
}

vec3 getWindAngle(vec3 pos)
{
	vec2 angle = vec2(cos(uWindDirection), sin(uWindDirection));
	float strength = dot(pos.xy/16.0, angle) / dot(angle, angle);
	float diroff = getNoise((((uTime * uWindDirectionalSpeed) - (strength / 3.0) - (pos.z/64.0)) * .075));
	return vec3(angle * diroff, 0.0) * (1.0 - step(max(in_Wave.x * uWindTerrain, uWindEnable), 0.0)) * uWindDirectionalStrength;
}

void main()
{
	vPosition = (gm_Matrices[MATRIX_WORLD] * vec4(in_Position + getWind(), 1.0)).xyz;
	vPosition += getWindAngle(in_Position);
	
	vNormal = (gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0)).xyz;
	vTangent = (gm_Matrices[MATRIX_WORLD] * vec4(in_Tangent, 0.0)).xyz;
	vColor = in_Colour * uBlendColor;
	vTexCoord = in_TextureCoord;
	vTime = uTime;
	vWindDirection = uWindDirection;
	vCustom = in_Wave;
	
	gl_Position = uTAAMatrix * gm_Matrices[MATRIX_PROJECTION] * (gm_Matrices[MATRIX_VIEW] * vec4(vPosition, 1.0));
}
