using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;

public class Text2 : MonoBehaviour
{
    public Text Qtext;
    float a_color;
    // Use this for initialization
    void Start()
    {
        //Qtext = GetComponentInChildren<Text>();
        
        a_color = 0.8f;
    }

    // Update is called once per frame
    void Update()
    {
        DateTime dt = DateTime.Now;
        string AMPM = "a";
        string Mon = "a";

        string TimeString = dt.ToString();
        if (dt.ToString("tt") == "午前")
        {
            AMPM = "AM";
        }
        else
        {
            AMPM = "PM";
        }

        switch (Convert.ToString(dt.Month))
        {
            case "1":
                Mon = "Jan";
                break;
            case "2":
                Mon = "Feb";
                break;
            case "3":
                Mon = "Mar";
                break;
            case "4":
                Mon = "Apr";
                break;
            case "5":
                Mon = "May";
                break;
            case "6":
                Mon = "Jun";
                break;
            case "7":
                Mon = "Jul";
                break;
            case "8":
                Mon = "Aug";
                break;
            case "9":
                Mon = "Sep";
                break;
            case "10":
                Mon = "Oct";
                break;
            case "11":
                Mon = "Nob";
                break;
            case "12":
                Mon = "Dec";
                break;
        }

        string AmPmString = AMPM + "  " + dt.ToString("hh:mm") + Environment.NewLine + Mon+"." + dt.Day +" "+ dt.Year ; //12時間表示のstring型へ変換

        Qtext.text = AmPmString;


        //テキストの透明度を変更する
        Qtext.color = new Color(1, 1, 1, a_color);
        //Qtext.text = "";
    }
}
