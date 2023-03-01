#include "Generated/GmlFunc.hpp"
#include "Generated/Scripts.hpp"

#include "Asset/Buffer.hpp"
#include "Asset/Surface.hpp"

namespace CppProject
{
	void buffer_copy(IntType src, IntType srcOffset, IntType size, IntType dst, IntType dstOffset)
	{
		Buffer* srcBuf = FindBuffer(src);
		Buffer* dstBuf = FindBuffer(dst);
		if (!srcBuf || !dstBuf)
			return;

		dstBuf->data.Copy(srcBuf->data, size, srcOffset, dstOffset);
	}

	IntType buffer_create(IntType size, IntType type, IntType align)
	{
		return (new Buffer(size, type == buffer_grow, align))->id;
	}

	IntType buffer_create_from_vertex_buffer(IntType, IntType, IntType)
	{
		// Unused
		return 0;
	}

	void buffer_delete(IntType id)
	{
		if (Buffer* buf = FindBuffer(id))
			delete buf;
	}

	void buffer_fill(IntType id, IntType offset, IntType type, VarType value, IntType size)
	{
		if (Buffer* buf = FindBuffer(id))
		{
			IntType pos = offset;
			while (pos < offset + size && buf->WriteVar(type, value, pos))
				continue;
		}
	}

	IntType buffer_get_size(IntType id)
	{
		if (Buffer* buf = FindBuffer(id))
			return buf->data.Size();
		return 0;
	}

	void buffer_get_surface(IntType buffer, IntType surface, IntType)
	{
		if (Buffer* buf = FindBuffer(buffer))
		{
			if (Surface* surf = FindSurface(surface))
			{
				buf->data.Alloc(surf->size.width() * surf->size.height() * 4, false);
				surf->frameBuffer->CopyColorData(buf->data.data);
			}
		}
	}

	IntType buffer_load(StringType file)
	{
		if (QFile::exists(file))
		{
			Buffer* buf = new Buffer(file);
			if (buf->data.Size())
				return buf->id;
			else
				delete buf;
		}
		return -1;
	}

	VarType buffer_peek(IntType id, IntType offset, IntType type)
	{
		if (Buffer* buf = FindBuffer(id))
			return buf->ReadVar(type, offset);
		
		return VarType();
	}

	void buffer_poke(IntType id, IntType offset, VarType type, IntType value)
	{
		if (Buffer* buf = FindBuffer(id))
			buf->WriteVar(type, value, offset);
	}

	VarType buffer_read(IntType id, IntType type)
	{
		if (Buffer* buf = FindBuffer(id))
			return buf->ReadVar(type, buf->pos);

		return VarType();
	}

	void buffer_resize(IntType id, IntType newSize)
	{
		if (Buffer* buf = FindBuffer(id))
			buf->data.Alloc(newSize);
	}

	void buffer_save(IntType id, StringType file)
	{
		if (Buffer* buf = FindBuffer(id))
			buf->Save(file);
	}

	void buffer_seek(IntType id, IntType base, IntType offset)
	{
		if (Buffer* buf = FindBuffer(id))
		{
			if (base == buffer_seek_start)
				buf->pos = offset;
			else if (base == buffer_seek_relative)
				buf->pos += offset;
			else if (base == buffer_seek_end)
				buf->pos = buf->data.Size() + offset;
		}
	}

	IntType buffer_tell(IntType id)
	{
		if (Buffer* buf = FindBuffer(id))
			return buf->pos;
		return -1;
	}

	IntType buffer_write(IntType id, IntType type, VarType value)
	{
		if (Buffer* buf = FindBuffer(id))
			if (buf->WriteVar(type, value, buf->pos))
				return 0;
		return -1;
	}

	IntType buffer_fast_peek_u8(IntType id, IntType offset)
	{
		if (Buffer* buf = FindBuffer(id))
			return CAST_BITS(uchar, buf->data[offset]);
		return 0;
	}

	IntType buffer_fast_peek_s32(IntType id, IntType offset)
	{
		if (Buffer* buf = FindBuffer(id))
			return CAST_BITS(int32_t, buf->data[offset]);
		return 0;
	}

	void buffer_fast_poke_u8(IntType id, IntType offset, IntType value)
	{
		if (Buffer* buf = FindBuffer(id))
			CAST_BITS(uchar, buf->data[offset]) = (uchar)value;
	}

	void buffer_fast_poke_s32(IntType id, IntType offset, IntType value)
	{
		if (Buffer* buf = FindBuffer(id))
			CAST_BITS(int32_t, buf->data[offset]) = (int32_t)value;
	}

	void buffer_write_string(StringType arg)
	{
		if (Buffer* buf = FindBuffer(global::buffer_current))
		{
			QString str = arg.QStr();
			IntType len = str.length();
			if (buf->pos + len > buf->data.Size()) // Allocate data
				buf->data.Alloc(buf->data.Size() + len);

			for (QChar c : str)
				buf->data[buf->pos++] = (uchar)c.unicode();
		}
	}
}