#include "Generated/Scripts.hpp"

#include "AppHandler.hpp"
#include "AppWindow.hpp"
#include "Asset/DataStructure.hpp"

#if OS_WINDOWS
#include <windows.h>
#include <shobjidl.h>
#include <winuser.h>
#endif

#include <QApplication>
#include <QClipboard>
#include <QDesktopWidget>
#include <QFileDialog>
#include <QMessageBox>
#include <QPushButton>
#include <QStandardPaths>
#include <QTime>

namespace CppProject
{
	QStringList GetFilenameFilterList(StringType str);

	BoolType is_cpp()
	{
		return true;
	}

	BoolType is_release()
	{
#if RELEASE_MODE // Release target
		return true;
#else
		return false;
#endif
	}

	BoolType is_optimized()
	{
#if OPTIMIZED // RelWithDebInfo, RunBenchmarks, Release targets
		return true;
#else
		return false;
#endif
	}

	ArrType program_args_get()
	{
		ArrType args;
		for (QString str : App->args)
			args.Append(StringType(str));
		
		return args;
	}

	IntType file_get_size(StringType filename)
	{
		return QFileInfo(filename).size();
	}

	void log_message(StringType text)
	{
		Printer::Line(text);
	}

	StringType log_file_get()
	{
#if OS_WINDOWS
		return data_directory + "/log.txt";
#else
		return QDir::homePath() + "/Mine-imator/log.txt";
#endif
	}

	StringType get_open_filenames_ext(StringType filter, StringType file, StringType dir, StringType caption)
	{
		QFileDialog fd;
		fd.setModal(true);
		fd.setAcceptMode(QFileDialog::AcceptOpen);
		fd.setFileMode(QFileDialog::ExistingFiles);
		fd.setNameFilters(GetFilenameFilterList(filter));
		
		if (file != "")
		{
			if (!file.Contains("/") && !dir.IsEmpty())
				file = dir + "/" + file;
			fd.selectFile(file);
		}
		else if (!dir.IsEmpty())
			fd.setDirectory(dir);
		
		fd.setWindowTitle(caption);
		
		if (!App->ExecDialog(&fd))
			return "";

		QStringList files = fd.selectedFiles();
		if (files.size() > 0)
			return files.join("\n");
		
		return "";
	}

	IntType show_message_ext(StringType title, StringType text, StringType button1, StringType button2, StringType button3)
	{
		QMessageBox msg;
		msg.setModal(true);
		msg.setText(text);
		msg.setWindowTitle(title);
		msg.setFixedWidth(300);
		msg.setStyleSheet("QLabel{padding: 15px;}");
		msg.addButton(button1, QMessageBox::ButtonRole::AcceptRole);
		msg.addButton(button2, QMessageBox::ButtonRole::DestructiveRole);
		msg.addButton(button3, QMessageBox::ButtonRole::RejectRole);
		App->ExecDialog(&msg);

		return msg.result();
	}

	StringType os_get()
	{
		return QSysInfo::prettyProductName();
	}

	IntType platform_get()
	{
#if OS_WINDOWS
		return e_platform_WINDOWS;
#elif OS_MAC
		return e_platform_MAC_OS;
#else
		return e_platform_LINUX;
#endif
	}

	StringType graphics_api_get()
	{
		if (IS_D3D11)
			return "D3D";

		if (IS_OPENGL)
			return "GL";

		return "";
	}

	RealType interface_scale_default_get()
	{
		RealType ratio;
#if OS_MAC
		ratio = qApp->desktop()->logicalDpiX() / 72.0;
#else
		ratio = qApp->desktop()->logicalDpiX() / 96.0;
#endif
		return (IntType)(ratio + 0.01);
	}

	void interface_scale_set(RealType factor)
	{
		factor = std::clamp(factor, 1.0, 3.0);
		if (App->scale == factor)
			return;

		App->scale = factor;
	}

	StringType file_directory_get()
	{
#if RELEASE_MODE
#if OS_WINDOWS
		return QStandardPaths::standardLocations(QStandardPaths::AppDataLocation)[0] + "_tmp/";
#else
		return QDir::tempPath() + "/" + StringType(PROJECT_NAME) + "_tmp/";
#endif
#endif
		return BUILD_FOLDER + "/";
	}

	StringType user_directory_get()
	{
#if OS_WINDOWS
		return gmlGlobal::working_directory + "Data/";
#else
		return QDir::homePath() + "/Mine-imator/";
#endif
	}

	StringType projects_directory_get()
	{
#if OS_WINDOWS
		return gmlGlobal::working_directory + "Projects/";
#else
		return QDir::homePath() + "/Mine-imator/Projects/";
#endif
	}

	StringType skins_directory_get()
	{
#if OS_WINDOWS
		return gmlGlobal::working_directory + "Skins/";
#else
		return QDir::homePath() + "/Mine-imator/Skins/";
#endif
	}

	StringType packs_directory_get()
	{
#if OS_WINDOWS
		return gmlGlobal::working_directory + "Packs/";
#else
		return QDir::homePath() + "/Mine-imator/Packs/";
#endif
	}

	StringType minecraft_java_directory_get()
	{
#if OS_WINDOWS
		return QFileInfo(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)).path() + "/.minecraft";
#elif OS_MAC
		return QDir::homePath() + "/Library/Application Support/minecraft";
#else
		return QDir::homePath() + "/.minecraft";
#endif
	}

	StringType drivers_url_get()
	{
#if OS_WINDOWS
		return "https://www.thewindowsclub.com/how-to-update-graphics-drivers-windows";
#elif OS_MAC
		return "http://www.cgl.ucsf.edu/chimera/graphics/updatemac.html";
#else
		return "http://www.cgl.ucsf.edu/chimera/graphics/updatelinux.html";
#endif
	}
}
