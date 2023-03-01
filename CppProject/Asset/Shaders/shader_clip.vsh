/// shader_clip

attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec4 vColor;
varying vec2 vTexCoord;
varying vec2 vPosition;

uniform vec2 uScreenSize;

void main()
{
	vColor = in_Colour;
	vTexCoord = in_TextureCoord;
	vPosition = in_Position.xy * uScreenSize;
	
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.0);
}
