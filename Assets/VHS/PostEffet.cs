using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostEffet : MonoBehaviour
{
	public Material VHS;
	[SerializeField, Range(0, 1)] float _bleeding = 0.8f;
	[SerializeField, Range(0, 1)] float _fringing = 1.0f;
	[SerializeField, Range(0, 1)] float _scanline = 0.125f;
	public RenderTexture tex;
	private float t;

	private void Start()
	{

	}


	private void Update()
	{
		t += Time.deltaTime;
		if (t >= 1.0f)
		{
			if (t > Random.Range(3.0f, 8.0f)) t = 0.0f;
		}
	}

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (tex != null) src = tex;
		VHS.SetFloat("_src", 0.5f);
		var bleedWidth = 0.04f * _bleeding;  // width of bleeding
		var bleedStep = 2.5f / src.width; // max interval of taps
		var bleedTaps = Mathf.CeilToInt(bleedWidth / bleedStep);
		var bleedDelta = bleedWidth / bleedTaps;
		var fringeWidth = 0.0025f * _fringing; // width of fringing

		VHS.SetInt("_Width", src.width);
		VHS.SetInt("_Height", src.height);
		VHS.SetInt("_BleedTaps", bleedTaps);
		VHS.SetFloat("_BleedDelta", bleedDelta);
		VHS.SetFloat("_FringeDelta", fringeWidth);
		VHS.SetFloat("_Scanline", _scanline);
		VHS.SetFloat("_NoiseY", 1.0f - t);


		Graphics.Blit(src, dest, VHS);
	}
}