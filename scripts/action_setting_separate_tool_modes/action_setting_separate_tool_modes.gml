/// action_setting_separate_tool_modes(yes)
/// @arg yes

function action_setting_separate_tool_modes(yes)
{
	setting_separate_tool_modes = yes
	
	action_tools_disable_all()
	setting_tool_select = setting_separate_tool_modes
}
