#include "Generated/GmlFunc.hpp"
#include "Generated/Scripts.hpp"

#include "AppHandler.hpp"
#include "AppWindow.hpp"
#include "Asset/Surface.hpp"
#include "Render/GraphicsApiHandler.hpp"

#include <QCursor>
#include <QDesktopWidget>

#if OS_MAC
#include <CoreGraphics/CoreGraphics.h>
#endif

namespace CppProject
{
	static void SetMousePosition(const QPoint& position)
	{
		if (AppWindow::mouseEnableLock)
		{
		#if OS_MAC
			CGError error = CGWarpMouseCursorPosition(CGPointMake(position.x(), position.y()));
			CGAssociateMouseAndMouseCursorPosition(true);
			if (error == kCGErrorSuccess)
				AppWin->mousePos = AppWin->mapFromGlobal(position);
		#else
			QCursor::setPos(AppWin->screen(), position);
		#endif
		}
		else if (!AppWin->mouseLocked)
		{
			AppWin->mouseLocked = true;
			AppWin->mouseLockPos = AppWin->mouseLockWinPos = AppWin->mousePos;
		}
	}

	IntType display_get_dpi_x()
	{
		return qApp->desktop()->logicalDpiX();
	}

	IntType display_get_dpi_y()
	{
		return qApp->desktop()->logicalDpiY();
	}

	IntType display_mouse_get_x()
	{
		if (App->headless)
			return 0;

		if (AppWindow::mouseEnableLock)
			return QCursor::pos().x() / App->scale;
		else
		{
			if (AppWin->mouseLocked)
				return (AppWin->mouseLockPos + (AppWin->mousePos - AppWin->mouseLastPos)).x();
			
			return AppWin->mousePos.x();
		}
	}

	IntType display_mouse_get_y()
	{
		if (App->headless)
			return 0;

		if (AppWindow::mouseEnableLock)
			return QCursor::pos().y() / App->scale;
		else
		{
			if (AppWin->mouseLocked)
				return (AppWin->mouseLockPos + (AppWin->mousePos - AppWin->mouseLastPos)).y();
			
			return AppWin->mousePos.y();
		}
	}

	void display_mouse_set(IntType x, IntType y)
	{
		if (App->headless)
			return;

		SetMousePosition({ (int)(x * App->scale), (int)(y * App->scale) });
	}

	IntType display_reset(IntType, IntType)
	{
		// Do nothing
		return 0;
	}

	IntType window_get_height()
	{
		if (App->headless)
			return App->headlessSurface->size.height();

		return AppWin->height() / App->scale;
	}

	IntType window_get_width()
	{
		if (App->headless)
			return App->headlessSurface->size.width();

		return AppWin->width() / App->scale;
	}

	IntType window_get_x()
	{
		if (App->headless)
			return 0;

		return AppWin->x();
	}

	IntType window_get_y()
	{
		if (App->headless)
			return 0;

		return AppWin->y();
	}

	StringType window_handle()
	{
		// Do nothing
		return "";
	}

	BoolType window_has_focus()
	{
		return AppWin->isActiveWindow();
	}

	void window_mouse_set(IntType x, IntType y)
	{
		if (App->headless)
			return;

		QPoint global = AppWin->mapToGlobal({ (int)(x * App->scale), (int)(y * App->scale) });
		SetMousePosition(global);

		AppWin->mouseLockWinPos = QPoint(x, y);
	}

	void window_set_caption(StringType caption)
	{
		if (AppWin)
			AppWin->setWindowTitle(caption);
	}

	void window_set_cursor(IntType cursor)
	{
		if (AppWin)
			AppWin->setCursor(App->cursorMap[cursor]);
	}

	void window_set_min_height(IntType height)
	{
		if (AppWin)
			AppWin->setMinimumHeight(height);
	}

	void window_set_min_width(IntType width)
	{
		if (AppWin)
			AppWin->setMinimumHeight(width);
	}

	void window_set_rectangle(IntType, IntType, IntType, IntType)
	{
		// Do nothing
	}

	void window_set_size(IntType width, IntType height)
	{
		if (AppWin)
			AppWin->newSize = { (int)width, (int)height };
	}

}
