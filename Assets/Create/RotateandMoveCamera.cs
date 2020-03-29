using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateandMoveCamera : MonoBehaviour
{
	private Transform tr;
	Camera_Move_Rotate c;
	public float speed = 1.0f;

	void Start()
	{
		tr = GetComponent<Transform>();
		c = new Camera_Move_Rotate();
	}

	void Update()
	{
		c.Rotare(tr);
		c.Move(tr, speed);
	}
}
