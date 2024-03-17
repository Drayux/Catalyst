//Converted to OpenGL by Q-mii & Exeldro February 25, 2022
uniform float4 color;
uniform float lumaMax<
    string label = "Luma Max";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 10.0;
    float step = 0.001;
> = 1.05;
uniform float lumaMin<
    string label = "Luma Min";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 10.0;
    float step = 0.001;
> = 0.01;
uniform float lumaMaxSmooth<
    string label = "Luma Max Smooth";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 10.0;
    float step = 0.001;
> = 0.10;
uniform float lumaMinSmooth<
    string label = "Luma Min Smooth";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 10.0;
    float step = 0.001;
> = 0.01;
uniform bool invertImageColor;
uniform bool invertAlphaChannel;
uniform string notes<
    string widget_type = "info";
> = "'luma max' - anything above will be transparent. 'luma min' - anything below will be transparent. 'luma(min or max)Smooth - make the transparency fade in or out by a distance. 'invert color' - inverts the color of the screen. 'invert alpha channel' - flips all settings on thier head, which is excellent for testing.";

float4 InvertColor(float4 rgba_in)
{	
	rgba_in.r = 1.0 - rgba_in.r;
	rgba_in.g = 1.0 - rgba_in.g;
	rgba_in.b = 1.0 - rgba_in.b;
	rgba_in.a = 1.0 - rgba_in.a;
	return rgba_in;
}

float4 mainImage(VertData v_in) : TARGET
{

	float4 rgba = image.Sample(textureSampler, v_in.uv);
    if (rgba.a > 0.0)
    {
    
    if (invertImageColor)
    {
        rgba = InvertColor(rgba);
    }
    float luminance = rgba.r * color.r * 0.299 + rgba.g * color.g * 0.587 + rgba.b * color.b * 0.114;

	//intensity = min(max(intensity,minIntensity),maxIntensity);
    float clo = smoothstep(lumaMin, lumaMin + lumaMinSmooth, luminance);
    float chi = 1. - smoothstep(lumaMax - lumaMaxSmooth, lumaMax, luminance);

    float amask = clo * chi;

    if (invertAlphaChannel)
    {
        amask = 1.0 - amask;
    }
    rgba *= color;
    rgba.a = clamp(amask, 0.0, 1.0);
        
    }
	return rgba;
}
