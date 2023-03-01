#include "AppWindow.hpp"
#include "AppHandler.hpp"
#include "Asset/Surface.hpp"
#include "Render/GLWidget.hpp"
#include "Render/GraphicsApiHandler.hpp"
#include "Generated/Scripts.hpp"

#include <QMimeData>
#include <QScreen>
#include <QStyle>
#include <QTimer>

namespace CppProject
{
#if !OS_MAC
	BoolType AppWindow::mouseEnableLock = true;
#else
	BoolType AppWindow::mouseEnableLock = false;
#endif

	AppWindow::AppWindow(IntType id) : id(id)
	{
	#if API_OPENGL
		glWidget = new GLWidget;
		QMainWindow::setCentralWidget(glWidget);
		new KeyChecker(glWidget);
	#else

		// QWidget subclass for ignoring mouse events, WA_TransparentForMouseEvents attribute breaks mouse locking
		struct D3DWidget : public QWidget
		{
			void mousePressEvent(QMouseEvent* event) override { event->ignore(); }
			void mouseReleaseEvent(QMouseEvent* event) override { event->ignore(); }
			void mouseMoveEvent(QMouseEvent* event) override { event->ignore(); }
		};
		d3dWidget = new D3DWidget;
		d3dWidget->setMouseTracking(true);
		QMainWindow::setCentralWidget(d3dWidget);
		new KeyChecker(d3dWidget);

		// Create swapchain
		DXGI_SWAP_CHAIN_DESC swapchainDesc = {};
		swapchainDesc.BufferDesc.Width = 0;
		swapchainDesc.BufferDesc.Height = 0;
		swapchainDesc.BufferDesc.Format = DXGI_FORMAT_B8G8R8A8_UNORM;
		swapchainDesc.BufferDesc.RefreshRate = { 1, 60 };
		swapchainDesc.BufferDesc.Scaling = DXGI_MODE_SCALING_UNSPECIFIED;
		swapchainDesc.BufferDesc.ScanlineOrdering = DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED;
		swapchainDesc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
		swapchainDesc.BufferCount = 2;
		swapchainDesc.SampleDesc.Count = 1;
		swapchainDesc.SampleDesc.Quality = 0;
		swapchainDesc.OutputWindow = (HWND)winId();
		swapchainDesc.Windowed = true;
		swapchainDesc.SwapEffect = DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL;
		swapchainDesc.Flags = 0;
		HRESULT hr = DXGIFactory->CreateSwapChain(D3DDevice, &swapchainDesc, &d3dSwapchain);
		if (FAILED(hr))
		{
			// FLIP_SEQUENTIAL not supported on Windows 7
			swapchainDesc.SwapEffect = DXGI_SWAP_EFFECT_SEQUENTIAL;
			hr = DXGIFactory->CreateSwapChain(D3DDevice, &swapchainDesc, &d3dSwapchain);
		}
		D3DCheckError(hr);

		surface = new Surface;
	#endif

		QWidget::setMouseTracking(true);
		QWidget::setAcceptDrops(true);
		if (!QWidget::acceptDrops())
			WARNING("setAcceptDrops failed");

		QWidget::setAttribute(Qt::WA_KeyCompression, true);
		QWidget::setMinimumSize(100, 50);
	}

	AppWindow::~AppWindow()
	{
	#if API_D3D11
		delete surface;
	#endif
	}

	void AppWindow::ShowNormal()
	{
		QMainWindow::showNormal();
	#if API_OPENGL
		glWidget->widgetRender = true;
	#endif
	}

	void AppWindow::Maximize()
	{
	#if API_OPENGL
		glWidget->hide(); // Mac OS fix
		QMainWindow::showMaximized();
		glWidget->show();
	#else
		QMainWindow::showMaximized();
	#endif
	}

	void AppWindow::UpdateSize()
	{
		if (newSize == QSize(0, 0))
			return;

		newSize.rwidth() *= App->scale;
		newSize.rheight() *= App->scale;
		QMainWindow::setGeometry(QStyle::alignedRect(Qt::LeftToRight, Qt::AlignCenter, newSize, qApp->primaryScreen()->geometry()));
		QTimer::singleShot(100, [&]()
			{
				QMainWindow::showNormal();
				QMainWindow::activateWindow();
			});

	#if API_OPENGL
		glWidget->widgetRender = true;
	#endif
		newSize = { 0, 0 };
	}

