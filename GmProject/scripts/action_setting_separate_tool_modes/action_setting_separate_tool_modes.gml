function action_setting_separate_tool_modes(enabled)
{
	setting_separate_tool_modes = enabled
	
	action_tools_disable_all()
	setting_tool_select = setting_separate_tool_modes
}
