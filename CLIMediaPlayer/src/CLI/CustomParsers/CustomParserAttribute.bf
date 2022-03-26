using System;

namespace CLIMediaPlayer.CLI.TypeConverters
{
	[AttributeUsage(.Types, .AlwaysIncludeTarget | .ReflectAttribute | .DisallowAllowMultiple, AlwaysIncludeUser=.IncludeAllMethods | .AssumeInstantiated, ReflectUser=.StaticMethods)]
	struct CustomParserAttribute<T> : Attribute, IComptimeTypeApply
	{
		bool mDirectOnly;

		public this(bool directOnly = false)
		{
			mDirectOnly = directOnly;
		}

		[Comptime]
		public void ApplyToType(Type type)
		{
			Compiler.EmitAddInterface(type, typeof(ICustomParser<T>));
		}
	}

	interface ICustomParser<T>
	{
		public static Result<void> Parse(ref StringSplitEnumerator args, ref T result);
	}
}