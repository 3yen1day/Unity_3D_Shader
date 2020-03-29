using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class NoiseController : MonoBehaviour
{
    float NoiseInterval;
    float IntervalTime;

    void Awake()
    {
        //インターバル設定
        NoiseInterval = Random.Range(1.0f, 3.0f);
	}

    IEnumerator GeneratePulseNoise()
    {
        //ランダム値設定
        int size = Random.Range(-20, 21);
        int j = Random.Range(1, 3) * 180;
        int k = Random.Range(6, 11) * 10;


        for (int i= Random.Range(-360, 1); i <= j; i += k)
        {
            if(i+k>j ){
                i = j;
        }
            GetComponent<Renderer>().material.SetFloat("_Amount", 0.1f * Mathf.Sin(i * Mathf.Deg2Rad));
            GetComponent<Renderer>().material.SetFloat("_Size", size);
            yield return null;
        }
    }

    void Update()
    {
        transform.Rotate(new Vector3(0, 0.2f, 0));

        IntervalTime += Time.deltaTime;

        if (IntervalTime >= NoiseInterval)
        {
            StartCoroutine(GeneratePulseNoise());
            IntervalTime = 0;
            NoiseInterval = Random.Range(1.0f, 3.0f);
        }
    }
}