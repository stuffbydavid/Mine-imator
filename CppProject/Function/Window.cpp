#include "Generated/Scripts.hpp"

#include "AppHandler.hpp"
#include "AppWindow.hpp"
#include "Asset/DataStructure.hpp"
#include "Render/GraphicsApiHandler.hpp"

#if OS_WINDOWS
#include <windows.h>
#include <shobjidl.h>
#include <winuser.h>
#endif

namespace CppProject
{
	void window_beep(IntType type)
	{
#if OS_WINDOWS
		switch ((IntType)type)
		{
		case 1: MessageBeep(MB_ICONERROR); break;
		case 2: MessageBeep(MB_ICONQUESTION); break;
		case 3: MessageBeep(MB_ICONWARNING); break;
		case 4: MessageBeep(MB_ICONINFORMATION); break;
		default: MessageBeep(MB_OK); break;
		}
#endif
	}

	void window_flash()
	{
		if (!AppHandler::handler || !AppHandler::handler->mainWindow)
			return;

#if OS_WINDOWS
		HWND hwnd = (HWND)AppHandler::handler->mainWindow->winId();
		if (!hwnd)
			return;

		FLASHWINFO fi;
		fi.cbSize = sizeof(FLASHWINFO);
		fi.hwnd = hwnd;
		fi.dwFlags = FLASHW_ALL | FLASHW_TIMERNOFG;
		fi.uCount = 3;
		fi.dwTimeout = 0;

		FlashWindowEx(&fi);
#endif
	}

	void window_mouse_set_permission(BoolType enabled)
	{
		AppWindow::mouseEnableLock = enabled;
	}

	BoolType window_mouse_get_permission()
	{
		return AppWindow::mouseEnableLock;
	}

	IntType window_get_current()
	{
		return AppWin ? AppWin->id : 0;
	}

	void window_create(Scope<app> self, IntType window, IntType x, IntType y, IntType width, IntType height)
	{
		if (App->headless)
			return;

		x *= App->scale;
		y *= App->scale;
		width *= App->scale;
		height *= App->scale;

		tip_reset(self);
		ds_list_add({ global::window_list, window });

		GFX->SubmitBatch();
		App->addedWindows.append({ window, QRect(x, y, width, height), AppWin });
	}

	void window_close(Scope<app>, IntType window)
	{
		for (AppWindow* win : App->windows)
		{
			if (win->id == window)
			{
				win->close();
				return;
			}
		}
	}

	BoolType window_mouse_is_active(IntType window)
	{
		return App->mouseWindow && App->mouseWindow->id == window;
	}

	void window_state_save(IntType window)
	{
		AppWindow* saveWin = App->mainWindow;

		for (AppWindow* win : App->windows)
			if (win->id == window)
				saveWin = win;
		if (!saveWin)
			return;

		int x, y, w, h;
		saveWin->geometry().getRect(&x, &y, &w, &h);
		json_save_var("rect", ArrType::From({ x, y, w, h }));
		json_save_var_bool("maximized", saveWin->isMaximized());
	}

	void window_state_restore(IntType window, IntType mapId)
	{
		if (App->headless)
			return;

		ds_list_add({ global::window_list, window });

		const Map& map = DsMap(mapId);
		const List& rectList = DsList(map.Value("rect"));
		QRect rect = QRect(rectList.Value(0), rectList.Value(1), rectList.Value(2), rectList.Value(3));
		BoolType maximized = map.Value("maximized").Int();
		App->addedWindows.append({ window, rect, nullptr, maximized });
	}

	void window_main_restore(VarType rect, BoolType maximize)
	{
		if (!App->mainWindow)
			return;

		if (rect == null_)
			App->mainWindow->Maximize();
		else
		{
			App->mainWindow->setGeometry(QRect(rect[0], rect[1], rect[2], rect[3]));
			if (maximize)
				App->mainWindow->Maximize();
		}
	}

#if OS_WINDOWS
	static ITaskbarList3* gTaskbar = nullptr;

	static BoolType EnsureTaskbarInit()
	{
		if (!gTaskbar)
		{
			(void)CoInitialize(nullptr);
			(void)CoCreateInstance(CLSID_TaskbarList, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&gTaskbar));
			if (gTaskbar)
				gTaskbar->HrInit();
		}

		return gTaskbar != nullptr;
	}
#endif

	void window_taskbar_progress_value_set(RealType value)
	{
		if (!AppHandler::handler || !AppHandler::handler->mainWindow)
			return;

#if OS_WINDOWS
		if (!EnsureTaskbarInit())
			return;

		HWND hwnd = (HWND)AppHandler::handler->mainWindow->winId();
		if (!hwnd)
			return;

		gTaskbar->SetProgressValue(hwnd, (ULONGLONG)(value * 1000.0), 1000);
#endif
	}

	void window_taskbar_progress_state_set(IntType state)
	{
		if (!AppHandler::handler || !AppHandler::handler->mainWindow)
			return;

#if OS_WINDOWS
		if (!EnsureTaskbarInit())
			return;

		HWND hwnd = (HWND)AppHandler::handler->mainWindow->winId();
		if (!hwnd)
			return;

		switch ((IntType)state)
		{
			case 1: gTaskbar->SetProgressState(hwnd, TBPF_INDETERMINATE); break;
			case 2: gTaskbar->SetProgressState(hwnd, TBPF_NORMAL); break;
			case 4: gTaskbar->SetProgressState(hwnd, TBPF_ERROR); break;
			case 8: gTaskbar->SetProgressState(hwnd, TBPF_PAUSED); break;
			default: gTaskbar->SetProgressState(hwnd, TBPF_NOPROGRESS); break; // 0
		}
#endif
	}
}
