// crt.glsl -- mild CRT look for Ghostty
// Effect: scanlines + vignette + chromatic aberration.
// No flicker on purpose: full-screen brightness pulsing in the 3-30Hz band
// is eye strain at best and a photosensitivity hazard at worst.

const float SCANLINE_STRENGTH = 0.08; // 0.0 = off, 0.3 = heavy
const float SCANLINE_PERIOD   = 3.0;  // px per scanline cycle
const float VIGNETTE          = 0.18; // darkness at corners
const float CHROMA            = 0.0012; // rgb split at corners
// 注意：不要加 3–30Hz 的整屏亮度闪烁，光敏性癫痫风险，也会让人眼睛疼。

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    // Chromatic aberration grows toward the edges.
    vec2 c = uv * 2.0 - 1.0;
    float r2 = dot(c, c);
    float ca = CHROMA * r2;

    vec4 base = texture(iChannel0, uv);
    float red  = texture(iChannel0, uv + vec2(ca, 0.0)).r;
    float blue = texture(iChannel0, uv - vec2(ca, 0.0)).b;

    vec3 col = vec3(red, base.g, blue);

    // Scanlines.
    float phase = fract(fragCoord.y / SCANLINE_PERIOD) * 6.28318530718;
    float scan  = 1.0 - SCANLINE_STRENGTH * (0.5 + 0.5 * cos(phase));
    col *= scan;

    // Vignette.
    col *= 1.0 - VIGNETTE * 0.5 * r2;

    fragColor = vec4(clamp(col, 0.0, 1.0), base.a);
}
