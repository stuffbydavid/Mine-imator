/// shader_high_fog
/// @desc White=fog, Black=no fog

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec4 in_Wave;
attribute vec3 in_Tangent;

varying vec3 vPosition;
varying vec4 vColor;
varying vec2 vTexCoord;
varying float vDepth;

uniform vec4 uBlendColor;

// Texture
uniform vec2 uTextureOffset;

#pragma shady: inline(common_position.WORLD_POSITION_LIB)
#pragma shady: inline(common_position.CLIP_POSITION_LIB)

void main()
{
	vPosition = getWorldPosition(in_Position, in_Wave);
	vColor = in_Colour * uBlendColor;
	vTexCoord = in_TextureCoord + uTextureOffset;
	
	vDepth = (gm_Matrices[MATRIX_WORLD_VIEW] * vec4(vPosition, 1.0)).z;
	
	gl_Position = getClipPosition(vPosition);
}
