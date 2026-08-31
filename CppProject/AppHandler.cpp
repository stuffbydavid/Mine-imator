#include "AppHandler.hpp"
#include "AppWindow.hpp"

#include "Asset/Font.hpp"
#include "Asset/Shader.hpp"
#include "Asset/Sound.hpp"
#include "Asset/Surface.hpp"
#include "ErrorDialog.hpp"
#include "Generated/Scripts.hpp"
#include "Render/GLWidget.hpp"
#include "Render/GraphicsApiHandler.hpp"
#include "Render/PrimitiveRenderer.hpp"
#include "Render/TexturePage.hpp"
#include "Render/VertexBufferRenderer.hpp"

#include <QDesktopWidget>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMessageBox>
#include <QNetworkInterface>
#include <QStyle>
#include <QTimer>

#ifdef OS_WINDOWS
#define USE_GPU 1
typedef unsigned long DWORD;
extern "C" __declspec(dllexport) DWORD NvOptimusEnablement = USE_GPU;
extern "C" __declspec(dllexport) DWORD AmdPowerXpressRequestHighPerformance = USE_GPU;
#endif

int main(int argc, char* argv[])
{
	return (new CppProject::AppHandler(argc, argv))->Run();
}

namespace CppProject
{
	AppHandler* AppHandler::handler = nullptr;
	Random::ThreadData Random::threadData[OPENMP_MAX_THREADS];
	IntType Printer::indent = 0;

