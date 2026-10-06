#include "Generated/Scripts.hpp"

#include "AppHandler.hpp"
#include "Asset/Shader.hpp"
#include "Asset/Surface.hpp"
#include "Render/GraphicsApiHandler.hpp"

namespace CppProject
{
	void render_update_frustum()
	{
		GFX->UpdateFrustum();
	}

	BoolType render_mask_blend(BoolType enabled, IntType mask)
	{
		if (IS_OPENGL && !Shader::gl43Supported)
			return false;

		GFX->SubmitBatch();
		if (enabled)
		{
			Surface* surf = FindSurface(mask);
			if (!surf)
				return false;

			surf->ClearColorCache();
			GFX->SetMRTIndex(1, surf->frameBuffer, QColor(0, 0, 0, 255));
		}
		else
		{
			GFX->ResetMRT();
			GFX->surface->frameBuffer->BeginUse();
		}

		GFX->SetMaskBlending(enabled);
		return true;
	}
}
