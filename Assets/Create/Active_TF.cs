using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Active_TF : MonoBehaviour
{

	public GameObject MainC;
	public GameObject SubC;
	bool TF = true;

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
		{
			TF = !TF;
			MainC.SetActive(TF);
			SubC.SetActive(!TF);
		}
    }
}