	AppHandler::AppHandler(int& argc, char* argv[])
	{
		handler = this;
		try
		{
			// Initialize string table
			StringType::AddQThread(QThread::currentThread());
			StringType::AddGMLStrings();

			// Parse args
			for (int a = 1; a < argc; a++)
			{
				QString arg = argv[a];
				QString nextArg = (a + 1 < argc) ? argv[a + 1] : "";

				if (arg == "--gfx")
				{
					nextArg = nextArg.toLower();
				#if OS_WINDOWS
					if (nextArg == "d3d" || nextArg == "d3d11")
						gfxApi = GfxApi::D3D11;
					else
				#endif
					if (nextArg == "gl" || nextArg == "opengl")
						gfxApi = GfxApi::OpenGL;
					else
						FATAL("Unknown graphics API: " + nextArg);
					a++;
					continue;
				}
				else if (arg == "--benchmark_project")
					headless = true;

				args.append(arg);
			}

			// Create graphics API handler
			new GraphicsApiHandler;

			// Disable DPI scaling
			QCoreApplication::setAttribute(Qt::AA_DisableHighDpiScaling);

			// Create application
			new QApplication(argc, argv);
			QCoreApplication::setApplicationName(PROJECT_NAME);

			// Set working directory
		#if RELEASE_MODE
			gmlGlobal::working_directory = QCoreApplication::applicationDirPath() + "/";
		#else
			gmlGlobal::working_directory = QDir::currentPath() + "/";
		#endif

			// Set paths
			QDir().mkpath(user_directory_get());
			QDir().mkpath(projects_directory_get());

			// Cycle logs
			StringType prevLog = log_file_get();
			if (file_exists_lib(prevLog))
			{
				StringType prevLogDest = filename_change_ext(log_file_get(), ".previous.txt");
				file_delete_lib(prevLogDest);
				file_rename_lib(prevLog, prevLogDest);
			}

		#if DEBUG_MODE
			DEBUG("Debug mode enabled");
		#endif

			DEBUG("Mine-imator version " + mineimator_version_full + " (" + mineimator_version_date + ")");

		#if OS_WINDOWS
		#ifdef _WIN64
			DEBUG("Platform: Windows x64");
			DEBUG("Executable: 64-bit");
		#else
			DEBUG("Platform: Windows x86");
			DEBUG("Executable: 32-bit");
		#endif
			DEBUG("Graphics API: " + QString(IS_D3D11 ? "D3D11" : "OpenGL"));
		#elif OS_MAC
			DEBUG("Platform: MacOS");
		#else
			DEBUG("Platform: Linux");
		#endif

			DEBUG("OS: " + os_get());
			DEBUG("working_directory: " + gmlGlobal::working_directory);
			DEBUG("user_directory: " + user_directory_get());
			DEBUG("DPI: " + NumStr(qApp->desktop()->logicalDpiX()));

			omp_set_num_threads(std::min(omp_get_max_threads(), OPENMP_MAX_THREADS));
			DEBUG("OpenMP max threads: " + NumStr(omp_get_max_threads()));

			// Create temporary folder
			StringType fileDir = file_directory_get();
			if (QDir(fileDir).exists())
				DEBUG("Using file directory " + fileDir);
			else if (QDir().mkdir(fileDir))
				DEBUG("Created file directory " + fileDir);
			else
				FATAL("Could not create file directory " + fileDir);

			DEBUG("Minecraft saves: " + world_import_get_saves_dir());

			// Set globals
			gmlGlobal::delta_time = 1.0;
			gmlGlobal::GM_runtime_version = "NA";
			gmlGlobal::async_load = ds_map_create();
			targetFps = 60;
			fpsLastUpdate = QDateTime::currentDateTime();
			startTime = QDateTime::currentDateTime().toMSecsSinceEpoch();

			// Map cursors
			cursorMap[cr_none] = Qt::BlankCursor;
			cursorMap[cr_default] = Qt::ArrowCursor;
			cursorMap[cr_beam] = Qt::IBeamCursor;
			cursorMap[cr_drag] = Qt::ClosedHandCursor;
			cursorMap[cr_size_nesw] = Qt::SizeBDiagCursor;
			cursorMap[cr_size_ns] = Qt::SizeVerCursor;
			cursorMap[cr_size_nwse] = Qt::SizeFDiagCursor;
			cursorMap[cr_size_we] = Qt::SizeHorCursor;
			cursorMap[cr_size_all] = Qt::SizeAllCursor;
			cursorMap[cr_handpoint] = Qt::PointingHandCursor;

			// Map Qt/GML key codes
			keyMap[Qt::Key_Alt] = vk_alt;
			keyMap[Qt::Key_Control] = vk_control;
			keyMap[Qt::Key_Shift] = vk_shift;
			keyMap[Qt::Key_Backspace] = vk_backspace;
			keyMap[Qt::Key_Delete] = vk_delete;
			keyMap[Qt::Key_Down] = vk_down;
			keyMap[Qt::Key_End] = vk_end;
			keyMap[Qt::Key_Return] = keyMap[Qt::Key_Enter] = vk_enter;
			keyMap[Qt::Key_Escape] = vk_escape;
			keyMap[Qt::Key_F1] = vk_f1;
			keyMap[Qt::Key_F2] = vk_f2;
			keyMap[Qt::Key_F3] = vk_f3;
			keyMap[Qt::Key_F4] = vk_f4;
			keyMap[Qt::Key_F5] = vk_f5;
			keyMap[Qt::Key_F6] = vk_f6;
			keyMap[Qt::Key_F7] = vk_f7;
			keyMap[Qt::Key_F8] = vk_f8;
			keyMap[Qt::Key_F9] = vk_f9;
			keyMap[Qt::Key_F10] = vk_f10;
			keyMap[Qt::Key_F11] = vk_f11;
			keyMap[Qt::Key_F12] = vk_f12;
			keyMap[Qt::Key_Home] = vk_home;
			keyMap[Qt::Key_Insert] = vk_insert;
			keyMap[Qt::Key_Left] = vk_left;
			keyMap[Qt::Key_multiply] = vk_multiply;
			keyMap[Qt::Key_PageDown] = vk_pagedown;
			keyMap[Qt::Key_PageUp] = vk_pageup;
			keyMap[Qt::Key_Pause] = vk_pause;
			keyMap[Qt::Key_Print] = vk_printscreen;
			keyMap[Qt::Key_Right] = vk_right;
			keyMap[Qt::Key_Space] = vk_space;
			keyMap[Qt::Key_Tab] = vk_tab;
			keyMap[Qt::Key_Up] = vk_up;

			// Initialize D3D11 manually, OpenGL manually only when headless
		#if OS_WINDOWS
			if (IS_D3D11)
				GFX->Init();
		#endif
			if (IS_OPENGL && headless)
				GFX->Init();

			// Initialize audio
			try
			{
				DEBUG("Initialize OpenAL");
				openALDevice = alcOpenDevice(nullptr);
				if (!openALDevice)
					throw QString("alcOpenDevice failed");

				openALContext = alcCreateContext(openALDevice, nullptr);
				if (!openALContext)
					throw QString("alcCreateContext failed");

				if (!alcMakeContextCurrent(openALContext))
					throw QString("alcMakeContextCurrent failed");

				DEBUG("Audio is supported");
				audioSupported = true;
			}
			catch (const QString& err)
			{
				DEBUG("Audio not supported: " + err);
				audioSupported = false;
			}

			if (headless)
			{
				if (!GFX->StartOffScreenRender())
					FATAL("Could not start headless rendering");
				headlessSurface = new Surface({ 1, 1 });
			}
			else
			{
				// Create main window
				AddWindow();
			}

		}
		catch (const QString& ex)
		{
			if (headless)
				DEBUG("[FATAL ERROR] " + ex);
			else
				new ErrorDialog(ex);
			qApp->exit(1);
		}
	}

