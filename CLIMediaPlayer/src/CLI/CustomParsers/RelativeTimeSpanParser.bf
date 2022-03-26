using System;

namespace CLIMediaPlayer.CLI.TypeConverters
{
	[CustomParser<TimeSpan>(true)]
	static class RelativeTimeSpanParser
	{
		public static Result<void> Parse(ref StringSplitEnumerator args, ref TimeSpan result)
		{
			StringView value = args.Current;

			bool isNeg = value.StartsWith('-');
			bool isPos = value.StartsWith('+');

			if (isNeg || isPos)
				value.RemoveFromStart(1);

			double valueDouble;
			if (!(double.Parse(value[...^2]) case .Ok(out valueDouble)))
				return .Err;

			if (value.EndsWith("ms"))
				result = TimeSpan.FromMilliseconds(valueDouble);
			else if (value.EndsWith('s'))
				result = TimeSpan.FromSeconds(valueDouble);
			else if (value.EndsWith('m'))
				result = TimeSpan.FromMinutes(valueDouble);
			else if (value.EndsWith('h'))
				result = TimeSpan.FromHours(valueDouble);
			else
				return .Err;

			if (isNeg)
				result = result.Negate();

			return .Ok;
		}
	}
}