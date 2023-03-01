#pragma once

#include "Common.hpp"
#include "Render/GraphicsApiHandler.hpp"

#include <QMainWindow>
#include <QLineEdit>
#include <QMouseEvent>
#include <QOpenGLWidget>

namespace CppProject
{
	struct GLWidget;
	struct FrameBuffer;

	// An application window
	struct AppWindow : QMainWindow
	{
		AppWindow(IntType id);
		~AppWindow();

		// Show window
		void ShowNormal();
		void Maximize();
		void UpdateSize();

		// Returns the current window surface to render to.
		Surface* GetSurface() const;

		// Present the rendered surface on the window.
		void Present();

		// Window events
		bool event(QEvent* event) override;
		void resizeEvent(QResizeEvent* event) override;
		void closeEvent(QCloseEvent* event) override;
		void dragEnterEvent(QDragEnterEvent* event) override;
		void dragMoveEvent(QDragMoveEvent* event) override;
		void dropEvent(QDropEvent* event) override;

		// Mouse events
		void mousePressEvent(QMouseEvent* event) override;
		void mouseReleaseEvent(QMouseEvent* event) override;
		void mouseMoveEvent(QMouseEvent* event) override;
		void wheelEvent(QWheelEvent* event) override;

		bool closing = false;
		IntType id = 0;
		QSize newSize = { 0, 0 };
	#if API_D3D11
		Surface* surface = nullptr;
		ID3D11RenderTargetView* d3dRTV = nullptr;
		IDXGISwapChain* d3dSwapchain = nullptr;
		QWidget* d3dWidget = nullptr;
	#else
		GLWidget* glWidget = nullptr;
	#endif

		QHash<IntType, BoolType> mouseDown;
		int mouseWheel = 0;
		QPoint mousePos, mouseLastPos, mouseLockPos, mouseLockWinPos;
		BoolType mouseLocked = false, mouseUnlock = true;

		static BoolType mouseEnableLock;
	};

	// Keyboard checker as a hidden QLineEdit widget
	struct KeyChecker : QLineEdit
	{
		KeyChecker(QWidget* parent);
		void focusOutEvent(QFocusEvent* e) override { QWidget::setFocus(); }
		void keyPressEvent(QKeyEvent* event) override;
		void keyReleaseEvent(QKeyEvent* event) override;
		void mouseDoubleClickEvent(QMouseEvent* event) override { event->ignore(); }
		void mouseMoveEvent(QMouseEvent* event) override { event->ignore(); }
		void mousePressEvent(QMouseEvent* event) override { event->ignore(); }
		void mouseReleaseEvent(QMouseEvent* event) override { event->ignore(); }
		void paintEvent(QPaintEvent* event) override { event->ignore(); }

		BoolType setPos = false;
		QString lastText = "";
	};
}