attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

uniform int uDim;

varying vec2 vTexCoord;
varying vec4 vColor1;
varying vec4 vColor2;

void main()
{
	if (uDim == 0) // Overworld
	{
		vColor1 = vec4(0.7, 0.7, 1.0, 1.0);
		vColor2 = vec4(0.725, 0.725, 1.0, 1.0);
	}
	else if (uDim == 1) // Nether
	{
		vColor1 = vec4(0.5, 0.2, 0.1, 1.0);
		vColor2 = vec4(0.525, 0.225, 0.1, 1.0);
	}
	else if (uDim == -1) // End
	{
		vColor1 = vec4(0.2, 0.1, 0.2, 1.0);
		vColor2 = vec4(0.225, 0.1, 0.225, 1.0);
	}

	vTexCoord = in_TextureCoord;
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.0);
}