using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PingPong_CellularAutomata : MonoBehaviour
{
    Texture2D texA;
    Texture2D texB;
    Texture2D inputTex;
    Texture2D outputTex;
    RenderTexture rt1;

    public Shader cellularAutomataShader;
    public Shader ouputTextureShader;

    public int width;
    public int height;

    Renderer rend;
    int count = 0;
    const int stages = 10;
    const float stageAmt = 1f / stages;

    public float step;
    float time = 0;

    void Start()
    {
        //print(SystemInfo.copyTextureSupport);

        texA = new Texture2D(width, height, TextureFormat.RGBA32, false);
        texB = new Texture2D(width, height, TextureFormat.RGBA32, false);

        texA.filterMode = FilterMode.Point;
        texB.filterMode = FilterMode.Point;

        for (int i = 0; i < height; i++)
        {
            for (int j = 0; j < width; j++)
            {
                int stage = Random.Range(0, stages);
                float val = stageAmt * stage;
                texA.SetPixel(i, j, new Color(val, val, val, 1));
            }
        }


        texA.Apply(); //copy changes to the GPU


        rt1 = new RenderTexture(width, height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
   

        rend = GetComponent<Renderer>();

        cellularAutomataShader = Shader.Find("Custom/RenderToTexture_CA");
        ouputTextureShader = Shader.Find("Custom/OutputTexture");

    }

   
    void Update()
    {
        time += Time.deltaTime;
        if (time < step)
            return;
        time = 0;
        //set active shader to be a shader that computes the next timestep
        //of the Cellular Automata system
        rend.material.shader = cellularAutomataShader;
      
        if (count % 2 == 0)
        {
            inputTex = texA;
            outputTex = texB;
        }
        else
        {
            inputTex = texB;
            outputTex = texA;
        }


        rend.material.SetTexture("_MainTex", inputTex);

        //source, destination, material
        Graphics.Blit(inputTex, rt1, rend.material);
        Graphics.CopyTexture(rt1, outputTex);


        //set the active shader to be a regular shader that maps the current
        //output texture onto a game object
        rend.material.shader = ouputTextureShader;
        rend.material.SetTexture("_MainTex", outputTex);
       

        count++;
    }
}
