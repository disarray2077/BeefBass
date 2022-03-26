using System;
using System.IO;
using System.Threading;

namespace BeefBass
{
    /// <summary>
    /// A Reusable Channel which can Load files like a Player.
    /// <para><see cref="MediaPlayer"/> is perfect for UIs, as it implements <see cref="INotifyPropertyChanged"/>.</para>
    /// <para>Also, unlike normal, Properties/Effects set on a <see cref="MediaPlayer"/> persist through subsequent loads.</para>
    /// </summary>
    public class MediaPlayer
    {
        #region Fields
        int32 _handle;
        
        /// <summary>
        /// Channel Handle of the loaded audio file.
        /// </summary>
        protected internal int32 Handle
        {
            get => _handle;
            private set
            {
                if (!Bass.ChannelGetInfo(value, var info))
                    Runtime.FatalError(scope $"Invalid Channel Handle: {value}");

                _handle = value;

                // Init Events
                Bass.ChannelSetSync(Handle, SyncFlags.Free, 0, (handle, channel, data, user) =>
				{
					let self = (Self)Internal.UnsafeCastToObject(user);
					self.Disposed(self, EventArgs.Empty);
				}, Internal.UnsafeCastToPtr(this));
                Bass.ChannelSetSync(Handle, SyncFlags.Stop, 0, (handle, channel, data, user) =>
				{
					let self = (Self)Internal.UnsafeCastToObject(user);
					self.MediaFailed(self, EventArgs.Empty);
				}, Internal.UnsafeCastToPtr(this));
                Bass.ChannelSetSync(Handle, SyncFlags.End, 0, (handle, channel, data, user) =>
                {
					let self = (Self)Internal.UnsafeCastToObject(user);
                    if (!Bass.ChannelHasFlag(self.Handle, BassFlags.Loop))
                        self.MediaEnded(self, EventArgs.Empty);
                    self.OnStateChanged();
                }, Internal.UnsafeCastToPtr(this));
            }
        }

        bool _restartOnNextPlayback;
        #endregion

        static this()
        {
            var currentDev = Bass.CurrentDevice;

            if (currentDev == -1 || !Bass.GetDeviceInfo(Bass.CurrentDevice).Get().IsInitialized)
                Bass.Init(currentDev);
        }

        /// <summary>
        /// Creates a new instance of <see cref="MediaPlayer"/>.
        /// </summary>
        public this() { }

		/// <summary>
		/// Frees all resources used by the player.
		/// </summary>
		public ~this()
		{
	        if (Bass.StreamFree(Handle))
	            _handle = 0;

		    OnStateChanged();
		}


        #region Events
        /// <summary>
        /// Fired when this Channel is Disposed.
        /// </summary>
        public Event<EventHandler> Disposed ~ _.Dispose();

        /// <summary>
        /// Fired when the Media Playback Ends
        /// </summary>
        public Event<EventHandler> MediaEnded ~ _.Dispose();

        /// <summary>
        /// Fired when the Playback fails
        /// </summary>
        public Event<EventHandler> MediaFailed ~ _.Dispose();
        #endregion

        #region Frequency
        double _freq = 44100;
        
        /// <summary>
        /// Gets or Sets the Playback Frequency in Hertz.
        /// Default is 44100 Hz.
        /// </summary>
        public double Frequency
        {
            get => _freq;
            set
            {
                if (!Bass.ChannelSetAttribute(Handle, ChannelAttribute.Frequency, value))
                    return;

                _freq = value;
                OnPropertyChanged();
            }
        }
        #endregion

        #region Balance
        double _pan;
        
        /// <summary>
        /// Gets or Sets Balance (Panning) (-1 ... 0 ... 1).
        /// -1 Represents Completely Left.
        ///  1 Represents Completely Right.
        /// Default is 0.
        /// </summary>
        public double Balance
        {
            get => _pan;
            set
            {
                if (!Bass.ChannelSetAttribute(Handle, ChannelAttribute.Pan, value))
                    return;

                _pan = value;
                OnPropertyChanged();
            }
        }
        #endregion

        #region Device
        int32 _dev = -1;

        /// <summary>
        /// Gets or Sets the Playback Device used.
        /// </summary>
        public int32 Device
        {
            get => (_dev = _dev == -1 ? Bass.ChannelGetDevice(Handle) : _dev);
            set
            {
				if (!Bass.GetDeviceInfo(value, var devInfo))
					return;

                if (!devInfo.IsInitialized)
                    if (!Bass.Init(value))
                        return;
                 
                if (!Bass.ChannelSetDevice(Handle, value))
                    return;

                _dev = value;
                OnPropertyChanged();
            }
        }
        #endregion

        #region Volume
        double _vol = 0.5;

        /// <summary>
        /// Gets or Sets the Playback Volume.
        /// </summary>
        public double Volume
        {
            get => _vol;
            set
            {
                if (!Bass.ChannelSetAttribute(Handle, ChannelAttribute.Volume, value))
                    return;

                _vol = value;
                OnPropertyChanged();
            }
        }
        #endregion

        #region Loop
        bool _loop;

        /// <summary>
        /// Gets or Sets whether the Playback is looped.
        /// </summary>
        public bool Loop
        {
            get => _loop;
            set
            {
                if (value ? !Bass.ChannelAddFlag(Handle, BassFlags.Loop) : !Bass.ChannelRemoveFlag(Handle, BassFlags.Loop))
                    return;

                _loop = value;
                OnPropertyChanged();
            }
        }
        #endregion
        
