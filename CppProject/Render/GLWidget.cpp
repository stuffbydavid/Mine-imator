#if API_OPENGL
#include "GLWidget.hpp"

#include "AppHandler.hpp"
#include "Asset/Shader.hpp"
#include "Asset/Surface.hpp"
#include "Generated/Scripts.hpp"
#include "GraphicsApiHandler.hpp"
#include "PrimitiveRenderer.hpp"
#include "TexturePage.hpp"
#include "VertexBufferRenderer.hpp"

#include <QDesktopWidget>

namespace CppProject
{
	void GLWidget::initializeGL()
	{
		GFX->Init();

		// Create VAO to enable OpenGL Core
		GFX->glGenVertexArrays(1, &glVboId);
		GL_CHECK_ERROR();

		// Create swapchain
		swapchain[0] = new Surface;
		swapchain[1] = new Surface;

		QWidget::setAttribute(Qt::WA_TransparentForMouseEvents);
	}

	void GLWidget::resizeGL(int width, int height)
	{
		QWidget::update();
	}

	void GLWidget::paintGL()
	{
		if (!widgetRender)
			return;
		
		RealType scale = QApplication::desktop()->devicePixelRatio();
		GFX->glViewport(0, 0, width() * scale, height() * scale);
		GL_CHECK_ERROR();

		GFX->surface = swapchain[1 - swapchainIndex];
 
		if (!App->blocked)
		{
			GFX->shader = PR->GetShader();
			GFX->shader->BeginUse();
		}

		GFX->SetCulling(false);
		GFX->glDisable(GL_BLEND);
		
		// Render swapchain surface
		draw_clear_alpha(0, 0.0);
		gpu_set_texfilter(false);
		draw_surface_ext(GFX->surface->id, 0, 0, App->scale, App->scale, 0.0, -1, 1.0);
		GFX->SubmitBatch();
		
		GFX->SetCulling(true);
		GFX->glEnable(GL_BLEND);

		if (!App->blocked)
			GFX->shader->EndUse();
	}
}
#endif