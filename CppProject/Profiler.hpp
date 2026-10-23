#pragma once
#include "Common.hpp"
#include <array>
#include <cstdint>
#include <vector>

namespace CppProject
{
	// GUI-thread only CPU wall times, not asynchronous GPU execution times
	struct Profiler
	{
		enum class Stage { FrameWork, Update, Draw, Submit, Present, Loading, Maintenance, Animation, SceneRender, Surface, Count };
		static constexpr size_t StageCount = size_t(Stage::Count);
		static constexpr size_t LiveFrames = 240;
		static constexpr size_t CaptureFrames = 20000;
		using Clock = std::chrono::steady_clock;

		struct Sample
		{
			double intervalMs = 0;
			std::array<double, StageCount> milliseconds = {};
			std::array<unsigned, StageCount> calls = {};
		};
		struct StageSummary
		{
			double meanMs = 0, maxMs = 0, callsPerFrame = 0;
		};
		struct Summary
		{
			size_t frames = 0;
			double meanMs = 0, p50Ms = 0, p95Ms = 0, p99Ms = 0, maxMs = 0;
			std::array<StageSummary, StageCount> stages = {};
		};

		struct Scope
		{
			explicit Scope(Stage stage);
			~Scope();
			Scope(const Scope&) = delete;
			Scope& operator=(const Scope&) = delete;
		private:
			Stage stage;
			uint64_t generation = 0;
		};
		struct FrameScope
		{
			explicit FrameScope(bool sampleFrame);
			~FrameScope();
			FrameScope(const FrameScope&) = delete;
			FrameScope& operator=(const FrameScope&) = delete;
		private:
			uint64_t generation = 0;
		};

		static Profiler& Get();
		static const char* StageName(Stage stage);
		bool Enabled() const { return enabled; }
		void SetEnabled(bool value);
		void StartCapture(double seconds = 10);
		void StopCapture();
		bool Capturing() const { return capturing; }
		size_t CapturedFrames() const { return capture.size(); }
		double CaptureSeconds() const { return captureSeconds; }
		Summary Summarize(bool captured) const;
		QString Report(const Summary& summary) const;
		QString Csv(bool captured) const;
		uint64_t BeginStage(Stage stage);
		void EndStage(Stage stage, uint64_t scopeGeneration);

	private:
		void BeginFrame();
		void EndFrame(uint64_t frameGeneration);
		void Commit(const Sample& sample);

		bool enabled = false, active = false, pending = false, capturing = false;
		bool currentCapture = false;
		uint64_t generation = 0;
		QThread* owner = nullptr;
		Clock::time_point frameStart;
		Sample current;
		std::array<unsigned, StageCount> depth = {};
		std::array<Clock::time_point, StageCount> starts;
		std::array<Sample, LiveFrames> live;
		size_t liveCount = 0, liveNext = 0;
		std::vector<Sample> capture;
		double captureDuration = 10, captureSeconds = 0;
	};
}
