
float progress = 0.5;
float startAngle = 0.0;
float totalAngle = 1.5 * 3.14159265;
float innerRadius = 0.4;
float outerRadius = 0.5;
float4 color = float4(0, 1, 1, 1);
float bgAlpha = 0.6;
float Time = 0.0;
float Freq1 = 12.0;
float Freq2 = 25.0;

sampler2D Sampler0;

struct PSInput {
    float2 TexCoord : TEXCOORD0;
    float4 Color : COLOR0;
};

float4 PixelShaderFunction(PSInput input) : COLOR0 {
    float2 uv = input.TexCoord - 0.5;
    float dist = length(uv);
    
    float soften = 0.025; 
    float tInner = innerRadius + soften * 0.5;
    float tOuter = outerRadius - soften * 0.5;

    float alphaInner = smoothstep(tInner - soften, tInner, dist);
    float alphaOuter = 1.0 - smoothstep(tOuter, tOuter + soften, dist);
    float ringAlpha = alphaInner * alphaOuter;

    if (ringAlpha <= 0) return float4(0, 0, 0, 0);
    
    float angle = atan2(uv.y, uv.x);
    float currentAngle = angle - startAngle;
    if (currentAngle < 0) currentAngle += 6.283185;
    
    if (currentAngle > totalAngle) return float4(0, 0, 0, 0);
    
    float p = currentAngle / totalAngle;
    
    // Liquid flow effect with adjustable frequencies
    float wave = sin(p * Freq1 - Time * 5.0) * 0.4 + sin(p * Freq2 + Time * 3.0) * 0.15;
    float liquidMult = 1.3 + wave * 0.8;
    
    float capSoften = 0.015; 
    float progressAlpha = 1.0 - smoothstep(progress - capSoften, progress, p);
    
    float4 activeColor = float4(color.rgb * liquidMult, color.a);
    float4 bgColor = float4(color.rgb * 0.25, bgAlpha);
    
    float4 finalColor = lerp(bgColor, activeColor, progressAlpha);
    
    return finalColor * ringAlpha;
}

technique ArcTechnique {
    pass P0 {
        PixelShader = compile ps_2_a PixelShaderFunction();
    }
}
