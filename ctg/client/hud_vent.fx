
float progress = 0.5;
float startAngle = 0.0;
float totalAngle = 3.14159265;
float Time = 0.0;

float startInner = 0.02;
float startOuter = 0.5;
float endInner = 0.20;
float endOuter = 0.5;

float4 color1 = float4(0, 1, 1, 1);
float4 color2 = float4(1, 0.75, 0, 1);
float bgAlpha = 0.6;

struct PSInput {
    float2 TexCoord : TEXCOORD0;
    float4 Color : COLOR0;
};

float4 PixelShaderFunction(PSInput input) : COLOR0 {
    float2 uv = input.TexCoord - 0.5;
    float dist = length(uv);
    
    float angle = atan2(uv.y, uv.x);
    float currentAngle = angle - startAngle;
    if (currentAngle < 0) currentAngle += 6.283185;
    
    if (currentAngle > totalAngle) return float4(0, 0, 0, 0);
    
    float p = currentAngle / totalAngle;
    
    float cInner = lerp(startInner, endInner, p);
    float cOuter = lerp(startOuter, endOuter, p);
    
    float soften = 0.04;
    cInner += soften * 0.5;
    cOuter -= soften * 0.5;

    float alphaInner = smoothstep(cInner - soften, cInner, dist);
    float alphaOuter = 1.0 - smoothstep(cOuter, cOuter + soften, dist);
    float ringAlpha = alphaInner * alphaOuter;
    
    if (ringAlpha <= 0) return float4(0, 0, 0, 0);
    
    // Cranked up liquid flow effect with more contrast
    float wave = sin(p * 18.0 - Time * 5.5) * 0.3 + sin(p * 35.0 + Time * 3.5) * 0.15;
    float liquidMult = 1.3 + wave * 0.8;
    
    float capSoften = 0.025;
    float progressAlpha = 1.0 - smoothstep(progress - capSoften, progress, p);
    
    float4 baseColor = lerp(color1, color2, p);
    float4 activeColor = float4(baseColor.rgb * liquidMult, baseColor.a);
    float4 bgColor = float4(baseColor.rgb * 0.25, bgAlpha);
    
    float4 finalColor = lerp(bgColor, activeColor, progressAlpha);
    
    return finalColor * ringAlpha;
}

technique VentTechnique {
    pass P0 {
        PixelShader = compile ps_2_a PixelShaderFunction();
    }
}
