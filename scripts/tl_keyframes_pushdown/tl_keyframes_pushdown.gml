/// tl_keyframes_pushdown(index)
/// @arg index
/// @desc Creates a new keyframe slot.

var ind = argument0;

for (var k = keyframe_amount; k > ind; k--)
{
	keyframe[k] = keyframe[k - 1]
	keyframe[k].index++
}
keyframe_amount++
