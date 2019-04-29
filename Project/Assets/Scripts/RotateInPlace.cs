using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateInPlace : MonoBehaviour
{
    public float speedMultiplier = 0;
    public float xSpeed;
    public float ySpeed;
    public float zSpeed;

    float time = 0;

    // Update is called once per frame
    void Update()
    {
        time += Time.deltaTime * speedMultiplier;

        float x = Mathf.Cos(time) * xSpeed;
        float y = Mathf.Sin(time) * ySpeed;
        float z = Mathf.Sin(time) * zSpeed;

        transform.rotation = new Quaternion(x,y,z,0);
    }
}