	AppHandler::~AppHandler()
	{
		StringType::qThreadActive = false;

		if (audioSupported)
		{
			alcMakeContextCurrent(nullptr);
			alcDestroyContext(openALContext);
			alcCloseDevice(openALDevice);
		}
	}

	int AppHandler::Run()
	{
		return qApp->exec();
	}

	void AppHandler::LoadResources()
	{
		if (prRenderer)
			return;

		DEBUG("Load resources");

		// Create renderers
		prRenderer = new PrimitiveRenderer;
		vbRenderer = new VertexBufferRenderer;

		// First texture page
		new TexturePage;

		// Load sprites and shaders into memory
		Shader::Init();
		Asset::Load();

		// GPU settings
		gpu_set_blendenable(true);
		gpu_set_blendmode(bm_normal);
		gpu_set_ztestenable(false);
		gpu_set_zwriteenable(false);
		gpu_set_cullmode(cull_counterclockwise);

		DEBUG("Resources loaded");

		// Start application loop
		stepTimer.start(10, this);
	}

	AppWindow* AppHandler::AddWindow(QRect rect, IntType id, AppWindow* from)
	{
		// Create main window
		AppWindow* win = new AppWindow(id);
		mouseWindow = win;
		windows.append(win);

		// Set as main
		if (!mainWindow)
			mainWindow = win;

		if (rect == QRect()) // Show minimized if no rect given
			win->showMinimized();
		
		else if (from) // Show relative to a window
		{
			win->setGeometry(from->x() + rect.x(), from->y() + rect.y() + QApplication::style()->pixelMetric(QStyle::PM_TitleBarHeight) + 4, rect.width(), rect.height());
			win->ShowNormal();
		}
		else
		{
			win->setGeometry(rect);
			win->ShowNormal();
		}

		win->UpdateSize();
		return win;
	}

