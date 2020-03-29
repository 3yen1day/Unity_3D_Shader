using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Camera_Move_Rotate : MonoBehaviour
{
	public float speed = 1.0f;

	//マウスで回転
	public void Rotare(Transform tr)
	{
		float X_Rotation = Input.GetAxis("Mouse X");
		float Y_Rotation = Input.GetAxis("Mouse Y");
		tr.Rotate(Y_Rotation, -X_Rotation, 0);
	}

    public void Move(Transform tr, float speed)
    {
		Vector3 pos = tr.position;

		if (Input.GetKey(KeyCode.D)) pos.x += Time.deltaTime * this.speed;
		if (Input.GetKey(KeyCode.A)) pos.x -= Time.deltaTime * this.speed;
		if (Input.GetKey(KeyCode.W)) pos.z += Time.deltaTime * this.speed;
		if (Input.GetKey(KeyCode.S)) pos.z -= Time.deltaTime * this.speed;

		tr.position = pos;
    }
}
