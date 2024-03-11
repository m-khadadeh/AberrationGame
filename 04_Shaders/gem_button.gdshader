shader_type canvas_item;

uniform vec3 polygon_color;
uniform float edge_min;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 tex_size = vec2(textureSize(TEXTURE, 0));
	vec2 scaled_uv = UV * tex_size;
	//COLOR.rgb = vec3(float(on_the_edge(UV, POINT_COORD) < stroke_width ? 1 : 0));
	vec4 splashes = texture(TEXTURE, scaled_uv);
	float mask = step(0.98, 1.0 - scaled_uv.g) * pow(scaled_uv.r, 2);
	COLOR.rgb = clamp(polygon_color + step(0.4, pow(scaled_uv.g, 3)) + pow(scaled_uv.g, 3) + mask, 0, 1);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