	void AppHandler::timerEvent(QTimerEvent* event)
	{
		stepTimer.stop();

		// Debug
		if (keyboard_check_pressed(vk_f6) && global::dev_mode)
		{
			move_all_to_texture_page();
			TexturePage::Debug();
		}

		QVector<AppWindow*> activeWindows = windows;
		if (headless)
			activeWindows = { nullptr };

		// Loop through opened windows or a single headless render target
		for (AppWindow* win : activeWindows)
		{
			if (win && win->closing)
				continue;

			currentWindow = win;

			// Set mouse to widget window
			if (win && mouseWindow == win)
			{
				if (AppWin->mouseLocked)
				{
					QPoint winPos = AppWin->mouseLockWinPos + (AppWin->mousePos - AppWin->mouseLastPos) / scale;
					gmlGlobal::mouse_x = winPos.x();
					gmlGlobal::mouse_y = winPos.y();
				}
				else
				{
					gmlGlobal::mouse_x = win->mousePos.x() / scale;
					gmlGlobal::mouse_y = win->mousePos.y() / scale;
				}
			}
			else
				gmlGlobal::mouse_x = gmlGlobal::mouse_y = -1;

			if (!GFX->StartOffScreenRender())
				continue;
			GFX->surface = win ? win->GetSurface() : headlessSurface;
			GFX->surface->BeginUse(win ? win->size() : QSize());

			GFX->ClearDepth();
			GFX->shader = PR->GetShader();
			GFX->shader->BeginUse();

			// Run application
			try
			{
				// Start
				if (!global::_app)
				{
					new app;
					app_event_create(global::_app->id);
				}

				app_event_step(global::_app->id);
				app_event_draw(global::_app->id);
			}
			catch (AppEndRequest)
			{
				DEBUG("App end requested");

				GFX->shader->EndUse();
				GFX->surface->EndUse();
				if (win)
				{
					mainWindow->closing = true;
					mainWindow->close();
				}
				else
					qApp->exit();
				return;
			}
			catch (const QString& ex)
			{
				if (headless)
				{
					DEBUG("[FATAL ERROR] " + ex);

					GFX->shader->EndUse();
					GFX->surface->EndUse();
					qApp->exit(1);
					return;
				}
				else
					new ErrorDialog(ex);

				qApp->exit(1);
			}

			GFX->SubmitBatch();
			GFX->shader->EndUse();
			GFX->surface->EndUse();

			if (win)
			{
				win->mouseWheel = 0;
				win->mouseLastPos = win->mousePos;
				if (win->mouseUnlock)
					win->mouseLocked = win->mouseUnlock = false;

				win->Present();
				win->UpdateSize();
			}
		}

		VB->EndFrame();
		currentWindow = mainWindow;
		blocked = false;

		// Reset pressed & release key states
		for (IntType key : keyStateMap.keys())
			keyStateMap[key].pressed = keyStateMap[key].released = false;
		for (IntType key : keyWinStateMap.keys())
			keyWinStateMap[key].pressed = keyWinStateMap[key].released = false;
		keyStateMap[vk_nokey].pressed = keyStateMap[vk_nokey].released = true;

		// Add new window(s)
		if (!headless && global::_app->window_state == "")
		{
			for (const AddedWindow& addWin : addedWindows)
			{
				AppWindow* win = AddWindow(addWin.rect, addWin.id, addWin.from);
				if (addWin.maximize)
					win->Maximize();
			}
			addedWindows.clear();
		}

		// Update fps every second
		if (fpsLastUpdate.msecsTo(QDateTime::currentDateTime()) > 1000)
		{
			// Calculate delta_time as duration of previous step in microseconds
			gmlGlobal::delta_time = fpsTimer.ElapsedMs() * 1000.0;

			// Calculate fps using duration of previous step minus step timer delay
			double elapsedMs = fpsTimer.ElapsedMs() - 1000.0 / targetFps;
			if (elapsedMs > 0.0)
				gmlGlobal::fps_real = 1.0 / (elapsedMs / 1000.0);

			gmlGlobal::fps = std::clamp(gmlGlobal::fps_real, IntType(0), targetFps);
			fpsLastUpdate = QDateTime::currentDateTime();

			// Clean unused data
			VecType::CleanHeapData();
			Font::CleanUnused();
			Mesh<>::CleanBuffers();
			StringType::GetCurrentQThreadData()->mainTable.Clean();

			// Reload shader when debugging
			Shader::CheckReload();
		}

		// Delete finished sounds
		SoundInstance::CleanSounds();

		// Schedule next step
		fpsTimer.Reset();
		stepTimer.start(1000.0 / targetFps, this);
	}

	IntType AppHandler::GetMsec() const
	{
		return QDateTime::currentDateTime().toMSecsSinceEpoch() - startTime;
	}

	int AppHandler::ExecDialog(QDialog* dialog)
	{
		if (headless)
		{
			WARNING("Modal dialog requested while headless");
			delete dialog;
			return QDialog::Rejected;
		}

		GFX->SubmitBatch();

		// Clear keys
		for (IntType key : keyStateMap.keys())
			keyStateMap[key] = {};
		for (IntType key : keyWinStateMap.keys())
			keyWinStateMap[key] = {};

		blocked = true;
		int res = dialog->exec();

		GFX->StartOffScreenRender();

		return res;
	}

