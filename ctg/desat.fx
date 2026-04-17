texture ScreenSource;

sampler TextureSampler = sampler_state
{
    Texture = <ScreenSource>;
};

float4 PixelShaderFunction(float2 TextureCoordinate : TEXCOORD0) : COLOR0
{
    float4 color = tex2D(TextureSampler, TextureCoordinate);
    float grey = dot(color.rgb, float3(0.299, 0.587, 0.114));
    return float4(grey, grey, grey, color.a);
}

technique Desaturate
{
    pass P0
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}