	Surface* AppWindow::GetSurface() const
	{
	#if API_D3D11
		return surface;
	#else
		return glWidget->swapchain[glWidget->swapchainIndex];
	#endif
	}

	void AppWindow::Present()
	{
	#if API_D3D11
		D3DContext->OMSetRenderTargets(1, &d3dRTV, nullptr);
		D3D11_VIEWPORT viewport = { 0, 0, (float)width(), (float)height(), 0.0, 1.0 };
		D3DContext->RSSetViewports(1, &viewport);

		// Disable blending
		float blendFactor[4] = { 0.0f, 0.0f, 0.0f, 0.0f };
		ID3D11BlendState* prevState = nullptr;
		D3DContext->OMGetBlendState(&prevState, nullptr, nullptr);
		D3DContext->OMSetBlendState(GFX->d3dNoBlendState, blendFactor, 0xFFFFFFFF);

		// Draw rendered surface
		GFX->surface = surface;
		GFX->SetCulling(false);
		gpu_set_texfilter(false);
		draw_surface_ext(surface->id, 0, 0, App->scale, App->scale, 0.0, -1, 1.0);
		GFX->SubmitBatch();
		GFX->SetCulling(true);

		d3dSwapchain->Present(0, 0);

		// Restore blending
		D3DContext->OMSetBlendState(prevState, blendFactor, 0xFFFFFFFF);
	#else
		// Redo frame if blocked, otherwise flip swapchain index and schedule draw
		if (!App->blocked)
			glWidget->swapchainIndex = 1 - glWidget->swapchainIndex;
		glWidget->update();
	#endif
	}

	bool AppWindow::event(QEvent* event)
	{
		if (event->type() == QEvent::WindowDeactivate && !closing)
		{
			// Clear keys
			for (IntType key : App->keyStateMap.keys())
				App->keyStateMap[key] = {};
			for (IntType key : App->keyWinStateMap.keys())
				App->keyWinStateMap[key] = {};
		}

		return QMainWindow::event(event);
	}

	void AppWindow::resizeEvent(QResizeEvent* event)
	{
	#if API_D3D11
		surface->Resize(size());
		releaseAndReset(d3dRTV);

		D3DCheckError(d3dSwapchain->ResizeBuffers(2, width(), height(), DXGI_FORMAT_B8G8R8A8_UNORM, 0));

		// Create RTV from window swapchain backbuffer
		ID3D11Texture2D* backBufferTex = nullptr;
		d3dSwapchain->GetBuffer(0, __uuidof(ID3D11Texture2D), (LPVOID*)&backBufferTex);
		if (!backBufferTex)
			FATAL("Could not get back buffer texture");
		else
			D3DCheckError(D3DDevice->CreateRenderTargetView(backBufferTex, NULL, &d3dRTV));
		backBufferTex->Release();
	#endif
	}

	void AppWindow::closeEvent(QCloseEvent* event)
	{
		// Confirm close
		if (App->mainWindow == this)
		{
			if (global::_app)
			{
				if (!app_event_game_end(ScopeAny(global::_app->id)))
				{
					event->ignore();
					return;
				}
			}

			for (AppWindow* appWindow : App->windows)
			{
				appWindow->id = 0;
				appWindow->close();
			}
			delete App;
		}
		else
		{
			if (id)
				window_event_closed(id);

			if (App->mouseWindow == this)
				App->mouseWindow = App->mainWindow;
			App->windows.removeOne(this);
		}

		closing = true;
		event->accept();
	}

	ArrType MimeDataToFiles(const QMimeData* mimeData)
	{
		ArrType files;
		if (mimeData->hasUrls())
			for (QUrl url : mimeData->urls())
				files.Append(StringType(url.toLocalFile()));

		return files;
	}

