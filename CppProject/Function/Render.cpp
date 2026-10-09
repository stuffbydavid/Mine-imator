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

	BoolType render_point_viewports(BoolType enabled, IntType size, VecType eye, RealType range)
	{
		Shader* shader = FindShader(ID_shader_depth_point);
		if (enabled && (!shader || !shader->IsLoaded() || shader->pointMultiviewUniform < 0 || (IS_OPENGL && shader->glPointProjection < 0)))
			return false;

	#if OS_WINDOWS
		if (enabled && IS_D3D11 && !shader->d3dPointShader)
			return false;
	#endif

		GFX->SubmitBatch();
		
		GFX->pointMultiview = enabled;
		
		if (!enabled)
		{
			render_set_viewport(0, 0, GFX->surface->size.width(), GFX->surface->size.height());
			return true;
		}

		// Multi-view setup
		const Matrix& projection = GFX->matrixP;
		Matrix vertical = Matrix::LookAt(eye, eye + VecType(0, -0.0001, 1), { 0, 0, 1 });
		RealType extent = range * 1.0001;

		GFX->pointBounds = Bounds(eye - VecType(extent, extent, extent), eye + VecType(extent, extent, extent));

		// Keep the existing projection and vertical-face normalization
		float* parameters = GFX->pointParameters;
		parameters[0] = eye.x;
		parameters[1] = eye.y;
		parameters[2] = eye.z;
		parameters[3] = vertical.m[10];
		parameters[4] = projection.m[0];
		parameters[5] = projection.m[5];
		parameters[6] = projection.m[10];
		parameters[7] = projection.m[14];
		parameters[8] = vertical.m[0];
		parameters[9] = vertical.m[5];
		parameters[10] = vertical.m[9];
		parameters[11] = vertical.m[6];
	
	#if OS_WINDOWS
		if (IS_D3D11)
		{
			D3D11_VIEWPORT viewports[6];
			for (IntType face = 0; face < 6; face++)
				viewports[face] = { (float)((face % 3) * size), (float)((face / 3) * size), (float)size, (float)size, 0.0f, 1.0f };
			
			D3DContext->RSSetViewports(6, viewports);
		}
	#endif
		if (IS_OPENGL)
		{
			GLfloat viewports[6 * 4];
			for (IntType face = 0; face < 6; face++)
			{
				viewports[face * 4] = (face % 3) * size;
				viewports[face * 4 + 1] = GFX->surface->size.height() - (face / 3 + 1) * size;
				viewports[face * 4 + 2] = viewports[face * 4 + 3] = size;
			}

			Shader::gl43Core->glViewportArrayv(0, 6, viewports);
			GL_CHECK_ERROR();
		}

		return true;
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
