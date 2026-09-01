attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec4 in_Wave;
attribute vec3 in_Tangent;

uniform float uFar; // static
uniform float uNear; // static

uniform vec4 uBlendColor;

varying vec3 vPosition;
varying vec2 vTexCoord;
varying float vDepth;
varying vec3 vNormal;
varying vec3 vTangent;
varying vec4 vColor;
varying vec4 vCustom;

// Texture
uniform vec2 uTextureOffset;

#pragma shady: inline(common_position.WORLD_POSITION_LIB)
#pragma shady: inline(common_position.CLIP_POSITION_LIB)

mat3 transpose2(mat3 mat)
{
	mat3 trans;
	
	trans[0][0] = mat[0][0];
	trans[1][0] = mat[0][1];
	trans[2][0] = mat[0][2];
	trans[0][1] = mat[1][0];
	trans[1][1] = mat[1][1];
	trans[2][1] = mat[1][2];
	trans[0][2] = mat[2][0];
	trans[1][2] = mat[2][1];
	trans[2][2] = mat[2][2];
	
	return trans;
}

mat3 inverse2(mat4 Original)
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
	
	return transpose2(Result);
}

void main()
{
	vPosition = getWorldPosition(in_Position, in_Wave);
	vTexCoord = in_TextureCoord + uTextureOffset;
	
	gl_Position = getClipPosition(vPosition);
	
	// Depth
	vec4 depthPos = (gm_Matrices[MATRIX_VIEW] * vec4(vPosition, 1.0));
	vDepth = ((depthPos.z - uNear) / (uFar - uNear));
	
	// Create vectors for TBN matrix
	mat3 worldViewInv = inverse2(gm_Matrices[MATRIX_WORLD_VIEW]);
	vNormal = normalize(worldViewInv * in_Normal);
	vTangent = normalize(worldViewInv * in_Tangent);
	
	// Color
	vColor = uBlendColor * in_Colour;
	
	// Custom
	vCustom = in_Wave;
}
