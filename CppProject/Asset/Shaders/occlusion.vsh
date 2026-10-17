attribute vec3 in_Position;

uniform vec4 uOcclusionRect; // static
uniform float uOcclusionDepth; // static

void main()
{
	gl_Position = vec4(mix(uOcclusionRect.xy, uOcclusionRect.zw, in_Position.xy), uOcclusionDepth, 1.0);
}
