#include "Generated/Scripts.hpp"

#include "AppHandler.hpp"
#include "Asset/VertexBuffer.hpp"
#include "Render/GraphicsApiHandler.hpp"
#include "Render/PrimitiveRenderer.hpp"
#include "Render/VertexBufferRenderer.hpp"

namespace CppProject
{
	void vertex_add(VecType pos, VecType normal, VecType texcoord)
	{
		IntType buffer = global::vbuffer_current;
		vertex_position_3d(buffer, pos.x, pos.y, pos.z);
		vertex_normal(buffer, normal.x, normal.y, normal.z);
		vertex_texcoord(buffer, texcoord.x, texcoord.y);

		vertex_add_wave(pos.z);
	}

	void vbuffer_add_triangle(VecType pos1, VecType pos2, VecType pos3,
		VecType tex1, VecType tex2, VecType tex3, VarType normal1, VarType normal2, VarType normal3,
		BoolType invert, VarType matrix)
	{
		VecType n1, n2, n3;
		if (!normal1.IsContainer())
		{
			n1 = vec3_cross(point3D_sub(pos1, pos2), point3D_sub(pos2, pos3));
			n2 = n1;
			n3 = n1;
		}
		else
		{
			n1 = normal1.ToVec();
			if (matrix != null_ && normal2 == null_)
				n2 = n1;
			else
				n2 = normal2.ToVec();

			if (matrix != null_ && normal3 == null_)
				n3 = n1;
			else
				n3 = normal3.ToVec();
		}

		if (matrix != null_)
		{
			MatrixType mat = matrix.ToMat();
			pos1 = point3D_mul_matrix(pos1, mat);
			pos2 = point3D_mul_matrix(pos2, mat);
			pos3 = point3D_mul_matrix(pos3, mat);
			n1 = vec3_normalize(vec3_mul_matrix(n1, mat));
			n2 = vec3_normalize(vec3_mul_matrix(n2, mat));
			n3 = vec3_normalize(vec3_mul_matrix(n3, mat));
		}

		if (invert)
		{
			std::swap(pos1, pos2);
			std::swap(tex1, tex2);
			n1 = -n1;
			n2 = -n2;
			n3 = -n3;
		}

		vertex_add(pos1, vec3_normalize(n1), tex1);
		vertex_add(pos2, vec3_normalize(n2), tex2);
		vertex_add(pos3, vec3_normalize(n3), tex3);
	}

	IntType get_vbuffer_triangles()
	{
		IntType num = VB->trianglesSubmitted;
		VB->trianglesSubmitted = 0;
		return num;
	}

	IntType get_vbuffer_render_calls()
	{
		IntType num = VB->renderCalls;
		VB->renderCalls = 0;
		return num;
	}

	IntType get_primitive_lines()
	{
		IntType num = PR->linesSubmitted;
		PR->linesSubmitted = 0;
		return num;
	}

	IntType get_primitive_triangles()
	{
		IntType num = PR->trianglesSubmitted;
		PR->trianglesSubmitted = 0;
		return num;
	}

	IntType get_primitive_render_calls()
	{
		IntType num = PR->renderCalls;
		PR->renderCalls = 0;
		return num;
	}

	void vbuffer_set_batching(IntType id, BoolType batching)
	{
		if (VertexBuffer* buf = FindVertexBuffer(id))
			buf->batching = batching;
	}

	IntType vbuffer_copy(IntType id)
	{
		if (VertexBuffer* buffer = FindVertexBuffer(id))
			if (VertexBuffer* copy = buffer->Copy())
				return copy->id;

		return null_;
	}

	void vbuffer_update(IntType id)
	{
		if (VertexBuffer* buffer = FindVertexBuffer(id))
			buffer->UpdateBuffers();
	}

	void submit_batch()
	{
		GFX->SubmitBatch();
	}
}
