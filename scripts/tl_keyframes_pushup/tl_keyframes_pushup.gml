/// tl_keyframes_pushup(index)
/// @arg index
/// @desc Deletes the keyframe at an index.

var ind = argument0;

keyframe_amount--
for (var k = ind; k < keyframe_amount; k++)
{
	keyframe[k] = keyframe[k + 1]
	keyframe[k].index--
}