	void AppHandler::SetKeyDown(QKeyEvent* event, BoolType down)
	{
		QVector<IntType> keys = {};
		switch (event->key())
		{
			case Qt::Key_Alt: keys = { vk_alt, vk_ralt, vk_lalt }; break;
			case Qt::Key_Control: keys = { vk_control, vk_rcontrol, vk_lcontrol }; break;
			case Qt::Key_Shift: keys = { vk_shift, vk_rshift, vk_lshift }; break;
			default:
			{
				if (keyMap.contains(event->key())) // Mapped key
					keys = { keyMap.value(event->key()) };
				else if (event->key() > 255 || event->modifiers() & Qt::ShiftModifier) // Unicode key pressed or shift
					keys = { event->nativeVirtualKey() };
				else
					keys = { event->key() };
				break;
			}
		}

		// Update key states
		for (IntType key : keys)
			keyStateMap[key].SetDown(down);

		// Set last key
		if (keys.length() && down)
			gmlGlobal::keyboard_lastkey = keys[0];

		// Update vk_nokey/vk_anykey down state
		keyStateMap[vk_nokey].down = true;
		keyStateMap[vk_anykey].down = false;

		QHashIterator<IntType, KeyState> it(keyStateMap);
		while (it.hasNext())
		{
			it.next();
			if (it.key() == vk_nokey || !it.value().down)
				continue;
			
			keyStateMap[vk_nokey].down = false;
			keyStateMap[vk_anykey].down = true;
			break;
		}

	#if DEBUG_MODE && 0
		QString keyStr = "";
		for (IntType key : keys)
			keyStr += NumStr(key) + " ";
		DEBUG(QString(down ? "KeyPress" : "KeyRelease") + " key=" + NumStr(event->key()) + ", nativeVirtualKey=" + NumStr(event->nativeVirtualKey()) + ", nativeScanCode=" + NumStr(event->nativeScanCode()) + " => " + keyStr);
	#endif
	}

	void AppHandler::SetWinKeyDown(IntType keyCode, BoolType down)
	{
	#if OS_WINDOWS
		IntType key = 0;
		switch (keyCode)
		{
			case 312: key = vk_ralt; break;
			case 56: key = vk_lalt; break;
			case 285: key = vk_rcontrol; break;
			case 29: key = vk_lcontrol; break;
			case 54: key = vk_rshift; break;
			case 42: key = vk_lshift; break;
		}

		if (key)
		{
			keyWinStateMap[key].SetDown(down);

			// Set last key
			if (down)
				gmlGlobal::keyboard_lastkey = key;
		}
	#endif
	}

	void AppHandler::KeyState::SetDown(BoolType down)
	{
		if (down && !this->down)
			pressed = true;
		if (!down && this->down)
			released = true;
		this->down = down;

		if (pressed)
		{
			App->keyStateMap[vk_nokey].pressed = false;
			App->keyStateMap[vk_anykey].pressed = true;
		}

		if (released)
		{
			App->keyStateMap[vk_nokey].released = false;
			App->keyStateMap[vk_anykey].released = true;
		}
	}

	void AppHandler::HttpProgress(const HttpRequest& request, IntType received, IntType total)
	{
		GFX->StartOffScreenRender();
		Map& asyncMap = DsMap(gmlGlobal::async_load);
		asyncMap["id"] = request.id;
		asyncMap["status"] = 1;
		asyncMap["sizeDownloaded"] = received;
		asyncMap["contentLength"] = total;
		app_event_http(ScopeAny(global::_app->id));
	}

	void AppHandler::HttpResponse(const HttpRequest& request)
	{
		GFX->StartOffScreenRender();
		Map& asyncMap = DsMap(gmlGlobal::async_load);
		asyncMap["id"] = request.id;
		asyncMap["http_status"] = request.data->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
		if (request.data->error())
		{
			asyncMap["status"] = -1;
			WARNING("Error fetching " + request.url + ":\n" + request.data->errorString());
		}
		else
		{
			asyncMap["status"] = 0;
			asyncMap["result"] = QString(request.data->readAll());
		}

		app_event_http(ScopeAny(global::_app->id));
	}
}
