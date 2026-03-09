#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;

    float progress;
    float startAngle;
    float sweepAngle;
    float outerRadius;
    float innerRadius;
    float chromeOuterRadius;
    float chromeInnerRadius;

    vec4 colorStart;
    vec4 colorEnd;
    vec4 chromeDark;
    vec4 chromeLight;
    vec4 backgroundColor;

    float bevelStrength;
    float antiAlias;
    float _pad0;
    float _pad1;
};

const float PI = 3.14159265359;
const float TWO_PI = 6.28318530718;

bool inArcAngle(float angle, float arcStart, float arcSweep)
{
    float norm = mod(angle - arcStart + TWO_PI, TWO_PI);
    return norm <= arcSweep + 0.001;
}

void main()
{
    vec2 uv = qt_TexCoord0 * 2.0 - 1.0;
    float r = length(uv);
    float angle = atan(uv.x, -uv.y);
    if (angle < 0.0) angle += TWO_PI;

    float aa = antiAlias;
    vec4 result = vec4(0.0);

    float arcStart = startAngle;
    float arcSweep = sweepAngle;

    bool angleInArc = inArcAngle(angle, arcStart, arcSweep);

    if (!angleInArc) {
        fragColor = vec4(0.0);
        return;
    }

    vec2 ndir = normalize(uv);
    float lightAngle = PI * 0.75;
    vec2 lightDir = vec2(cos(lightAngle), sin(lightAngle));
    float baseBevel = dot(ndir, lightDir) * 0.5 + 0.5;

    float outerRing = smoothstep(chromeOuterRadius + aa, chromeOuterRadius, r)
                    * (1.0 - smoothstep(outerRadius, outerRadius - aa, r));

    if (outerRing > 0.0)
    {
        float edgeFade = smoothstep(chromeOuterRadius, outerRadius, r);
        float bevel = mix(baseBevel, 1.0 - baseBevel, edgeFade * 0.3);
        bevel = pow(bevel, 0.7) * bevelStrength;

        vec4 highlight = vec4(chromeLight.rgb * 1.3, chromeLight.a);
        vec4 chromeCol = mix(chromeDark, highlight, bevel);

        float edgeHighlight = smoothstep(chromeOuterRadius, chromeOuterRadius - aa * 3.0, r);
        chromeCol.rgb += vec3(0.08) * edgeHighlight * baseBevel;

        result = mix(result, chromeCol, outerRing);
    }

    float bgRing = smoothstep(outerRadius + aa, outerRadius, r)
                 * (1.0 - smoothstep(innerRadius, innerRadius - aa, r));

    if (bgRing > 0.0)
    {
        result = mix(result, backgroundColor, bgRing);
    }

    float innerRing = smoothstep(innerRadius + aa, innerRadius, r)
                    * (1.0 - smoothstep(chromeInnerRadius, chromeInnerRadius - aa, r));

    if (innerRing > 0.0)
    {
        float bevel = baseBevel * bevelStrength * 0.5;
        vec4 chromeCol = mix(chromeDark, chromeLight, bevel);

        float innerEdge = smoothstep(innerRadius, chromeInnerRadius, r);
        chromeCol.rgb += vec3(0.04) * (1.0 - innerEdge) * baseBevel;

        result = mix(result, chromeCol, innerRing);
    }

    float fillArcSweep = arcSweep * clamp(progress, 0.0, 1.0);
    bool angleInFill = inArcAngle(angle, arcStart, fillArcSweep);

    if (bgRing > 0.0 && angleInFill)
    {
        float normAngle = mod(angle - arcStart + TWO_PI, TWO_PI);
        float t = clamp(normAngle / max(arcSweep, 0.001), 0.0, 1.0);
        vec4 fillColor = mix(colorStart, colorEnd, t);

        float glow = 1.0 + 0.15 * (1.0 - abs(2.0 * ((r - innerRadius) / (outerRadius - innerRadius)) - 1.0));
        fillColor.rgb *= glow;

        result = mix(result, fillColor, bgRing * 0.95);
    }

    fragColor = result * qt_Opacity;
}
