// 1. MTA Variables
float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;
float4x4 gWorld : WORLD;
float3 gCameraPosition : CAMERAPOSITION;

texture gTexture;

sampler2D BaseSampler = sampler_state
{
    Texture = <gTexture>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
};

// 2. Stripped down input to prevent memory shifting
struct VSInput
{
    float3 Position : POSITION;
    float3 Normal   : NORMAL;
    float2 TexCoord : TEXCOORD0; 
};

struct PSInput
{
    float4 Position : POSITION;
    float3 WorldPos : TEXCOORD0;
    float3 Normal   : TEXCOORD1;
    float2 TexCoord : TEXCOORD2;
};

// 3. VERTEX SHADER
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS;
    PS.Position = mul(float4(VS.Position, 1.0), gWorldViewProjection);
    PS.TexCoord = VS.TexCoord;
    PS.WorldPos = mul(float4(VS.Position, 1.0), gWorld).xyz;
    PS.Normal   = mul(VS.Normal, (float3x3)gWorld);
    return PS;
}

// 4. PIXEL SHADER
float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    float3 normal = normalize(PS.Normal);
    float3 viewDir = normalize(gCameraPosition - PS.WorldPos);
    
    // The Fake Sun
    float3 lightDir = normalize(float3(-0.8, -0.8, -0.6));
     
    // Shadows
    float nDotL = max(dot(normal, -lightDir), 0.0);
    float ambient = 0.3; // High ambient so shadows aren't pitch black
    float diffuseInt = ambient + (nDotL * 0.4); 
    
    // Metal Shine
    float3 reflectDir = reflect(lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 30.0); 
    float3 specColor = spec * float3(0.95, 0.83, 0.37);
    
    // Grab the texture
    float4 texColor = tex2D(BaseSampler, PS.TexCoord);
    
    // ==========================================
    // THE FAILSAFE HACK
    // If RenderWare drops the UV map and renders black, 
    // inject a mathematical mustard-gold base color!
    // ==========================================
    if (texColor.r < 0.1 && texColor.g < 0.1) {
        texColor = float4(0.85, 0.65, 0.15, 1.0); 
    }
    
    // Blend the color, shadows, and shine
    float3 finalColor = (texColor.rgb * diffuseInt) + specColor;
    
    return float4(finalColor, 1.0);
}

// 5. Technique
technique metallic_gold
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader  = compile ps_2_0 PixelShaderFunction();
    }
}