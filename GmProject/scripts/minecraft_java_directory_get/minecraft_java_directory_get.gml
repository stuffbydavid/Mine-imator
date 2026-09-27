/// CppSeparate StringType minecraft_java_directory_get()
/// Returns the location of Minecraft Java, used to find sound, music and world files.

function minecraft_java_directory_get()
{
	return environment_get_variable("APPDATA") + "/.minecraft";
}
