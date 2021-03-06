using System;

namespace BeefBass.Fx
{
    /// <summary>
	/// User defined callback function, to get the bpm detection process in percents.
	/// </summary>
	/// <param name="Channel">Channel that the <see cref="BassFx.BPMDecodeGet" /> applies to.</param>
	/// <param name="Percent">The progress of the process in percent (0%..100%).</param>
	/// <param name="User">The user instance data given when <see cref="BassFx.BPMDecodeGet" /> was called.</param>
	[CallingConvention(.Stdcall)]
	public function void BPMProgressProcedure(int32 Channel, float Percent, void* User);
}