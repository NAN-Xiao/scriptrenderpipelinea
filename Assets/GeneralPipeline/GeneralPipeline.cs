using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
namespace RederPipeline
{
    public class GeneralPipeline : RenderPipeline
    {

        CommandBuffer _buffer;
        GeneralPipelineAsset _asset;
        bool _DynamicBatching;
        bool _drawinstancing;
        int _mobileimumLightCount = 32;
        int _nonmobileimumLightCount = 256;
        static int visibleLightColorsId = Shader.PropertyToID("_VisibleLightColors");
        static int visibleLightDirectionsId = Shader.PropertyToID("_VisibleLightDirections");
        int _maximumLightCount
        {
            get
            {
                return (Application.isMobilePlatform || SystemInfo.graphicsDeviceType == GraphicsDeviceType.OpenGLCore)
             ? _mobileimumLightCount : _nonmobileimumLightCount;
            }
        }

        static ShaderTagId GpassNameId = new ShaderTagId("Gpass");
        public GeneralPipeline(GeneralPipelineAsset asset)
        {
            _asset = asset;
            _DynamicBatching = asset._dynamicBatching;
            _drawinstancing = asset._gpuinstancing;
            GraphicsSettings.lightsUseLinearIntensity = true;
        }

        protected override void Render(ScriptableRenderContext context, Camera[] cameras)
        {

            foreach (var camera in cameras)
            {
                RenderCamera(context, camera);
            }

            return;
        }

        void RenderCamera(ScriptableRenderContext context, Camera camera)
        {


            //设置渲染相关相机参数,包含相机的各个矩阵和剪裁平面等
            context.SetupCameraProperties(camera);
            //清理myCommandBuffer，设置渲染目标的颜色为灰色。
            CommandBuffer cm = new CommandBuffer();
            cm.ClearRenderTarget(true, true, Color.gray);

            //同上一节的剪裁
            ScriptableCullingParameters cullParam = new ScriptableCullingParameters();
            camera.TryGetCullingParameters(out cullParam);
            cullParam.isOrthographic = false;
            CullingResults cullResults = context.Cull(ref cullParam);

            //在剪裁结果中获取灯光并进行参数获取
            var lights = cullResults.visibleLights;
            cm.name = "Render Lights";
            int id = Shader.PropertyToID("Lcolor");
            const int maxDirectionalLights = 4;
            //将灯光参数改为参数组
            //var _LightDir0 = Shader.PropertyToID("_LightDir0");
            //var _LightColor0 = Shader.PropertyToID("_LightColor0");    
            Vector4[] DLightColors = new Vector4[maxDirectionalLights];
            Vector4[] DLightDirections = new Vector4[maxDirectionalLights];
            //针对shader中的平行光参数，映射ID
            var DLightDir = Shader.PropertyToID("_DLightDir");
            var DLightColor = Shader.PropertyToID("_DLightColor");
            //然后在render函数中增加以下代码：
            //获取灯光并传入灯光参数
            // var lights = cullResults.visibleLights;
            // myCommandBuffer.name = "Render Lights";
            int i = 0;
            foreach (var light in lights)
            {
                //判断灯光类型
                if (light.lightType != LightType.Directional) continue;
                //在限定的灯光数量下，获取参数    
                if (i < maxDirectionalLights)
                {
                    //获取灯光参数,平行光朝向即为灯光Z轴方向。矩阵第一到三列分别为xyz轴项，第四列为位置。
                    Vector4 lightpos = light.localToWorldMatrix.GetColumn(2);
                    DLightColors[i] = light.finalColor;
                    DLightDirections[i] = -lightpos;
                    DLightDirections[i].w = 0;
                    i++;
                }
            }
            //将灯光参数组传入Shader           
            cm.SetGlobalVectorArray(DLightColor, DLightColors);
            cm.SetGlobalVectorArray(DLightDir, DLightDirections);

            context.ExecuteCommandBuffer(cm);
            cm.Clear();
            FilteringSettings filtSet = new FilteringSettings(RenderQueueRange.opaque, -1);
            SortingSettings sortSet = new SortingSettings(camera) { criteria = SortingCriteria.CommonOpaque };
            DrawingSettings drawSet = new DrawingSettings(new ShaderTagId("GeneralForward"), sortSet);
            context.DrawRenderers(cullResults, ref drawSet, ref filtSet);
            context.DrawSkybox(camera);
            context.Submit();
        }
        void ConfigureLights(CullingResults cull)
        {
            Vector4[] visibleLightColors = new Vector4[_maximumLightCount];
            Vector4[] visibleLightDirections = new Vector4[_maximumLightCount];
            for (int i = 0; i < cull.visibleLights.Length; i++)
            {
                if (i > _maximumLightCount)
                {
                    break;
                }
                VisibleLight light = cull.visibleLights[i];
                visibleLightColors[i] = light.finalColor;
                // visibleLightColors[i].y = light.finalColor.g;
                // visibleLightColors[i].z = light.finalColor.b;

                Vector4 v = light.localToWorldMatrix.GetColumn(2);
                v.x = -v.x;
                v.y = -v.y;
                v.z = -v.z;
                visibleLightDirections[i] = v;
            }
            if (cull.visibleLights.Length > _maximumLightCount)
            {
                var lightIndices = cull.GetLightIndexMap(new Unity.Collections.Allocator());//.GetLightIndexMap();
                for (int i = _maximumLightCount; i < cull.visibleLights.Length; i++)
                {
                    lightIndices[i] = -1;
                }
                cull.SetLightIndexMap(lightIndices);
            }

            _buffer.SetGlobalVectorArray(Shader.PropertyToID("_VisibleLightColors"), visibleLightColors);
            _buffer.SetGlobalVectorArray(Shader.PropertyToID("_VisibleLightDirections"), visibleLightDirections);
        }
    }
}

