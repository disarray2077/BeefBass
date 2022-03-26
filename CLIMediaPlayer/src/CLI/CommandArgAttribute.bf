using System;

namespace CLIMediaPlayer.CLI
{
	[AttributeUsage(.Method, .AlwaysIncludeTarget | .ReflectAttribute)]
	struct CommandArgAttribute : Attribute
	{
		public String mArgName;
		public Type mArgType;
		public bool mOptional;

		public this(String argName, Type argType, bool optional = false)
		{
			mArgName = argName;
			mArgType = argType;
			mOptional = optional;
		}
	}
}