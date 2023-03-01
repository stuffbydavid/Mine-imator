/// shader_high_samples_add

attribute vec3 in_Position;
attribute vec2 in_TextureCoord;

varying vec2 vTexCoord;
varying vec3 vPosition;

void main()
{
	vTexCoord = in_TextureCoord;
	vPosition = in_Position;
	
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.0);
}
