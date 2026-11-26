#include "Generated/Scripts.hpp"

#include "Render/GraphicsApiHandler.hpp"

namespace CppProject
{
	BoolType clip_is_active()
	{
		return GFX->clipEnabled;
	}

	void clip_begin(IntType x, IntType y, IntType width, IntType height)
	{
		if (width == 0 && height == 0) // Re-use previous rect
			GFX->ClipBegin(GFX->clipRect);
		else
			GFX->ClipBegin({ (int)x, (int)y, (int)width, (int)height });
	}

	void clip_end()
	{
		GFX->ClipEnd();
	}
}
