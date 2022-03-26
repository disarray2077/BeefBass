// Adopted from http://www.codeproject.com/Articles/12919/C-Bitwise-Helper-Class

namespace BeefBass
{
    /// <summary>
    /// Helps perform certain operations on primative types that deal with bits
    /// </summary>
    public static class BitHelper
    {
        /// <summary>
        /// The return value is the high-order double word of the specified value.
        /// </summary>
        public static int64 HiDword(this int64 DWord) => (int64)((uint64)DWord >> 32);

        /// <summary>
        /// The return value is the low-order word of the specified value.
        /// </summary>
        public static int64 LoDword(this int64 DWord) => DWord & 0xFFFF'FFFF;

        /// <summary>
        /// The return value is the high-order word of the specified value.
        /// </summary>
        public static int32 HiWord(this int32 DWord) => (int32)((uint32)DWord >> 16);

        /// <summary>
        /// The return value is the low-order word of the specified value.
        /// </summary>
        public static int32 LoWord(this int32 DWord) => DWord & 0xFFFF;

        /// <summary>
        /// The return value is the high-order uint8 of the specified value.
        /// </summary>
        public static uint8 HiByte(this int16 Word) => (uint8)(Word >> 8);

        /// <summary>
        /// The return value is the low-order byte of the specified value.
        /// </summary>
        public static uint8 LoByte(this int16 Word) => (uint8)(Word & 0xFF);

        /// <summary>
        /// Make an int16 from 2-bytes.
        /// </summary>
        public static int16 MakeWord(uint8 Low, uint8 High) => (int16)(Low | (uint16)((uint16)High << 8));

        /// <summary>
        /// Make an integer putting <paramref name="Low"/> in low 2-uint8s and <paramref name="High"/> in high 2-uint8s.
        /// </summary>
        public static int32 MakeLong(int16 Low, int16 High) => (int32)((uint16)Low | (uint32)((uint32)High << 16));
    }
}