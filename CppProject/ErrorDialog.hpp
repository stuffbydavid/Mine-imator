#pragma once
#include "Common.hpp"
#include <QDialog>

namespace CppProject
{
	struct ErrorDialog : QDialog
	{
		ErrorDialog(QString error);
	};
}