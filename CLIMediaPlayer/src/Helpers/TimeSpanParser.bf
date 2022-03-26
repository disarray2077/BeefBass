namespace System
{
	extension TimeSpan
	{
		// Very simple TimeSpan.Parse, better than nothing
		public static Result<TimeSpan> Parse(StringView str)
		{
			var msSeparator = str.Split('.');
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
				return TimeSpan(hours, minutes, 0);
			}

			let seconds = ParseComponent!(components.GetNext());

			if (!components.HasMore)
			{
				int32 milliseconds = 0;
				if (msSeparator.HasMore)
					milliseconds = ParseComponent!(msSeparator.GetNext());
				return TimeSpan(0, hours, minutes, seconds, milliseconds);
			}

			return .Err;
		}
	}
}