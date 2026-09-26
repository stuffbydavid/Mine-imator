#include "Generated/Scripts.hpp"

#include "Asset/Sound.hpp"
#include "Asset/Surface.hpp"
#include "AppHandler.hpp"

#include <limits>
#include <QRunnable>
#include <QThreadPool>

extern "C"
{
	#include <libavutil/channel_layout.h>
	#include <libavutil/opt.h>
	#include <libavutil/mathematics.h>
	#include <libavcodec/avcodec.h>
	#include <libavformat/avformat.h>
	#include <libswscale/swscale.h>
	#include <libswresample/swresample.h>
}

#define INPUT_PIXEL_FORMAT					AV_PIX_FMT_RGBA
#define STREAM_VIDEO_PIXEL_FORMAT			AV_PIX_FMT_YUV420P

#define STREAM_AUDIO_BIT_RATE				320000
#define STREAM_AUDIO_SAMPLE_RATE			44100
#define STREAM_AUDIO_FRAME_SIZE				1152
#define STREAM_AUDIO_SAMPLE_FORMAT			AV_SAMPLE_FMT_S16
#define STREAM_AUDIO_SAMPLE_FORMAT_MOVIE	AV_SAMPLE_FMT_FLTP
#define STREAM_AUDIO_CHANNEL_LAYOUT			AV_CH_LAYOUT_STEREO
#define STREAM_AUDIO_CHANNELS				2

namespace CppProject
{
	// Media file output
	AVFormatContext* outContext;

	// Video
	IntType videoWidth, videoHeight, videoBitRate, videoFrameRate;
	AVStream* videoStream;
	AVCodecContext* videoCodecContext;
	IntType videoFrameNum;
	SwsContext* videoSwsContext;
	uchar* videoFrameData = nullptr;

	// Audio
	BoolType audioEnabled;
	AVStream* audioStream;
	AVCodec* audioCodec;
	AVCodecContext* audioCodecContext;
	AVRational audioTimeBase;
	IntType audioFrameNum;

	// Movie sound
	struct MovieSound
	{
		Sound* sound;
		IntType frame, start, end;
		RealType volume, pitch;
	};
	QVector<MovieSound*> movieSounds;

	RealType lib_movie_init()
	{
		// Do nothing
		return 0;
	}

	RealType lib_movie_audio_file_decode(StringType, StringType)
	{
		// Unused
		return 0;
	}

