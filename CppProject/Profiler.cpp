#include "Profiler.hpp"
#include <cmath>

namespace CppProject
{
	Profiler& Profiler::Get()
	{
		static Profiler profiler;
		return profiler;
	}

	const char* Profiler::StageName(Stage stage)
	{
		static const char* names[] = { "CPU frame work", "Application update", "Application draw", "Batch submission", "Presentation dispatch / resize", "Queued loading", "Maintenance", "Animation", "Scene rendering", "Surface requests" };
		return names[size_t(stage)];
	}

	Profiler::Scope::Scope(Stage stage) : stage(stage), generation(Get().BeginStage(stage)) {}
	Profiler::Scope::~Scope() { Get().EndStage(stage, generation); }
	Profiler::FrameScope::FrameScope(bool sampleFrame)
	{
		auto& profiler = Get();
		if (sampleFrame && profiler.Enabled())
		{
			profiler.BeginFrame();
			generation = profiler.generation;
		}
	}
	Profiler::FrameScope::~FrameScope() { Get().EndFrame(generation); }

	void Profiler::SetEnabled(bool value)
	{
		if (enabled == value)
			return;
		StopCapture();
		enabled = value;
		active = pending = false;
		depth.fill(0);
		generation++;
	}

	void Profiler::StartCapture(double seconds)
	{
		SetEnabled(true);
		StopCapture();
		capture.clear();
		capture.reserve(CaptureFrames);
		captureDuration = std::clamp(seconds, 1.0, 60.0);
		captureSeconds = 0;
		capturing = true;
	}

	void Profiler::StopCapture()
	{
		capturing = false;
		currentCapture = false;
	}

	void Profiler::BeginFrame()
	{
		auto now = Clock::now();
		if (pending)
		{
			// Finalize only when the full interval, including Qt's timer wait, is known
			current.intervalMs = std::chrono::duration<double, std::milli>(now - frameStart).count();
			Commit(current);
		}
		current = {};
		depth.fill(0);
		frameStart = now;
		owner = QThread::currentThread();
		active = true;
		pending = false;
		currentCapture = capturing;
		generation++;
		BeginStage(Stage::FrameWork);
	}

	void Profiler::EndFrame(uint64_t frameGeneration)
	{
		if (!active || !frameGeneration || frameGeneration != generation)
			return;
		EndStage(Stage::FrameWork, frameGeneration);
		active = false;
		pending = true;
	}

	uint64_t Profiler::BeginStage(Stage stage)
	{
		if (!enabled || !active || QThread::currentThread() != owner)
			return 0;
		size_t index = size_t(stage);
		if (depth[index]++ == 0)
			starts[index] = Clock::now();
		return generation;
	}

	void Profiler::EndStage(Stage stage, uint64_t scopeGeneration)
	{
		if (!active || !scopeGeneration || scopeGeneration != generation || QThread::currentThread() != owner)
			return;
		size_t index = size_t(stage);
		if (!depth[index])
			return;
		current.calls[index]++;
		if (--depth[index] == 0)
			current.milliseconds[index] += std::chrono::duration<double, std::milli>(Clock::now() - starts[index]).count();
	}

	void Profiler::Commit(const Sample& sample)
	{
		live[liveNext] = sample;
		liveNext = (liveNext + 1) % LiveFrames;
		liveCount = std::min(liveCount + 1, LiveFrames);
		if (capturing && currentCapture)
		{
			capture.push_back(sample);
			captureSeconds += sample.intervalMs / 1000.0;
			if (captureSeconds >= captureDuration || capture.size() >= CaptureFrames)
				StopCapture();
		}
	}

	Profiler::Summary Profiler::Summarize(bool captured) const
	{
		Summary summary;
		summary.frames = captured ? capture.size() : liveCount;
		if (!summary.frames)
			return summary;
		std::vector<double> intervals;
		intervals.reserve(summary.frames);
		for (size_t frame = 0; frame < summary.frames; frame++)
		{
			const auto& sample = captured ? capture[frame] : live[(liveNext + LiveFrames - liveCount + frame) % LiveFrames];
			intervals.push_back(sample.intervalMs);
			summary.meanMs += sample.intervalMs;
			for (size_t stage = 0; stage < StageCount; stage++)
			{
				auto& row = summary.stages[stage];
				row.meanMs += sample.milliseconds[stage];
				row.maxMs = std::max(row.maxMs, sample.milliseconds[stage]);
				row.callsPerFrame += sample.calls[stage];
			}
		}
		summary.meanMs /= summary.frames;
		for (auto& row : summary.stages)
		{
			row.meanMs /= summary.frames;
			row.callsPerFrame /= summary.frames;
		}
		std::sort(intervals.begin(), intervals.end());
		auto percentile = [&](double fraction) { return intervals[size_t(std::ceil(fraction * intervals.size())) - 1]; };
		summary.p50Ms = percentile(0.50);
		summary.p95Ms = percentile(0.95);
		summary.p99Ms = percentile(0.99);
		summary.maxMs = intervals.back();
		return summary;
	}

	QString Profiler::Report(const Summary& summary) const
	{
		QString report;
		QTextStream out(&report);
		out.setRealNumberNotation(QTextStream::FixedNotation);
		out.setRealNumberPrecision(3);
		out << "Mine-imator CPU profiler\nFrames: " << quint64(summary.frames)
			<< "\nFrame interval mean: " << summary.meanMs << " ms\nP50 / P95 / P99 / max: "
			<< summary.p50Ms << " / " << summary.p95Ms << " / " << summary.p99Ms << " / " << summary.maxMs << " ms\n"
			<< "Stage (inclusive)\tMean ms\tMax ms\tCalls/frame\n";
		for (size_t stage = 0; stage < StageCount; stage++)
		{
			const auto& row = summary.stages[stage];
			out << StageName(Stage(stage)) << '\t' << row.meanMs << '\t' << row.maxMs << '\t' << row.callsPerFrame << '\n';
		}
		out << "Frame interval includes scheduling and waits; CPU frame work excludes the timer wait.\n"
			<< "Stage times are inclusive and overlap. These are CPU wall times, not GPU timings.\n"
			<< "OpenGL widget painting normally happens later, outside the measured callback work.\n"
			<< "Loading-only callbacks are not sampled.\n";
		return report;
	}

	QString Profiler::Csv(bool captured) const
	{
		QString csv;
		QTextStream out(&csv);
		out.setRealNumberNotation(QTextStream::FixedNotation);
		out.setRealNumberPrecision(6);
		out << "frame,interval_ms";
		for (size_t stage = 0; stage < StageCount; stage++)
			out << ',' << StageName(Stage(stage)) << " ms," << StageName(Stage(stage)) << " calls";
		out << '\n';
		size_t count = captured ? capture.size() : liveCount;
		for (size_t frame = 0; frame < count; frame++)
		{
			const auto& sample = captured ? capture[frame] : live[(liveNext + LiveFrames - liveCount + frame) % LiveFrames];
			out << quint64(frame + 1) << ',' << sample.intervalMs;
			for (size_t stage = 0; stage < StageCount; stage++)
				out << ',' << sample.milliseconds[stage] << ',' << sample.calls[stage];
			out << '\n';
		}
		return csv;
	}
}
