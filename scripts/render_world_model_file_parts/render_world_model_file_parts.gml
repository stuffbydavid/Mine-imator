/// render_world_model_file_parts(modelfile, texturename, resource)
/// @arg modelfile
/// @arg texturename
/// @arg resource
/// @desc Renders a modelfile in its default position.

var modelfile, texname, res;
modelfile = argument0
texname = argument1
res = argument2


for (var p = 0; p < modelfile.part_amount; p++) 
{
	var part = modelfile.part[p];
	render_world_model_part(part, texname, res, 0)
	render_world_model_file_parts(part, texname, res)
}