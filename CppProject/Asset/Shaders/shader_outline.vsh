/// shader_outline
/// @desc Creates an outline around opaque pixels

attribute vec3 in_Position;
attribute vec2 in_TextureCoord;

varying vec2 vTexCoord;

void main()
{
	vTexCoord = in_TextureCoord;
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.0);
}
