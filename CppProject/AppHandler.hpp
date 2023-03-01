#pragma once

#include "Common.hpp"

#include <QBasicTimer>
#include <QCloseEvent>
#include <QMessageBox>
#include <QNetworkAccessManager>
#include <QNetworkReply>

#define App AppHandler::handler
#define AppWin App->currentWindow
#define PR App->prRenderer
#define VB App->vbRenderer

namespace CppProject
{
	struct AppEndRequest {};
	struct AppWindow;
	struct GraphicsApiHandler;
	struct Font;
	struct Object;
	struct PrimitiveRenderer;
	struct Shader;
	struct Surface;
	struct VertexBuffer;
	struct VertexBufferRenderer;

	// Application handler
	struct AppHandler : QObject
	{
		AppHandler(int argc, char* argv[]);
		~AppHandler();

		// Run QApplication instance.
		int Run();

		// Load app resourcs.
		void LoadResources();

		// Create a new AppWindow containing an GLRenderer.
		AppWindow* AddWindow(QRect rect = {}, IntType id = 0, AppWindow* from = nullptr);

		// Runs once per frame and runs the app logic and drawing to the opened widgets.
		void timerEvent(QTimerEvent* event) override;

		// Gets the amount of milliseconds since the application started.
		IntType GetMsec() const;

		// Executes a modal QDialog, returning the result.
		int ExecDialog(QDialog* dialog);

		// Sets whether a GML key is down.
		void SetKeyDown(QKeyEvent* event, BoolType down);

		// Sets whether a Windows key is down (right or left shift/alt/control)
		void SetWinKeyDown(IntType key, BoolType down);

		// Runs when a HTTP request progresses.
		struct HttpRequest;
		void HttpProgress(const HttpRequest& request, IntType received, IntType total);

		// Runs when a HTTP response is received.
		void HttpResponse(const HttpRequest& request);

		PrimitiveRenderer* prRenderer = nullptr;
		VertexBufferRenderer* vbRenderer = nullptr;

		AppWindow* mainWindow = nullptr;
		AppWindow* mouseWindow = nullptr;
		AppWindow* currentWindow = nullptr;
		QVector<AppWindow*> windows;
		struct AddedWindow
		{
			IntType id;
			QRect rect;
			AppWindow* from = nullptr;
			BoolType maximize = false;
		};
		QVector<AddedWindow> addedWindows;

		QBasicTimer stepTimer;
		BoolType blocked = false;

		Timer randomizeTimer;
		IntType startTime = 0;
		RealType scale = 1.0;
		Timer fpsTimer;
		QDateTime fpsLastUpdate;

		QNetworkAccessManager httpManager;
		IntType httpNextId = 1;
		struct HttpRequest
		{
			IntType id;
			QNetworkReply* data = nullptr;
			QString url;
		};

		ALCdevice* openALDevice = nullptr;
		ALCcontext* openALContext = nullptr;
		BoolType audioSupported;

		QHash<IntType, Qt::CursorShape> cursorMap;
		QHash<IntType, IntType> keyMap;

		// Keyboard key state, pressed/released is reset after each step
		struct KeyState
		{
			BoolType down = false, pressed = false, released = false;
			void SetDown(BoolType down);
		};
		QHash<IntType, KeyState> keyStateMap;
		QHash<IntType, KeyState> keyWinStateMap;

		static AppHandler* handler;
	};
}
