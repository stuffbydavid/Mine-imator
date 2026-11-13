function version_get()
{
	var version = mineimator_version;
	
	if (mineimator_version_sub != "")
		version += " " + mineimator_version_sub
	
	if (mineimator_version_extra != "")
		version += " (" + mineimator_version_extra + ")"
		
	return version
}