#pragma once

#include <QDialog>
#include <QPointer>

class QCheckBox;
class QCloseEvent;
class QComboBox;
class QDoubleSpinBox;
class QLabel;
class QPushButton;
class QTableWidget;
class QTimer;

namespace CppProject
{
	struct ProfilerWindow : QDialog
	{
		static void Show(QWidget* parent);

	private:
		explicit ProfilerWindow(QWidget* parent);
		void closeEvent(QCloseEvent* event) override;
		void Refresh();
		void ExportCsv();

		QCheckBox* enabled;
		QDoubleSpinBox* duration;
		QPushButton* start;
		QPushButton* stop;
		QPushButton* copy;
		QPushButton* exportCsv;
		QComboBox* source;
		QLabel* status;
		QLabel* summary;
		QTableWidget* stages;
		QTimer* refreshTimer;
		QString selectedReport;
		bool wasCapturing = false, selectCaptureOnStop = true, exporting = false;

		static QPointer<ProfilerWindow> instance;
	};
}
