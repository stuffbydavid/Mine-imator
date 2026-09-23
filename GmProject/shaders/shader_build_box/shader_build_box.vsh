attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;

uniform mat4 uTAAMatrix;
uniform vec2 uViewportSize;
uniform float uLineLength;
uniform vec3 uCameraPosition;

void main()
{
	vec3 start = in_Position;
	vec3 end = in_Position + in_Normal * uLineLength;
	if (in_TextureCoord.x > 0.5)
	{
		start = in_Position - in_Normal * uLineLength;
		end = in_Position;
	}

	vec4 startClip = uTAAMatrix * gm_Matrices[MATRIX_PROJECTION] * (gm_Matrices[MATRIX_VIEW] * (gm_Matrices[MATRIX_WORLD] * vec4(start, 1.0)));
	vec4 endClip = uTAAMatrix * gm_Matrices[MATRIX_PROJECTION] * (gm_Matrices[MATRIX_VIEW] * (gm_Matrices[MATRIX_WORLD] * vec4(end, 1.0)));
	vec2 direction = (endClip.xy / endClip.w - startClip.xy / startClip.w) * uViewportSize;
	vec2 perpendicular = vec2(-direction.y, direction.x) / max(length(direction), 0.0001);

	vec3 worldPosition = (gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1.0)).xyz;
	vec3 toEye = uCameraPosition - worldPosition;
	worldPosition += toEye * (0.25 / max(length(toEye), 0.0001));
	
	float lineWidth = 2.5;
	gl_Position = uTAAMatrix * gm_Matrices[MATRIX_PROJECTION] * (gm_Matrices[MATRIX_VIEW] * vec4(worldPosition, 1.0));
	gl_Position.xy += perpendicular * (lineWidth / uViewportSize) * gl_Position.w * (in_TextureCoord.y * 2.0 - 1.0);
}
