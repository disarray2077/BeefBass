using System;

namespace BeefBass
{
    extension Bass
    {
        /// <summary>
        /// Retrieves the decoding/download/end position of a file stream.
        /// </summary>
        /// <param name="Handle">The stream's handle.</param>
        /// <param name="Mode">The file position to retrieve. One of <see cref="FileStreamPosition" /> values.</param>
        /// <returns>If succesful, then the requested file position is returned, else -1 is returned. Use <see cref="LastError" /> to get the error code.</returns>
        /// <remarks>
        /// <para>ID3 tags (both v1 and v2) and WAVE headers, as well as any other rubbish at the start of the file, are excluded from the calculations of this function.</para>
        /// <para>This is useful for average bitrate calculations, but it means that the <see cref="FileStreamPosition.Current"/> position may not be the actual file position - the <see cref="FileStreamPosition.Start"/> position can be added to it to get the actual file position.</para>
        /// <para>
        /// When streaming a file from the internet or a "buffered" user file stream, the entire file is downloaded even if the audio data ends before that, in case there are tags to be read.
        /// This means that the <see cref="FileStreamPosition.Download"/> position may go beyond the <see cref="FileStreamPosition.End"/> position.
        /// </para>
        /// <para>
        /// It's unwise to use this function (with mode = <see cref="FileStreamPosition.Current"/>) for syncing purposes because it returns the position that's being decoded, not the position that's being heard.
        /// Use <see cref="ChannelGetPosition" /> for syncing instead.
        /// </para>
        /// </remarks>
        /// <exception cref="Errors.Handle"><paramref name="Handle" /> is not valid.</exception>
        /// <exception cref="Errors.NotFile">The stream is not a file stream.</exception>
        /// <exception cref="Errors.NotAvailable">The requested file position/status is not available.</exception>
        [Import(DllName), CallingConvention(.Stdcall), LinkName("BASS_StreamGetFilePosition")]
        public static extern int64 StreamGetFilePosition(int32 Handle, FileStreamPosition Mode = FileStreamPosition.Current);

        #region StreamProcedure
		/// <summary>
		/// Creates a user sample stream.
		/// </summary>
		/// <param name="Frequency">The default sample rate. The sample rate can be changed using <see cref="ChannelSetAttribute(int, ChannelAttribute, float)" />.</param>
		/// <param name="Channels">The number of channels... 1 = mono, 2 = stereo, 4 = quadraphonic, 6 = 5.1, 8 = 7.1. More than stereo requires WDM drivers, and the Speaker flags are ignored.</param>
		/// <param name="Flags">A combination of <see cref="BassFlags"/>.</param>
		/// <param name="Procedure">The user defined stream writing function (see <see cref="StreamProcedure" />).</param>
		/// <param name="User">User instance data to pass to the callback function.</param>
		/// <returns>If successful, the new stream's handle is returned, else 0 is returned. Use <see cref="LastError" /> to get the error code.</returns>
		/// <remarks>
		/// <para>
		/// Sample streams allow any sample data to be played through Bass, and are particularly useful for playing a large amount of sample data without requiring a large amount of memory.
		/// If you wish to play a sample format that BASS does not support, then you can create a stream and decode the sample data into it.
		/// </para>
		/// <para>
		/// Bass can automatically stream MP3, MP2, MP1, OGG, WAV and AIFF files, using <see cref="CreateStream(string,long,long,BassFlags)" />, and also from HTTP and FTP servers,
		/// using <see cref="CreateStream(string,int,BassFlags,DownloadProcedure,IntPtr)" />, <see cref="CreateStream(StreamSystem,BassFlags,FileProcedures,IntPtr)" /> allows streaming from other sources too.
		/// </para>
		/// <para>However, the callback method must deliver PCM sample data as specified, so opening an MP3 file and just passing that file data will not work here.</para>
		/// </remarks>
		/// <exception cref="Errors.Init"><see cref="Init" /> has not been successfully called.</exception>
		/// <exception cref="Errors.NotAvailable">Only decoding channels (<see cref="BassFlags.Decode"/>) are allowed when using the <see cref="NoSoundDevice"/> device. The <see cref="BassFlags.AutoFree"/> flag is also unavailable to decoding channels.</exception>
		/// <exception cref="Errors.SampleFormat">The sample format is not supported by the device/drivers. If the stream is more than stereo or the <see cref="BassFlags.Float"/> flag is used, it could be that they are not supported.</exception>
		/// <exception cref="Errors.Speaker">The specified Speaker flags are invalid. The device/drivers do not support them, they are attempting to assign a stereo stream to a mono speaker or 3D functionality is enabled.</exception>
		/// <exception cref="Errors.Memory">There is insufficient memory.</exception>
		/// <exception cref="Errors.No3D">Could not initialize 3D support.</exception>
		/// <exception cref="Errors.Unknown">Some other mystery problem!</exception>
        [Import(DllName), CallingConvention(.Stdcall), LinkName("BASS_StreamCreate")]
        public static extern int32 CreateStream(int32 Frequency, int32 Channels, BassFlags Flags, StreamProcedure Procedure, void* User);
        #endregion

