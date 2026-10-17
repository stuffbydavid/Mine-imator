#include "Generated/Scripts.hpp"

#include "Asset/Buffer.hpp"

namespace CppProject
{
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
