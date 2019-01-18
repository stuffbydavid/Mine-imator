/// action_setting_cubist_platform


if(argument0 != setting_cubist_platform) {
	//call to dll
	log("Changing OpenCL platform to", argument0)	
	cubist_set_platform(argument0)
	
	
	setting_cubist_platform = argument0
	
	action_setting_cubist_device(0)
}