shader_type canvas_item;
// CRT overlay: scanlines, vignette, flicker and phosphor tint applied over
// the whole terminal. Rendered as a full-rect ColorRect reading the screen
// texture, so it composites over all terminal content beneath it.
//
// Phosphor persistence is approximated (tint glow only); a true afterimage
// would need back-buffer feedback — deferred to Phase 4 polish.

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

// Phosphor color: green default, amber alt (set from code on toggle).
uniform vec3 phosphor_tint = vec3(0.30, 1.0, 0.45);
// Accessibility: set to 0.0 to disable flicker entirely.
uniform float flicker_amplitude = 0.035;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.22;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.38;

void fragment() {
	vec3 col = texture(screen_texture, SCREEN_UV).rgb;

	// Phosphor tint: collapse to luminance, re-emit in the phosphor color.
	float lum = dot(col, vec3(0.299, 0.587, 0.114));
	vec3 tinted = lum * phosphor_tint * 1.35;

	// Scanlines: dark band every other pixel row.
	float row = SCREEN_UV.y / SCREEN_PIXEL_SIZE.y;
	float scan = abs(sin(row * 3.14159));
	tinted *= 1.0 - scanline_strength * scan;

	// Vignette: darkened, blurred corners like a curved glass bezel.
	float dist = distance(SCREEN_UV, vec2(0.5, 0.5));
	tinted *= 1.0 - vignette_strength * smoothstep(0.35, 0.85, dist);

	// Flicker: fast subtle brightness oscillation.
	float flicker = flicker_amplitude * (0.5 + 0.5 * sin(TIME * 73.0));
	tinted *= 1.0 - flicker;

	COLOR = vec4(tinted, 1.0);
}
