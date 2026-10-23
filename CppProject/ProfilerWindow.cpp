#include "ProfilerWindow.hpp"
#include "AppHandler.hpp"
#include "Profiler.hpp"

#include <QCheckBox>
#include <QClipboard>
#include <QCloseEvent>
#include <QComboBox>
#include <QDoubleSpinBox>
#include <QFileDialog>
#include <QHeaderView>
#include <QHBoxLayout>
#include <QLabel>
#include <QMessageBox>
#include <QPushButton>
#include <QSaveFile>
#include <QSignalBlocker>
#include <QTableWidget>
#include <QTimer>
#include <QVBoxLayout>

namespace CppProject
{
	QPointer<ProfilerWindow> ProfilerWindow::instance;

	void ProfilerWindow::Show(QWidget* parent)
	{
		if (App && App->headless)
			return;
		if (!instance)
			instance = new ProfilerWindow(parent);
		instance->Refresh();
		instance->show();
		instance->raise();
		instance->activateWindow();
	}

	ProfilerWindow::ProfilerWindow(QWidget* parent) : QDialog(parent)
	{
		setWindowTitle("Performance / Benchmark");
		setModal(false);
		setAttribute(Qt::WA_DeleteOnClose, false);
		resize(740, 540);

		auto layout = new QVBoxLayout(this);
		auto controls = new QHBoxLayout;
		enabled = new QCheckBox("Enable CPU profiling", this);
		enabled->setChecked(false);
		controls->addWidget(enabled);
		controls->addStretch();
		controls->addWidget(new QLabel("Capture duration:", this));
		duration = new QDoubleSpinBox(this);
		duration->setRange(1, 60);
		duration->setDecimals(1);
		duration->setValue(10);
		duration->setSuffix(" s");
		controls->addWidget(duration);
		start = new QPushButton("Start capture", this);
		start->setToolTip("Starts a new capture and enables CPU profiling");
		stop = new QPushButton("Stop capture", this);
		controls->addWidget(start);
		controls->addWidget(stop);
		layout->addLayout(controls);

		status = new QLabel(this);
		status->setTextInteractionFlags(Qt::TextSelectableByMouse);
		layout->addWidget(status);
		auto results = new QHBoxLayout;
		results->addWidget(new QLabel("Results:", this));
		source = new QComboBox(this);
		source->addItem(QString("Live (last %1 frames)").arg(qulonglong(Profiler::LiveFrames)));
		source->addItem("Captured results");
		results->addWidget(source);
		results->addStretch();
		copy = new QPushButton("Copy report", this);
		exportCsv = new QPushButton("Export CSV...", this);
		results->addWidget(copy);
		results->addWidget(exportCsv);
		layout->addLayout(results);

		summary = new QLabel(this);
		summary->setWordWrap(true);
		summary->setTextInteractionFlags(Qt::TextSelectableByMouse);
		layout->addWidget(summary);
		stages = new QTableWidget(int(Profiler::StageCount), 4, this);
		stages->setHorizontalHeaderLabels({ "Stage (inclusive)", "Mean ms", "Max ms", "Calls/frame" });
		stages->horizontalHeader()->setSectionResizeMode(0, QHeaderView::Stretch);
		for (int column = 1; column < 4; column++)
			stages->horizontalHeader()->setSectionResizeMode(column, QHeaderView::ResizeToContents);
		stages->verticalHeader()->hide();
		stages->setEditTriggers(QAbstractItemView::NoEditTriggers);
		stages->setSelectionBehavior(QAbstractItemView::SelectRows);
		stages->setAlternatingRowColors(true);
		layout->addWidget(stages, 1);

		auto explanation = new QLabel("CPU wall times, not GPU timings. Stage times are inclusive and overlap; do not add them. "
			"Animation playback covers editor playback advance and animation updates. Means include inactive frames. "
			"GPU bend preparation is CPU setup, not shader execution. "
			"Frame interval includes timer waits and presentation. CPU frame work excludes timer waits. "
			"OpenGL widget paint / swap normally occurs later, outside CPU frame work. "
			"Loading-only callbacks are not sampled. Closing this window does not stop profiling or capture.", this);
		explanation->setWordWrap(true);
		layout->addWidget(explanation);

		// Avoid making Return in the duration editor start or stop a capture
		for (auto button : { start, stop, copy, exportCsv })
			button->setAutoDefault(false);
		connect(enabled, &QCheckBox::toggled, this, [this](bool checked)
		{
			Profiler::Get().SetEnabled(checked);
			Refresh();
		});
		connect(start, &QPushButton::clicked, this, [this]
		{
			Profiler::Get().StartCapture(duration->value());
			selectCaptureOnStop = true;
			Refresh();
		});
		connect(stop, &QPushButton::clicked, this, [this]
		{
			Profiler::Get().StopCapture();
			Refresh();
		});
		connect(source, QOverload<int>::of(&QComboBox::activated), this, [this](int)
		{
			selectCaptureOnStop = false;
			Refresh();
		});
		connect(copy, &QPushButton::clicked, this, [this]
		{
			QApplication::clipboard()->setText(selectedReport);
		});
		connect(exportCsv, &QPushButton::clicked, this, [this] { ExportCsv(); });
		refreshTimer = new QTimer(this);
		refreshTimer->setInterval(500);
		connect(refreshTimer, &QTimer::timeout, this, [this] { if (isVisible()) Refresh(); });
		refreshTimer->start();
		Refresh();
	}

