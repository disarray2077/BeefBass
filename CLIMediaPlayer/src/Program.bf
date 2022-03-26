using System;
using System.IO;
using System.Collections;
using System.Reflection;
using System.Threading;
using CLIMediaPlayer.CLI;
using CLIMediaPlayer.CLI.TypeConverters;
using BeefBass;

namespace CLIMediaPlayer
{
	class Program : CLI<Program>
	{
		public static MediaPlayer mMediaPlayer = new .() ~ delete _;

		public static int Main(String[] args)
		{
			Console.WriteLine("CLIMediaPlayer commands:");
			ShowCommands();
			Console.WriteLine();

			if (!args.IsEmpty)
				PlayMedia(args[0]);
			Run();
			return 0;
		}

		[Command("watch", "Watch one of the dynamic channel properties. (\"position\")")]
		[CommandArg("property", typeof(String))]
		public static void StartWatch(String property)
		{
			if (mMediaPlayer.[Friend]Handle == 0)
			{
				Console.WriteLine("No media has been loaded.");
				return;
			}

			switch (property)
			{
			case "position":
				bool breakWatch = false;
				Console.OnCancel.Add(new [&](kind, terminate) => { breakWatch = true; terminate = false; });
				while (!breakWatch)
				{
					Console.Write("Position: {0}\r", mMediaPlayer.Position);
					Thread.Sleep(1);
				}
				Console.WriteLine();
				Console.OnCancel.Dispose();
			default:
				Console.WriteLine("Property \"{}\" can't be watched.", property);
			}
		}

		[Command("play", "Play media in specified path or continue playing current media channel.")]
		[CommandArg("media_path", typeof(String), true)]
		public static void PlayMedia(String mediaPath)
		{
			if (mediaPath != null)
			{
				if (mMediaPlayer.Load(mediaPath) case .Err)
				{
					Console.WriteLine("Failed to load specified media. (ErrorType: {})", Bass.LastError);
					return;
				}
			}
			else if (mMediaPlayer.[Friend]Handle == 0)
			{
				Console.WriteLine("No media has been loaded.");
				return;
			}

			mMediaPlayer.Play();

			Console.WriteLine("Now playing: \"{}\"", mMediaPlayer.Title);
		}

		[Command("pause", "Pause current media channel.")]
		public static void PauseMedia()
		{
			if (mMediaPlayer.[Friend]Handle == 0)
			{
				Console.WriteLine("No media has been loaded.");
				return;
			} else if (mMediaPlayer.State == .Paused)
			{
				Console.WriteLine("Current media channel is already paused.");
				return;
			} else if (mMediaPlayer.State == .Stopped)
			{
				Console.WriteLine("Current media channel is stopped.");
				return;
			}

			mMediaPlayer.Pause();

			Console.WriteLine("Media paused.");
		}

		[Command("stop", "Stop current media channel.")]
		public static void StopMedia()
		{
			if (mMediaPlayer.[Friend]Handle == 0)
			{
				Console.WriteLine("No media has been loaded.");
				return;
			} else if (mMediaPlayer.State == .Stopped)
			{
				Console.WriteLine("Current media channel is already stopped.");
				return;
			}

			mMediaPlayer.Stop();

			Console.WriteLine("Media stopped.");
		}

		[Command("frequency", "Gets or sets the frequency of the current media channel.")]
		[CommandArg("frequency", typeof(double?), true)]
		public static void GetSetFrequency(double? value)
		{
			if (mMediaPlayer.[Friend]Handle == 0)
			{
				Console.WriteLine("No media has been loaded.");
				return;
			}

			if (value.HasValue)
				mMediaPlayer.Frequency = value.Value;
			else
				Console.WriteLine("Frequency: {0}", mMediaPlayer.Frequency);
		}

		[Command("volume", "Gets or sets the volume of the current media channel.")]
		[CommandArg("volume", typeof(double?), true)]
		public static void GetSetVolume(double? value)
		{
			if (mMediaPlayer.[Friend]Handle == 0)
			{
				Console.WriteLine("No media has been loaded.");
				return;
			}

			if (value.HasValue)
				mMediaPlayer.Volume = value.Value;
			else
				Console.WriteLine("Volume: {0}", mMediaPlayer.Volume);
		}

		[Command("loop", "Gets or sets whether the current media channel will loop. (Options = y | n)")]
		[CommandArg("value", typeof(bool?), true)]
		public static void GetSetLoop(bool? value)
		{
			if (mMediaPlayer.[Friend]Handle == 0)
			{
				Console.WriteLine("No media has been loaded.");
				return;
			}

			if (value.HasValue)
				mMediaPlayer.Loop = value.Value;
			else
				Console.WriteLine("Loop: {0}", mMediaPlayer.Loop ? "y" : "n");
		}

		[Command("duration", "Gets the duration of the media in the current channel.")]
		public static void GetDuration()
		{
			if (mMediaPlayer.[Friend]Handle == 0)
			{
				Console.WriteLine("No media has been loaded.");
				return;
			}

			Console.WriteLine("Duration: {0}", mMediaPlayer.Duration);
		}

		[Command("position", "Gets or sets the position of the current media channel. (Format = HH:MM:SS)")]
		[CommandArg("value", typeof(TimeSpan?), true)]
		public static void GetSetPosition(TimeSpan? value)
		{
			if (mMediaPlayer.[Friend]Handle == 0)
			{
				Console.WriteLine("No media has been loaded.");
				return;
			}

			if (value.HasValue)
			{
				Console.Write("{0} -> ", mMediaPlayer.Position);
				mMediaPlayer.Position = value.Value;
				Console.WriteLine(mMediaPlayer.Position);
			}
			else
				Console.WriteLine("Position: {0}", mMediaPlayer.Position);
		}

		[Command("seek", "Seeks the current media channel. (Format = Time + ms | s | m | h)")]
		[CommandArg("relative_time", typeof(RelativeTimeSpanParser))]
		public static void Seek(TimeSpan relativeTime)
		{
			if (mMediaPlayer.[Friend]Handle == 0)
			{
				Console.WriteLine("No media has been loaded.");
				return;
			}

			Console.Write("{0} -> ", mMediaPlayer.Position);
			mMediaPlayer.Position += relativeTime;
			Console.WriteLine(mMediaPlayer.Position);
		}
	}
}