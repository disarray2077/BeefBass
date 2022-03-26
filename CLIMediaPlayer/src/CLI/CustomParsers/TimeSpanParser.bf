using System;

namespace CLIMediaPlayer.CLI.TypeConverters
{
	[CustomParser<TimeSpan>]
	static class TimeSpanParser
	{
		public static Result<void> Parse(ref StringSplitEnumerator args, ref TimeSpan result)
		{
			var msSeparator = args.Current.Split('.');
			var components = Try!(msSeparator.GetNext()).Split(':');

			mixin ParseComponent(var component)
			{
				int32 parsedComponent;
				if (!(int32.Parse(component) case .Ok(out parsedComponent)))
					return .Err;
				parsedComponent
			}

			let hours = ParseComponent!(components.GetNext());
			let minutes = ParseComponent!(Try!(components.GetNext()));

			if (!components.HasMore)
			{
				if (msSeparator.HasMore)
					return .Err;
				result = TimeSpan(hours, minutes, 0);
				return .Ok;
			}

			let seconds = ParseComponent!(components.GetNext());

			if (!components.HasMore)
			{
				int32 milliseconds = 0;
				if (msSeparator.HasMore)
					milliseconds = ParseComponent!(msSeparator.GetNext());
				result = TimeSpan(0, hours, minutes, seconds, milliseconds);
				return .Ok;
			}

			return .Err;
		}
	}
}