	void AppWindow::dragEnterEvent(QDragEnterEvent* event)
	{
		ArrType files = MimeDataToFiles(event->mimeData());
		if (files.Size() && window_drop_enter(ScopeAny(global::_app->id), files))
			event->accept();
		else
			event->ignore();
	}

	void AppWindow::dragMoveEvent(QDragMoveEvent* event)
	{
		ArrType files = MimeDataToFiles(event->mimeData());
		if (files.Size() && window_drop_enter(ScopeAny(global::_app->id), files))
			event->accept();
		else
			event->ignore();
	}

	void AppWindow::dropEvent(QDropEvent* event)
	{
		GFX->StartOffScreenRender();
		window_drop(ScopeAny(global::_app->id), MimeDataToFiles(event->mimeData()));
	}

	KeyChecker::KeyChecker(QWidget* parent) : QLineEdit(parent)
	{
		QWidget::setAcceptDrops(false);
		QWidget::setContextMenuPolicy(Qt::NoContextMenu);
		QWidget::unsetCursor();
		QWidget::setAttribute(Qt::WA_MacShowFocusRect, 0);
		QLineEdit::setEchoMode(QLineEdit::NoEcho);
		QWidget::connect(this, &QLineEdit::cursorPositionChanged, [&](int oldPos, int newPos)
			{
				// Disable left/right/home/end, keep cursor at string end
				if (!setPos)
				{
					setPos = true;
					QLineEdit::setCursorPosition(text().length());
					setPos = false;
				}
			});
		QWidget::connect(this, &QLineEdit::textChanged, [&]()
			{
				// Add
				if (QLineEdit::text().length() > lastText.length())
					gmlGlobal::keyboard_string += QString(QLineEdit::text().at(QLineEdit::text().length() - 1));
				else // Erase (last only)
					gmlGlobal::keyboard_string = gmlGlobal::keyboard_string.Left(gmlGlobal::keyboard_string.GetLength() - 1);

				lastText = QLineEdit::text();
			});

		QWidget::setFocus();
		QWidget::hide();
	}

	void KeyChecker::keyPressEvent(QKeyEvent* event)
	{
		if (!event->isAutoRepeat())
		{
			// Send key to AppHandler
			App->SetKeyDown(event, true);
			App->SetWinKeyDown(event->nativeScanCode(), true);
		}

		// Add text if not copy/paste
		if (!event->matches(QKeySequence::Copy) && !event->matches(QKeySequence::Cut) && !event->matches(QKeySequence::Paste))
			QLineEdit::keyPressEvent(event);

		// Propagate to application
		event->ignore();
	}

	void KeyChecker::keyReleaseEvent(QKeyEvent* event)
	{
		if (!event->isAutoRepeat())
		{
			// Send key to AppHandler
			App->SetKeyDown(event, false);
			App->SetWinKeyDown(event->nativeScanCode(), false);
		}

		// Add text
		QLineEdit::keyReleaseEvent(event);

		// Propagate to application
		event->ignore();
	}

	void AppWindow::mousePressEvent(QMouseEvent* event)
	{
		switch (event->button())
		{
			case Qt::LeftButton: mouseDown[mb_left] = true; break;
			case Qt::RightButton: mouseDown[mb_right] = true; break;
			case Qt::MiddleButton: mouseDown[mb_middle] = true; break;
		}
	}

	void AppWindow::mouseReleaseEvent(QMouseEvent* event)
	{
		switch (event->button())
		{
			case Qt::LeftButton: mouseDown[mb_left] = false; break;
			case Qt::RightButton: mouseDown[mb_right] = false; break;
			case Qt::MiddleButton: mouseDown[mb_middle] = false; break;
		}
		mouseUnlock = true;
	}

	void AppWindow::mouseMoveEvent(QMouseEvent* event)
	{
		App->mouseWindow = this;
		mousePos = event->pos();
	}

	void AppWindow::wheelEvent(QWheelEvent* event)
	{
		if (event->angleDelta().y() < 0)
			mouseWheel = -1;
		else if (event->angleDelta().y() > 0)
			mouseWheel = 1;
		else
			mouseWheel = 0;
	}
}
