using System;

namespace BeefBass
{
    /// <summary>
    /// Table of callback functions used with <see cref="Bass.CreateStream(StreamSystem,BassFlags,FileProcedures,IntPtr)" />.
    /// </summary>
    /// <remarks>
    /// A copy is made of the <see cref="FileProcedures"/> callback function table, so it does not have to persist beyond this function call.
    /// Unlike Bass.Net, a reference to <see cref="FileProcedures"/> doesn't need to be held by you manually.
    /// BeefBass automatically holds a reference and frees it when the Channel is freed.
    /// </remarks>
    [CRepr]
    public struct FileProcedures
    {
        /// <summary>
        /// Callback function to close the file.
        /// </summary>
        public FileCloseProcedure Close;

        /// <summary>
        /// Callback function to get the file Length.
        /// </summary>
        public FileLengthProcedure Length;

        /// <summary>
        /// Callback function to read from the file.
        /// </summary>
        public FileReadProcedure Read;

        /// <summary>
        /// Callback function to seek in the file. Not used by buffered file streams.
        /// </summary>
        public FileSeekProcedure Seek;
    }
}
