using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Metaballs
{
	public class RayMarchSphere : MonoBehaviour
	{
		[SerializeField] private float scale;
		[SerializeField] private Color color;
		[SerializeField] private RayMarch marcher;
		[SerializeField] private int id;
		[SerializeField] private Vector3 movement;
		public void CreateSphere(float scale, Color color, RayMarch marcher, int id)
		{
			this.scale = scale;
			this.color = color;
			this.marcher = marcher;
			this.id = id;

			movement = new Vector3(Random.Range(0.1f, 2.0f), Random.Range(0.1f, 2.0f), Random.Range(0.1f, 2.0f));
		}

		private void FixedUpdate()
		{
			if(transform.position.x > 10.0f || transform.position.x < -10.0f)
			{
				movement.x = -movement.x;
			}
			if(transform.position.y > 10.0f || transform.position.y < -10.0f)
			{
				movement.y = -movement.y;
			}
			if (transform.position.z > 10.0f || transform.position.z < 0.0f)
			{
				movement.z = -movement.z;
			}

			transform.position += movement * Time.deltaTime;

			marcher.UpdateSphere(new Vector4(transform.position.x, transform.position.y, transform.position.z, scale), color, id);
		}
	}
}