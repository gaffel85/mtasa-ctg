
float progress = 0.0; // 0 = inactive, 1 = active
float4 color = float4(1, 0.75, 0, 1);
float bgAlpha = 0.6;
float Time = 0.0;
float2 size = float2(100, 50);
float radius = 10.0;

struct PSInput {
    float2 TexCoord : TEXCOORD0;
    float4 Color : COLOR0;
};

float4 PixelShaderFunction(PSInput input) : COLOR0 {
    // Rounded corner logic
    float2 p = (input.TexCoord - 0.5) * size;
    float2 q = abs(p) - (size * 0.5 - radius);
    float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
    float mask = 1.0 - smoothstep(-1.0, 1.0, d);
    
    if (mask <= 0) return float4(0,0,0,0);

    // Liquid flow effect (horizontal scroll)
    float wave = sin(input.TexCoord.x * 10.0 - Time * 5.0) * 0.35 + sin(input.TexCoord.x * 22.0 + Time * 3.0) * 0.15;
    float liquidMult = 1.3 + wave * 0.8;
    
    float4 activeColor = float4(color.rgb * liquidMult, color.a);
    float4 bgColor = float4(color.rgb * 0.25, bgAlpha);
    
    float4 finalColor = lerp(bgColor, activeColor, progress);
    
    return finalColor * mask;
}

technique LiquidTechnique {
    pass P0 {
        PixelShader = compile ps_2_a PixelShaderFunction();
    }
}