	// Decode audio without accessing application state
	static void DecodeSound(QString filename, SoundDecodeData& decoded)
	{
		AVFormatContext* formatContext = nullptr;
		const AVCodec* codec = nullptr;
		AVCodecContext* codecContext = nullptr;
		SwrContext* swrContext = nullptr;
		AVFrame* decodedFrame = nullptr;
		uint8_t* convertedData = nullptr;
		AVPacket* inPacket = nullptr;

		BoolType success = false;
		try
		{
			std::string filenameStd = filename.toStdString();

			// Get format from audio file
			formatContext = avformat_alloc_context();
			if (avformat_open_input(&formatContext, filenameStd.c_str(), nullptr, nullptr) != 0)
				throw "avformat_open_input failed";

			if (avformat_find_stream_info(formatContext, nullptr) < 0)
				throw "avformat_find_stream_info failed";

			codecContext = avcodec_alloc_context3(nullptr);
			IntType streamIndex = -1;
			for (IntType i = 0; i < formatContext->nb_streams; i++)
			{
				AVCodecParameters* par = formatContext->streams[i]->codecpar;
				if (par->codec_type == AVMEDIA_TYPE_AUDIO)
				{
					codec = avcodec_find_decoder(par->codec_id);
					if (!codec)
						throw "avcodec_find_decoder failed";
					if (avcodec_parameters_to_context(codecContext, par) < 0)
						throw "avcodec_parameters_to_context failed";
					streamIndex = i;
					break;
				}
			}

			if (!codec)
				throw "No codec found";

			// Reserve decoded PCM from the input duration
			AVStream* inputStream = formatContext->streams[streamIndex];
			AVRational outputTimeBase = { 1, STREAM_AUDIO_SAMPLE_RATE };
			AVRational timeBase = { 1, AV_TIME_BASE };
			IntType duration = 0;
			if (inputStream->duration != AV_NOPTS_VALUE)
				duration = av_rescale_q(inputStream->duration, inputStream->time_base, outputTimeBase);
			else if (formatContext->duration != AV_NOPTS_VALUE)
				duration = av_rescale_q(formatContext->duration, timeBase, outputTimeBase);

			IntType bytesPerSample = STREAM_AUDIO_CHANNELS * sizeof(int16_t);
			if (duration > 0 && duration <= std::numeric_limits<int>::max() / bytesPerSample)
				decoded.pcm.reserve((int)(duration * bytesPerSample));

			IntType peakSize = STREAM_AUDIO_SAMPLE_RATE / sample_avg_per_sec;
			if (duration > 0)
			{
				IntType peakCapacity = duration / peakSize + 1;
				decoded.waveformMax.reserve((int)peakCapacity);
				decoded.waveformMin.reserve((int)peakCapacity);
			}
			IntType peakSamples = 0;
			int16_t peakMax = 0, peakMin = 0;

			// Open codec of the audio file
			if (avcodec_open2(codecContext, codec, nullptr) < 0)
				throw "avcodec_open2 failed";

			// Prepare resampling
			swrContext = swr_alloc();
			if (!swrContext)
				throw "swr_alloc failed";

			av_opt_set_chlayout(swrContext, "in_chlayout", &codecContext->ch_layout, 0);
			av_opt_set_int(swrContext, "in_sample_rate", codecContext->sample_rate, 0);
			av_opt_set_sample_fmt(swrContext, "in_sample_fmt", codecContext->sample_fmt, 0);

			av_opt_set_int(swrContext, "out_channel_count", STREAM_AUDIO_CHANNELS, 0);
			av_opt_set_int(swrContext, "out_channel_layout", STREAM_AUDIO_CHANNEL_LAYOUT, 0);
			av_opt_set_int(swrContext, "out_sample_rate", STREAM_AUDIO_SAMPLE_RATE, 0);
			av_opt_set_sample_fmt(swrContext, "out_sample_fmt", STREAM_AUDIO_SAMPLE_FORMAT, 0);

			if (swr_init(swrContext))
				throw "swr_init failed";

			// Create packet
			inPacket = av_packet_alloc();
			if (!inPacket)
				throw "av_packet_alloc failed";

			// Prepare to read data
			decodedFrame = av_frame_alloc();
			if (!decodedFrame)
				throw "av_packet_alloc failed";

			IntType convertedCapacity = 0;
			auto allocateConverted = [&](IntType capacity)
			{
				if (capacity <= convertedCapacity)
					return;

				av_freep(&convertedData);
				if (av_samples_alloc(&convertedData, nullptr, STREAM_AUDIO_CHANNELS, capacity, STREAM_AUDIO_SAMPLE_FORMAT, 1) < 0)
					throw "av_samples_alloc failed";
				convertedCapacity = capacity;
			};

			auto writeConverted = [&](IntType outSamples)
			{
				if (outSamples <= 0)
					return;

				IntType bufferSize = av_samples_get_buffer_size(nullptr, STREAM_AUDIO_CHANNELS, outSamples, STREAM_AUDIO_SAMPLE_FORMAT, 1);
				if (bufferSize < 0)
					throw "av_samples_get_buffer_size failed";

				const int16_t* data = (const int16_t*)convertedData;
				for (IntType sample = 0; sample < outSamples; sample++)
				{
					int16_t channel1 = data[sample * STREAM_AUDIO_CHANNELS];
					int16_t channel2 = data[sample * STREAM_AUDIO_CHANNELS + 1];
					peakMax = std::max(peakMax, std::max(channel1, channel2));
					peakMin = std::min(peakMin, std::min(channel1, channel2));
					if (++peakSamples == peakSize)
					{
						decoded.waveformMax.append((RealType)peakMax / sample_max);
						decoded.waveformMin.append((RealType)peakMin / sample_max);
						peakSamples = 0;
						peakMax = 0;
						peakMin = 0;
					}
				}

				decoded.pcm.append((const char*)convertedData, (int)bufferSize);
				decoded.samples += outSamples;
			};

			auto convertFrame = [&]()
			{
				IntType outCapacity = av_rescale_rnd(
					swr_get_delay(swrContext, codecContext->sample_rate) + decodedFrame->nb_samples,
					STREAM_AUDIO_SAMPLE_RATE,
					codecContext->sample_rate,
					AV_ROUND_UP
				);
				if (outCapacity <= 0)
					return;

				allocateConverted(outCapacity);

				IntType outSamples = swr_convert(swrContext, &convertedData, outCapacity, (const uint8_t**)decodedFrame->extended_data, decodedFrame->nb_samples);
				if (outSamples < 0)
					throw "swr_convert failed";
				writeConverted(outSamples);
			};

			auto receiveFrames = [&]()
			{
				while (true)
				{
					IntType result = avcodec_receive_frame(codecContext, decodedFrame);
					if (result == AVERROR(EAGAIN) || result == AVERROR_EOF)
						break;
					if (result < 0)
						throw "avcodec_receive_frame failed";

					try
					{
						convertFrame();
					}
					catch (...)
					{
						av_frame_unref(decodedFrame);
						throw;
					}
					av_frame_unref(decodedFrame);
				}
			};

			// Read and decode audio packets
			while (av_read_frame(formatContext, inPacket) >= 0)
			{
				if (inPacket->stream_index != streamIndex)
				{
					av_packet_unref(inPacket);
					continue;
				}

				IntType result = avcodec_send_packet(codecContext, inPacket);
				if (result == AVERROR(EAGAIN))
				{
					receiveFrames();
					result = avcodec_send_packet(codecContext, inPacket);
				}
				av_packet_unref(inPacket);
				if (result < 0)
					throw "avcodec_send_packet failed";

				receiveFrames();
			}

			// Flush decoder
			IntType result = avcodec_send_packet(codecContext, nullptr);
			if (result == AVERROR(EAGAIN))
			{
				receiveFrames();
				result = avcodec_send_packet(codecContext, nullptr);
			}
			if (result < 0 && result != AVERROR_EOF)
				throw "avcodec_send_packet flush failed";
			receiveFrames();

			// Drain delayed resampler samples
			while (true)
			{
				IntType outCapacity = av_rescale_rnd(
					swr_get_delay(swrContext, codecContext->sample_rate),
					STREAM_AUDIO_SAMPLE_RATE,
					codecContext->sample_rate,
					AV_ROUND_UP
				);
				if (outCapacity <= 0)
					break;

				allocateConverted(outCapacity);

				IntType outSamples = swr_convert(swrContext, &convertedData, outCapacity, nullptr, 0);
				if (outSamples == 0)
					break;
				if (outSamples < 0)
					throw "swr_convert failed";
				writeConverted(outSamples);
			}

			// Add the partial final waveform peak
			decoded.waveformMax.append(peakSamples ? (RealType)peakMax / sample_max : 0);
			decoded.waveformMin.append(peakSamples ? (RealType)peakMin / sample_max : 0);
			success = true;
		}
		catch (const char* err)
		{
			decoded.error = err;
			decoded.samples = 0;
			decoded.pcm.clear();
			decoded.waveformMax.clear();
			decoded.waveformMin.clear();
		}

		// Cleanup
		if (decodedFrame)
			av_frame_free(&decodedFrame);
		if (swrContext)
			swr_free(&swrContext);
		if (codecContext)
			avcodec_free_context(&codecContext);
		if (formatContext)
			avformat_close_input(&formatContext);
		if (convertedData)
			av_freep(&convertedData);
		if (inPacket)
			av_packet_free(&inPacket);

		decoded.success = success;
	}

