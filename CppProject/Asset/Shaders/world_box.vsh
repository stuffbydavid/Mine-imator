attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec4 in_Wave;

varying vec2 vUv;
varying vec2 vUvScale;
varying float vAlpha;

uniform vec3 uBoxSize;
uniform vec3 uEye;
uniform vec3 uResizeDir;

bool vec3_equals(vec3 a, vec3 b)
{
	return (abs(a.x - b.x) < 0.01 && abs(a.y - b.y) < 0.01 && abs(a.z - b.z) < 0.01);
}

void main()
{
	vUv = in_TextureCoord;
	vUvScale = vec2(0.0);

	vec3 normal = abs(in_Normal);
	if (normal.x >= 1) vUvScale = 1.0 / vec2(uBoxSize.y, uBoxSize.z);
	if (normal.y >= 1) vUvScale = 1.0 / vec2(uBoxSize.x, uBoxSize.z);
	if (normal.z >= 1) vUvScale = 1.0 / vec2(uBoxSize.x, uBoxSize.y);

	if (vec3_equals(in_Normal, uResizeDir))
		vAlpha = 0.6;
	else
		vAlpha = 0.4;

	vec3 worldPosition = (gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1.0)).xyz;
	float dis = length(uEye - worldPosition);
	vUvScale *= dis * 0.05;

	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.0);
}