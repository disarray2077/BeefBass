using System;

namespace CLIMediaPlayer.CLI.TypeConverters
{
	[CustomParser<bool>]
	static class BoolParser
	{
		public static Result<void> Parse(ref StringSplitEnumerator args, ref bool result)
		{
			let value = args.Current;
			if (value == "y" || value == "n")
			{
				result = value == "y";
				return .Ok;
			}
			return .Err;
		}
	}
}