using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Displace : MonoBehaviour
{
    public Material mat;
    public string floatName;
    public float stepTime;
    float time;

    // Update is called once per frame
    void Update()
    {
        time += Time.deltaTime;
        if(time >= stepTime)
        {
            time = 0;
            mat.SetFloat(floatName, Random.value /4);
        }      
    }
}
