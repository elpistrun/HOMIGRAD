sampler ImageBuffer       : register(s0);
sampler MaskTexture       : register(s1); 
sampler BackgroundTexture : register(s2);

float2 C0                 : register(c0);
float2 BUFFER_PIXEL_SIZE  : register(c1);
// C2.x = Bleed Weight, C2.y = Depth Threshold, C2.z = Falloff Curve, C2.w = Bleed Search Radius
float4 C2                 : register(c2); 

struct PS_INPUT
{
    float2 pPos      : VPOS;
    float2 vTexCoord : TEXCOORD0;
};

// Poisson disk samples (pre‑computed)
static const float2 poisson[12] =
{
    float2(-0.326, -0.406), float2(-0.840, -0.074), float2(-0.696,  0.457), float2(-0.203,  0.621),
    float2( 0.962, -0.195), float2( 0.473, -0.480), float2( 0.519,  0.767), float2( 0.185, -0.893),
    float2( 0.507,  0.064), float2( 0.896,  0.412), float2(-0.322, -0.933), float2(-0.792, -0.598)
};

half4 main(PS_INPUT i) : COLOR
{
    float2 uv = i.vTexCoord.xy;

    half centerMask   = tex2Dlod(MaskTexture, float4(uv, 0.0, 0.0)).r;
    float4 centerSamp = tex2Dlod(ImageBuffer, float4(uv, 0.0, 0.0));
    
    // early exit
    if (centerMask >= 0.995h) return half4(centerSamp.rgb, 1.0h);

    float2 off2x = float2(BUFFER_PIXEL_SIZE.x * 2.0, 0.0);
    float2 off2y = float2(0.0, BUFFER_PIXEL_SIZE.y * 2.0);
    
    float trueDepth = min(centerSamp.a, min(
        min(tex2Dlod(ImageBuffer, float4(uv + off2y, 0.0, 0.0)).a, tex2Dlod(ImageBuffer, float4(uv - off2y, 0.0, 0.0)).a),
        min(tex2Dlod(ImageBuffer, float4(uv + off2x, 0.0, 0.0)).a, tex2Dlod(ImageBuffer, float4(uv - off2x, 0.0, 0.0)).a)
    ));

    float t = saturate(trueDepth / max(C0.y, 1e-5));
    float trueFocus = 1.0 - t * t;
    
    // early exit
    if (trueFocus <= 0.001) return half4(centerSamp.rgb, 1.0h);

    float s, c;
    sincos(frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453), s, c);

    float2 bleedRad = BUFFER_PIXEL_SIZE * C2.w;
    float2 blurRad  = BUFFER_PIXEL_SIZE * (C0.x * trueFocus);
    
    float2x2 bleedMat = float2x2(c * bleedRad.x, -s * bleedRad.x, s * bleedRad.y, c * bleedRad.y);
    float2x2 blurMat  = float2x2(c * blurRad.x,  -s * blurRad.x,  s * blurRad.y,  c * blurRad.y);

    float depthThresh = trueDepth + C2.y;
    float bgHits = 0.0;
    half3 col = (half3)0.0;
    float totalWeight = 0.0; 

    [unroll]
    for (int j = 0; j < 12; ++j)
    {
        float2 p = poisson[j];

        float2 bleedCoord = uv + mul(bleedMat, p);
        float bleedDepth  = tex2Dlod(ImageBuffer, float4(bleedCoord, 0.0, 0.0)).a;
        half bleedMask    = tex2Dlod(MaskTexture, float4(bleedCoord, 0.0, 0.0)).r;
        
        bgHits += step(depthThresh, bleedDepth) * step(bleedMask, 0.199);

        float2 blurCoord = uv + mul(blurMat, p);
        half blurMask    = tex2Dlod(MaskTexture, float4(blurCoord, 0.0, 0.0)).r;
        
        float sampleWeight = step(blurMask, 0.199);
        col += (half3)tex2Dlod(ImageBuffer, float4(blurCoord, 0.0, 0.0)).rgb * sampleWeight;
        totalWeight += sampleWeight;
    }

    col = (totalWeight > 1e-4) ? (col / totalWeight) : centerSamp.rgb;

    float edgeFactor = min(bgHits * 0.1666667, 1.0); 
    float bleedWeight = pow(saturate(edgeFactor * trueFocus * C2.x), max(C2.z, 1e-4));

    half3 bgColor = (half3)tex2Dlod(BackgroundTexture, float4(uv, 0.0, 0.0)).rgb;
    
    col = lerp(col, bgColor, bleedWeight);
    col = lerp(col, centerSamp.rgb, centerMask);

    return half4(col, 1.0h);
}