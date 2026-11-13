/// @desc Skips a number of bytes.

function buffer_skip(bytes)
{
	buffer_seek(buffer_current, buffer_seek_relative, bytes)
}
