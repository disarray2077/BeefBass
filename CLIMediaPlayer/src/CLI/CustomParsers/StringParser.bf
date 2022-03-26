using System;
using System.Diagnostics;

namespace CLIMediaPlayer.CLI.TypeConverters
{
	[CustomParser<String>]
	static class StringParser
	{
		public static Result<void> Parse(ref StringSplitEnumerator args, ref String result)
		{
			if (result == null)
				result = new .();

			StringView value = args.Current;

			if (value.StartsWith('"') && value.EndsWith('"'))
				value = value[1...^2];

			if (value.StartsWith('"'))
			{
				result.Set(value[1...]);
				result.Append(' ');

				while (true)
				{
					if (!(args.GetNext() case .Ok(out value)))
						return .Err;

					if (value.EndsWith('"'))
					{
						result.Append(value[...^2]);
						break;
					}

					result.Append(value);
					result.Append(' ');
				}
			}
			else
			{
				result.Set(value);
			}

			return .Ok;
		}
	}
}