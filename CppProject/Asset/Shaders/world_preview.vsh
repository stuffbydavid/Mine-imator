#define PREVIEW_TEXTURE_SIZE 64
#define CHUNK_HEIGHT_MIN -64

attribute uint in_Pos;
attribute uint in_Data;

flat varying vec2 vTexCoord;
varying float vLight;

void main()
{
	vec3 pos = vec3(
		float(in_Pos >> 20),
		float(int(in_Pos >> 10) & 1023) + CHUNK_HEIGHT_MIN,
		float(int(in_Pos) & 1023)
	);

	vLight = float(int(in_Data) & 63) / 55.0;
	int texPos = int(in_Data >> 6);
	vTexCoord = vec2(
		(float(texPos % PREVIEW_TEXTURE_SIZE) + 0.5) / PREVIEW_TEXTURE_SIZE,
		(float(texPos / PREVIEW_TEXTURE_SIZE) + 0.5) / PREVIEW_TEXTURE_SIZE
	);
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(pos, 1.0);
}
