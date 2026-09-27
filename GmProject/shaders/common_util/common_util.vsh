#pragma shady: skip_compilation
void main() {}

#region MATRIX_LIB
#pragma shady: macro_begin MATRIX_LIB

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

#pragma shady: macro_end
#endregion
