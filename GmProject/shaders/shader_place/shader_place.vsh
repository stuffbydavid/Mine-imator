attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec4 in_Wave;

uniform vec4 uBlendColor;
uniform vec2 uTextureOffset;

uniform mat4 uTAAMatrix;
uniform mat4 uPlaceNormalMatrix;

varying vec3 vPosition;
varying vec2 vTexCoord;
varying float vClipDepth;
varying vec3 vNormal;
varying vec4 vColor;

#pragma shady: inline(common_position.WORLD_POSITION_LIB)
#pragma shady: inline(common_util.MATRIX_LIB)

void main()
{
	vTexCoord = in_TextureCoord + uTextureOffset;
	vPosition = getWorldPosition(in_Position, in_Wave);
	
	gl_Position = uTAAMatrix * gm_Matrices[MATRIX_PROJECTION] * (gm_Matrices[MATRIX_VIEW] * vec4(vPosition, 1.0));
	vClipDepth = gl_Position.z;
	vNormal = (uPlaceNormalMatrix * vec4(normalize(inverse2(gm_Matrices[MATRIX_WORLD]) * in_Normal), 0.0)).xyz;
	vColor = uBlendColor * in_Colour;
}
