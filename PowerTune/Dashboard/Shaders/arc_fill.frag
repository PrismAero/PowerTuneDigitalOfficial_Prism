#version 440

layout(location = 0) in vec2 vTexCoord;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float uProgress;
    float uStartAngleDeg;
    float uSweepAngleDeg;
    float uThickness;
    vec4 uColorStart;
    vec4 uColorMid;
    vec4 uColorEnd;
    vec4 uBgColor;
    float uUseMidColor;
    float uMidPos;
    float uHighlightStrength;
    float uHighlightWidth;
    float uInnerFade;
    float uOuterFade;
    float uWarningMix;
    float uOpacity;
};

const float PI = 3.14159265359;

vec4 gradientColor(float t)
{
    t = clamp(t, 0.0, 1.0);
    if (uUseMidColor > 0.5) {
        float midPos = clamp(uMidPos, 0.01, 0.99);
        if (t < midPos)
            return mix(uColorStart, uColorMid, t / midPos);
        return mix(uColorMid, uColorEnd, (t - midPos) / (1.0 - midPos));
    }
    return mix(uColorStart, uColorEnd, t);
}

void main()
{
    vec2 uv = (vTexCoord * 2.0) - 1.0;
    float radius = length(uv);
    float outerRadius = 1.0;
    float innerRadius = max(0.0, 1.0 - uThickness);

    if (radius > outerRadius || radius < innerRadius) {
        fragColor = vec4(0.0);
        return;
    }

    float angle = atan(uv.x, -uv.y);
    if (angle < 0.0)
        angle += 2.0 * PI;

    float start = radians(uStartAngleDeg);
    float sweep = radians(uSweepAngleDeg);
    float totalSweep = max(abs(sweep), 0.0001);

    float relAngle = angle - start;
    if (relAngle < 0.0)
        relAngle += 2.0 * PI;

    float sweepRatio = clamp(relAngle / totalSweep, 0.0, 1.0);
    float activeSweep = totalSweep * clamp(uProgress, 0.0, 1.0);

    float edgeSoftness = 0.01;
    float fillMask = smoothstep(activeSweep + edgeSoftness, activeSweep - edgeSoftness, relAngle);

    float radialPos = (radius - innerRadius) / max(outerRadius - innerRadius, 0.0001);
    float innerAlpha = smoothstep(0.0, max(uInnerFade, 0.0001), radialPos);
    float outerAlpha = smoothstep(0.0, max(uOuterFade, 0.0001), 1.0 - radialPos);
    float radialAlpha = innerAlpha * outerAlpha;

    vec4 fillColor = gradientColor(sweepRatio);

    float highlightBand = smoothstep(1.0 - max(uHighlightWidth, 0.001), 1.0, sweepRatio);
    float outerGlow = smoothstep(0.55, 1.0, radialPos);
    fillColor.rgb += highlightBand * outerGlow * uHighlightStrength;

    fillColor = mix(fillColor, vec4(1.0, 0.0, 0.0, fillColor.a), clamp(uWarningMix, 0.0, 1.0));
    fillColor.a *= fillMask * radialAlpha;
    fragColor = fillColor * uOpacity * qt_Opacity;
}
