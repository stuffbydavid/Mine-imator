#include "Generated/Scripts.hpp"

#include "Asset/Shader.hpp"
#include "Render/GraphicsApiHandler.hpp"

namespace CppProject
{
	void shader_submit_int(IntType index, IntType value)
	{
		GFX->shader->SubmitInt(index, value);
	}

	void shader_submit_float(IntType index, RealType value)
	{
		GFX->shader->SubmitFloat(index, value);
	}

	void shader_submit_vec2(IntType index, RealType x, RealType y)
	{
		GFX->shader->SubmitVec2(index, x, y);
	}

	void shader_submit_vec3(IntType index, RealType x, RealType y, RealType z)
	{
		GFX->shader->SubmitVec3(index, x, y, z);
	}

	void shader_submit_vec4(IntType index, RealType x, RealType y, RealType z, RealType w)
	{
		GFX->shader->SubmitVec4(index, x, y, z, w);
	}

	void shader_submit_float_array(IntType index, VarType array)
	{
		GFX->shader->SubmitFloatArray(index, array);
	}

	void shader_submit_mat4_array(IntType index, ArrType array)
	{
		GFX->shader->SubmitMat4Array(index, array);
	}
}
