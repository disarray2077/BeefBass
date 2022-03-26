using System;

namespace BeefBass
{
    /// <summary>
    /// Structure used by the 3D functions to describe positions, velocities, and orientations in the left-handed coordinate system.
    /// </summary>
    [CRepr]
    public class Vector3D
    {
        /// <summary>
        /// +values=right, -values=left (default=0)
        /// </summary>
        public float X;

        /// <summary>
        /// +values=up, -values=down (default=0)
        /// </summary>
        public float Y;

        /// <summary>
        /// +values=front, -values=behind (default=0)
        /// </summary>
        public float Z;

        /// <summary>
        /// Creates a new instance of <see cref="Vector3D"/>.
        /// </summary>
        public this() { }

        /// <summary>
        /// Creates a new instance of Vector3D and initialises members.
        /// </summary>
        public this(float X, float Y, float Z)
        {
            this.X = X;
            this.Y = Y;
            this.Z = Z;
        }

        /// <summary>
        /// Returns a string representation of this Vector.
        /// </summary>
        public override void ToString(String outString)
		{
			outString.AppendF($"({X}, {Y}, {Z})");
		}
    }
}
