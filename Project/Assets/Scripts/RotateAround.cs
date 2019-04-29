using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateAround : MonoBehaviour
{
    public float width = 0;
    public float height = 0;
    public float depth = 0;
    public float speedMultiplier = 0;
    Vector3 origin;
    float time = 0;
    public bool wonky = false;
    // Start is called before the first frame update
    void Start()
    {
        origin = transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        time += Time.deltaTime * speedMultiplier;

        float x = origin.x + (Mathf.Cos(time) * width);
        float y = origin.y + ((wonky ? Mathf.Tan(time) : Mathf.Sin(time)) * height);
        float z = origin.z + ((wonky ? Mathf.Tan(time) : Mathf.Sin(time)) * depth);

        transform.position = new Vector3(x, y, z);
    }
}
