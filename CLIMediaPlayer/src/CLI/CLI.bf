using System;
using System.Collections;
using System.Reflection;

namespace CLIMediaPlayer.CLI
{
	abstract class CLI<T>
	{
		public static bool CLIRunning = false;

		public static void ShowCommands()
		{
			int maxCmdStrLength = 0;
			List<(String, String)> commandList = scope .();

			for (let method in typeof(T).GetMethods(.Static | .Public))
			{
				CommandAttribute attrib = ?;
				if (!(method.GetCustomAttribute<CommandAttribute>() case .Ok(out attrib)))
					continue;

				String str = scope:: .();

				str.Append(attrib.mCommand);
				str.Append(" ");

				for (let argAttrib in method.GetCustomAttributes<CommandArgAttribute>())
				{
					if (argAttrib.mOptional)
						str.AppendF("[{0}] ", argAttrib.mArgName);
					else
						str.AppendF("<{0}> ", argAttrib.mArgName);
				}

				if (maxCmdStrLength < str.Length)
					maxCmdStrLength = str.Length;

				commandList.Add((str, attrib.mDesc));
			}

			for (let (cmdStr, desc) in commandList)
			{
				Console.Write(cmdStr..PadRight(maxCmdStrLength + 1));
				Console.WriteLine(desc);
			}
		}

		public static void Run()
		{
			CLIRunning = true;

			runLoop: while (CLIRunning)
			{
				Console.Write("> ");

				String cmd = scope .();
				if (Console.ReadLine(cmd) case .Err)
				{
					CLIRunning = false;
					break;
				}

				cmd.Trim();
				var argEnumerator = cmd.Split(' ');

				StringView argName;
				if (!(argEnumerator.GetNext() case .Ok(out argName)))
					continue;

				for (let method in typeof(T).GetMethods(.Static | .Public))
				mLoop: {
					CommandAttribute attrib = ?;
					if (!(method.GetCustomAttribute<CommandAttribute>() case .Ok(out attrib)))
						continue;

					if (attrib.mCommand != argName)
						continue;

					int argCount = 0;
					for (let argAttrib in method.GetCustomAttributes<CommandArgAttribute>())
						argCount++;

					int argIdx = 0;
					Object[] argArray = scope Object[argCount];

					for (let argAttrib in method.GetCustomAttributes<CommandArgAttribute>())
					{
						StringView argStr = .();
						if (!(argEnumerator.GetNext() case .Ok(out argStr)) && !argAttrib.mOptional)
						{
							Console.WriteLine("Not enough arguments to run command '{}', expected {} more.", attrib.mCommand, argCount - argIdx);
							continue runLoop;
						}

						Type argType = argAttrib.mArgType;
						bool argNullable = argType.IsNullable;
						if (argNullable)
							argType = ((SpecializedGenericType)argType).GetGenericArg(0);

						switch (argType)
						{
						case typeof(TimeSpan):
							if (!argStr.IsEmpty)
							{
								TimeSpan argTS;
								if (!(TimeSpan.Parse(argStr) case .Ok(out argTS)))
								{
									Console.WriteLine("Time is in invalid format.");
									continue runLoop;
								}

								argArray[argIdx] = scope:mLoop box argTS;
							}
							else if (!argNullable)
								Runtime.FatalError("Argument is optional but isn't nullable!");
						case typeof(bool):
							if (!argStr.IsEmpty)
							{
								if (argStr == "y" || argStr == "n")
									argArray[argIdx] = scope:mLoop box argStr == "y";
								else
								{
									Console.WriteLine("Boolean is in invalid format.");
									continue runLoop;
								}
							}
							else if (!argNullable)
								Runtime.FatalError("Argument is optional but isn't nullable!");
						case typeof(double):
							if (!argStr.IsEmpty)
							{
								double argDouble;
								if (!(double.Parse(argStr) case .Ok(out argDouble)))
								{
									Console.WriteLine("Number is in invalid format.");
									continue runLoop;
								}

								argArray[argIdx] = scope:mLoop box argDouble;
							}
							else if (!argNullable)
								Runtime.FatalError("Argument is optional but isn't nullable!");
						case typeof(String):
							String fullArgStr = scope:mLoop .();
							argArray[argIdx] = fullArgStr;

							if (argStr.StartsWith('"') && argStr.EndsWith('"'))
								argStr = argStr[1...^2];

							if (argStr.StartsWith('"'))
							{
								fullArgStr.Set(argStr[1...]);
								fullArgStr.Append(' ');

								while (true)
								{
									if (!(argEnumerator.GetNext() case .Ok(out argStr)))
									{
										Console.WriteLine("Unterminated quoted string.");
										continue runLoop;
									}

									if (argStr.EndsWith('"'))
									{
										fullArgStr.Append(argStr[...^2]);
										break;
									}

									fullArgStr.Append(argStr);
									fullArgStr.Append(' ');
								}
							}
							else
							{
								fullArgStr.Set(argStr);
							}
						}

						argIdx++;
					}

					if (method.Invoke(null, params argArray) case .Ok(var val))
						val.Dispose();

					continue runLoop;
				}

				if (!argName.IsEmpty)
					Console.WriteLine("Unknown command '{}'.", argName);
			}
		}
	}
}