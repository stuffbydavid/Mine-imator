#include "Generated/GmlFunc.hpp"

namespace CppProject
{
	void camera_apply(IntType id)
	{
		// Do nothing
	}

	IntType camera_create()
	{
		// Do nothing
		return 0;
	}

	void camera_set_proj_mat(IntType id, MatrixType mat)
	{
		matrix_set(matrix_projection, mat);
	}

	void camera_set_view_mat(IntType id, MatrixType mat)
	{
		matrix_set(matrix_view, mat);
	}

	void camera_set_view_pos(IntType id, RealType x, RealType y)
	{
		// Do nothing
	}

	void camera_set_view_size(IntType id, RealType width, RealType height)
	{
		// Do nothing
	}

	void view_set_camera(IntType, IntType)
	{
		// Do nothing
	}

	RealType view_set_hport(IntType, IntType)
	{
		// Do nothing
		return 0;
	}

	RealType view_set_wport(IntType, IntType)
	{
		// Do nothing
		return 0;
	}
}