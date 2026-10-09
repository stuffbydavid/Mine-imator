layout(triangles) in;
layout(triangle_strip, max_vertices = 18) out;

uniform vec4 _pointEye; // Light position and vertical forward Z
uniform vec4 _pointProjection; // X/Y scale and Z scale/offset
uniform vec4 _pointVertical; // Side X, up Y/Z and forward Y
uniform int _pointMultiview;

in vec3 _point_vPosition[];
in vec2 _point_vTexCoord[];
in vec4 _point_vColor[];
flat in uint _point_vObjIndex[];

out vec3 vPosition;
out vec2 vTexCoord;
out vec4 vColor;
flat out uint _vObjIndex;

vec4 projectPointFace(vec3 pos, int face)
{
	vec3 view;
	switch (face)
	{
		case 0: view = vec3(pos.y, pos.z, pos.x); break;
		case 1: view = vec3(-pos.y, pos.z, -pos.x); break;
		case 2: view = vec3(-pos.x, pos.z, pos.y); break;
		case 3: view = vec3(pos.x, pos.z, -pos.y); break;
		case 4: view = vec3(pos.x * _pointVertical.x, pos.y * _pointVertical.y + pos.z * _pointVertical.z, pos.y * _pointVertical.w + pos.z * _pointEye.w); break;
		default: view = vec3(pos.x * _pointVertical.x, -pos.y * _pointVertical.y + pos.z * _pointVertical.z, pos.y * _pointVertical.w - pos.z * _pointEye.w); break;
	}
	
	return vec4(view.xy * _pointProjection.xy, view.z * _pointProjection.z + _pointProjection.w, view.z);
}

void main()
{
	vec3 relative[3];
	if (_pointMultiview > 0)
		for (int v = 0; v < 3; v++)
			relative[v] = _point_vPosition[v] - _pointEye.xyz;
	
	for (int face = 0; face < (_pointMultiview > 0 ? 6 : 1); face++)
	{
		vec4 p[3];
		for (int v = 0; v < 3; v++)
			p[v] = _pointMultiview > 0 ? projectPointFace(relative[v], face) : gl_in[v].gl_Position;
		
		// Reject triangles outside this face before emitting geometry
		if (all(lessThan(vec3(p[0].x, p[1].x, p[2].x), -vec3(p[0].w, p[1].w, p[2].w))) ||
			all(greaterThan(vec3(p[0].x, p[1].x, p[2].x), vec3(p[0].w, p[1].w, p[2].w))) ||
			all(lessThan(vec3(p[0].y, p[1].y, p[2].y), -vec3(p[0].w, p[1].w, p[2].w))) ||
			all(greaterThan(vec3(p[0].y, p[1].y, p[2].y), vec3(p[0].w, p[1].w, p[2].w))) ||
			all(lessThan(vec3(p[0].z, p[1].z, p[2].z), -vec3(p[0].w, p[1].w, p[2].w))) ||
			all(greaterThan(vec3(p[0].z, p[1].z, p[2].z), vec3(p[0].w, p[1].w, p[2].w))))
		{
			continue;
		}
		
		for (int v = 0; v < 3; v++)
		{
			gl_Position = p[v];
			gl_ViewportIndex = face;

			vPosition = _point_vPosition[v];
			vTexCoord = _point_vTexCoord[v];
			vColor = _point_vColor[v];
			_vObjIndex = _point_vObjIndex[v];

			EmitVertex();
		}

		EndPrimitive();
	}
}
