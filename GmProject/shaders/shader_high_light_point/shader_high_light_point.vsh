/// @desc Add shadows from a point light.

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;
attribute vec4 in_Custom;
attribute vec3 in_Tangent;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vTangent;
varying vec2 vTexCoord;
varying vec4 vCustom;
varying vec4 vColor;
varying vec4 vClipPosition;

uniform vec4 uBlendColor;

// Texture
uniform vec2 uTextureOffset;

#pragma shady: inline(common_position.WORLD_POSITION_LIB)
#pragma shady: inline(common_position.CLIP_POSITION_LIB)
#pragma shady: inline(common_util.MATRIX_LIB)

void main()
{
	vPosition = getWorldPosition(in_Position, in_Custom);
	vNormal = inverse2(gm_Matrices[MATRIX_WORLD]) * in_Normal;
	vTangent = (gm_Matrices[MATRIX_WORLD] * vec4(in_Tangent, 0.0)).xyz;
	
	vTexCoord = in_TextureCoord + uTextureOffset;
	vCustom = getVertexCustom(in_Custom);
	vColor = uBlendColor * getVertexColor(in_Custom);
	
	gl_Position = getClipPosition(vPosition);
	vClipPosition = gl_Position;
}
