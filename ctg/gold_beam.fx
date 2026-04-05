// ctg/gold_beam.fx
texture gTexture;
float gTime;

sampler2D BaseSampler = sampler_state
{
    Texture = <gTexture>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};

struct VSInput
{
    float3 Position : POSITION;
    float4 Color    : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

struct PSInput
{
    float4 Position : POSITION;
    float4 Color    : COLOR0;
    float2 TexCoord : TEXCOORD1;
};

PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS;
    PS.Position = mul(float4(VS.Position, 1.0), 1); // MTA handles this if we use dxDrawMaterialLine3D
    PS.TexCoord = VS.TexCoord;
    PS.Color = VS.Color;
    return PS;
}

float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    // Scroll the V coordinate downwards over time
    float2 scrolledUV = PS.TexCoord;
    scrolledUV.y += gTime * 2.0; 
    
    float4 texColor = tex2D(BaseSampler, scrolledUV);
    
    // Brighten the beam and apply vertex color
    return texColor * PS.Color * 2.0;
}

technique beam_tech
{
    pass P0
    {
        VertexShader = null; // Use MTA's default vertex processing for 3D lines
        PixelShader  = compile ps_2_0 PixelShaderFunction();
    }
}
