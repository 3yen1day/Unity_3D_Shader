using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneTransfar : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
		if (Input.GetKeyDown(KeyCode.RightArrow))
		{
			if (SceneManager.GetActiveScene().name.Equals("SampleScene")) SceneManager.LoadScene("KougakuMeisai");
			else if (SceneManager.GetActiveScene().name.Equals("KougakuMeisai")) SceneManager.LoadScene("Hisyakai");
			else if (SceneManager.GetActiveScene().name.Equals("Hisyakai")) SceneManager.LoadScene("Kairal");
			else if (SceneManager.GetActiveScene().name.Equals("Kairal")) SceneManager.LoadScene("SampleScene");
		}else if (Input.GetKeyDown(KeyCode.LeftArrow))
		{
			if (SceneManager.GetActiveScene().name.Equals("SampleScene")) SceneManager.LoadScene("Kairal");
			else if (SceneManager.GetActiveScene().name.Equals("Kairal")) SceneManager.LoadScene("Hisyakai");
			else if (SceneManager.GetActiveScene().name.Equals("Hisyakai")) SceneManager.LoadScene("KougakuMeisai");
			else if (SceneManager.GetActiveScene().name.Equals("KougakuMeisai")) SceneManager.LoadScene("SampleScene");
		}
	}
}
