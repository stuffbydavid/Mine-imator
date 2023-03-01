#include "Generated/Scripts.hpp"

#include "AppHandler.hpp"
#include "Asset/DataStructure.hpp"

#include <QApplication>
#include <QClipboard>
#include <QDesktopWidget>
#include <QMessageBox>
#include <QPushButton>
#include <QTime>

namespace CppProject
{
	void array_copy(VarType dstArrRef, IntType dstIndex, VarType srcArrRef, IntType srcIndex, IntType len)
	{
		ArrType& dstArr = dstArrRef.Arr();
		ArrType& srcArr = srcArrRef.Arr();
		for (int i = 0; i < len; i++)
			dstArr[dstIndex + i] = srcArr[srcIndex + i];
	}

	ArrType array_create(VarArgs args)
	{
		ArrType arr;
		IntType size = args[0].ToInt();

		if (args.Size() == 2) // Initialize with value
		{
			for (IntType i = 0; i < size; i++)
				arr.Append(args[1]);
		}
		else // Initialize with undefined
		{
			for (IntType i = 0; i < size; i++)
				arr.Append(VarType());
		}
		return arr;
	}

	IntType array_equals(VarType arr1Ref, VarType arr2Ref)
	{
		return arr1Ref.Arr() == arr2Ref.Arr();
	}

	IntType array_length(VarType arrRef)
	{
		return arrRef.Arr().Size();
	}

	VarType choose(VarArgs args)
	{
		return args[(IntType)Random::Get(args.Size())];
	}

	StringType chr(IntType code)
	{
		return QString(QChar((char)code));
	}

	RealType clamp(RealType value, RealType val1, RealType val2)
	{
		// Order of max/min is not strict in GML
		if (val1 < val2)
			return std::clamp(value, val1, val2);
		else
			return std::clamp(value, val2, val1);
	}

	StringType clipboard_get_text()
	{
		return QApplication::clipboard()->text();
	}

	IntType clipboard_has_text()
	{
		return !QApplication::clipboard()->text().isEmpty();
	}

	void clipboard_set_text(StringType text)
	{
		QApplication::clipboard()->setText(text);
	}

	IntType current_time()
	{
		return App->GetMsec();
	}

	BoolType code_is_compiled()
	{
		return true;
	}

	StringType base64_decode(StringType str)
	{
		return QByteArray::fromBase64(str.ToUtf8(), QByteArray::Base64Encoding);
	}

	StringType environment_get_variable(StringType name)
	{
		return qgetenv(name.ToUtf8());
	}

	VarType external_call(VarArgs args)
	{
		// Do nothing, external_calls are replaced by their C++ functions in Library/
		return VarType(); 
	}

	IntType external_define(VarArgs args)
	{
		// Do nothing
		return 0;
	}

	void game_end()
	{
		throw AppEndRequest();
	}

	void gc_collect()
	{
		// Do nothing
	}

	void gc_target_frame_time(IntType)
	{
		// Do nothing
	}

	void gml_pragma(VarArgs args)
	{
		// Do nothing
	}

	void gml_release_mode(BoolType)
	{
		// Do nothing
	}

	IntType http_get_file(StringType url, StringType targetFile)
	{
		QNetworkRequest req((QString)url);
		req.setAttribute(QNetworkRequest::RedirectPolicyAttribute, QNetworkRequest::NoLessSafeRedirectPolicy);
		QNetworkReply* reply = App->httpManager.get(req);
		AppHandler::HttpRequest request = { App->httpNextId, reply, url };
		reply->connect(reply, &QNetworkReply::downloadProgress, [request](qint64 received, qint64 total)
		{
			App->HttpProgress(request, received, total);
		});
		reply->connect(reply, &QNetworkReply::finished, [targetFile, request]()
		{
			QFile file(targetFile);
			AddPerms(file);
			if (!file.open(QIODevice::WriteOnly))
			{
				WARNING("Could not open targe file "+ targetFile + " for writing.");
				return;
			}
			file.write(request.data->readAll());
			file.close();
			App->HttpResponse(request);
		});
		return App->httpNextId++;
	}

