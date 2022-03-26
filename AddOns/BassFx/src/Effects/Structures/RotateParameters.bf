using System;

namespace BeefBass.Fx
{
    /// <summary>
    /// Parameters for Rotate Effect.
    /// </summary>
    [CRepr]
    public struct RotateParameters : IEffectParameter
    {
        /// <summary>
        /// Rotation rate/speed in Hz (A negative rate can be used for reverse direction).
        /// </summary>
        public float fRate;

        /// <summary>
        /// A <see cref="FXChannelFlags" /> flag to define on which channels to apply the effect. Default: <see cref="FXChannelFlags.All"/>
        /// </summary>
        public FXChannelFlags lChannel = FXChannelFlags.All;

        /// <summary>
        /// Gets the <see cref="EffectType"/>.
        /// </summary>
        public EffectType FXType => EffectType.Rotate;
    }
}