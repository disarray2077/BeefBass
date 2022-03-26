using System;
using System.Collections;
using System.IO;
using System.Text;

namespace BeefBass
{
    /// <summary>
    /// Contains Helper and Extension methods.
    /// </summary>
    public static class Extensions
    {
        /// <summary>
        /// Converts <see cref="Resolution"/> to <see cref="BassFlags"/>
        /// </summary>
        public static BassFlags ToBassFlag(this Resolution Resolution)
        {
            switch (Resolution)
            {
                case .Byte:
                    return BassFlags.Byte;
                case .Float:
                    return BassFlags.Float;
                default:
                    return BassFlags.Default;
            }
        }
        
        /// <summary>
        /// Returns the <param name="N">n'th (max 15)</param> pair of Speaker Assignment Flags
        /// </summary>
        public static BassFlags SpeakerN(int32 N) => (BassFlags)(N << 24);

        static bool? _floatable;

        /// <summary>
        /// Check whether Floating point streams are supported in the Current Environment.
        /// </summary>
        public static bool SupportsFloatingPoint
        {
            get
            {
                if (_floatable.HasValue) 
                    return _floatable.Value;

                // try creating a floating-point stream
                var hStream = Bass.CreateStream(44100, 1, BassFlags.Float, StreamProcedureType.Dummy);

                _floatable = hStream != 0;

                // floating-point channels are supported! (free the test stream)
                if (_floatable.Value) 
                    Bass.StreamFree(hStream);

                return _floatable.Value;
            }
        }

        /// <summary>
        /// Gets a <see cref="Version"/> object for a version number returned by BASS.
        /// </summary>
        public static Version GetVersion(uint32 Num)
        {
            return Version(Num >> 24 & 0xff,
                           Num >> 16 & 0xff,
                           Num >> 8 & 0xff,
                           Num & 0xff);
        }
        
        /// <summary>
        /// Returns a string representation for given number of channels.
        /// </summary>
        public static StringView ChannelCountToString(int32 Channels)
        {
            switch (Channels)
            {
                case 1:
                    return "Mono";
                case 2:
                    return "Stereo";
                case 3:
                    return "2.1";
                case 4:
                    return "Quad";
                case 5:
                    return "4.1";
                case 6:
                    return "5.1";
                case 7:
                    return "6.1";
                default:
                    return "Many channels";
            }
        }
    }
}