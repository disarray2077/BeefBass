using System;
using System.Collections;
using System.Reflection;
using CLIMediaPlayer.CLI.TypeConverters;

namespace CLIMediaPlayer.CLI
{
	abstract class CLI<T>
	{
		protected static bool CLIRunning = false;
		private static Dictionary<Type, MethodInfo> sCustomConverters = new .() ~ delete _;

		static this()
		{
			for (let type in Type.Types)
			{
				if (!(type is TypeInstance))
					continue;

				for (let attrib in type.GetCustomAttributes())
				{
					let attribType = attrib.VariantType as SpecializedGenericType;
					if (attribType == null || attribType.UnspecializedType != typeof(CustomParserAttribute<>))
						continue;

					let directOnlyField = attribType.GetField("mDirectOnly").Get();
					bool directOnly = directOnlyField.GetValue(attrib).Get().Get<bool>();
					if (directOnly)
						continue;

					MethodInfo parseMethod;
					Runtime.Assert(type.GetMethod("Parse") case .Ok(out parseMethod));

					sCustomConverters.Add(attribType.GetGenericArg(0), parseMethod);
				}
			}
		}

		[Command("quit", "Quits the application.")]
		public static void Quit()
		{
			CLIRunning = false;
		}

		protected static void ShowCommands()
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

		protected static void Run()
		{
			CLIRunning = true;

			while (CLIRunning)
			{
				Console.Write("> ");

				String cmd = scope .();
				if (Console.ReadLine(cmd) case .Err)
				{
					CLIRunning = false;
					break;
				}
				
				cmd.Trim();
				RunCommand(cmd);
			}
		}

		protected static bool RunCommand(String cmd)
		{
			var argEnumerator = cmd.Split(' ');

			StringView argName;
			if (!(argEnumerator.GetNext() case .Ok(out argName)))
				return true;

			for (let method in typeof(T).GetMethods(.Static | .Public))
			methodLoop:
			{
				CommandAttribute attrib = ?;
				if (!(method.GetCustomAttribute<CommandAttribute>() case .Ok(out attrib)))
					continue;

				if (attrib.mCommand != argName)
					continue;

				int argCount = 0;
				for (let argAttrib in method.GetCustomAttributes<CommandArgAttribute>())
					argCount++;

				int argIdx = 0;
				Variant[] argArray = scope Variant[argCount];

				for (let argAttrib in method.GetCustomAttributes<CommandArgAttribute>())
				{
					StringView argStr = .();
					if (!(argEnumerator.GetNext() case .Ok(out argStr)) && !argAttrib.mOptional)
					{
						Console.WriteLine("Not enough arguments to run command '{}', expected {} more.", attrib.mCommand, argCount - argIdx);
						return false;
					}

					Type argType = argAttrib.mArgType;
					bool argNullable = argType.IsNullable;
					if (argNullable)
						argType = ((SpecializedGenericType)argType).GetGenericArg(0);

					Type customParserType = null;
					if (argType.Interfaces.GetNext() case .Ok(let interfaceType))
					{
						if (let specializedType = interfaceType as SpecializedGenericType && specializedType.UnspecializedType == typeof(ICustomParser<>))
						{
							customParserType = argType;
							argType = specializedType.GetGenericArg(0);
						}
					}

					ref Variant result = ref argArray[argIdx];
					
					if (argStr.IsEmpty)
					{
						if (argType.IsValueType && !argNullable)
							Runtime.FatalError("Argument is optional but isn't nullable!");

						result = Variant.CreateReference(argType, null);
					}
					else
					{
						if (argType.IsValueType)
							result = Variant.AllocOwned(argType, .. ?);
						else
						{
							result.[Friend]mStructType = (int)Internal.UnsafeCastToPtr(argType) | 1;
							result.[Friend]mData = (int)(void*)new void*();
						}
	
						defer:methodLoop result.Dispose();
						
						MethodInfo? customParseMethod = null;
						if (customParserType != null)
						{
							if (!(customParserType.GetMethod("Parse") case .Ok(out customParseMethod)))
								Runtime.FatalError(scope $"No parse method available for supplied custom parser {customParserType}!");
						}
						else
						{
							if (sCustomConverters.TryGetValue(argType, let val))
								customParseMethod = val;
						}
	
						if (customParseMethod.HasValue)
						{
							if (customParseMethod.Value.Invoke(default, Variant.CreateReference(typeof(decltype(argEnumerator)), &argEnumerator), result) case .Ok(var returnVal))
							{
								if (returnVal.Get<Result<void>>() case .Err)
								{
									Console.WriteLine("Argument {} is in invalid format.", argIdx + 1);
									return false;
								}
								
								if (!argType.IsValueType)
								{
									// HACK: From ref to value
									result.[Friend]mData = (int)*((void**)(void*)result.[Friend]mData);
									// COMPILER-BUG: For some reason I can't use :methodLoop in the defer below...
									defer:: delete Internal.UnsafeCastToObject((.)result.[Friend]mData);
								}
							}
							else
							{
								Runtime.FatalError("Invokation of Parse method failed!");
							}
						}
						else
						{
							MethodInfo parseMethod;
							if (!(argType.GetMethod("Parse") case .Ok(out parseMethod)))
								Runtime.FatalError(scope $"No converter available for type {argType}!");
	
	
						}
					}

					argIdx++;
				}

				if (method.Invoke(default, params argArray) case .Ok(var val))
					val.Dispose();

				return true;
			}

			if (!argName.IsEmpty)
			{
				Console.WriteLine("Unknown command '{}'.", argName);
				return false;
			}

			return true;
		} 
	}
}