	QVector<Sound*> Sound::loadingSounds;

	// Limit concurrent audio decode jobs
	static QThreadPool& SoundDecodePool()
	{
		static QThreadPool pool;
		static BoolType initialized = false;
		if (!initialized)
		{
			pool.setMaxThreadCount(2);
			initialized = true;
		}
		return pool;
	}

	struct SoundDecodeTask : QRunnable
	{
		SoundDecodeTask(QString filename, QString tempFilename, std::shared_ptr<SoundDecodeData> data) : filename(filename), tempFilename(tempFilename), data(data)
		{
		}

		void run() override
		{
			// Decode result outside the main thread
			DecodeSound(filename, *data);

			// Delete temporary source after decode
			if (!tempFilename.isEmpty())
				QFile::remove(tempFilename);

			data->complete.store(true, std::memory_order_release);
		}

		QString filename;
		QString tempFilename;
		std::shared_ptr<SoundDecodeData> data;
	};

	Sound::Sound() : Asset(ID_Sound)
	{
	}

	void Sound::LoadAsync(QString filename, IntType resourceId, QString tempFilename)
	{
		// Keep decoding data alive if the sound is destroyed
		this->resourceId = resourceId;
		decode = std::make_shared<SoundDecodeData>();
		loadingSounds.append(this);

		SoundDecodePool().start(new SoundDecodeTask(filename, tempFilename, decode));
	}

