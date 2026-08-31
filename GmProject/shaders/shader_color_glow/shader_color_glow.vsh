/// shader_color_glow
/// @desc Renders scene with glowing object colors

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec4 in_Wave;
attribute vec3 in_Tangent;

varying vec3 vPosition;
varying float vDepth;
varying vec4 vColor;
varying vec2 vTexCoord;
varying float vEmissive;

uniform vec4 uBlendColor;
uniform float uDefaultEmissive;

// Texture
uniform vec2 uTextureOffset;

#pragma shady: inline(common_position.WORLD_POSITION_LIB)
#pragma shady: inline(common_position.CLIP_POSITION_LIB)

void main()
{
	vPosition = getWorldPosition(in_Position, in_Wave);
	vDepth = (gm_Matrices[MATRIX_VIEW] * vec4(vPosition, 1.0)).z;
	vColor = in_Colour * uBlendColor;
	vTexCoord = in_TextureCoord + uTextureOffset;
	vEmissive = clamp(in_Wave.z * uDefaultEmissive, 0.0, 1.0);
	
	gl_Position = getClipPosition(vPosition);
}
