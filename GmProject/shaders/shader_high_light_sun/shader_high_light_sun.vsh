/// @desc Add shadows from the sun.

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
varying vec2 vTexCoord;
varying vec4 vScreenCoord0;
varying vec4 vScreenCoord1;
varying vec4 vScreenCoord2;
varying vec2 vDepthSlope0;
varying vec2 vDepthSlope1;
varying vec2 vDepthSlope2;
varying float vClipSpaceDepth;
varying vec4 vColor;
varying vec4 vCustom;
varying vec4 vClipPosition;

uniform vec4 uBlendColor;

// Texture
uniform vec2 uTextureOffset;

#pragma shady: inline(common_position.WORLD_POSITION_LIB)
#pragma shady: inline(common_position.CLIP_POSITION_LIB)
#pragma shady: inline(common_util.MATRIX_LIB)

#pragma shady: inline(common_shadows.PCSS_PLANE_LIB)

void main()
{
	vPosition = getWorldPosition(in_Position, in_Wave);
	gl_Position = getClipPosition(vPosition);
	vClipPosition = gl_Position;
	vClipSpaceDepth = gl_Position.z;
	
	vScreenCoord0 = uLightMatBiasMVP[0] * vec4(vPosition, 1.0);
	vScreenCoord1 = uLightMatBiasMVP[1] * vec4(vPosition, 1.0);
	vScreenCoord2 = uLightMatBiasMVP[2] * vec4(vPosition, 1.0);
	
	vNormal = inverse2(gm_Matrices[MATRIX_WORLD]) * in_Normal;
	vec3 normal = normalize(vNormal);
	vDepthSlope0 = getPCSSOrthoSlope(uLightMatBiasMVP[0], normal);
	vDepthSlope1 = getPCSSOrthoSlope(uLightMatBiasMVP[1], normal);
	vDepthSlope2 = getPCSSOrthoSlope(uLightMatBiasMVP[2], normal);
	vTangent = (gm_Matrices[MATRIX_WORLD] * vec4(in_Tangent, 0.0)).xyz;
	
	vTexCoord = in_TextureCoord + uTextureOffset;
	vCustom = in_Wave;
	
	vColor = uBlendColor * in_Colour;
}
