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

	void render_set_viewport(IntType x, IntType y, IntType width, IntType height)
	{
		GFX->SubmitBatch();

	#if OS_WINDOWS
		if (IS_D3D11)
		{
			D3D11_VIEWPORT viewport = { (float)x, (float)y, (float)width, (float)height, 0.0f, 1.0f };
			D3DContext->RSSetViewports(1, &viewport);
		}
	#endif
		if (IS_OPENGL)
		{
			// Convert top-left surface coordinates to OpenGL's bottom-left origin
			GFX->glViewport(x, GFX->surface->size.height() - y - height, width, height);
			GL_CHECK_ERROR();
		}
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

	BoolType render_color_gbuffers(IntType depth, IntType normal, IntType material, IntType shadows, IntType specular)
	{
		if (!render_mask_blend_supported() || !GFX->maskBlend || !GFX->fogBlend)
			return false;
		
		Surface* surfaces[] = {
			FindSurface(depth),
			FindSurface(normal),
			FindSurface(material),
			FindSurface(shadows),
			FindSurface(specular)
		};

		for (Surface* surface : surfaces)
			if (!surface)
				return false;
		
		GFX->SubmitBatch();
		
		for (IntType i = 0; i < 5; i++)
		{
			surfaces[i]->ClearColorCache();
			
			QColor clear = i == 0 ? QColor(255, 255, 255, 255) : QColor(0, 0, 0, i < 3 ? 0 : 255);
			GFX->SetMRTIndex(i + 3, surfaces[i]->frameBuffer, clear);
		}
		
		GFX->SetSunBlending(6);
		
		return true;
	}
}