	IntType http_get(StringType url)
	{
		QNetworkRequest req((QString)url);
		req.setAttribute(QNetworkRequest::RedirectPolicyAttribute, QNetworkRequest::NoLessSafeRedirectPolicy);
		QNetworkReply* reply = App->httpManager.get(req);
		AppHandler::HttpRequest request = { App->httpNextId, reply, url };
		reply->connect(reply, &QNetworkReply::finished, [request]()
		{
			App->HttpResponse(request);
		});
		return App->httpNextId++;
	}

	IntType irandom_range(IntType n1, IntType n2)
	{
		return n1 + (IntType)Random::Get((n2 - n1) + 1);
	}

	IntType irandom(IntType max)
	{
		return Random::Get(max + 1);
	}

	BoolType is_array(VarType v)
	{
		return (v.IsArray() || v.IsVec() || v.IsMatrix());
	}

	BoolType is_bool(VarType v)
	{
		return v.IsBool();
	}

	BoolType is_int32(VarType v)
	{
		return v.IsInt();
	}

	BoolType is_int64(VarType v)
	{
		return v.IsInt();
	}

	BoolType is_real(VarType v)
	{
		return (v.IsInt() || v.IsReal());
	}

	BoolType is_string(VarType v)
	{
		return v.IsString();
	}

	BoolType is_undefined(VarType v)
	{
		return v.IsUndefined();
	}

	RealType max(VarArgs args)
	{
		RealType maxVal = args[0];
		for (IntType i = 1; i < args.Size(); i++)
			maxVal = std::max(maxVal, args[i].ToReal());
		return maxVal;
	}

	RealType min(VarArgs args)
	{
		RealType minVal = args[0];
		for (IntType i = 1; i < args.Size(); i++)
			minVal = std::min(minVal, args[i].ToReal());
		return minVal;
	}

	IntType ord(StringType ch)
	{
		return ch.At(0).unicode();
	}

	IntType os_get_info()
	{
		return (new Map)->id;
	}

	StringType os_get_language()
	{
		return "";
	}

	StringType os_get_region()
	{
		return "";
	}

	BoolType os_is_network_connected()
	{
		return false;
	}

	IntType random_get_seed()
	{
		return Random::GetSeed();
	}

	RealType random_range(RealType min, RealType max)
	{
		return min + Random::Get(max - min);
	}

	void random_set_seed(IntType seed)
	{
		Random::Set(seed);
	}

	RealType random(RealType max)
	{
		return Random::Get(max);
	}

	void randomize()
	{
		Random::Set((IntType)(App->randomizeTimer.ElapsedMs() * 1000.0 * 12345678) & 0xFFFF);
	}

	RealType real(VarType v)
	{
		if (v.IsString())
			return v.Str().ToReal();
		return v.ToReal();
	}

	void show_debug_message(StringType str)
	{
		DEBUG(str);
	}
	
	void show_message(StringType text)
	{
		QMessageBox msg;
		msg.setModal(true);
		msg.setText(text);
		msg.setFixedWidth(300);
		msg.setStyleSheet("QLabel{padding: 15px;}");
		App->ExecDialog(&msg);
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

	struct QMessageBoxNoEsc : public QMessageBox
	{
		void keyPressEvent(QKeyEvent* event) override
		{
			if (event->key() == Qt::Key_Escape) {
				event->accept();
				return;
			}
			else {
				QMessageBox::keyPressEvent(event);
			}
		}
	};

	BoolType show_question(StringType text)
	{
		QMessageBoxNoEsc msg;
		msg.setModal(true);
		msg.setText(text);
		msg.setFixedWidth(300);
		msg.setStyleSheet("QLabel{padding: 15px;}");
		msg.setStandardButtons(QMessageBox::Yes);
		msg.addButton(QMessageBox::No);
		App->ExecDialog(&msg);

		return (msg.result() == QMessageBox::Yes);
	}

	BoolType is_cpp()
	{
		return true;
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

	StringType os_get()
	{
		return QSysInfo::prettyProductName();
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

	IntType thread_get_number()
	{
		return omp_get_max_threads();
	}

	IntType thread_get_id()
	{
		return omp_get_thread_num();
	}

	void thread_task_begin()
	{
		StringType::BeginOmp();
	}

	void thread_task_end()
	{
		StringType::EndOmp();
	}

	void log_message(StringType text)
	{
		Printer::Line(text);
	}
}