	BoolType Sound::IsReady() const
	{
		// Read state without accessing worker data
		return ready.load(std::memory_order_acquire);
	}

	void Sound::UpdateLoads()
	{
		// Publish completed worker jobs on the main thread
		for (IntType i = loadingSounds.size() - 1; i >= 0; i--)
		{
			Sound* sound = loadingSounds[i];
			std::shared_ptr<SoundDecodeData> data = sound->decode;
			if (!data || !data->complete.load(std::memory_order_acquire))
				continue;

			obj_resource* res = ObjTypeOpt(obj_resource, sound->resourceId);

			// Drop cancelled or failed loads
			if (!res || res->sound_index != sound->id || !data->success || data->pcm.isEmpty())
			{
				if (res && res->sound_index == sound->id)
				{
					res->sound_index = null_;
					res->sound_samples = 0;
					error("errorloadaudio");
				}

				auto sounds = SoundInstance::sounds;
				for (SoundInstance* instance : sounds)
					if (instance->sound == sound)
						delete instance;

				delete sound;
				continue;
			}

			// Transfer decoded data to the main thread's sound
			sound->pcm = std::move(data->pcm);
			sound->samples = data->samples;
			sound->waveform_max.vec.Alloc(data->waveformMax.size());
			sound->waveform_min.vec.Alloc(data->waveformMin.size());
			for (RealType sample : data->waveformMax)
				sound->waveform_max.Append(sample);
			for (RealType sample : data->waveformMin)
				sound->waveform_min.Append(sample);

			if (App->audioSupported)
			{
				// Upload PCM using the main thread OpenAL context
				alGenBuffers(1, &sound->alBuffer);
				alBufferData(sound->alBuffer, AL_FORMAT_STEREO16, sound->pcm.constData(), sound->pcm.size(), sample_rate_);
			}

			// Publish complete waveform data to the resource
			res->sound_samples = sound->samples;
			res->sound_max_sample = sound->waveform_max;
			res->sound_min_sample = sound->waveform_min;
			sound->ready.store(true, std::memory_order_release);
			res->ready = true;
			res->load_stage = "";
			sound->decode.reset();
			loadingSounds.removeAt(i);

			// Start playback requested while decoding
			SoundInstance::StartPending(sound);
			tl_update_length();
		}
	}

	Sound::~Sound()
	{
		loadingSounds.removeOne(this);
		if (alBuffer)
			alDeleteBuffers(1, &alBuffer);
	}

