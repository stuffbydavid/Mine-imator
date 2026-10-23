#include "Generated/Scripts.hpp"
#include "AppHandler.hpp"
#include "AppWindow.hpp"
#include "Profiler.hpp"
#include "ProfilerWindow.hpp"

namespace CppProject
{
	void debug_profiler_show()
	{
		if (!App->headless)
			ProfilerWindow::Show(App->mainWindow);
	}

	IntType debug_profiler_begin(StringType name)
	{
		auto& profiler = Profiler::Get();
		if (!profiler.Enabled())
			return 0;
		QString label = name;
		for (size_t stage = 0; stage < Profiler::StageCount; stage++)
			if (label == Profiler::StageName(Profiler::Stage(stage)))
				return profiler.BeginStage(Profiler::Stage(stage));
		return 0;
	}

	void debug_profiler_end(StringType name, IntType generation)
	{
		if (!generation)
			return;
		QString label = name;
		for (size_t stage = 0; stage < Profiler::StageCount; stage++)
			if (label == Profiler::StageName(Profiler::Stage(stage)))
			{
				Profiler::Get().EndStage(Profiler::Stage(stage), generation);
				return;
			}
	}
}
