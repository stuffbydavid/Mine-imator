#pragma once
#include <algorithm>
#include <chrono>
#include <functional>
#include <initializer_list>
#include <iostream>
#include <omp.h>
#include <random>

#include <QApplication>
#include <QColor>
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QHash>
#include <QImage>
#include <QMap>
#include <QPoint>
#include <QRegularExpression>
#include <QSize>
#include <QStack>
#include <QString>
#include <QtMath>
#include <QTextStream>
#include <QThread>
#include <QTransform>
#include <QVector>

#define AL_LIBTYPE_STATIC
#include <AL/al.h>
#include <AL/alc.h>

using std::function;

#define DEBUG(line) Printer::Line(line)
#define WARNING(line) Printer::Warning(QString(line) + " in " + QString(__FUNCTION__) + ":" + NumStr(__LINE__))
#define FATAL(line) Printer::Fatal(QString(line) + "\nin " + QString(__FUNCTION__) + ":" + NumStr(__LINE__))
#define CAST_BITS(type, bits) *(type*)&bits
#define STR(id) StringType(IntType(id))

#define deleteAndReset(x) { if (x) delete x; x = nullptr; }
#define deleteArrayAndReset(x) { if (x) delete[] x; x = nullptr; }
#define releaseAndReset(x) { if (x) x->Release(); x = nullptr; }

typedef double RealType;
typedef int64_t IntType;
typedef bool BoolType;

// Pick graphics API
#ifdef OS_WINDOWS
#define API_D3D11 1
#define API_OPENGL 0
#else
#define API_D3D11 0
#define API_OPENGL 1
#endif

#if API_OPENGL
#include <QOpenGLBuffer>
#include <QOpenGLContext>
#endif

#define OPENMP_FOR omp parallel for schedule(dynamic)
#define OPENMP_MAX_THREADS 32

#define DEGTORAD 0.0174533
#define RADTODEG 57.2957958

namespace CppProject
{
	// Data type
#define TYPE_OPTIMIZED !DEBUG_MODE
#if TYPE_OPTIMIZED
	typedef char Type;

	#define UNDEFINED_t 0
	#define REAL_t 1
	#define REAL_REF_t 2
	#define INTEGER_t 3
	#define BOOLEAN_t 4
	#define STRING_t 5
	#define VECTOR_t 6
	#define MATRIX_t 7
	#define MATRIX_REF_t 8
	#define ARRAY_t 9
	#define ARRAY_REF_t 10
	#define VARIANT_t 11
	#define VARIANT_REF_t 12
#else
	enum Type
	{
		UNDEFINED_t = 0,
		REAL_t = 1,
		REAL_REF_t = 2,
		INTEGER_t = 3,
		BOOLEAN_t = 4,
		STRING_t = 5,
		VECTOR_t = 6,
		MATRIX_t = 7,
		MATRIX_REF_t = 8,
		ARRAY_t = 9,
		ARRAY_REF_t = 10,
		VARIANT_t = 11,
		VARIANT_REF_t = 12
	};
#endif

	inline void AddPerms(QFile& file)
	{
		file.setPermissions(file.permissions() |
			QFile::WriteOwner | QFile::WriteUser | QFile::WriteGroup | QFile::WriteOther |
			QFile::ReadOwner | QFile::ReadUser | QFile::ReadGroup | QFile::ReadOther);
	}

	inline QString NumStr(RealType num, IntType prec = 8)
	{
		QString str;
		str.setNum(num, 'f', prec);
		while (str.back() == '0')
			str.chop(1);
		if (str.back() == '.')
			str.chop(1);
		return str;
	}

	inline RealType mod(RealType a, RealType b)
	{
		return fmod(a, b);
	}

	inline QString TypeName(Type type)
	{
		switch (type)
		{
			case UNDEFINED_t: return "Undefined";
			case REAL_t: return "Real";
			case REAL_REF_t: return "Real&";
			case INTEGER_t: return "Integer";
			case BOOLEAN_t: return "Boolean";
			case STRING_t: return "String";
			case VECTOR_t: return "Vector";
			case MATRIX_t: return "Matrix";
			case MATRIX_REF_t: return "Matrix&";
			case ARRAY_t: return "Array";
			case ARRAY_REF_t: return "Array&";
			case VARIANT_t: return "Variant";
			case VARIANT_REF_t: return "Variant&";
		}
		return "";
	}

	// Log file & console printer
	struct Printer
	{
		static void Line(QString text);
		static void Warning(QString text);
		static void Fatal(QString text);

		static IntType indent;
	};

	// Timer for benchmarking.
	struct Timer
	{
		Timer() { Reset(); }

		// Resets the timer.
		void Reset()
		{
			start = std::chrono::high_resolution_clock::now();
		}

		// Returns the total elapsed time in seconds.
		double Elapsed() const
		{
			return std::chrono::duration_cast<std::chrono::duration<double, std::ratio<1>>>(std::chrono::high_resolution_clock::now() - start).count();
		}

		// Returns the total elapsed time in milliseconds.
		double ElapsedMs() const
		{
			return Elapsed() * 1000.0;
		}

		// Prints the total elapsed time in seconds along with a prefix.
		void Print(QString prefix)
		{
			DEBUG(prefix + ": " + NumStr(Elapsed()) + "s");
		}

		std::chrono::time_point<std::chrono::high_resolution_clock> start;
	};

	// Random number generator
	struct Random
	{
		struct ThreadData
		{
			IntType seed = 1;
			std::mt19937 gen;
			std::uniform_real_distribution<RealType> dist = std::uniform_real_distribution<RealType>(0.0, 1.0);
		};
		static ThreadData threadData[OPENMP_MAX_THREADS];

		// Returns a random number between 0 and max (exclusive).
		static RealType Get(RealType max = 1.0);

		// Sets the seed of the random number generator.
		static void Set(IntType seed);

		// Returns the current random seed.
		static uint16_t GetSeed();
	};

	// UV rectangle on a texture
	struct UvRect
	{
		RealType x, y, w, h;
	};
}
