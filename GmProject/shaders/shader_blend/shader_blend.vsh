/// @desc Blends (multiplies) all pixels by the given color factor.

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;
attribute vec4 in_Custom;
attribute vec3 in_Tangent;

uniform vec4 uBlendColor;

varying vec3 vPosition;
varying vec2 vTexCoord;
varying vec4 vColor;

// Texture
uniform vec2 uTextureOffset;

#pragma shady: inline(common_position.WORLD_POSITION_LIB)
#pragma shady: inline(common_position.CLIP_POSITION_LIB)

void main()
{
	vPosition = getWorldPosition(in_Position, in_Custom);
	vColor = getVertexColor(in_Custom) * uBlendColor;
	vTexCoord = in_TextureCoord + uTextureOffset;
	
	gl_Position = getClipPosition(vPosition);
}
