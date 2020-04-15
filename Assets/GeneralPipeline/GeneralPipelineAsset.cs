using UnityEngine;
using UnityEngine.Rendering;

namespace RederPipeline
{
    [CreateAssetMenu(menuName = "Rendering/GeneralPipeline")]
    public class GeneralPipelineAsset : RenderPipelineAsset
    {
        [SerializeField]
        public bool _dynamicBatching;
        [SerializeField]
        public bool _gpuinstancing;
        public GeneralPipelineAsset()
        {
        }
        protected override RenderPipeline CreatePipeline()
        {
            return new GeneralPipeline(this);
        }
    }
}