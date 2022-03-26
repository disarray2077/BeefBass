using System;

namespace BeefBass
{
    /// <summary>
    /// Level retrieval flags (to be used with <see cref="Bass.ChannelGetLevel(int,float[],float,LevelRetrievalFlags)" />).
    /// </summary>
    public enum LevelRetrievalFlags : int32
    {
        /// <summary>
        /// Retrieves mono levels
        /// </summary>
        All,

        /// <summary>
        /// Retrieves mono levels
        /// </summary>
        Mono = 0x1,

        /// <summary>
        /// Retrieves stereo levels
        /// </summary>
        Stereo = 0x2,

        /// <summary>
        /// Optional Flag: If set it returns RMS levels instead of peak leavels
        /// </summary>
        RMS = 0x4,

        /// <summary>
        /// Apply the current <see cref="ChannelAttribute.Volume"/> and <see cref="ChannelAttribute.Pan"/> values to the level reading. 
        /// </summary>
        VolPan = 0x8
    }
}
