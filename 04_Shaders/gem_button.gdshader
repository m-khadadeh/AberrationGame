shader_type canvas_item;

uniform vec3 polygon_color;
uniform float edge_min;

void vertex() {
	// Called for every vertex the material is visible on.
}
vec3 hsv_to_rgb(vec3 color) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(color.xxx + K.xyz) * 6.0 - K.www);
	return color.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), color.y);
}

vec3 rgb_to_hsv(vec3 color) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(color.bg, K.wz), vec4(color.gb, K.xy), step(color.b, color.g));
	vec4 q = mix(vec4(p.xyw, color.r), vec4(color.r, p.yzx), step(p.x, color.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 rgbToHsv(vec3 rgbColor) {
	int max_col = 1;
	float max_val = rgbColor.r;
	int min_col = 1;
	float min_val = rgbColor.r;
	if(rgbColor.g > max_val){
		max_col = 2;
		max_val = rgbColor.g;
	}
	if(rgbColor.g < min_val){
		min_col = 2;
		min_val = rgbColor.g;
	}
	if(rgbColor.b > max_val){
		max_col = 3;
		max_val = rgbColor.b;
	}
	if(rgbColor.b < min_val){
		min_col = 3;
		min_val = rgbColor.b;
	}
	
	float lum = (max_val + min_val)/2.0;
	if(max_val == min_val)
	{
		return vec3(0, 0, lum);
	}
	
	float sat;
	if(lum <= 0.5)
	{
		sat = (max_val - min_val)/(max_val+min_val);
	}
	else
	{
		sat = (max_val - min_val)/(2.0 - max_val - min_val);
	}
	
	float hue;
	if(max_col == 1)
	{
		hue = (rgbColor.g - rgbColor.b)/(max_val - min_val);
	}
	else if(max_col == 2)
	{
		hue = 2.0 + (rgbColor.b - rgbColor.r)/(max_val - min_val);
	}
	else
	{
		hue = 4.0 + (rgbColor.r - rgbColor.g)/(max_val - min_val);
	}
	return vec3(60.0 * hue, sat, lum);
}

vec3 hsvToRgb(vec3 hsvColor) {
	if(hsvColor.y == 0.0) {
		return vec3(hsvColor.z);
	}
	float max_val = hsvColor.z;
	float chroma = hsvColor.y * hsvColor.z;
	float min_val = max_val - chroma;
	
	
	float wrapped_hue;
	if(hsvColor.x > 360.0)
		wrapped_hue = hsvColor.x - 360.0;
	else
		wrapped_hue = hsvColor.x;
	
	float hue_prime;
	if(wrapped_hue >= 300.0)
		hue_prime = (wrapped_hue - 360.0)/60.0;
	if(wrapped_hue >= 300.0)
		hue_prime = wrapped_hue/60.0;
	if(hue_prime >= -1.0 && hue_prime < 1.0){
		if(hue_prime - 0.0 < 0.0)
		{
			return vec3(max_val, min_val, min_val - (hue_prime * chroma));
		}
		else
		{
			return vec3(max_val, min_val + (hue_prime * chroma), min_val);
		}
	}
	else if(hue_prime >= 1.0 && hue_prime < 3.0){
		if(hue_prime - 2.0 < 0.0)
		{
			return vec3(min_val - ((hue_prime - 2.0) * chroma), max_val, min_val);
		}
		else
		{
			return vec3(min_val, max_val, min_val + ((hue_prime - 2.0) * chroma));
		}
	}
	else{
		if(hue_prime - 4.0 < 0.0)
		{
			return vec3(min_val, min_val - ((hue_prime - 4.0) * chroma), max_val);
		}
		else
		{
			return vec3(min_val + ((hue_prime - 4.0) * chroma), min_val, max_val);
		}
	}
}

vec3 hsvShift(vec3 color, vec3 shifts)
{
	vec3 hsvColor = rgb_to_hsv(color);
	return hsv_to_rgb(hsvColor + shifts);
}

void fragment() {
	vec2 tex_size = vec2(textureSize(TEXTURE, 0));
	vec2 scaled_uv = UV * tex_size;
	//COLOR.rgb = vec3(float(on_the_edge(UV, POINT_COORD) < stroke_width ? 1 : 0));
	vec4 splashes = texture(TEXTURE, scaled_uv.rg);
	float mask = step(0.98, 1.0 - scaled_uv.g) * pow(scaled_uv.r, 2);
	vec3 color_middle = clamp(polygon_color + step(0.4, pow(scaled_uv.g, 3)) + pow(scaled_uv.g, 3) + mask, 0, 1);
	float pattern = texture(TEXTURE, scaled_uv).r;
	vec3 shifted = hsvShift(color_middle, vec3(0.02 * pattern, 0.2 * pattern, 0.15 * pattern));
	
	COLOR.rgb = shifted;
}