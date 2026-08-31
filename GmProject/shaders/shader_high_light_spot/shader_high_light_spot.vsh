/// shader_high_light_spot

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec4 in_Wave;
attribute vec3 in_Tangent;

uniform mat4 uLightMatrix; // static
uniform mat4 uShadowMatrix; // static

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vTangent;
varying mat3 vTBN;
varying vec2 vTexCoord;
varying vec4 vScreenCoord;
varying vec4 vShadowCoord;
varying vec4 vCustom;
varying vec4 vColor;

uniform vec4 uBlendColor;

// Texture
uniform vec2 uTextureOffset;

#pragma shady: inline(common_position.WORLD_POSITION_LIB)
#pragma shady: inline(common_position.CLIP_POSITION_LIB)

void main()
{
	vPosition = getWorldPosition(in_Position, in_Wave);
	vNormal = (gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0)).xyz;
	vTangent = (gm_Matrices[MATRIX_WORLD] * vec4(in_Tangent, 0.0)).xyz;
	vTangent = normalize(vTangent - dot(vTangent, vNormal) * vNormal);
	vTBN = mat3(vTangent, cross(vTangent, vNormal), vNormal);
	
	vTexCoord = in_TextureCoord + uTextureOffset;
	vScreenCoord = uLightMatrix * vec4(vPosition, 1.0);
	vShadowCoord = uShadowMatrix * vec4(vPosition, 1.0);
	vCustom = in_Wave;
	vColor = uBlendColor * in_Colour;
	
	gl_Position = getClipPosition(vPosition);
}
