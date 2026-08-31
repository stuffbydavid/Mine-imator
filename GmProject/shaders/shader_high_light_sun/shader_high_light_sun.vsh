/// shader_high_light_sun
/// @desc Add shadows from the sun

#define NUM_CASCADES 3

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec4 in_Wave;
attribute vec3 in_Tangent;

uniform mat4 uLightMatBiasMVP[NUM_CASCADES]; // static

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vTangent;
varying mat3 vTBN;
varying vec2 vTexCoord;
varying vec4 vScreenCoord0;
varying vec4 vScreenCoord1;
varying vec4 vScreenCoord2;
varying float vClipSpaceDepth;
varying vec4 vColor;
varying vec4 vCustom;

uniform vec4 uBlendColor;

// Texture
uniform vec2 uTextureOffset;

// Wind
uniform float uTime; // static
uniform float uWindEnable;
uniform float uWindTerrain;
uniform float uWindSpeed; // static
uniform float uWindStrength;
uniform vec2 uWindDirection; // static
uniform float uWindDirectionalSpeed; // static
uniform float uWindDirectionalStrength;

#pragma shady: inline(common_position.WORLD_POSITION_LIB)
#pragma shady: inline(common_position.CLIP_POSITION_LIB)

void main()
{
	vPosition = getWorldPosition(in_Position, in_Wave);
	gl_Position = getClipPosition(vPosition);
	vClipSpaceDepth = gl_Position.z;
	
	vScreenCoord0 = uLightMatBiasMVP[0] * vec4(vPosition, 1.0);
	vScreenCoord1 = uLightMatBiasMVP[1] * vec4(vPosition, 1.0);
	vScreenCoord2 = uLightMatBiasMVP[2] * vec4(vPosition, 1.0);
	
	vNormal = (gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0)).xyz;
	vTangent = (gm_Matrices[MATRIX_WORLD] * vec4(in_Tangent, 0.0)).xyz;
	vTangent = normalize(vTangent - dot(vTangent, vNormal) * vNormal);
	vTBN = mat3(vTangent, cross(vTangent, vNormal), vNormal);
	
	vTexCoord = in_TextureCoord + uTextureOffset;
	vCustom = in_Wave;
	
	vColor = uBlendColor * in_Colour;
}
