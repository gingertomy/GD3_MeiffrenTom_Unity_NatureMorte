#ifndef KUWAHARA_INCLUDED
#define KUWAHARA_INCLUDED

void Kuwahara_float(UnityTexture2D Tex, UnitySamplerState SS, float2 UV, float Radius, out float3 Out)
{
    int r = max(1, (int) Radius);
    float2 texel = 1.0 / _ScreenParams.xy;
    float n = (r + 1) * (r + 1);

    float bestVar = 1e20;
    float3 bestMean = 0;

    [loop]
    for (int q = 0; q < 4; q++)
    {
        // Décalage du quadrant : 0 = haut-gauche, 1 = haut-droite, 2 = bas-droite, 3 = bas-gauche
        int ox = (q == 0 || q == 3) ? -r : 0;
        int oy = (q < 2) ? -r : 0;

        float3 sum = 0;
        float sumL = 0;
        float sumL2 = 0;

        [loop]
        for (int j = 0; j <= r; j++)
        {
            [loop]
            for (int i = 0; i <= r; i++)
            {
                float2 uv = UV + float2(ox + i, oy + j) * texel;
                float3 c = SAMPLE_TEXTURE2D_LOD(Tex.tex, SS.samplerstate, uv, 0).rgb;
                float l = dot(c, float3(0.299, 0.587, 0.114));
                sum += c;
                sumL += l;
                sumL2 += l * l;
            }
        }

        float3 mean = sum / n;
        float meanL = sumL / n;
        float variance = sumL2 / n - meanL * meanL;

        if (variance < bestVar)
        {
            bestVar = variance;
            bestMean = mean;
        }
    }

    Out = bestMean;
}

#endif