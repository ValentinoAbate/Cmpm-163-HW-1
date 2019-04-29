//Code taken from https://github.com/PacktPublishing/Unity-2018-Shaders-and-Effects-Cookbook-Third-Edition by Doran and Zucconi 

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RenderEffectBSC : MonoBehaviour {

    public Shader curShader;
    public float intensity = 1.0f;
    private Material screenMat;
  
    Material ScreenMat
    {
        get
        {
            if (screenMat == null)
            {
                screenMat = new Material(curShader);
                screenMat.hideFlags = HideFlags.HideAndDontSave;
            }
            return screenMat;
        }
    }


    void Start()
    {
        if (!SystemInfo.supportsImageEffects)
        {
            enabled = false;
            return;
        }

        if (!curShader && !curShader.isSupported)
        {
            enabled = false;
        }
    }

    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        if (curShader != null)
        {
            ScreenMat.SetFloat("_Intensity", intensity);

            Graphics.Blit(sourceTexture, destTexture, ScreenMat);
        }
        else
        {
            Graphics.Blit(sourceTexture, destTexture);
        }
    }

    void Update()
    {
        intensity = Mathf.Clamp(Input.mousePosition.x / Screen.width, 0.0f, 1.0f);
    }

    void OnDisable()
    {
        if (screenMat)
        {
            DestroyImmediate(screenMat);
        }
    }
}