        #region Dummy/Push
        /// <summary>
        /// Creates a Dummy or Push stream.
        /// </summary>
        /// <param name="Frequency">The default sample rate. The sample rate can be changed using <see cref="ChannelSetAttribute(int, ChannelAttribute, float)" />.</param>
        /// <param name="Channels">The number of channels... 1 = mono, 2 = stereo, 4 = quadraphonic, 6 = 5.1, 8 = 7.1. More than stereo requires WDM drivers, and the SPEAKER flags are ignored.</param>
        /// <param name="Flags">A combination of <see cref="BassFlags"/>.</param>
        /// <param name="ProcedureType">The type of stream.</param>
        /// <returns>If successful, the new stream's handle is returned, else 0 is returned. Use <see cref="LastError" /> to get the error code.</returns>
        /// <remarks>
        /// A dummy stream doesn't have any sample data of its own, but a decoding dummy stream (with <see cref="BassFlags.Decode"/> flag) can be used to apply DSP/FX processing to any sample data,
        /// by setting DSP/FX on the stream and feeding the data through <see cref="ChannelGetData(int,IntPtr,int)" />.
        /// <para>The dummy stream should have the same sample format as the data being fed through it.</para>
        /// </remarks>
        /// <exception cref="Errors.Init"><see cref="Init" /> has not been successfully called.</exception>
        /// <exception cref="Errors.NotAvailable">Only decoding channels (<see cref="BassFlags.Decode"/>) are allowed when using the <see cref="NoSoundDevice"/> device. The <see cref="BassFlags.AutoFree"/> flag is also unavailable to decoding channels.</exception>
        /// <exception cref="Errors.SampleFormat">The sample format is not supported by the device/drivers. If the stream is more than stereo or the <see cref="BassFlags.Float"/> flag is used, it could be that they are not supported.</exception>
        /// <exception cref="Errors.Speaker">The specified Speaker flags are invalid. The device/drivers do not support them, they are attempting to assign a stereo stream to a mono speaker or 3D functionality is enabled.</exception>
        /// <exception cref="Errors.Memory">There is insufficient memory.</exception>
        /// <exception cref="Errors.No3D">Could not initialize 3D support.</exception>
        /// <exception cref="Errors.Unknown">Some other mystery problem!</exception>
        public static int32 CreateStream(int32 Frequency, int32 Channels, BassFlags Flags, StreamProcedureType ProcedureType)
        {
            return CreateStream(Frequency, Channels, Flags, (.)ProcedureType, null);
        }
        #endregion

