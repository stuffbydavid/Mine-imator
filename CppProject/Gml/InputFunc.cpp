#include "Generated/GmlFunc.hpp"

#include "AppHandler.hpp"
#include "AppWindow.hpp"

namespace CppProject
{
	BoolType keyboard_check_direct(IntType key)
	{
	#ifdef OS_WINDOWS
		if (key == vk_ralt || key == vk_lalt ||
			key == vk_rcontrol || key == vk_lcontrol ||
			key == vk_rshift || key == vk_lshift)
			return App->keyStateMap[key].down;
		else
	#endif
		return App->keyStateMap[key].down;
	}

	BoolType keyboard_check_pressed(IntType key)
	{
		return (App->keyStateMap[key].pressed);
	}

	BoolType keyboard_check_released(IntType key)
	{
		return (!App->keyStateMap[key].released);
	}

	BoolType keyboard_check(IntType key)
	{
		return App->keyStateMap[key].down;
	}

	void keyboard_clear(IntType key)
	{
		App->keyStateMap[key] = { false, false, false };
	}

	BoolType mouse_check_button(IntType button)
	{
		return AppWin->mouseDown[button];
	}

	BoolType mouse_clear(IntType button)
	{
		AppWin->mouseDown[button] = false;
		return false;
	}

	BoolType mouse_wheel_down()
	{
		return (AppWin->mouseWheel < 0);
	}

	BoolType mouse_wheel_up()
	{
		return (AppWin->mouseWheel > 0);
	}
}