	RealType lib_movie_set(RealType width, RealType height, RealType bitRate, RealType frameRate, RealType audio)
	{
		videoWidth = width;
		videoHeight = height;
		videoBitRate = bitRate;
		videoFrameRate = frameRate;
		audioEnabled = audio > 0.0;
		return 0;
	}

	RealType lib_movie_start(StringType outFile, StringType outFormat)
	{
		std::string outFileStd = outFile.ToStdString();
		std::string outFormatStd = outFormat.ToStdString();
		
		try
		{
			// Find format
			const AVOutputFormat* outFmt = av_guess_format(outFormatStd.c_str(), 0, 0);
			if (!outFmt)
				throw "av_guess_format failed";

			// Allocate the output media context
			avformat_alloc_output_context2(&outContext, outFmt, 0, 0);
			if (!outContext)
				throw "avformat_alloc_output_context2 failed";

			// Find video encoder
			const AVCodec* videoCodec = avcodec_find_encoder(outContext->oformat->video_codec);
			if (!videoCodec)
				throw "avcodec_find_encoder failed";

			DEBUG("Encoder: " + QString(videoCodec->long_name));

			// Start video stream
			videoStream = avformat_new_stream(outContext, videoCodec);
			if (!videoStream)
				throw "avformat_new_stream failed";

			videoStream->id = 0;
			videoStream->codecpar->width = videoWidth;
			videoStream->codecpar->height = videoHeight;
			videoStream->codecpar->codec_id = videoCodec->id;
			videoStream->codecpar->codec_type = videoCodec->type;
			videoStream->avg_frame_rate = { (int)videoFrameRate, 1 };
			
			// Setup context
			videoCodecContext = avcodec_alloc_context3(videoCodec);
			videoCodecContext->bit_rate = videoBitRate * 5;
			videoCodecContext->width = videoWidth;
			videoCodecContext->height = videoHeight;
			videoCodecContext->time_base = { 1, (int)videoFrameRate };
			videoCodecContext->framerate = { (int)videoFrameRate, 1 };
			videoCodecContext->pix_fmt = STREAM_VIDEO_PIXEL_FORMAT;
			videoCodecContext->gop_size = 12;
			if (outContext->oformat->flags & AVFMT_GLOBALHEADER)
				videoCodecContext->flags |= AV_CODEC_FLAG_GLOBAL_HEADER;

			// Open the codec
			AVDictionary* opt = NULL;
			av_dict_set(&opt, "tune", "zerolatency", 0);
			if (avcodec_open2(videoCodecContext, videoCodec, &opt) < 0)
				throw "avcodec_open2 failed";

			videoFrameNum = 0;
			avcodec_parameters_from_context(videoStream->codecpar, videoCodecContext);

			// Scaling context
			videoSwsContext = sws_getContext(videoWidth, videoHeight, INPUT_PIXEL_FORMAT,
											 videoWidth, videoHeight, STREAM_VIDEO_PIXEL_FORMAT,
											 SWS_BILINEAR, nullptr, nullptr, nullptr);
			if (!videoSwsContext)
				throw "sws_getContext failed";

			deleteArrayAndReset(videoFrameData);
			videoFrameData = new uchar[videoWidth * videoHeight * 4];

			if (audioEnabled)
			{
				// Find audio encoder
				const AVCodec* audioCodec = avcodec_find_encoder(outContext->oformat->audio_codec);
				if (!audioCodec)
					throw "avcodec_find_encoder failed";

				// Start audio stream
				audioStream = avformat_new_stream(outContext, audioCodec);
				if (!audioStream)
					throw "avformat_new_stream failed";
				audioStream->id = 1;
				audioStream->codecpar->sample_rate = STREAM_AUDIO_SAMPLE_RATE;
				audioStream->codecpar->frame_size = STREAM_AUDIO_FRAME_SIZE;
				audioStream->codecpar->codec_id = audioCodec->id;
				audioStream->codecpar->codec_type = audioCodec->type;

				// Setup context
				audioCodecContext = avcodec_alloc_context3(audioCodec);
				audioCodecContext->sample_fmt = STREAM_AUDIO_SAMPLE_FORMAT_MOVIE;
				audioCodecContext->sample_rate = STREAM_AUDIO_SAMPLE_RATE;
				audioCodecContext->bit_rate = STREAM_AUDIO_BIT_RATE;
				av_channel_layout_default(&audioCodecContext->ch_layout, STREAM_AUDIO_CHANNELS);
				if (outContext->oformat->flags & AVFMT_GLOBALHEADER)
					audioCodecContext->flags |= AV_CODEC_FLAG_GLOBAL_HEADER;

				// Open the codec
				if (avcodec_open2(audioCodecContext, audioCodec, nullptr) < 0)
					throw "avcodec_open2 failed";

				audioFrameNum = 0;
				audioTimeBase = { audioCodecContext->frame_size, STREAM_AUDIO_SAMPLE_RATE };
				avcodec_parameters_from_context(audioStream->codecpar, audioCodecContext);
			}

			// Open the output file
			if (avio_open(&outContext->pb, outFileStd.c_str(), AVIO_FLAG_WRITE) < 0)
				throw "avio_open failed";

			// Write the stream header, if any
			if (avformat_write_header(outContext, nullptr) < 0)
				throw "avformat_write_header failed";

			return 0;
		}
		catch (const char* err)
		{
			log({ err });
			WARNING(err);
			return -1;
		}
	}