        #region Stream Put Data
        /// <summary>
        /// Adds sample data to a "push" stream.
        /// </summary>
        /// <param name="Handle">The stream handle (as created with <see cref="CreateStream(int,int,BassFlags,StreamProcedureType)" />).</param>
        /// <param name="Buffer">Pointer to the sample data (<see cref="IntPtr.Zero"/> = allocate space in the queue buffer so that there is at least length bytes of free space).</param>
        /// <param name="Length">The amount of data in bytes, optionally using the <see cref="StreamProcedureType.End"/> flag to signify the end of the stream. 0 can be used to just check how much data is queued.</param>
        /// <returns>If successful, the amount of queued data is returned, else -1 is returned. Use <see cref="LastError" /> to get the error code.</returns>
        /// <remarks>
        /// <para>
        /// As much data as possible will be placed in the stream's playback buffer, and any remainder will be queued for when more space becomes available, ie. as the buffered data is played.
        /// With a decoding channel, there is no playback buffer, so all data is queued in that case.
        /// There is no limit to the amount of data that can be queued, besides available memory.
        /// The queue buffer will be automatically enlarged as required to hold the data, but it can also be enlarged in advance.
        /// The queue buffer is freed when the stream ends or is reset, eg. via <see cref="ChannelPlay" /> (with restart = <see langword="true"/>) or <see cref="ChannelSetPosition(int, long, PositionFlags)" /> (with Position = 0).
        /// </para>
        /// <para>DSP/FX are applied when the data reaches the playback buffer, or the <see cref="ChannelGetData(int,IntPtr,int)" /> call in the case of a decoding channel.</para>
        /// <para>
        /// Data should be provided at a rate sufficent to sustain playback.
        /// If the buffer gets exhausted, Bass will automatically stall playback of the stream, until more data is provided.
        /// <see cref="ChannelGetData(int,IntPtr,int)" /> (<see cref="DataFlags.Available"/>) can be used to check the buffer level, and <see cref="ChannelIsActive" /> can be used to check if playback has stalled.
        /// A <see cref="SyncFlags.Stalled"/> sync can also be set via <see cref="ChannelSetSync" />, to be triggered upon playback stalling or resuming.
        /// </para>
        /// </remarks>
        /// <exception cref="Errors.Handle"><paramref name="Handle" /> is not valid.</exception>
        /// <exception cref="Errors.NotAvailable">The stream is not using the push system.</exception>
        /// <exception cref="Errors.Parameter"><paramref name="Length" /> is not valid, it must equate to a whole number of samples.</exception>
        /// <exception cref="Errors.Ended">The stream has ended.</exception>
        /// <exception cref="Errors.Memory">There is insufficient memory.</exception>
        [Import(DllName), CallingConvention(.Stdcall), LinkName("BASS_StreamPutData")]
        public static extern int32 StreamPutData(int32 Handle, void* Buffer, int32 Length);

