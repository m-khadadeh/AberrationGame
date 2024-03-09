shader_type canvas_item;

uniform vec2 texture_scale;
uniform vec3 polygon_color;
uniform float edge;
uniform float exponent;

varying vec2 scaled_uv;

void vertex() {
	scaled_uv = UV * texture_scale;
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR.rgb = vec3(pow(scaled_uv.r, exponent));
	// float uv_g = abs(scaled_uv.g);
	// float mask = max(step(edge, pow(scaled_uv.r, exponent)), uv_g);
	// COLOR.rgb = vec3(mask) * polygon_color;
	
	//COLOR.rgb = vec3(scaled_uv.r) * polygon_color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
