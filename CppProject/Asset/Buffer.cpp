#include "Buffer.hpp"

#include "Generated/GmlFunc.hpp"

namespace CppProject
{
	Buffer::Buffer(StringType filename) : Asset(ID_Buffer)
	{
		QFile readFile(filename);
		if (readFile.open(QFile::ReadOnly))
			data = readFile.readAll();
	}

	Buffer::Buffer(IntType size, BoolType grow, IntType align) : Asset(ID_Buffer)
	{
		data.Alloc(size);
		this->grow = grow;
		this->align = align;
	}

	BoolType Buffer::WriteVar(int type, VarType var, IntType& pos)
	{
		if (pos % align != 0)
			pos = (std::ceil((RealType)pos / align)) * align;

		IntType dataSize = GetDataSize(type);
		if (pos > data.Size() - dataSize) // Not enough space
		{
			if (grow)
				data.Alloc(pos + dataSize);
			else
				return false;
		}

		// Write bytes
		switch (type)
		{
			case buffer_u8:
			{
				CAST_BITS(uint8_t, data.data[pos]) = (uint8_t)var.ToInt();
				pos++;
				break;
			}
			case buffer_s8:
			{
				data.data[pos] = (int8_t)var.ToInt();
				pos++;
				break;
			}
			case buffer_u16:
			{
				CAST_BITS(uint16_t, data.data[pos]) = (uint16_t)var.ToInt();
				pos += 2;
				break;
			}
			case buffer_s16:
			{
				CAST_BITS(int16_t, data.data[pos]) = (int16_t)var.ToInt();
				pos += 2;
				break;
			}
			case buffer_u32:
			{
				CAST_BITS(uint32_t, data.data[pos]) = (uint32_t)var.ToInt();
				pos += 4;
				break;
			}
			case buffer_s32:
			{
				CAST_BITS(int32_t, data.data[pos]) = (int32_t)var.ToInt();
				pos += 4;
				break;
			}
			case buffer_f32:
			{
				CAST_BITS(float, data.data[pos]) = (float)var.ToReal();
				pos += 4;
				break;
			}
			case buffer_f64:
			{
				CAST_BITS(double, data.data[pos]) = (double)var.ToReal();
				pos += 4;
				break;
			}
		}

		return true;
	}
	
	VarType Buffer::ReadVar(int type, IntType& pos)
	{
		IntType dataSize = GetDataSize(type);
		if (pos + dataSize > data.Size())
			return 0;

		switch (type)
		{
			case buffer_u8:
			{
				uint8_t dat = CAST_BITS(uint8_t, data.data[pos]);
				pos++;
				return VarType((IntType)dat);
			}
			case buffer_s8:
			{
				int8_t dat = data.Value(pos);
				pos++;
				return VarType((IntType)dat);
			}
			case buffer_u16:
			{
				uint16_t dat = CAST_BITS(uint16_t, data.data[pos]);
				pos += 2;
				return VarType((IntType)dat);
			}
			case buffer_s16:
			{
				int16_t dat = CAST_BITS(int16_t, data.data[pos]);
				pos += 2;
				return VarType((IntType)dat);
			}
			case buffer_u32:
			{
				uint32_t dat = CAST_BITS(uint32_t, data.data[pos]);
				pos += 4;
				return VarType((IntType)dat);
			}
			case buffer_s32:
			{
				int32_t dat = CAST_BITS(int32_t, data.data[pos]);
				pos += 4;
				return VarType((IntType)dat);
			}
			case buffer_f32:
			{
				float dat = CAST_BITS(float, data.data[pos]);
				pos += 4;
				return VarType((RealType)dat);
			}
			case buffer_f64:
			{
				double dat = CAST_BITS(double, data.data[pos]);
				pos += 8;
				return VarType((RealType)dat);
			}
		}

		return 0;
	}

	void Buffer::Save(StringType filename)
	{
		QFile file(filename);
		AddPerms(file);
		if (file.open(QFile::WriteOnly))
			file.write((char*)data.Data(), data.Size());
		else
			WARNING("Could not save buffer to " + filename.QStr() + ": " + file.errorString());
	}

	IntType Buffer::GetDataSize(int type)
	{
		switch (type)
		{
			case buffer_u8: return 1;
			case buffer_s8: return 1;
			case buffer_u16: return 2;
			case buffer_s16: return 2;
			case buffer_u32: return 4;
			case buffer_s32: return 4;
			case buffer_f32: return 4;
			case buffer_f64: return 8;
		}
		return 0;
	}
}