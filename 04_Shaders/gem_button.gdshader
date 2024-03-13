shader_type canvas_item;

uniform vec3 polygon_color;
uniform float edge_min;

void vertex() {
	// Called for every vertex the material is visible on.
}
vec3 hsv_to_rgb(vec3 hsvColor) {
	// Based on Sam Hocevar's work
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(hsvColor.xxx + K.xyz) * 6.0 - K.www);
	return hsvColor.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsvColor.y);
}

vec3 rgb_to_hsv(vec3 rgbColor) {
	// Based on Sam Hocevar's and Emil Persson's work
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = rgbColor.g < rgbColor.b ? vec4(rgbColor.bg, K.wz) : vec4(rgbColor.gb, K.xy);
    vec4 q = rgbColor.r < p.x ? vec4(p.xyw, rgbColor.r) : vec4(rgbColor.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsvShift(vec3 color, vec3 shifts)
{
	vec3 hsvColor = rgb_to_hsv(color);
	return hsv_to_rgb(hsvColor + shifts);
}

void fragment() {
	vec2 tex_size = vec2(textureSize(TEXTURE, 0));
	vec2 scaled_uv = UV * tex_size;
	vec4 splashes = texture(TEXTURE, scaled_uv.rg);
	float mask = step(0.98, 1.0 - scaled_uv.g) * pow(scaled_uv.r, 2);
	vec3 color_middle = clamp(polygon_color + step(0.4, pow(scaled_uv.g, 3)) + pow(scaled_uv.g, 3) + mask, 0, 1);
	float pattern = texture(TEXTURE, scaled_uv).r;
	vec3 shifted = hsvShift(color_middle, vec3(0.02 * pattern, 0.2 * pattern, 0.15 * pattern));
	
	COLOR.rgb = shifted;
}