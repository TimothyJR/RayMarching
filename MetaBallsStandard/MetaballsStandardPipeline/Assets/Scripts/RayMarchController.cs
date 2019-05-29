using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Metaballs
{
	public class RayMarchController : MonoBehaviour
	{
		[SerializeField] private int numberOfSpheres = 100;
		[SerializeField] private GameObject sphereObject;
		[SerializeField] private RayMarch rayMarcher;
		// Start is called before the first frame update
		void Start()
		{
			rayMarcher.Init(numberOfSpheres);

			for (int i = 0; i < numberOfSpheres; i++)
			{
				GameObject go = GameObject.Instantiate(sphereObject);
				float scale = Random.Range(0.5f, 3f);
				Color col = new Color(Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f));
				sphereObject.GetComponent<RayMarchSphere>().CreateSphere(scale, col, rayMarcher, i);
				sphereObject.transform.position = new Vector3(Random.Range(-10.0f, 10.0f), Random.Range(-10.0f, 10.0f), Random.Range(0.0f, 10.0f));

				rayMarcher.AddSphere(new Vector4(sphereObject.transform.position.x, sphereObject.transform.position.y, sphereObject.transform.position.z, scale), col, i);
			}
		}
	}

}