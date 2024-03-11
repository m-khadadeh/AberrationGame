shader_type canvas_item;

uniform vec3 polygon_color;
uniform float edge_min;
uniform bool hovered;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 tex_size = vec2(textureSize(TEXTURE, 0));
	vec2 scaled_uv = UV * tex_size;
	//COLOR.rgb = vec3(float(on_the_edge(UV, POINT_COORD) < stroke_width ? 1 : 0));
	vec4 splashes = texture(TEXTURE, scaled_uv);
	float slashed = step(splashes.r, clamp(scaled_uv.g, 0.0, 1.0));
	COLOR.rgb = step(0.8, vec3(1.0 - scaled_uv.r)) * float(hovered);
	COLOR.rgb += scaled_uv.g * polygon_color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