        /// <summary>
        /// Adds sample data to a "push" stream.
        /// </summary>
        /// <param name="Handle">The stream handle (as created with <see cref="CreateStream(int,int,BassFlags,StreamProcedureType)" />).</param>
        /// <param name="Buffer">byte sample data buffer (<see langword="null"/> = allocate space in the queue buffer so that there is at least length bytes of free space).</param>
        /// <param name="Length">The amount of data in bytes, optionally using the <see cref="StreamProcedureType.End"/> flag to signify the end of the stream. 0 can be used to just check how much data is queued.</param>
        /// <returns>If successful, the amount of queued data is returned, else -1 is returned. Use <see cref="LastError" /> to get the error code.</returns>
        /// <remarks>
        /// <para>
        /// As much data as possible will be placed in the stream's playback buffer, and any remainder will be queued for when more space becomes available, ie. as the buffered data is played.
        /// With a decoding channel, there is no playback buffer, so all data is queued in that case.
        /// There is no limit to the amount of data that can be queued, besides available memory.
        /// The queue buffer will be automatically enlarged as required to hold the data, but it can also be enlarged in advance.
        /// The queue buffer is freed when the stream ends or is reset, eg. via <see cref="ChannelPlay" /> (with restart = <see langword="true"/>) or <see cref="ChannelSetPosition(int, long, PositionFlags)" /> (with Position = 0).
        /// </para>
        /// <para>DSP/FX are applied when the data reaches the playback buffer, or the <see cref="ChannelGetData(int,IntPtr,int)" /> call in the case of a decoding channel.</para>
        /// <para>
        /// Data should be provided at a rate sufficent to sustain playback.
        /// If the buffer gets exhausted, Bass will automatically stall playback of the stream, until more data is provided.
        /// <see cref="ChannelGetData(int,IntPtr,int)" /> (<see cref="DataFlags.Available"/>) can be used to check the buffer level, and <see cref="ChannelIsActive" /> can be used to check if playback has stalled.
        /// A <see cref="SyncFlags.Stalled"/> sync can also be set via <see cref="ChannelSetSync" />, to be triggered upon playback stalling or resuming.
        /// </para>
        /// </remarks>
        /// <exception cref="Errors.Handle"><paramref name="Handle" /> is not valid.</exception>
        /// <exception cref="Errors.NotAvailable">The stream is not using the push system.</exception>
        /// <exception cref="Errors.Parameter"><paramref name="Length" /> is not valid, it must equate to a whole number of samples.</exception>
        /// <exception cref="Errors.Ended">The stream has ended.</exception>
        /// <exception cref="Errors.Memory">There is insufficient memory.</exception>
        public static int32 StreamPutData(int32 Handle, uint8[] Buffer, int32 Length)
		{
			return StreamPutData(Handle, Buffer.Ptr, Length);
		}

        /// <summary>
        /// Adds sample data to a "push" stream.
        /// </summary>
        /// <param name="Handle">The stream handle (as created with <see cref="CreateStream(int,int,BassFlags,StreamProcedureType)" />).</param>
        /// <param name="Buffer">short sample data buffer (<see langword="null"/> = allocate space in the queue buffer so that there is at least length bytes of free space).</param>
        /// <param name="Length">The amount of data in bytes, optionally using the <see cref="StreamProcedureType.End"/> flag to signify the end of the stream. 0 can be used to just check how much data is queued.</param>
        /// <returns>If successful, the amount of queued data is returned, else -1 is returned. Use <see cref="LastError" /> to get the error code.</returns>
        /// <remarks>
        /// <para>
        /// As much data as possible will be placed in the stream's playback buffer, and any remainder will be queued for when more space becomes available, ie. as the buffered data is played.
        /// With a decoding channel, there is no playback buffer, so all data is queued in that case.
        /// There is no limit to the amount of data that can be queued, besides available memory.
        /// The queue buffer will be automatically enlarged as required to hold the data, but it can also be enlarged in advance.
        /// The queue buffer is freed when the stream ends or is reset, eg. via <see cref="ChannelPlay" /> (with restart = <see langword="true"/>) or <see cref="ChannelSetPosition(int, long, PositionFlags)" /> (with Position = 0).
        /// </para>
        /// <para>DSP/FX are applied when the data reaches the playback buffer, or the <see cref="ChannelGetData(int,IntPtr,int)" /> call in the case of a decoding channel.</para>
        /// <para>
        /// Data should be provided at a rate sufficent to sustain playback.
        /// If the buffer gets exhausted, Bass will automatically stall playback of the stream, until more data is provided.
        /// <see cref="ChannelGetData(int,IntPtr,int)" /> (<see cref="DataFlags.Available"/>) can be used to check the buffer level, and <see cref="ChannelIsActive" /> can be used to check if playback has stalled.
        /// A <see cref="SyncFlags.Stalled"/> sync can also be set via <see cref="ChannelSetSync" />, to be triggered upon playback stalling or resuming.
        /// </para>
        /// </remarks>
        /// <exception cref="Errors.Handle"><paramref name="Handle" /> is not valid.</exception>
        /// <exception cref="Errors.NotAvailable">The stream is not using the push system.</exception>
        /// <exception cref="Errors.Parameter"><paramref name="Length" /> is not valid, it must equate to a whole number of samples.</exception>
        /// <exception cref="Errors.Ended">The stream has ended.</exception>
        /// <exception cref="Errors.Memory">There is insufficient memory.</exception>
        public static int32 StreamPutData(int32 Handle, int16[] Buffer, int32 Length)
		{
			return StreamPutData(Handle, Buffer.Ptr, Length);
		}

