using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Metaballs
{
	[RequireComponent(typeof(Camera)), ExecuteInEditMode]
	public class RayMarch : MonoBehaviour
	{
		[SerializeField] private Shader rayMarchShader;
		[SerializeField] private Material rayMarchMaterial;
		[SerializeField] private Camera mainCamera;
		[SerializeField] private float maxDistance;
		[SerializeField] private Transform sunLight;
		[SerializeField] private Color rayMarchColor;
		[SerializeField] private Vector4[] spheres;
		[SerializeField] private Color[] colors;
		private int sphereCount;

		public void Init(int numberOfSpheres)
		{
			spheres = new Vector4[numberOfSpheres];
			colors = new Color[numberOfSpheres];
			sphereCount = 0;
		}

		public void AddSphere(Vector4 sphereData, Color color, int index)
		{
			spheres[index] = sphereData;
			colors[index] = color;
			sphereCount++;
		}

		private void OnRenderImage(RenderTexture source, RenderTexture destination)
		{
			if(!rayMarchMaterial)
			{
				Graphics.Blit(source, destination);
				return;
			}
			else if(sphereCount < 1)
			{
				Graphics.Blit(source, destination);
				return;
			}

			rayMarchMaterial.SetMatrix("_CameraFrustum", CameraFrustum(mainCamera));
			rayMarchMaterial.SetMatrix("_CameraViewMatrix", mainCamera.cameraToWorldMatrix);
			rayMarchMaterial.SetFloat("_MaxDistance", maxDistance);
			rayMarchMaterial.SetVector("_LightDirection", sunLight.forward);
			rayMarchMaterial.SetColor("_MainColor", rayMarchColor);
			rayMarchMaterial.SetVectorArray("_Spheres", spheres);
			rayMarchMaterial.SetColorArray("_Colors", colors);
			rayMarchMaterial.SetInt("_SphereCount", sphereCount);

			RenderTexture.active = destination;
			rayMarchMaterial.SetTexture("_MainTex", source);

			GL.PushMatrix();
			GL.LoadOrtho();
			rayMarchMaterial.SetPass(0);

			GL.Begin(GL.QUADS);

			// Bottom Left
			GL.MultiTexCoord2(0, 0, 0);
			GL.Vertex3(0, 0, 3);

			// Bottom Right
			GL.MultiTexCoord2(0, 1, 0);
			GL.Vertex3(1, 0, 2);

			//Top Right
			GL.MultiTexCoord2(0, 1, 1);
			GL.Vertex3(1, 1, 1);

			// Top Left
			GL.MultiTexCoord2(0, 0, 1);
			GL.Vertex3(0, 1, 0);

			GL.End();
			GL.PopMatrix();

		}

		private Matrix4x4 CameraFrustum(Camera mainCamera)
		{
			Matrix4x4 frustum = Matrix4x4.identity;
			float fov = Mathf.Tan(mainCamera.fieldOfView * 0.5f * Mathf.Deg2Rad);

			Vector3 up = Vector3.up * fov;
			Vector3 right = Vector3.right * fov * mainCamera.aspect;

			Vector3 cameraTopLeft = -Vector3.forward - right + up;
			Vector3 cameraTopRight = -Vector3.forward + right + up;
			Vector3 cameraBottomLeft = -Vector3.forward - right - up;
			Vector3 cameraBottomRight = -Vector3.forward + right - up;

			frustum.SetRow(0, cameraTopLeft);
			frustum.SetRow(1, cameraTopRight);
			frustum.SetRow(2, cameraBottomRight);
			frustum.SetRow(3, cameraBottomLeft);

			return frustum;
		}

		public void UpdateSphere(Vector4 sphere, Color color, int id)
		{
			spheres[id] = sphere;
			colors[id] = color;
		}
	}
}