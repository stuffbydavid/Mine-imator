/// shader_color_camera

attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

uniform vec4 uBlendColor;

varying vec4 vColor;
varying vec2 vTexCoord;

void main()
{
	vColor = uBlendColor * in_Colour;
	vTexCoord = in_TextureCoord;
	
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.0);
}
