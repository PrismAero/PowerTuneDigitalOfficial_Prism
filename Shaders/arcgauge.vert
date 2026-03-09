#version 440

layout(location = 0) in vec4 qt_Vertex;
layout(location = 1) in vec2 qt_MultiTexCoord0;

layout(location = 0) out vec2 qt_TexCoord0;

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

void main()
{
    qt_TexCoord0 = qt_MultiTexCoord0;
    gl_Position = qt_Matrix * qt_Vertex;
}
