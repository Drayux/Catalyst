// Selective Color shader by Charles Fettinger for obs-shaderfilter plugin 3/2019
//https://github.com/Oncorporation/obs-shaderfilter
//updated 4/13/2020: take into account the opacity/alpha of input image		-thanks Skeletonbow for suggestion
//Converted to OpenGL by Q-mii February 25, 2020
uniform float cutoff_Red<
    string label = "cutoff Red";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.001;
> = 0.40;
uniform float cutoff_Green<
    string label = "cutoff Green";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.001;
> = 0.025;
uniform float cutoff_Blue<
    string label = "cutoff Blue";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.001;
> = 0.25;
uniform float cutoff_Yellow<
    string label = "cutoff Yellow";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.001;
> = 0.25;
uniform float acceptance_Amplifier<
    string label = "acceptance Amplifier";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 20.0;
    float step = 0.001;
> = 5.0;

uniform bool show_Red = true;
uniform bool show_Green = true;
uniform bool show_Blue = true;
uniform bool show_Yellow = true;
uniform string notes<
    string widget_type = "info";
> = "defaults: .4,.03,.25,.25, 5.0, true,true, true, true. cuttoff higher = less color, 0 = all 1 = none.";
uniform int background_type<
  string label = "background type";
  string widget_type = "select";
  int    option_0_value = 0;
  string option_0_label = "Grey";
  int    option_1_value = 1;
  string option_1_label = "Luma";
  int    option_2_value = 2;
  string option_2_label = "White";
  int    option_3_value = 3;
  string option_3_label = "Black";
  int    option_4_value = 4;
  string option_4_label = "Transparent";
  int    option_5_value = 5;
  string option_5_label = "Background Color";
> = 0;

float4 mainImage(VertData v_in) : TARGET
{
	const float PI		= 3.1415926535897932384626433832795;//acos(-1);
	const float3 coefLuma = float3(0.2126, 0.7152, 0.0722);
	float4 color		= image.Sample(textureSampler, v_in.uv);

	float luminance 	= dot(coefLuma, color.rgb);	
	float4 gray			= float4(luminance, luminance, luminance, 1.0);

	 if (background_type == 0)
	 {
	 	luminance		= (color.r + color.g + color.b) * 0.3333;
	 	gray 			= float4(luminance,luminance,luminance, 1.0);
	 }	 	
	 //if (background_type == 1)
	 //{
	 //	gray 			= float4(luminance,luminance,luminance, 1.0);
	 //}
	 if (background_type == 2)
	 	gray 			= float4(1.0,1.0,1.0,1.0);
	 if (background_type == 3)
	 	gray 			= float4(0.0,0.0,0.0,1.0);
	 if (background_type == 4)
	 	gray.a 			=  0.01;
	 if (background_type == 5)
	 	gray 			= color;

	float redness		= max ( min ( color.r - color.g , color.r - color.b ) / color.r , 0);
	float greenness		= max ( min ( color.g - color.r , color.g - color.b ) / color.g , 0);
	float blueness		= max ( min ( color.b - color.r , color.b - color.g ) / color.b , 0);
	
	float rgLuminance	= (color.r*1.4 + color.g*0.6)/2;
	float rgDiff		= abs(color.r-color.g)*1.4;

 	float yellowness	= 0.1 + rgLuminance * 1.2 - color.b - rgDiff;

	float4 accept;
	accept.r			= float(show_Red) * (redness - cutoff_Red);
	accept.g			= float(show_Green) * (greenness - cutoff_Green);
	accept.b			= float(show_Blue) * (blueness - cutoff_Blue);
	accept[3]			= float(show_Yellow) * (yellowness - cutoff_Yellow);

	float acceptance	= max (accept.r, max(accept.g, max(accept.b, max(accept[3],0))));
	float modAcceptance	= min (acceptance * acceptance_Amplifier, 1);

	float4 result = color;
	if (result.a > 0) {
		result			= modAcceptance * color + (1.0 - modAcceptance) * gray;
		//result.a 		*= gray.a;
	}

	return result;
}
