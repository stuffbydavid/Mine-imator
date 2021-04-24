/// buffer_skip(bytes)
/// @arg bytes
/// @desc Skips some bytes.

function buffer_skip(bytes)
{
	buffer_seek(buffer_current, buffer_seek_relative, bytes)
}
