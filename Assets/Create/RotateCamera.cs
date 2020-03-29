using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateCamera : MonoBehaviour
{
	private Transform tr;
	Camera_Move_Rotate c;

	void Start()
	{
		tr = GetComponent<Transform>();
		c = new Camera_Move_Rotate();
	}

	void Update()
    {
		c.Rotare(tr);
    }
}
