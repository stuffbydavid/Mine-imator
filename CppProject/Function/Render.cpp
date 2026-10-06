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

	BoolType render_mask_blend_supported()
	{
		return !IS_OPENGL || Shader::gl43Supported;
	}

	BoolType render_mask_blend(BoolType enabled, IntType mask, IntType fog)
	{
		if (!render_mask_blend_supported())
			return false;

		GFX->SubmitBatch();

		if (enabled)
		{
			Surface* surf = FindSurface(mask);
			Surface* fogSurf = (fog != noone ? FindSurface(fog) : nullptr);
			if (!surf || (fog != noone && !fogSurf))
				return false;

			surf->ClearColorCache();
			GFX->SetMRTIndex(1, surf->frameBuffer, QColor(0, 0, 0, 255));

			if (fogSurf)
			{
				fogSurf->ClearColorCache();
				GFX->SetMRTIndex(2, fogSurf->frameBuffer, QColor(0, 0, 0, 255));
			}
		}
		else
		{
			GFX->ResetMRT();
			GFX->surface->frameBuffer->BeginUse();
		}

		GFX->SetMaskBlending(enabled, enabled && fog != noone);

		return true;
	}

	void render_sun_blend(IntType index)
	{
		if (render_mask_blend_supported())
			GFX->SetSunBlending(index);
	}
}
