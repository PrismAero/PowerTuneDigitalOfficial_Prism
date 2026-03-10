#version 440

// Arc overlay fragment shader for PrismPT.Dashboard ArcGauge component.
// Renders a GPU-accelerated arc gauge with SDF-based anti-aliasing, round end
// caps, 2-3 stop gradient fill, value-driven partial fill, and warning flash.
//
// Angle convention: 0 = right (positive X), increasing counter-clockwise in
// standard math coordinates. Screen Y is flipped, so visually the arc sweeps
// clockwise when startAngle < endAngle.

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

// std140 layout -- floats grouped before vec4s for natural alignment.
// Offsets: qt_Matrix=0, qt_Opacity=64, startAngle=68, endAngle=72,
//          arcWidth=76, value=80, warningActive=84, flashPhase=88,
//          useMidColor=92, colorStart=96, colorMid=112, colorEnd=128,
//          bgColor=144, warningColor=160.
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;

    // Arc geometry (radians)
    float startAngle;
    float endAngle;
    float arcWidth;

    // Fill state
    float value;

    // Warning control
    float warningActive;
    float flashPhase;

    // Gradient mode
    float useMidColor;

    // Gradient colors (premultiplied RGBA from Qt)
    vec4 colorStart;
    vec4 colorMid;
    vec4 colorEnd;
    vec4 bgColor;
    vec4 warningColor;
};

const float PI  = 3.14159265359;
const float TWO_PI = 6.28318530718;

// Outer edge of the arc ring in UV space [-1, 1].
// Slightly inside 0.5 to avoid clipping at component edges.
const float OUTER_RADIUS = 0.48;

// Compute the fragment angle in [0, TWO_PI) using the project's convention:
// 0 = right, increasing CCW in math coords (visually CW on screen with y-down).
float fragmentAngle(vec2 p)
{
    float a = atan(-p.y, p.x);
    return a < 0.0 ? a + TWO_PI : a;
}

// Signed distance to an arc annulus with round end caps.
//   p       - fragment position in UV space (centered at origin)
//   sa      - start angle (radians)
//   sweep   - sweep angle (radians, positive)
//   midR    - midpoint radius of the ring
//   halfW   - half-width of the ring
// Returns negative inside the shape, positive outside.
float sdArcRound(vec2 p, float sa, float sweep, float midR, float halfW)
{
    float r = length(p);
    float angle = fragmentAngle(p);

    // Normalize angle into arc-local coordinate [0, TWO_PI)
    float normAng = mod(angle - sa + TWO_PI, TWO_PI);

    if (normAng <= sweep)
    {
        // Inside the angular range: SDF is purely radial distance to annulus
        return abs(r - midR) - halfW;
    }

    // Outside angular range: distance to the nearest round cap center
    float ea = sa + sweep;
    vec2 capStart = midR * vec2(cos(sa), -sin(sa));
    vec2 capEnd   = midR * vec2(cos(ea), -sin(ea));

    float dStart = length(p - capStart) - halfW;
    float dEnd   = length(p - capEnd)   - halfW;

    return min(dStart, dEnd);
}

void main()
{
    vec2 uv = qt_TexCoord0 * 2.0 - 1.0;

    // Derive inner radius from outer and arcWidth
    float innerR = max(OUTER_RADIUS - arcWidth, 0.01);
    float midR   = (OUTER_RADIUS + innerR) * 0.5;
    float halfW  = (OUTER_RADIUS - innerR) * 0.5;

    // Compute total sweep, handling wrap-around (e.g. 135 deg to 405 deg)
    float sweep = mod(endAngle - startAngle + TWO_PI, TWO_PI);
    if (sweep < 0.001)
        sweep = TWO_PI;

    // Anti-aliasing feather width: ~1.5 pixels in UV space.
    // fwidth gives the per-pixel rate of change of the radius, providing
    // resolution-independent AA that works at any component size.
    float aa = fwidth(length(uv)) * 1.5;
    aa = max(aa, 0.001); // safety floor

    // ---- Background arc (full sweep, shows unfilled region) ----
    float bgDist = sdArcRound(uv, startAngle, sweep, midR, halfW);
    float bgMask = 1.0 - smoothstep(-aa, aa, bgDist);

    // Early discard: outside the full arc entirely
    if (bgMask < 0.001)
    {
        fragColor = vec4(0.0);
        return;
    }

    // ---- Fill arc (partial sweep driven by value) ----
    float fillSweep = sweep * clamp(value, 0.0, 1.0);
    float fillMask  = 0.0;

    if (fillSweep > 0.001)
    {
        float fillDist = sdArcRound(uv, startAngle, fillSweep, midR, halfW);
        fillMask = 1.0 - smoothstep(-aa, aa, fillDist);
    }

    // ---- Gradient color along the arc sweep ----
    float angle = fragmentAngle(uv);
    float normAngle = mod(angle - startAngle + TWO_PI, TWO_PI);
    float t = clamp(normAngle / max(sweep, 0.001), 0.0, 1.0);

    vec4 gradColor;
    if (useMidColor > 0.5)
    {
        // 3-stop gradient: colorStart -> colorMid (at midpoint) -> colorEnd
        if (t < 0.5)
            gradColor = mix(colorStart, colorMid, t * 2.0);
        else
            gradColor = mix(colorMid, colorEnd, (t - 0.5) * 2.0);
    }
    else
    {
        // 2-stop gradient: colorStart -> colorEnd
        gradColor = mix(colorStart, colorEnd, t);
    }

    // Subtle radial glow: brighten toward the center of the ring band
    float r = length(uv);
    float radialNorm = clamp((r - innerR) / max(OUTER_RADIUS - innerR, 0.001), 0.0, 1.0);
    float glow = 1.0 + 0.12 * (1.0 - abs(2.0 * radialNorm - 1.0));
    gradColor.rgb *= glow;

    // ---- Warning flash override ----
    vec4 finalFillColor = gradColor;
    if (warningActive > 0.5)
    {
        // flashPhase oscillates 0-1 driven by QML Timer.
        // Sinusoidal pulse for smooth visual flash.
        float flash = 0.5 + 0.5 * sin(flashPhase * TWO_PI);
        // When flash is high (1.0): mostly warningColor.
        // When flash is low (0.0): almost full warningColor still, slight gradient bleed.
        finalFillColor = mix(warningColor, gradColor, flash * 0.3);
    }

    // ---- Compose final layers ----
    vec4 result = vec4(0.0);

    // Layer 1: Background arc in unfilled regions
    float bgOnly = bgMask * (1.0 - fillMask);
    result = mix(result, bgColor, bgOnly);

    // Layer 2: Filled arc with gradient (or warning color)
    result = mix(result, finalFillColor, fillMask);

    // Layer 3: Leading-edge highlight at the fill tip for visual punch
    if (fillSweep > 0.01 && fillMask > 0.0)
    {
        float edgeAngle = startAngle + fillSweep;
        float edgeDist = mod(angle - edgeAngle + PI + TWO_PI, TWO_PI) - PI;
        float edgeBand = 1.0 - smoothstep(0.0, 0.05, abs(edgeDist));
        float tipGlow = edgeBand * fillMask * 0.35;
        result.rgb += vec3(tipGlow);
    }

    fragColor = result * qt_Opacity;
}
