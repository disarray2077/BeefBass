using System;

namespace CLIMediaPlayer.CLI
{
	[AttributeUsage(.Method, .AlwaysIncludeTarget | .ReflectAttribute | .DisallowAllowMultiple)]
	struct CommandAttribute : Attribute
	{
		public String mCommand;
		public String mDesc;

		public this(String cmd, String desc)
		{
			mCommand = cmd;
			mDesc = desc;
		}
	}
}