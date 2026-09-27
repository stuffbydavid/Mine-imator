#include "Generated/Scripts.hpp"

#include "Asset/Surface.hpp"
#include "Render/GraphicsApiHandler.hpp"

namespace CppProject
{
	IntType surface_create_ext2(IntType width, IntType height, IntType format, BoolType depthBuffer)
	{
		return (new Surface({ (int)width, (int)height }, format, depthBuffer))->id;
	}

	void surface_clear_depth_cache(IntType id)
	{
		if (Surface* surf = FindSurface(id))
			surf->ClearDepthCache();
	}

	RealType surface_get_depth(IntType id, IntType x, IntType y)
	{
		if (Surface* surf = FindSurface(id))
			return surf->GetDepth(QPoint(x, y));
		return 0.0;
	}

	IntType surface_get_max_size()
	{
		return GFX->GetMaxSize();
	}
}