	void ProfilerWindow::closeEvent(QCloseEvent* event)
	{
		hide();
		event->accept();
	}

	void ProfilerWindow::Refresh()
	{
		if (exporting)
			return;
		auto& profiler = Profiler::Get();
		bool capturing = profiler.Capturing();
		if (wasCapturing && !capturing && selectCaptureOnStop)
			source->setCurrentIndex(1);
		wasCapturing = capturing;
		QSignalBlocker blocker(enabled);
		enabled->setChecked(profiler.Enabled());
		start->setEnabled(!capturing);
		stop->setEnabled(capturing);
		duration->setEnabled(!capturing);
		status->setText(QString("%1 | %2 captured frames | %3 s sampled")
			.arg(capturing ? "Capturing" : (profiler.CapturedFrames() ? "Capture stopped / complete" : "No capture"))
			.arg(qulonglong(profiler.CapturedFrames())).arg(profiler.CaptureSeconds(), 0, 'f', 2));

		bool captured = source->currentIndex() == 1;
		const auto data = profiler.Summarize(captured);
		copy->setEnabled(data.frames != 0);
		exportCsv->setEnabled(data.frames != 0);
		if (!data.frames)
			summary->setText("No sampled frames in this source. Enable profiling or start a capture to collect data.");
		else
			summary->setText(QString("%1 frames | Mean frame: %2 ms | FPS: %3\n"
				"P50: %4 ms | P95: %5 ms | P99: %6 ms | Max: %7 ms\nCPU frame work: %8 ms mean / %9 ms max")
				.arg(qulonglong(data.frames)).arg(data.meanMs, 0, 'f', 3)
				.arg(data.meanMs > 0 ? 1000.0 / data.meanMs : 0, 0, 'f', 2)
				.arg(data.p50Ms, 0, 'f', 3).arg(data.p95Ms, 0, 'f', 3).arg(data.p99Ms, 0, 'f', 3)
				.arg(data.maxMs, 0, 'f', 3).arg(data.stages[size_t(Profiler::Stage::FrameWork)].meanMs, 0, 'f', 3)
				.arg(data.stages[size_t(Profiler::Stage::FrameWork)].maxMs, 0, 'f', 3));

		// Sort raw values before formatting so rounding never changes the row order
		std::array<size_t, Profiler::StageCount> order;
		for (size_t index = 0; index < order.size(); index++)
			order[index] = index;
		std::stable_sort(order.begin(), order.end(), [&](size_t left, size_t right)
		{
			return data.stages[left].meanMs > data.stages[right].meanMs;
		});
		for (size_t row = 0; row < order.size(); row++)
		{
			const auto& stage = data.stages[order[row]];
			stages->setItem(int(row), 0, new QTableWidgetItem(Profiler::StageName(Profiler::Stage(order[row]))));
			const double values[] = { stage.meanMs, stage.maxMs, stage.callsPerFrame };
			for (int column = 1; column < 4; column++)
			{
				auto item = new QTableWidgetItem(QString::number(values[column - 1], 'f', 3));
				item->setTextAlignment(Qt::AlignRight | Qt::AlignVCenter);
				stages->setItem(int(row), column, item);
			}
		}

		selectedReport = QString("Source: %1\n").arg(source->currentText());
		if (App)
			selectedReport += QString("Graphics API: %1\nTarget FPS: %2\n")
				.arg(App->gfxApi == GfxApi::D3D11 ? "Direct3D 11" : "OpenGL").arg(qlonglong(App->targetFps));
		selectedReport += QString("Mean FPS: %1\n").arg(data.meanMs > 0 ? 1000.0 / data.meanMs : 0, 0, 'f', 2);
		selectedReport += profiler.Report(data);
	}

	void ProfilerWindow::ExportCsv()
	{
		if (exporting || (App && App->headless))
			return;
		Refresh();
		// Snapshot before the nested modal event loop can collect frames or replace a capture
		const QByteArray csv = Profiler::Get().Csv(source->currentIndex() == 1).toUtf8();
		exporting = true;
		QPointer<ProfilerWindow> window(this);
		// Unparented stack dialogs remain valid even if the editor deletes this window's parent
		QFileDialog dialog;
		dialog.setWindowTitle("Export profiler CSV");
		dialog.setAcceptMode(QFileDialog::AcceptSave);
		dialog.setFileMode(QFileDialog::AnyFile);
		dialog.setNameFilter("CSV files (*.csv)");
		dialog.setDefaultSuffix("csv");
		dialog.selectFile("cpu-profile.csv");
		int result = App ? App->ExecDialog(&dialog) : dialog.exec();
		if (!window)
			return;
		if (result == QDialog::Accepted && !dialog.selectedFiles().isEmpty())
		{
			QSaveFile file(dialog.selectedFiles().first());
			QString error;
			bool saved = false;
			if (!file.open(QIODevice::WriteOnly))
				error = file.errorString();
			else if (file.write(csv) != csv.size())
			{
				error = file.errorString();
				file.cancelWriting();
			}
			else if (!file.commit())
				error = file.errorString();
			else
				saved = true;
			if (!saved)
			{
				if (error.isEmpty())
					error = "The file could not be written completely.";
				QMessageBox message(QMessageBox::Critical, "Profiler export failed",
					QString("Could not save %1\n\n%2").arg(dialog.selectedFiles().first(), error), QMessageBox::Ok);
				if (App)
					App->ExecDialog(&message);
				else
					message.exec();
			}
		}
		if (window)
		{
			window->exporting = false;
			window->Refresh();
		}
	}
}
