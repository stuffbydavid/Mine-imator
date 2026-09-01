/// shader_replace
/// @desc Replaces all pixels with the given color, alpha is rounded up.

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec4 in_Wave;
attribute vec3 in_Tangent;

varying vec2 vTexCoord;

// Texture
uniform vec2 uTextureOffset;

#pragma shady: inline(common_position.WORLD_POSITION_LIB)
#pragma shady: inline(common_position.CLIP_POSITION_LIB)

void main()
{
	vec3 pos = getWorldPosition(in_Position, in_Wave);
	vTexCoord = in_TextureCoord + uTextureOffset;
	
	gl_Position = getClipPosition(pos);
}
