attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec4 in_Wave;

uniform vec4 uBlendColor;
uniform vec2 uTextureOffset;

uniform float uTime;
uniform float uWindEnable;
uniform float uWindTerrain;
uniform float uWindSpeed;
uniform float uWindStrength;
uniform vec2 uWindDirection;
uniform float uWindDirectionalSpeed;
uniform float uWindDirectionalStrength;
uniform mat4 uTAAMatrix;

varying vec3 vPosition;
varying vec2 vTexCoord;
varying float vClipDepth;
varying vec3 vNormal;
varying vec4 vColor;

#define PI 3.14159265
float getNoise(float v)
{
	return cos(v * PI) * cos(v * 3.0 * PI) * cos(v * 5.0 * PI) * cos(v * 7.0 * PI) + sin(v * 5.0 * PI) * 0.1;
}

vec3 getWind()
{
	return vec3(
		sin((uTime + in_Position.x * 10.0 + in_Position.y + in_Position.z) * (uWindSpeed / 5.0)) * max(in_Wave.x * uWindTerrain, uWindEnable) * uWindStrength,
		sin((uTime + in_Position.x + in_Position.y * 10.0 + in_Position.z) * (uWindSpeed / 7.5)) * max(in_Wave.x * uWindTerrain, uWindEnable) * uWindStrength,
		sin((uTime + in_Position.x + in_Position.y + in_Position.z * 10.0) * (uWindSpeed / 10.0)) * max(in_Wave.y * uWindTerrain, uWindEnable) * uWindStrength
	);
}

vec3 getWindAngle(vec3 pos)
{
	float strength = dot(pos.xy / 16.0, uWindDirection) / dot(uWindDirection, uWindDirection);
	float diroff = getNoise((uWindDirectionalSpeed - (strength / 3.0) - (pos.z / 64.0)) * .075);
	return vec3(uWindDirection * diroff, 0.0) * (1.0 - step(max(in_Wave.x * uWindTerrain, uWindEnable), 0.0)) * uWindDirectionalStrength;
}

mat3 transpose2(mat3 mat)
{
	mat3 trans;
	trans[0][0] = mat[0][0]; trans[1][0] = mat[0][1]; trans[2][0] = mat[0][2];
	trans[0][1] = mat[1][0]; trans[1][1] = mat[1][1]; trans[2][1] = mat[1][2];
	trans[0][2] = mat[2][0]; trans[1][2] = mat[2][1]; trans[2][2] = mat[2][2];
	return trans;
}

mat3 inverse2(mat4 original)
{
	float det = original[0][0] * original[1][1] * original[2][2] + original[0][1] * original[1][2] * original[2][0] + original[0][2] * original[1][0] * original[2][1]
		- original[0][0] * original[1][2] * original[2][1] - original[0][1] * original[1][0] * original[2][2] - original[0][2] * original[1][1] * original[2][0];
	float invdet = 1.0 / det;
	mat3 tmp;
	tmp[0][0] = original[1][1] * original[2][2] - original[2][1] * original[1][2];
	tmp[1][0] = original[2][0] * original[1][2] - original[1][0] * original[2][2];
	tmp[2][0] = original[1][0] * original[2][1] - original[2][0] * original[1][1];
	tmp[0][1] = original[2][1] * original[0][2] - original[0][1] * original[2][2];
	tmp[1][1] = original[0][0] * original[2][2] - original[2][0] * original[0][2];
	tmp[2][1] = original[2][0] * original[0][1] - original[0][0] * original[2][1];
	tmp[0][2] = original[0][1] * original[1][2] - original[1][1] * original[0][2];
	tmp[1][2] = original[1][0] * original[0][2] - original[0][0] * original[1][2];
	tmp[2][2] = original[0][0] * original[1][1] - original[1][0] * original[0][1];
	mat3 result;
	result[0][0] = invdet * tmp[0][0]; result[1][0] = invdet * tmp[1][0]; result[2][0] = invdet * tmp[2][0];
	result[0][1] = invdet * tmp[0][1]; result[1][1] = invdet * tmp[1][1]; result[2][1] = invdet * tmp[2][1];
	result[0][2] = invdet * tmp[0][2]; result[1][2] = invdet * tmp[1][2]; result[2][2] = invdet * tmp[2][2];
	return transpose2(result);
}

void main()
{
	vTexCoord = in_TextureCoord + uTextureOffset;
	if (max((in_Wave.x + in_Wave.y) * uWindTerrain, uWindEnable) * uWindStrength > 0.0)
	{
		vPosition = (gm_Matrices[MATRIX_WORLD] * vec4(in_Position + getWind(), 1.0)).xyz;
		vPosition += getWindAngle(in_Position);
	}
	else
		vPosition = (gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1.0)).xyz;
	
	gl_Position = uTAAMatrix * gm_Matrices[MATRIX_PROJECTION] * (gm_Matrices[MATRIX_VIEW] * vec4(vPosition, 1.0));
	vClipDepth = gl_Position.z;
	vNormal = normalize(inverse2(gm_Matrices[MATRIX_WORLD]) * in_Normal);
	vColor = uBlendColor * in_Colour;
}
