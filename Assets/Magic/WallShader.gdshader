shader_type canvas_item;

uniform vec2 target = vec2(0.5);
uniform float radius = 0.5;
void fragment(){
	COLOR = texture(TEXTURE,UV);
	float dist = abs(distance(target,SCREEN_UV));
	if(dist<=radius && COLOR.a>0.0){
		COLOR.a = 0.6;
	}
}