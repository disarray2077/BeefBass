using System;

namespace BeefBass.Fx
{
    /// <summary>
    /// User defined callback function, to auto get the BPM after each period of time in seconds.
    /// </summary>
    /// <param name="Channel">Handle that the <see cref="BassFx.BPMCallbackSet" /> applies to.</param>
    /// <param name="BPM">The new original bpm value.</param>
    /// <param name="User">The user instance data given when <see cref="BassFx.BPMCallbackSet" /> was called.</param>
    [CallingConvention(.Stdcall)]
    public function void BPMProcedure(int32 Channel, float BPM, void* User);
}