        /// <summary>
        /// Adds sample data to a "push" stream.
        /// </summary>
        /// <param name="Handle">The stream handle (as created with <see cref="CreateStream(int,int,BassFlags,StreamProcedureType)" />).</param>
        /// <param name="Buffer">int sample data buffer (<see langword="null"/> = allocate space in the queue buffer so that there is at least length bytes of free space).</param>
        /// <param name="Length">The amount of data in bytes, optionally using the <see cref="StreamProcedureType.End"/> flag to signify the end of the stream. 0 can be used to just check how much data is queued.</param>
        /// <returns>If successful, the amount of queued data is returned, else -1 is returned. Use <see cref="LastError" /> to get the error code.</returns>
        /// <remarks>
        /// <para>
        /// As much data as possible will be placed in the stream's playback buffer, and any remainder will be queued for when more space becomes available, ie. as the buffered data is played.
        /// With a decoding channel, there is no playback buffer, so all data is queued in that case.
        /// There is no limit to the amount of data that can be queued, besides available memory.
        /// The queue buffer will be automatically enlarged as required to hold the data, but it can also be enlarged in advance.
        /// The queue buffer is freed when the stream ends or is reset, eg. via <see cref="ChannelPlay" /> (with restart = <see langword="true"/>) or <see cref="ChannelSetPosition(int, long, PositionFlags)" /> (with Position = 0).
        /// </para>
        /// <para>DSP/FX are applied when the data reaches the playback buffer, or the <see cref="ChannelGetData(int,IntPtr,int)" /> call in the case of a decoding channel.</para>
        /// <para>
        /// Data should be provided at a rate sufficent to sustain playback.
        /// If the buffer gets exhausted, Bass will automatically stall playback of the stream, until more data is provided.
        /// <see cref="ChannelGetData(int,IntPtr,int)" /> (<see cref="DataFlags.Available"/>) can be used to check the buffer level, and <see cref="ChannelIsActive" /> can be used to check if playback has stalled.
        /// A <see cref="SyncFlags.Stalled"/> sync can also be set via <see cref="ChannelSetSync" />, to be triggered upon playback stalling or resuming.
        /// </para>
        /// </remarks>
        /// <exception cref="Errors.Handle"><paramref name="Handle" /> is not valid.</exception>
        /// <exception cref="Errors.NotAvailable">The stream is not using the push system.</exception>
        /// <exception cref="Errors.Parameter"><paramref name="Length" /> is not valid, it must equate to a whole number of samples.</exception>
        /// <exception cref="Errors.Ended">The stream has ended.</exception>
        /// <exception cref="Errors.Memory">There is insufficient memory.</exception>
        public static int32 StreamPutData(int32 Handle, int32[] Buffer, int32 Length)
		{
			return StreamPutData(Handle, Buffer.Ptr, Length);
		}

