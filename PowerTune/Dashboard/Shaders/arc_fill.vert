#version 440

layout(location = 0) in vec4 qt_Vertex;
layout(location = 1) in vec2 qt_MultiTexCoord0;

layout(location = 0) out vec2 vTexCoord;

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

void main()
{
    vTexCoord = qt_MultiTexCoord0;
    gl_Position = qt_Matrix * qt_Vertex;
}
