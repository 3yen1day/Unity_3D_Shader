using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class text : MonoBehaviour
{
    public Text Qtext;
    float a_color;
    // Use this for initialization
    void Start()
    {
        a_color = 0.8f;
    }

    // Update is called once per frame
    void Update()
    {
            //テキストの透明度を変更する
            Qtext.color = new Color(1, 1, 1, a_color);
    }
}