        /// <summary>
        /// Adds sample data to a "push" stream.
        /// </summary>
        /// <param name="Handle">The stream handle (as created with <see cref="CreateStream(int,int,BassFlags,StreamProcedureType)" />).</param>
        /// <param name="Buffer">float sample data buffer (<see langword="null"/> = allocate space in the queue buffer so that there is at least length bytes of free space).</param>
        /// <param name="Length">The amount of data in bytes, optionally using the <see cref="StreamProcedureType.End"/> flag to signify the end of the stream. 0 can be used to just check how much data is queued.</param>
        /// <returns>If successful, the amount of queued data is returned, else -1 is returned. Use <see cref="LastError" /> to get the error code.</returns>
        /// <remarks>
        /// <para>
        /// As much data as possible will be placed in the stream's playback buffer, and any remainder will be queued for when more space becomes available, ie. as the buffered data is played.
        /// With a decoding channel, there is no playback buffer, so all data is queued in that case.
        /// There is no limit to the amount of data that can be queued, besides available memory.
        /// The queue buffer will be automatically enlarged as required to hold the data, but it can also be enlarged in advance.
        /// The queue buffer is freed when the stream ends or is reset, eg. via <see cref="ChannelPlay" /> (with restart = <see langword="true"/>) or <see cref="ChannelSetPosition(int, long, PositionFlags)" /> (with Position = 0).
        /// </para>
        /// <para>DSP/FX are applied when the data reaches the playback buffer, or the <see cref="ChannelGetData(int,IntPtr,int)" /> call in the case of a decoding channel.</para>
        /// <para>
        /// Data should be provided at a rate sufficent to sustain playback.
        /// If the buffer gets exhausted, Bass will automatically stall playback of the stream, until more data is provided.
        /// <see cref="ChannelGetData(int,IntPtr,int)" /> (<see cref="DataFlags.Available"/>) can be used to check the buffer level, and <see cref="ChannelIsActive" /> can be used to check if playback has stalled.
        /// A <see cref="SyncFlags.Stalled"/> sync can also be set via <see cref="ChannelSetSync" />, to be triggered upon playback stalling or resuming.
        /// </para>
        /// </remarks>
        /// <exception cref="Errors.Handle"><paramref name="Handle" /> is not valid.</exception>
        /// <exception cref="Errors.NotAvailable">The stream is not using the push system.</exception>
        /// <exception cref="Errors.Parameter"><paramref name="Length" /> is not valid, it must equate to a whole number of samples.</exception>
        /// <exception cref="Errors.Ended">The stream has ended.</exception>
        /// <exception cref="Errors.Memory">There is insufficient memory.</exception>
        public static int32 StreamPutData(int32 Handle, float[] Buffer, int32 Length)
		{
			return StreamPutData(Handle, Buffer.Ptr, Length);
		}
        #endregion

        #region Stream Put File Data
        /// <summary>
        /// Adds data to a "push buffered" user file stream's buffer.
        /// </summary>
        /// <param name="Handle">The stream handle (as created with <see cref="CreateStream(StreamSystem,BassFlags,FileProcedures,IntPtr)" /> and the <see cref="StreamSystem.BufferPush"/> system flag.).</param>
        /// <param name="Buffer">Pointer to the file data.</param>
        /// <param name="Length">The amount of data in bytes, or <see cref="StreamProcedureType.End"/> to end the file.</param>
        /// <returns>If successful, the number of bytes read from buffer is returned, else -1 is returned. Use <see cref="LastError" /> to get the error code.</returns>
        /// <remarks>
        /// <para>If there is not enough space in the stream's file buffer to receive all of the data, then only the amount that will fit is read from buffer. <see cref="StreamGetFilePosition" /> can be used to check the amount of space in the buffer.</para>
        /// <para>
        /// File data should be provided at a rate sufficent to sustain playback.
        /// If there is insufficient file data, and the playback buffer is subsequently exhausted, Bass will automatically stall playback of the stream, until more data is available.
        /// A <see cref="SyncFlags.Stalled"/> sync can be set via <see cref="ChannelSetSync" />, to be triggered upon playback stalling or resuming.
        /// </para>
        /// </remarks>
        /// <exception cref="Errors.Handle"><paramref name="Handle" /> is not valid.</exception>
        /// <exception cref="Errors.NotAvailable">The stream is not using the <see cref="StreamSystem.BufferPush"/> file system.</exception>
        /// <exception cref="Errors.Ended">The stream has ended.</exception>
        [Import(DllName), CallingConvention(.Stdcall), LinkName("BASS_StreamPutFileData")]
        public static extern int32 StreamPutFileData(int32 Handle, void* Buffer, int32 Length);

