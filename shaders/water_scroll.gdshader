shader_type spatial;
render_mode cull_disabled; // Disable face culling to render both sides

uniform vec3 water_color : source_color;
uniform float uv_scale : hint_range(0.0, 80.0, 1) = 4.0;
uniform float time_scale : hint_range(0.0, 2.0, 0.25) = 1.0;
uniform sampler2D water_normal_texture;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable;
uniform float normal : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float roughness : hint_range(0.0, 1.0, 0.1) = 0.3;
uniform float scroll_speed : hint_range(-3.0, 0.0, 0.1) = -0.01; // New uniform for scrolling speed

void fragment() {
    vec2 _uv = UV * uv_scale;
    vec2 _suv = SCREEN_UV;

    // Add a scrolling offset to the UV coordinates
    _uv.x += TIME * scroll_speed; // Scrolling effect towards the x-axis
	_uv.y += TIME * scroll_speed;

    // Add some sine and cosine waves to UV coordinates for wave effect
    _uv.x += sin(TIME * time_scale + (_uv.x + _uv.y) * 10.0) * 0.02;
    _uv.y += cos(TIME * time_scale + (_uv.x - _uv.y) * 10.0) * 0.02;

    _suv.x += sin(TIME * time_scale + (_suv.x + _suv.y) * 30.0) * 0.001;
    _suv.y += cos(TIME * time_scale + (_suv.x - _suv.y) * 30.0) * 0.001;

    vec3 screen_color = texture(screen_texture, _suv).rgb;
    vec3 normal_map = texture(water_normal_texture, _uv).rgb;

    // Blend the water color with the screen color
    ALBEDO = mix(screen_color, water_color, 0.85);
    NORMAL_MAP = normal_map;
    NORMAL *= normal;
    ROUGHNESS = roughness;
}
