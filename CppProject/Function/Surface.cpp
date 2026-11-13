#include "Generated/Scripts.hpp"

#include "Asset/Surface.hpp"
#include "Render/GraphicsApiHandler.hpp"

namespace CppProject
{
	IntType surface_create_ext2(IntType width, IntType height, IntType format, BoolType depthBuffer, BoolType depthOnly)
	{
		return (new Surface({ (int)width, (int)height }, format, depthBuffer, depthOnly))->id;
	}

	BoolType surface_get_depth_enabled(IntType id)
	{
		if (Surface* surf = FindSurface(id))
			return surf->frameBuffer->depthBuffer;
		
		return false;
	}

	IntType surface_get_max_size()
	{
		return GFX->GetMaxSize();
	}
}