        /// <summary>
        /// Adds data to a "push buffered" user file stream's buffer.
        /// </summary>
        /// <param name="Handle">The stream handle (as created with <see cref="CreateStream(StreamSystem,BassFlags,FileProcedures,IntPtr)" /> and the <see cref="StreamSystem.BufferPush"/> system flag.).</param>
        /// <param name="Buffer">byte buffer.</param>
        /// <param name="Length">The amount of data in bytes, or <see cref="StreamProcedureType.End"/> to end the file.</param>
        /// <returns>If successful, the number of bytes read from buffer is returned, else -1 is returned. Use <see cref="LastError" /> to get the error code.</returns>
        /// <remarks>
        /// <para>If there is not enough space in the stream's file buffer to receive all of the data, then only the amount that will fit is read from buffer. <see cref="StreamGetFilePosition" /> can be used to check the amount of space in the buffer.</para>
        /// <para>
        /// File data should be provided at a rate sufficent to sustain playback.
        /// If there is insufficient file data, and the playback buffer is subsequently exhausted, Bass will automatically stall playback of the stream, until more data is available.
        /// A <see cref="SyncFlags.Stalled"/> sync can be set via <see cref="ChannelSetSync" />, to be triggered upon playback stalling or resuming.
        /// </para>
        /// </remarks>
        /// <exception cref="Errors.Handle"><paramref name="Handle" /> is not valid.</exception>
        /// <exception cref="Errors.NotAvailable">The stream is not using the <see cref="StreamSystem.BufferPush"/> file system.</exception>
        /// <exception cref="Errors.Ended">The stream has ended.</exception>
        public static int32 StreamPutFileData(int32 Handle, uint8[] Buffer, int32 Length)
		{
			return StreamPutFileData(Handle, Buffer.Ptr, Length);
		}

        /// <summary>
        /// Adds data to a "push buffered" user file stream's buffer.
        /// </summary>
        /// <param name="Handle">The stream handle (as created with <see cref="CreateStream(StreamSystem,BassFlags,FileProcedures,IntPtr)" /> and the <see cref="StreamSystem.BufferPush"/> system flag.).</param>
        /// <param name="Buffer">short buffer.</param>
        /// <param name="Length">The amount of data in bytes, or <see cref="StreamProcedureType.End"/> to end the file.</param>
        /// <returns>If successful, the number of bytes read from buffer is returned, else -1 is returned. Use <see cref="LastError" /> to get the error code.</returns>
        /// <remarks>
        /// <para>If there is not enough space in the stream's file buffer to receive all of the data, then only the amount that will fit is read from buffer. <see cref="StreamGetFilePosition" /> can be used to check the amount of space in the buffer.</para>
        /// <para>
        /// File data should be provided at a rate sufficent to sustain playback.
        /// If there is insufficient file data, and the playback buffer is subsequently exhausted, Bass will automatically stall playback of the stream, until more data is available.
        /// A <see cref="SyncFlags.Stalled"/> sync can be set via <see cref="ChannelSetSync" />, to be triggered upon playback stalling or resuming.
        /// </para>
        /// </remarks>
        /// <exception cref="Errors.Handle"><paramref name="Handle" /> is not valid.</exception>
        /// <exception cref="Errors.NotAvailable">The stream is not using the <see cref="StreamSystem.BufferPush"/> file system.</exception>
        /// <exception cref="Errors.Ended">The stream has ended.</exception>
        public static int32 StreamPutFileData(int32 Handle, int16[] Buffer, int32 Length)
		{
			return StreamPutFileData(Handle, Buffer.Ptr, Length);
		}

