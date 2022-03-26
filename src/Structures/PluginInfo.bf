using System;

namespace BeefBass
{
    /// <summary>
    /// Used with <see cref="Bass.PluginGetInfo" /> to retrieve information on a plugin.
    /// </summary>
    [CRepr]
    public struct PluginInfo
    {
        int32 version;
        int32 formatc;
        PluginFormat* formats;

        /// <summary>
        /// Plugin version.
        /// </summary>
        public Version Version => Extensions.GetVersion((.)version);

        /// <summary>
        /// The collection of supported formats.
        /// </summary>
        /// <remarks>
        /// Note: There is no guarantee that the list of supported formats is complete or might contain formats not being supported on your particular OS/machine (due to additional or missing audio codecs).
        /// </remarks>
        public Span<PluginFormat> Formats => .(formats, formatc)
    }
}
