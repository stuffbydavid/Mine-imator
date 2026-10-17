#include "Generated/Scripts.hpp"

#include "AppHandler.hpp"
#include "Asset/VertexBuffer.hpp"
#include "Render/GraphicsApiHandler.hpp"
#include "Render/PrimitiveRenderer.hpp"
#include "Render/VertexBufferRenderer.hpp"

namespace CppProject
{
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

	void vbuffer_set_save_data(IntType id, BoolType save)
	{
		if (VertexBuffer* buf = FindVertexBuffer(id))
			buf->saveData = save;
	}

	void submit_batch()
	{
		GFX->SubmitBatch();
	}
}
