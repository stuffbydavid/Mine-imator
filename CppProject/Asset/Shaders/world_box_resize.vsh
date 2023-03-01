attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec4 in_Wave;

uniform vec3 uBoxSize;
uniform vec3 uEye;

varying vec4 vColor;

void main() 
{
	if (in_Normal.x < -0.1) vColor = vec4(0.5, 0.0, 0.0, 1.0);
	if (in_Normal.x > 0.1) vColor = vec4(1.0, 0.0, 0.0, 1.0);
	if (in_Normal.y < -0.1) vColor = vec4(0.0, 0.5, 0.0, 1.0);
	if (in_Normal.y > 0.1) vColor = vec4(0.0, 1.0, 0.0, 1.0);
	if (in_Normal.z < -0.1) vColor = vec4(0.0, 0.0, 0.5, 1.0);
	if (in_Normal.z > 0.1) vColor = vec4(0.0, 0.0, 1.0, 1.0);

	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.0);
}