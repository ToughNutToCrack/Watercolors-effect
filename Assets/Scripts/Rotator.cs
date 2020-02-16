
using UnityEngine;

public class Rotator : MonoBehaviour{
    public float power;
    public Vector3 dir;

    void Update(){
        transform.Rotate(dir * power);
    }
}
