#if API_OPENGL
#pragma once

#include "Matrix.hpp"
#include "Vertex.hpp"

#include <QOpenGLWidget>

namespace CppProject
{
	struct AppWindow;
	struct Font;
	struct Shader;
	struct Surface;
	struct VertexBuffer;

	// OpenGL widget in an AppWindow.
	struct GLWidget : QOpenGLWidget
	{
		void initializeGL() override;
		void resizeGL(int width, int height) override;
		void paintGL() override;

		Surface* swapchain[2] = { nullptr, nullptr };
		IntType swapchainIndex = 0;
		BoolType widgetRender = false;
		GLuint glVboId = 0;
	};
}
#endif