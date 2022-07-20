attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec4 in_Wave;
attribute vec3 in_Tangent;

uniform float uFar;
uniform float uNear;

varying vec3 vPosition;
varying vec2 vTexCoord;
varying float vDepth;
varying vec3 vNormal;
varying vec3 vTangent;
varying vec4 vColor;
varying vec4 vCustom;
varying mat3 vWorldInv;
varying mat3 vWorldViewInv;
varying float vTime;
varying float vWindDirection;

// Wind
uniform float uTime;
uniform float uWindEnable;
uniform float uWindTerrain;
uniform float uWindSpeed;
uniform float uWindStrength;
uniform float uWindDirection;
uniform float uWindDirectionalSpeed;
uniform float uWindDirectionalStrength;

// TAA
uniform mat4 uTAAMatrix;

// GPU Gems 3: Chapter 6
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
	vec2 angle = vec2(cos(uWindDirection), sin(uWindDirection));
	float strength = dot(pos.xy/16.0, angle) / dot(angle, angle);
	float diroff = getNoise((((uTime * uWindDirectionalSpeed) - (strength / 3.0) - (pos.z/64.0)) * .075));
	return vec3(angle * diroff, 0.0) * (1.0 - step(max(in_Wave.x * uWindTerrain, uWindEnable), 0.0)) * uWindDirectionalStrength;
}

mat3 transpose(mat3 mat)
{
	mat3 trans;
	
	for (int i = 0; i < 3; i++)
		for (int j = 0; j < 3; j++)
			trans[j][i] = mat[i][j];
	
	return trans;
}

mat3 inverse(mat4 Original)
{
	float det = Original[0][0] * Original[1][1] * Original[2][2]
			  + Original[0][1] * Original[1][2] * Original[2][0]
			  + Original[0][2] * Original[1][0] * Original[2][1]
			  - Original[0][0] * Original[1][2] * Original[2][1]
			  - Original[0][1] * Original[1][0] * Original[2][2]
			  - Original[0][2] * Original[1][1] * Original[2][0];
						
	float inv_det = 1.0 / det;
	
	mat3 tmp;
	tmp[0][0] = Original[1][1] * Original[2][2] - Original[2][1] * Original[1][2];
	tmp[1][0] = Original[2][0] * Original[1][2] - Original[1][0] * Original[2][2];
	tmp[2][0] = Original[1][0] * Original[2][1] - Original[2][0] * Original[1][1];
	tmp[0][1] = Original[2][1] * Original[0][2] - Original[0][1] * Original[2][2];
	tmp[1][1] = Original[0][0] * Original[2][2] - Original[2][0] * Original[0][2];
	tmp[2][1] = Original[2][0] * Original[0][1] - Original[0][0] * Original[2][1];
	tmp[0][2] = Original[0][1] * Original[1][2] - Original[1][1] * Original[0][2];
	tmp[1][2] = Original[1][0] * Original[0][2] - Original[0][0] * Original[1][2];
	tmp[2][2] = Original[0][0] * Original[1][1] - Original[1][0] * Original[0][1];
	
	mat3 Result;
	Result[0][0] = inv_det * tmp[0][0];
	Result[1][0] = inv_det * tmp[1][0];
	Result[2][0] = inv_det * tmp[2][0];
	Result[0][1] = inv_det * tmp[0][1];
	Result[1][1] = inv_det * tmp[1][1];
	Result[2][1] = inv_det * tmp[2][1];
	Result[0][2] = inv_det * tmp[0][2];
	Result[1][2] = inv_det * tmp[1][2];
	Result[2][2] = inv_det * tmp[2][2];
	
	return transpose(Result);
}

void main()
{
	vTexCoord = in_TextureCoord;
	
	vPosition = (gm_Matrices[MATRIX_WORLD] * vec4(in_Position + getWind(), 1.0)).xyz;
	vPosition += getWindAngle(in_Position);
	
	gl_Position = uTAAMatrix * gm_Matrices[MATRIX_PROJECTION] * (gm_Matrices[MATRIX_VIEW] * vec4(vPosition, 1.0));
	
	// Depth
	vec4 depthPos = (gm_Matrices[MATRIX_VIEW] * vec4(vPosition, 1.0));
	vDepth = ((depthPos.z - uNear) / (uFar - uNear));
	
	// Create vectors for TBN matrix
	vWorldViewInv = inverse(gm_Matrices[MATRIX_WORLD_VIEW]);
	
	vNormal       = normalize((vWorldViewInv * in_Normal));
	vTangent	  = normalize((vWorldViewInv * in_Tangent));
	vTangent	  = normalize(vTangent - dot(vTangent, vNormal) * vNormal);
	
	// Color
	vColor = in_Colour;
	
	// Custom
	vCustom = in_Wave;
	
	vTime = uTime;
	vWindDirection = uWindDirection;
}

