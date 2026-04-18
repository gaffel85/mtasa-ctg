
float4 color = float4(1, 1, 1, 1);
float thickness = 2.0;
float2 size = float2(40, 40);
float radius = 5.0;

struct PSInput {
    float2 TexCoord : TEXCOORD0;
    float4 Color : COLOR0;
};

float4 PixelShaderFunction(PSInput input) : COLOR0 {
    float2 p = (input.TexCoord - 0.5) * size;
    float2 q = abs(p) - (size * 0.5 - radius);
    float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
    
    // Smooth border mask
    float mask = smoothstep(-thickness - 1.5, -thickness, d) * (1.0 - smoothstep(-1.5, 1.0, d));
    
    if (mask <= 0) return float4(0,0,0,0);
    
    // More pronounced directional relief
    // We calculate a diagonal gradient for the lighting
    float lightDir = (input.TexCoord.x + input.TexCoord.y) - 1.0; // -1 to 1
    
    float4 finalColor = color;
    
    // Stronger contrast for relief
    if (lightDir < 0) {
        finalColor.rgb *= 1.6; // Strong highlight on top-left
    } else {
        finalColor.rgb *= 0.3; // Strong shadow on bottom-right
    }
    
    return finalColor * mask;
}

technique ReliefTechnique {
    pass P0 {
        PixelShader = compile ps_2_a PixelShaderFunction();
    }
}
