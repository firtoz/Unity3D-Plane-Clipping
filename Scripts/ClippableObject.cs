using UnityEngine;
using System.Collections;
using System.Linq;

[ExecuteInEditMode]
public class ClippableObject : MonoBehaviour {
    public void OnEnable() {
        //let's just create a new material instance.
        GetComponent<MeshRenderer>().sharedMaterial = new Material(Shader.Find("Custom/StandardClippable")) {
            hideFlags = HideFlags.HideAndDontSave
        };
    }

    public void Start() { }

    //only 3 clip planes for now, will need to modify the shader for more.
    [Range(0, 3)]
    public int clipPlanes = 0;

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
    private void DrawPlane(Vector3 position, Vector3 euler) {
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

    private void OnDrawGizmosSelected() {
        if (clipPlanes >= 1) {
            DrawPlane(plane1Position, plane1Rotation);
        }
        if (clipPlanes >= 2) {
            DrawPlane(plane2Position, plane2Rotation);
        }
        if (clipPlanes >= 3) {
            DrawPlane(plane3Position, plane3Rotation);
        }
    }

    //Ideally the planes do not need to be updated every frame, but we'll just keep the logic here for simplicity purposes.
    public void Update()
    {
        var sharedMaterial = GetComponent<MeshRenderer>().sharedMaterial;

        //Only should enable one keyword. If you want to enable any one of them, you actually need to disable the others. 
        //This may be a bug...
        switch (clipPlanes) {
            case 0:
                sharedMaterial.DisableKeyword("CLIP_ONE");
                sharedMaterial.DisableKeyword("CLIP_TWO");
                sharedMaterial.DisableKeyword("CLIP_THREE");
                break;
            case 1:
                sharedMaterial.EnableKeyword("CLIP_ONE");
                sharedMaterial.DisableKeyword("CLIP_TWO");
                sharedMaterial.DisableKeyword("CLIP_THREE");
                break;
            case 2:
                sharedMaterial.DisableKeyword("CLIP_ONE");
                sharedMaterial.EnableKeyword("CLIP_TWO");
                sharedMaterial.DisableKeyword("CLIP_THREE");
                break;
            case 3:
                sharedMaterial.DisableKeyword("CLIP_ONE");
                sharedMaterial.DisableKeyword("CLIP_TWO");
                sharedMaterial.EnableKeyword("CLIP_THREE");
                break;
        }

        //pass the planes to the shader if necessary.
        if (clipPlanes >= 1)
        {
            sharedMaterial.SetVector("_planePos", plane1Position);
            //plane normal vector is the rotated 'up' vector.
            sharedMaterial.SetVector("_planeNorm", Quaternion.Euler(plane1Rotation) * Vector3.up);
        }

        if (clipPlanes >= 2)
        {
            sharedMaterial.SetVector("_planePos2", plane2Position);
            sharedMaterial.SetVector("_planeNorm2", Quaternion.Euler(plane2Rotation) * Vector3.up);
        }

        if (clipPlanes >= 3)
        {
            sharedMaterial.SetVector("_planePos3", plane3Position);
            sharedMaterial.SetVector("_planeNorm3", Quaternion.Euler(plane3Rotation) * Vector3.up);
        }
    }
}