	RealType lib_movie_audio_file_add(StringType)
	{
		if (Sound* sound = FindSound(global::_app->exportmovie_current_sound))
			return sound->id;

		return -1;
	}

	RealType lib_movie_audio_sound_add(RealType id, RealType time, RealType volume, RealType pitch, RealType start, RealType end)
	{
		if (!audioEnabled)
			return 0.0;

		movieSounds.append(
			new MovieSound({
				FindSound(id),
				av_rescale_q(time * 1000, { 1, 1000 }, audioTimeBase),
				av_rescale_q(start * 1000, { 1, 1000 }, audioTimeBase),
				av_rescale_q(end * 1000, { 1, 1000 }, audioTimeBase),
				volume,
				pitch
			})
		);
		return 0.0;
	}

	void Encode(AVCodecContext* context, AVFrame* frame, AVStream* stream)
	{
		AVPacket* packet = av_packet_alloc();
		if (!packet)
			throw "av_packet_alloc failed";

		// Send in a frame, a nullptr will enable flush mode
		if (avcodec_send_frame(context, frame) < 0)
			throw "avcodec_send_frame failed";

		// Encode a submitted video or audio frame to the stream
		while (true)
		{
			switch (avcodec_receive_packet(context, packet))
			{
				case 0:
				{
					av_packet_rescale_ts(packet, context->time_base, stream->time_base);
					packet->stream_index = stream->index;

					if (av_interleaved_write_frame(outContext, packet) < 0)
						throw "av_interleaved_write_frame failed";
					break;
				}
				case AVERROR(EAGAIN):
				case AVERROR_EOF:
					av_packet_free(&packet);
					return;

				default:
					throw "avcodec_receive_packet failed";
			}
		}

		av_packet_free(&packet);
	}

