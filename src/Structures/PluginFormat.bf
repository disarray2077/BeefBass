using System;

namespace BeefBass
{
    /// <summary>
    /// Used with <see cref="Bass.PluginGetInfo" /> to retrieve information on the supported plugin formats.
    /// </summary>
    /// <remarks>
    /// The plugin information does not change, so the returned pointer remains valid for as long as the plugin is loaded.
    /// <para>
    /// The extension filter is for information only.
    /// A plugin will check the file contents rather than file extension, to verify that it is a supported format.
    /// </para>
    /// </remarks>
    [CRepr]
    public struct PluginFormat
    {
        ChannelType ctype;
        char8* name;
        char8* exts;

        /// <summary>
        /// The channel Type, as would appear in the <see cref="ChannelInfo" /> structure.
        /// </summary>
        public ChannelType ChannelType => ctype;

        /// <summary>
        /// The Format description or name.
        /// </summary>
        public StringView Name => name == null ? default : .(name);

        /// <summary>
        /// File extension filter, in the form of "*.ext1;*.ext2;etc...".
        /// </summary>
        /// <remarks>
        /// The extension filter is for information only.
        /// A plugin will check the file contents rather than file extension, to verify that it is a supported format.
        /// </remarks>
        public StringView FileExtensions => exts == null ? default : .(exts);
    }
}
