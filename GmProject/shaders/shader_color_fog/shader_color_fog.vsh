/// @desc Blends all pixels by the given color factor and enables fog.

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec4 in_Wave;
attribute vec3 in_Tangent;

varying vec3 vPosition;
varying vec4 vColor;
varying vec2 vTexCoord;
varying vec3 vPlaceNormal;
varying float vPlaceDistance;
varying vec4 vCustom;

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
	vCustom = in_Wave;
	
	vPlaceNormal = in_Normal;
	vPlaceDistance = (gm_Matrices[MATRIX_VIEW] * vec4(vPosition, 1.0)).z;
	
	gl_Position = getClipPosition(vPosition);
}