        /// <summary>
        /// Override this method for custom loading procedure.
        /// </summary>
        /// <param name="FileName">Path to the File to Load.</param>
        /// <returns><see langword="true"/> on Success, <see langword="false"/> on failure</returns>
        protected virtual int32 OnLoad(StringView FileName) => Bass.CreateStream(FileName);

        #region Tags
        String _title = null ~ delete _, _artist = null ~ delete _, _album = null ~ delete _;

        /// <summary>
        /// Title of the Loaded Media.
        /// </summary>
        public String Title 
        {
            get => _title;
            private set
            {
                String.NewOrSet!(_title, value);
                OnPropertyChanged();
            }
        }

        /// <summary>
        /// Artist of the Loaded Media.
        /// </summary>
        public String Artist
        {
            get => _artist;
            private set
            {
                String.NewOrSet!(_artist, value);
                OnPropertyChanged();
            }
        }
        
        /// <summary>
        /// Album of the Loaded Media.
        /// </summary>
        public String Album
        {
            get => _album;
            private set
            {
                String.NewOrSet!(_album, value);
                OnPropertyChanged();
            }
        }
        #endregion
        
        /// <summary>
        /// Gets the Playback State of the Channel.
        /// </summary>
        public PlaybackState State => Handle == 0 ? PlaybackState.Stopped : Bass.ChannelIsActive(Handle);

        #region Playback
        /// <summary>
        /// Starts the Channel Playback.
        /// </summary>
        public bool Play()
        {
            var result = Bass.ChannelPlay(Handle, _restartOnNextPlayback);

            if (result)
                _restartOnNextPlayback = false;
		
			OnStateChanged();
            return result;
        }

        /// <summary>
        /// Pauses the Channel Playback.
        /// </summary>
        public bool Pause()
        {
			defer OnStateChanged();
            return Bass.ChannelPause(Handle);
        }

        /// <summary>
        /// Stops the Channel Playback.
        /// </summary>
        /// <remarks>Difference from <see cref="Bass.ChannelStop"/>: Playback is restarted when <see cref="Play"/> is called.</remarks>
        public bool Stop()
        {
            _restartOnNextPlayback = true;
			defer OnStateChanged();
            return Bass.ChannelStop(Handle);
        }
        #endregion

        /// <summary>
        /// Gets the Playback Duration.
        /// </summary>
        public TimeSpan Duration => TimeSpan.FromSeconds(Bass.ChannelBytes2Seconds(Handle, Bass.ChannelGetLength(Handle)));

        /// <summary>
        /// Gets or Sets the Playback Position.
        /// </summary>
        public TimeSpan Position
        {
            get => TimeSpan.FromSeconds(Bass.ChannelBytes2Seconds(Handle, Bass.ChannelGetPosition(Handle)));
            set => Bass.ChannelSetPosition(Handle, Bass.ChannelSeconds2Bytes(Handle, value.TotalSeconds));
        }

        /// <summary>
        /// Loads a file into the player.
        /// </summary>
        /// <param name="FileName">Path to the file to Load.</param>
        /// <returns><see langword="true"/> on succes, <see langword="false"/> on failure.</returns>
        public Result<void> Load(StringView FileName)
        {
            if (Handle != 0)
                Bass.StreamFree(Handle);

            if (_dev != -1)
                if (Bass.SetCurrentDevice(_dev) case .Err)
					return .Err;

            var currentDev = Bass.CurrentDevice;

			DeviceInfo currentDevInfo = ?;
			if (!(Bass.GetDeviceInfo(Bass.CurrentDevice) case .Ok(out currentDevInfo)))
				return .Err;

            if (currentDev == -1 || !currentDevInfo.IsInitialized)
                Bass.Init(currentDev);

            var h = OnLoad(FileName);

            if (h == 0)
                return .Err;

            Handle = h;

			// TODO :^)
			/*
            var tags = TagReader.Read(Handle);

            Title = !string.IsNullOrWhiteSpace(tags.Title) ? tags.Title 
                                                           : Path.GetFileNameWithoutExtension(FileName);
            Artist = tags.Artist;
            Album = tags.Album;
			*/
			Title = Path.GetFileNameWithoutExtension(FileName, .. scope .());
            
            InitProperties();

            MediaLoaded(h);

            OnPropertyChanged("");

            return .Ok;
        }

        /// <summary>
        /// Fired when a Media is Loaded.
        /// </summary>
        public Event<delegate void(int32)> MediaLoaded ~ _.Dispose();

        /// <summary>
        /// Initializes Properties on every call to <see cref="LoadAsync"/>.
        /// </summary>
        protected virtual void InitProperties()
        {
            Frequency = _freq;
            Balance = _pan;
            Volume = _vol;
            Loop = _loop;
        }
        
        void OnStateChanged() => OnPropertyChanged("State");

        /// <summary>
        /// Fired when a property value changes.
        /// </summary>
        public Event<delegate void(Object, String)> PropertyChanged;

        /// <summary>
        /// Fires the <see cref="PropertyChanged"/> event.
        /// </summary>
        protected virtual void OnPropertyChanged(String PropertyName = Compiler.CallerMemberName)
        {
            PropertyChanged(this, PropertyName);
        }
    }
}