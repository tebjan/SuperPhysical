//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 

uint materialID;

int IntanceStartIndex = 0;
StructuredBuffer<float4x4> world;

struct gBuffer{
	
	float4 pos : COLOR0;
	float4 norm : COLOR1;
	float4 uv : COLOR2;
	
};

struct vsInput
{
	uint ii : SV_InstanceID;
    float4 posObject : POSITION;
	float3 norm : NORMAL;
	float4 uv: TEXCOORD0;
};

struct psInput
{
	uint ii : SV_InstanceID;
    float4 posScreen : SV_Position;
	float4 posW : POSW;
	float3 norm : NORMAL;
	float4 uv: TEXCOORD0;
};


cbuffer cbPerDraw : register(b0)
{
	float4x4 tVP : LAYERVIEWPROJECTION;
	float4x4 tWI : WORLDINVERSE;
	float4x4 tW : WORLD;
	float4x4 tV : VIEW;
	float4x4 tP : PROJECTION;
};


cbuffer cbTextureData : register(b2)
{
	float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;
};

psInput VS(vsInput input)
{
	/*Here we look up for local world transform using
	the object instance id and start offset*/
	float4x4 wo = world[input.ii + IntanceStartIndex];
	
	/* the WORLD transform applies to the 
	whole batch in case of instancing, so we can transform 
	all the batch at once using it */
	wo = mul(wo,tW);
	
	float4x4 wv = mul(wo,tV);
		
	psInput output;
	output.posW = mul(input.posObject, wo);
	output.posScreen = mul(input.posObject,mul(wo,tVP));
	output.norm = normalize( mul(mul(input.norm, (float3x3)wo), (float3x3)transpose(tWI)) );
	output.uv = input.uv;
	output.ii = input.ii;
	return output;
}



gBuffer PS(psInput input): SV_Target

{
	gBuffer output;
	
	output.pos = input.posW;
	output.norm = float4(input.norm,(float) materialID * 0.001);
	output.uv = input.uv;
	
	return output;

}



technique11 GBuffer
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}




