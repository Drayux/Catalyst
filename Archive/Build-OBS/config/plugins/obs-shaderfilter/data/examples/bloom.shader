// Bloom shader by Charles Fettinger for obs-shaderfilter plugin 3/2019
//https://github.com/Oncorporation/obs-shaderfilter
//Converted to OpenGL by Exeldro February 15, 2022
uniform int Angle_Steps<
    string label = "Angle Steps";
    string widget_type = "slider";
    int minimum = 1;
    int maximum = 20;
    int step = 1;
> = 5; //<range 1 - 20>
uniform int Radius_Steps<
    string label = "Radius Steps";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 20;
    int step = 1;
> = 9; //<range 0 - 20>
uniform float ampFactor<
    string label = "amp Factor";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 10.0;
    float step = 0.01;
> = 2.0;
uniform string notes<
    string widget_type = "info";
> = "Steps limited in range from 0 to 20. Edit bloom.shader to remove limits at your own risk.";

float4 mainImage(VertData v_in) : TARGET
{
	int radiusSteps = clamp(Radius_Steps, 0, 20);
	int angleSteps = clamp(Angle_Steps, 1, 20);
	float PI = 3.1415926535897932384626433832795;//acos(-1);
	float minRadius = (0.0 * uv_pixel_interval.y);
	float maxRadius = (10.0 * uv_pixel_interval.y);

	float4 c0 = image.Sample(textureSampler, v_in.uv);
	float4 outputPixel = c0;
	float4 accumulatedColor = float4(0,0,0,0);

	int totalSteps = radiusSteps * angleSteps;
	float angleDelta = (2.0 * PI) / float(angleSteps);
	float radiusDelta = (maxRadius - minRadius) / float(radiusSteps);

	for (int radiusStep = 0; radiusStep < radiusSteps; radiusStep++) {
		float radius = minRadius + float(radiusStep) * radiusDelta;

		for (float angle=0.0; angle <(2.0*PI); angle += angleDelta) {
			float2 currentCoord;

			float xDiff = radius * cos(angle);
			float yDiff = radius * sin(angle);
			
			currentCoord = v_in.uv + float2(xDiff, yDiff);
			float4 currentColor =image.Sample(textureSampler, currentCoord);
			float currentFraction = float(radiusSteps+1 - radiusStep) / float(radiusSteps + 1);

			accumulatedColor +=   currentFraction * currentColor / float(totalSteps);
			
		}
	}

	outputPixel += accumulatedColor * ampFactor;

	return outputPixel;
}
