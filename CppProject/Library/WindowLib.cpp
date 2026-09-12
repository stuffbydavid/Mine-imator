#include "Generated/Scripts.hpp"

#include "AppHandler.hpp"
#include "AppWindow.hpp"

#if OS_WINDOWS
#include <windows.h>
#include <shobjidl.h>
#include <winuser.h>
#endif

namespace CppProject
{
	RealType lib_window_maximize(StringType)
	{
		// Unused
		return 0;
	}

	RealType lib_window_set_focus(StringType)
	{
		// Unused
		return 0;
	}

#if OS_WINDOWS
	static ITaskbarList3* gTaskbar = nullptr;

	static void EnsureTaskbarInit()
	{
		if (!gTaskbar)
		{
			CoInitialize(nullptr);
			CoCreateInstance(CLSID_TaskbarList, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&gTaskbar));
			if (gTaskbar)
				gTaskbar->HrInit();
		}
	}

	RealType lib_window_taskbar_progress_value_set(RealType value)
	{
		EnsureTaskbarInit();
		if (!gTaskbar || !AppHandler::handler || !AppHandler::handler->mainWindow)
			return 0;

		HWND hwnd = (HWND)AppHandler::handler->mainWindow->winId();
		if (!hwnd)
			return 0;

		gTaskbar->SetProgressValue(hwnd, (ULONGLONG)(value * 1000.0), 1000);
		return 0;
	}

	RealType lib_window_taskbar_progress_state_set(RealType state)
	{
		EnsureTaskbarInit();
		if (!gTaskbar || !AppHandler::handler || !AppHandler::handler->mainWindow)
			return 0;

		HWND hwnd = (HWND)AppHandler::handler->mainWindow->winId();
		if (!hwnd)
			return 0;

		switch ((IntType)state)
		{
		case 1: gTaskbar->SetProgressState(hwnd, TBPF_INDETERMINATE); break;
		case 2: gTaskbar->SetProgressState(hwnd, TBPF_NORMAL); break;
		case 4: gTaskbar->SetProgressState(hwnd, TBPF_ERROR); break;
		case 8: gTaskbar->SetProgressState(hwnd, TBPF_PAUSED); break;
		default: gTaskbar->SetProgressState(hwnd, TBPF_NOPROGRESS); break; // 0
		}
		return 0;
	}

	RealType lib_window_flash()
	{
		if (!AppHandler::handler || !AppHandler::handler->mainWindow)
			return 0;

		HWND hwnd = (HWND)AppHandler::handler->mainWindow->winId();
		if (!hwnd)
			return 0;

		FLASHWINFO fi;
		fi.cbSize = sizeof(FLASHWINFO);
		fi.hwnd = hwnd;
		fi.dwFlags = FLASHW_ALL | FLASHW_TIMERNOFG;
		fi.uCount = 3;
		fi.dwTimeout = 0;

		FlashWindowEx(&fi);
		return 0;
	}

	RealType lib_window_beep(RealType type)
	{
		switch ((IntType)type)
		{
		case 1: MessageBeep(MB_ICONERROR); break;
		case 2: MessageBeep(MB_ICONQUESTION); break;
		case 3: MessageBeep(MB_ICONWARNING); break;
		case 4: MessageBeep(MB_ICONINFORMATION); break;
		default: MessageBeep(MB_OK); break;
		}
		return 0;
	}
#else
	RealType lib_window_taskbar_progress_value_set(RealType)
	{
		return 0;
	}

	RealType lib_window_taskbar_progress_state_set(RealType)
	{
		return 0;
	}

	RealType lib_window_flash()
	{
		return 0;
	}

	RealType lib_window_beep(RealType)
	{
		return 0;
	}
#endif

}