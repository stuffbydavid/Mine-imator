#include "ErrorDialog.hpp"
#include "Generated/Scripts.hpp"

#include <QApplication>
#include <QBoxLayout>
#include <QLabel>
#include <QPushButton>
#include <QTextEdit>
#include <QDesktopServices>

namespace CppProject
{
	ErrorDialog::ErrorDialog(QString error)
	{
		QDialog::setWindowFlag(Qt::WindowContextHelpButtonHint, false);
		QDialog::setFixedSize(400, 400);
		QDialog::setStyleSheet("font-size: 12px;");

		QBoxLayout* mainLayout = new QVBoxLayout;
		mainLayout->setSpacing(12);
		QTextEdit* textArea = new QTextEdit;
		textArea->setReadOnly(true);
		textArea->setStyleSheet("font-family: Consolas;");
		textArea->setPlainText(error + "\nVersion: " + mineimator_version + (mineimator_version_extra.IsEmpty() ? "" : " " + mineimator_version_extra) + " (" + os_get() + ")");

		// Error
		mainLayout->addWidget(new QLabel("A fatal error has occurred!"));
		mainLayout->addWidget(textArea);

		// Report
		QLabel* text1 = new QLabel("Please report the error on the Mine-imator forums along with the log file contents and instructions how to recreate the error message. If the issue occurs with a certain project file, please upload the project folder as well and include a link to it in your topic.");
		text1->setWordWrap(true);
		mainLayout->addWidget(text1);
		QLayout* buttonLayout = new QHBoxLayout;
		QPushButton* button1 = new QPushButton("View log");
		QPushButton* button2 = new QPushButton("Visit forums");
		QPushButton* button3 = new QPushButton("Upload project");
		button1->setFixedHeight(50);
		button2->setFixedHeight(50);
		button3->setFixedHeight(50);
		button1->connect(button1, &QPushButton::released, [&]() { QDesktopServices::openUrl((QString)log_file); });
		button2->connect(button2, &QPushButton::released, [&]() { QDesktopServices::openUrl((QString)link_forums_bugs); });
		button3->connect(button3, &QPushButton::released, [&]() { QDesktopServices::openUrl((QString)link_forums_upload); });
		buttonLayout->addWidget(button1);
		buttonLayout->addWidget(button2);
		buttonLayout->addWidget(button3);
		mainLayout->addLayout(buttonLayout);

		QLabel* text2 = new QLabel("Unsaved work will be lost, however backups may be available in the project folder depending on your settings.");
		text2->setWordWrap(true);
		mainLayout->addWidget(text2);

		// Restart
		QPushButton* button4 = new QPushButton("Restart"); 
		button4->connect(button4, &QPushButton::released, [&]() { QDesktopServices::openUrl(QUrl("Mine-imator.exe")); QDialog::close(); });
		button4->setFixedSize(80, 30);
		mainLayout->addWidget(button4);
		mainLayout->setAlignment(button4, Qt::AlignHCenter);
		QDialog::setLayout(mainLayout);

		QDialog::exec();
	}
}