	RealType lib_movie_frame(StringType)
	{
		try
		{
			// Allocate and init frame
			AVFrame* videoFrame = av_frame_alloc();
			if (!videoFrame)
				throw "av_frame_alloc failed";

			videoFrame->pts = videoFrameNum++;
			videoFrame->format = videoCodecContext->pix_fmt;
			videoFrame->width = videoCodecContext->width;
			videoFrame->height = videoCodecContext->height;

			if (av_frame_get_buffer(videoFrame, 0) < 0)
				throw "av_frame_get_buffer failed";

			// Convert surface into frame
			FindSurface(global::_app->export_surface)->frameBuffer->CopyColorData(videoFrameData);
			uint8_t* inData[1] = { videoFrameData }; // RGBA have one plane
			int inLinesize[1] = { 4 * (int)videoWidth }; // RGBA stride
			sws_scale(videoSwsContext, inData, inLinesize, 0, videoHeight, videoFrame->data, videoFrame->linesize);
			
			// Submit frame and encode
			Encode(videoCodecContext, videoFrame, videoStream);

			// Cleanup video
			av_frame_free(&videoFrame);

			// Write interleaved audio
			while (audioEnabled && av_compare_ts(videoFrameNum, videoCodecContext->time_base, audioFrameNum, audioTimeBase) > 0)
			{
				// Allocate frame
				AVFrame* audioFrame = av_frame_alloc();
				if (!audioFrame)
					throw "av_frame_alloc failed";

				audioFrame->nb_samples = audioCodecContext->frame_size;
				audioFrame->format = STREAM_AUDIO_SAMPLE_FORMAT_MOVIE;
				av_channel_layout_default(&audioFrame->ch_layout, STREAM_AUDIO_CHANNELS);
				audioFrame->sample_rate = STREAM_AUDIO_SAMPLE_RATE;

				if (av_frame_get_buffer(audioFrame, 0) < 0)
					throw "av_frame_get_buffer failed";

				if (av_frame_make_writable(audioFrame) < 0)
					throw "av_frame_make_writable failed";

				// Find sounds
				QVector<MovieSound*> frameSounds;
				for (MovieSound* sound : movieSounds)
					if (audioFrameNum >= sound->frame &&
						audioFrameNum < sound->frame + sound->sound->samples / audioCodecContext->frame_size / sound->pitch - sound->start + sound->end)
						frameSounds.append(sound);

				// Write to frame (mix sounds)
				for (IntType c = 0; c < 2; c++)
				{
					float* dstData = (float*)audioFrame->data[c];
					for (IntType s = 0; s < audioCodecContext->frame_size; s++)
					{
						float dstVal = 0.f; // 0 = silence

						for (MovieSound* sound : frameSounds)
						{
							const int16_t* srcData = (const int16_t*)sound->sound->pcm.constData();
							IntType srcSample = ((((audioFrameNum - sound->frame + sound->start) * audioCodecContext->frame_size) % (uint64_t)(sound->sound->samples / sound->pitch)) + s) * sound->pitch;

							// Add and clamp audio if in buffer range
							if (srcSample < sound->sound->samples)
							{
								float srcVal = (float)srcData[srcSample * 2 + c] / sample_max;
								dstVal = std::clamp(dstVal + srcVal * (float)sound->volume, -1.f, 1.f);
							}
						}

						dstData[s] = dstVal;
					}
				}

				audioFrame->pts = av_rescale_q(audioFrameNum++, audioTimeBase, audioCodecContext->time_base);

				// Submit frame and encode
				Encode(audioCodecContext, audioFrame, audioStream);

				// Cleanup audio
				av_frame_free(&audioFrame);
			}

			return 0;
		}
		catch (const char* err)
		{
			log({ err });
			WARNING(err);
			return -1;
		}
	}

	RealType lib_movie_done()
	{
		try
		{
			// Flush video & audio
			Encode(videoCodecContext, nullptr, videoStream);
			if (audioEnabled)
				Encode(audioCodecContext, nullptr, audioStream);

			// Write the trailer
			if (av_write_trailer(outContext) < 0)
				throw "av_write_trailer failed";

			// Close video
			sws_freeContext(videoSwsContext);
			avcodec_close(videoCodecContext);

			// Close audio
			if (audioEnabled)
			{
				avcodec_close(audioCodecContext);

				for (MovieSound* snd : movieSounds)
					delete snd;
				movieSounds.clear();
			}

			// Close the output file.
			if (avio_close(outContext->pb) < 0)
				throw "avio_close failed";

			// Free the stream
			avformat_free_context(outContext);

			deleteArrayAndReset(videoFrameData);

			return 0;
		}
		catch (const char* err)
		{
			log({ err });
			WARNING(err);
			return -1;
		}
	}

}
