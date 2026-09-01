/// shader_high_subsurface

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec4 in_Wave;
attribute vec3 in_Tangent;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec4 vColor;
varying vec2 vTexCoord;
varying vec4 vCustom;

uniform vec4 uBlendColor;

// Texture
uniform vec2 uTextureOffset;

#pragma shady: inline(common_position.WORLD_POSITION_LIB)
#pragma shady: inline(common_position.CLIP_POSITION_LIB)

void main()
{
	vPosition = getWorldPosition(in_Position, in_Wave);
	vNormal = (gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0)).xyz;
	vColor = in_Colour * uBlendColor;
	vTexCoord = in_TextureCoord + uTextureOffset;
	vCustom = in_Wave;
	
	gl_Position = getClipPosition(vPosition);
}
