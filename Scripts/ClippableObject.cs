using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

[ExecuteInEditMode]
public class ClippableObject : MonoBehaviour
{
    public void OnEnable()
    {
        //let's just create a new material instance.
        var sharedMaterial = GetComponent<MeshRenderer>().sharedMaterial;

        if (sharedMaterial.shader.name != "Custom/StandardClippableV2")
        {
            Debug.Log(sharedMaterial.shader.name);

            sharedMaterial = new Material(Shader.Find("Custom/StandardClippableV2"))
            {
                hideFlags = HideFlags.HideAndDontSave
            };

            GetComponent<MeshRenderer>().sharedMaterial = sharedMaterial;
        }

        UpdateClipPlanes(sharedMaterial);
    }

    public void Start()
    {
    }

    //only 3 clip planes for now, will need to modify the shader for more.
    [Range(0, 3)] public int clipPlanes = 0;

    //preview size for the planes. Shown when the object is selected.
    public float planePreviewSize = 5.0f;

    //Positions and rotations for the planes. The rotations will be converted into normals to be used by the shaders.
    public Vector3 plane1Position = Vector3.zero;

    public Vector3 plane1Rotation = new Vector3(0, 0, 0);

    public Vector3 plane2Position = Vector3.zero;
    public Vector3 plane2Rotation = new Vector3(0, 90, 90);

    public Vector3 plane3Position = Vector3.zero;
    public Vector3 plane3Rotation = new Vector3(0, 0, 90);

    //Only used for previewing a plane. Draws diagonals and edges of a limited flat plane.
    private void DrawPlane(Vector3 position, Vector3 euler)
    {
        var forward = Quaternion.Euler(euler) * Vector3.forward;
        var left = Quaternion.Euler(euler) * Vector3.left;

        var forwardLeft = position + forward * planePreviewSize * 0.5f + left * planePreviewSize * 0.5f;
        var forwardRight = forwardLeft - left * planePreviewSize;
        var backRight = forwardRight - forward * planePreviewSize;
        var backLeft = forwardLeft - forward * planePreviewSize;

        Gizmos.DrawLine(position, forwardLeft);
        Gizmos.DrawLine(position, forwardRight);
        Gizmos.DrawLine(position, backRight);
        Gizmos.DrawLine(position, backLeft);

        Gizmos.DrawLine(forwardLeft, forwardRight);
        Gizmos.DrawLine(forwardRight, backRight);
        Gizmos.DrawLine(backRight, backLeft);
        Gizmos.DrawLine(backLeft, forwardLeft);
    }

    private void OnDrawGizmosSelected()
    {
        if (clipPlanes >= 1)
        {
            DrawPlane(plane1Position, plane1Rotation);
        }
        if (clipPlanes >= 2)
        {
            DrawPlane(plane2Position, plane2Rotation);
        }
        if (clipPlanes >= 3)
        {
            DrawPlane(plane3Position, plane3Rotation);
        }
    }

    public static readonly string[] ClipKeywords = {
        "CLIP_ONE",
        "CLIP_TWO",
        "CLIP_THREE"
    };

    private int _clipPlanesCache = -1;

    private void UpdateClipPlanes(Material material)
    {
        var extraKeywords = new List<string>();

        if (clipPlanes >= 1 && clipPlanes <= 3)
        {
            for (var i = 0; i < ClipKeywords.Length; i++)
            {
                var clipKeyword = ClipKeywords[i];

                var indexInClipKeywords = i + 1;

                if (clipPlanes == indexInClipKeywords)
                {
                    Debug.LogFormat("Enabling {0}", clipKeyword);
                    material.EnableKeyword(clipKeyword);
                    extraKeywords.Add(clipKeyword);
                }
                else
                {
                    material.DisableKeyword(clipKeyword);
                }
            }
        }
        else
        {
            foreach (var clipKeyword in ClipKeywords)
            {
                material.DisableKeyword(clipKeyword);
            }
        }
    }

    //Ideally the planes do not need to be updated every frame, but we'll just keep the logic here for simplicity purposes.
    public void Update()
    {
        var sharedMaterial = GetComponent<MeshRenderer>().sharedMaterial;

        if (_clipPlanesCache != clipPlanes)
        {
            //Only should enable one keyword. If you want to enable any one of them, you actually need to disable the others. 
            //This may be a bug...
            UpdateClipPlanes(sharedMaterial);

            _clipPlanesCache = clipPlanes;
        }

        //pass the planes to the shader if necessary.
        if (clipPlanes >= 1)
        {
            sharedMaterial.SetVector("_planePos", plane1Position);
            //plane normal vector is the rotated 'up' vector.
            sharedMaterial.SetVector("_planeNorm", Quaternion.Euler(plane1Rotation) * Vector3.up);

            if (clipPlanes >= 2)
            {
                sharedMaterial.SetVector("_planePos2", plane2Position);
                sharedMaterial.SetVector("_planeNorm2", Quaternion.Euler(plane2Rotation) * Vector3.up);

                if (clipPlanes >= 3)
                {
                    sharedMaterial.SetVector("_planePos3", plane3Position);
                    sharedMaterial.SetVector("_planeNorm3", Quaternion.Euler(plane3Rotation) * Vector3.up);
                }
            }
        }
    }
}