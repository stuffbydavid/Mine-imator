#pragma shady: skip_compilation
void main() {}

#region VSH_FULLSCREEN_TEMPLATE
#pragma shady: macro_begin VSH_FULLSCREEN_TEMPLATE

attribute vec3 in_Position;
attribute vec2 in_TextureCoord;

varying vec2 vTexCoord;

void main()
{
	vTexCoord = in_TextureCoord;
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.0);
}

#pragma shady: macro_end
#endregion

#region VSH_COLOR_FULLSCREEN_TEMPLATE
#pragma shady: macro_begin VSH_COLOR_FULLSCREEN_TEMPLATE

attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 vTexCoord;
varying vec4 vColor;

void main()
{
	vColor = in_Colour;
	vTexCoord = in_TextureCoord;
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.0);
}

#pragma shady: macro_end
#endregion
