shader_type canvas_item;

//citation: https://github.com/paddy-exe/ShaderFunction-Extras/blob/main/addons/ShaderFunction-Extras/Color/color_adjustment.gdshaderinc
vec3 hsv_to_rgb(vec3 color) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(color.xxx + K.xyz) * 6.0 - K.www);
	return color.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), color.y);
}

//citation: https://github.com/paddy-exe/ShaderFunction-Extras/blob/main/addons/ShaderFunction-Extras/Color/color_adjustment.gdshaderinc
vec3 rgb_to_hsv(vec3 color) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(color.bg, K.wz), vec4(color.gb, K.xy), step(color.b, color.g));
	vec4 q = mix(vec4(p.xyw, color.r), vec4(color.r, p.yzx), step(p.x, color.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

uniform vec4 c_mode : hint_color = vec4(1.0);
uniform float c_strength: hint_range(0, 1) = 0.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	//APPLY CONTRAST 
	//RBG->HSV
	vec3 hsv = rgb_to_hsv(color.rgb);
	vec3 hsv2 = rgb_to_hsv(c_mode.rgb);
	//LERP H of base to overlay
	hsv.x = mix(hsv.x,hsv2.x,c_strength);
	hsv.y = mix(hsv.y,hsv2.y,c_strength);
	//HSV->RGB
	color = vec4(hsv_to_rgb(hsv),color.a);
	
	COLOR = color;
}