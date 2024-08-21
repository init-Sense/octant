shader_type spatial;
render_mode blend_mix, cull_disabled;

uniform vec3 camera_position;
uniform float transparency_start_distance = 30.0;
uniform float transparency_end_distance = 300.0;
uniform float transparency_min = 0.0;
uniform vec3 albedo_color = vec3(1.0, 0.5, 0.2);
uniform float fog_density = 0.01;
uniform vec3 fog_color = vec3(0.5, 0.6, 0.7);

void fragment() {
    float distance_from_player = length(VERTEX - camera_position);
    float transparency_factor = clamp((distance_from_player - transparency_start_distance) / (transparency_end_distance - transparency_start_distance), 0.0, 1.0);
    ALPHA = mix(1.0, transparency_min, transparency_factor);
    BASE_COLOR = mix(albedo_color, fog_color, 1.0 - exp(-fog_density * distance_from_player));
}