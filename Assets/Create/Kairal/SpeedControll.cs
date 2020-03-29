using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpeedControll : MonoBehaviour
{

    private Material m;
    private bool dissolve;
    private float t = 0.0f;
    // Start is called before the first frame update
    void Start()
    {
        m = GetComponent<Renderer>().material;
        //m.DisableKeyword("_Dissolve_ON");
        //m.EnableKeyword("_Dissolve_OFF");
    }

    // Update is called once per frame
    void Update()
    {
        
        float f = (Time.time * m.GetFloat("_NoiseSpeed"))%1.0f;
        if(f >0.99f){
        //周期変化
        m.SetFloat("_NoiseSpeed",Random.Range(4.0f,6.0f) );
        }

        if (Input.GetKey(KeyCode.Space)){
            Dissolve();
        }
        if (dissolve){
            t+=Time.deltaTime;
            m.SetFloat("_T",t );
        }
    }

    void Dissolve(){
        m.SetFloat("_NoiseSize", 1.5f);
        m.SetFloat("_NoiseRange",0.96f);
        m.EnableKeyword("Dissolve_ON");
        dissolve = true;
    }
}