        /// <summary>
        /// Adds data to a "push buffered" user file stream's buffer.
        /// </summary>
        /// <param name="Handle">The stream handle (as created with <see cref="CreateStream(StreamSystem,BassFlags,FileProcedures,IntPtr)" /> and the <see cref="StreamSystem.BufferPush"/> system flag.).</param>
        /// <param name="Buffer">int buffer.</param>
        /// <param name="Length">The amount of data in bytes, or <see cref="StreamProcedureType.End"/> to end the file.</param>
        /// <returns>If successful, the number of bytes read from buffer is returned, else -1 is returned. Use <see cref="LastError" /> to get the error code.</returns>
        /// <remarks>
        /// <para>If there is not enough space in the stream's file buffer to receive all of the data, then only the amount that will fit is read from buffer. <see cref="StreamGetFilePosition" /> can be used to check the amount of space in the buffer.</para>
        /// <para>
        /// File data should be provided at a rate sufficent to sustain playback.
        /// If there is insufficient file data, and the playback buffer is subsequently exhausted, Bass will automatically stall playback of the stream, until more data is available.
        /// A <see cref="SyncFlags.Stalled"/> sync can be set via <see cref="ChannelSetSync" />, to be triggered upon playback stalling or resuming.
        /// </para>
        /// </remarks>
        /// <exception cref="Errors.Handle"><paramref name="Handle" /> is not valid.</exception>
        /// <exception cref="Errors.NotAvailable">The stream is not using the <see cref="StreamSystem.BufferPush"/> file system.</exception>
        /// <exception cref="Errors.Ended">The stream has ended.</exception>
        public static int32 StreamPutFileData(int32 Handle, int32[] Buffer, int32 Length)
		{
			return StreamPutFileData(Handle, Buffer.Ptr, Length);
		}

        /// <summary>
        /// Adds data to a "push buffered" user file stream's buffer.
        /// </summary>
        /// <param name="Handle">The stream handle (as created with <see cref="CreateStream(StreamSystem,BassFlags,FileProcedures,IntPtr)" /> and the <see cref="StreamSystem.BufferPush"/> system flag.).</param>
        /// <param name="Buffer">float buffer.</param>
        /// <param name="Length">The amount of data in bytes, or <see cref="StreamProcedureType.End"/> to end the file.</param>
        /// <returns>If successful, the number of bytes read from buffer is returned, else -1 is returned. Use <see cref="LastError" /> to get the error code.</returns>
        /// <remarks>
        /// <para>If there is not enough space in the stream's file buffer to receive all of the data, then only the amount that will fit is read from buffer. <see cref="StreamGetFilePosition" /> can be used to check the amount of space in the buffer.</para>
        /// <para>
        /// File data should be provided at a rate sufficent to sustain playback.
        /// If there is insufficient file data, and the playback buffer is subsequently exhausted, Bass will automatically stall playback of the stream, until more data is available.
        /// A <see cref="SyncFlags.Stalled"/> sync can be set via <see cref="ChannelSetSync" />, to be triggered upon playback stalling or resuming.
        /// </para>
        /// </remarks>
        /// <exception cref="Errors.Handle"><paramref name="Handle" /> is not valid.</exception>
        /// <exception cref="Errors.NotAvailable">The stream is not using the <see cref="StreamSystem.BufferPush"/> file system.</exception>
        /// <exception cref="Errors.Ended">The stream has ended.</exception>
        public static int32 StreamPutFileData(int32 Handle, float[] Buffer, int32 Length)
		{
			return StreamPutFileData(Handle, Buffer.Ptr, Length);
		}
        #endregion

        /// <summary>
        /// Frees a sample stream's resources, including any SYNC/DSP/FX it has.
        /// </summary>
        /// <param name="Handle"> The stream handle.</param>
        /// <returns>If successful, <see langword="true" /> is returned, else <see langword="false" /> is returned. Use <see cref="LastError" /> to get the error code.</returns>
        /// <exception cref="Errors.Init"><paramref name="Handle" /> is not valid.</exception>
        [Import(DllName), CallingConvention(.Stdcall), LinkName("BASS_StreamFree")]
        public static extern bool StreamFree(int32 Handle);
    }
}
