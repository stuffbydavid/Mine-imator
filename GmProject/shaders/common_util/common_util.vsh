#pragma shady: skip_compilation
void main() {}

#region MATRIX_LIB
#pragma shady: macro_begin MATRIX_LIB

mat3 transpose2(mat3 mat)
{
	mat3 trmat;

	trmat[0][0] = mat[0][0];
	trmat[1][0] = mat[0][1];
	trmat[2][0] = mat[0][2];
	trmat[0][1] = mat[1][0];
	trmat[1][1] = mat[1][1];
	trmat[2][1] = mat[1][2];
	trmat[0][2] = mat[2][0];
	trmat[1][2] = mat[2][1];
	trmat[2][2] = mat[2][2];

	return trmat;
}

mat3 inverse2(mat4 mat)
{
	float det = mat[0][0] * mat[1][1] * mat[2][2]
			  + mat[0][1] * mat[1][2] * mat[2][0]
			  + mat[0][2] * mat[1][0] * mat[2][1]
			  - mat[0][0] * mat[1][2] * mat[2][1]
			  - mat[0][1] * mat[1][0] * mat[2][2]
			  - mat[0][2] * mat[1][1] * mat[2][0];

	float invdet = 1.0 / det;

	mat3 tmp;
	tmp[0][0] = mat[1][1] * mat[2][2] - mat[2][1] * mat[1][2];
	tmp[1][0] = mat[2][0] * mat[1][2] - mat[1][0] * mat[2][2];
	tmp[2][0] = mat[1][0] * mat[2][1] - mat[2][0] * mat[1][1];
	tmp[0][1] = mat[2][1] * mat[0][2] - mat[0][1] * mat[2][2];
	tmp[1][1] = mat[0][0] * mat[2][2] - mat[2][0] * mat[0][2];
	tmp[2][1] = mat[2][0] * mat[0][1] - mat[0][0] * mat[2][1];
	tmp[0][2] = mat[0][1] * mat[1][2] - mat[1][1] * mat[0][2];
	tmp[1][2] = mat[1][0] * mat[0][2] - mat[0][0] * mat[1][2];
	tmp[2][2] = mat[0][0] * mat[1][1] - mat[1][0] * mat[0][1];

	mat3 invmat;
	invmat[0][0] = invdet * tmp[0][0];
	invmat[1][0] = invdet * tmp[1][0];
	invmat[2][0] = invdet * tmp[2][0];
	invmat[0][1] = invdet * tmp[0][1];
	invmat[1][1] = invdet * tmp[1][1];
	invmat[2][1] = invdet * tmp[2][1];
	invmat[0][2] = invdet * tmp[0][2];
	invmat[1][2] = invdet * tmp[1][2];
	invmat[2][2] = invdet * tmp[2][2];

	return transpose2(invmat);
}

#pragma shady: macro_end
#endregion
