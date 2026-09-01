/// shader_depth
/// @desc Renders to a depth buffer

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec4 in_Wave;
attribute vec3 in_Tangent;

uniform float uNear; // static
uniform float uFar; // static

varying vec3 vPosition;
varying vec2 vTexCoord;
varying float vDepth;
varying vec4 vColor;
uniform vec4 uBlendColor;

// Texture
uniform vec2 uTextureOffset;

#pragma shady: inline(common_position.WORLD_POSITION_LIB)
#pragma shady: inline(common_position.CLIP_POSITION_LIB)

void main()
{
	vPosition = getWorldPosition(in_Position, in_Wave);
	vTexCoord = in_TextureCoord + uTextureOffset;
	
	gl_Position = getClipPosition(vPosition);
	vDepth = (gl_Position.z - uNear) / (uFar - uNear);
	
	vColor = uBlendColor * in_Colour;
}
