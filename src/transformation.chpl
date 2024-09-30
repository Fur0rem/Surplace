module Transformation {

    use Vector;
    use Math;

    record Quaterion {
        var x: real(64);
        var y: real(64);
        var z: real(64);
        var w: real(64);
    }

    proc Quaterion_identity() : Quaterion {
        return new Quaterion(0.0, 0.0, 0.0, 1.0);
    }

    proc Quaterion_rotation(axis: Vec3, angle: real(64)) : Quaterion {
        var halfAngle = angle / 2.0;
        var sinHalfAngle = sin(halfAngle);
        return new Quaterion(
            axis.x * sinHalfAngle,
            axis.y * sinHalfAngle,
            axis.z * sinHalfAngle,
            cos(halfAngle)
        );
    }

    proc Quaternion_from_euler(euler: Vec3) : Quaterion {
        var c1 = cos(euler.y / 2.0);
        var c2 = cos(euler.z / 2.0);
        var c3 = cos(euler.x / 2.0);
        var s1 = sin(euler.y / 2.0);
        var s2 = sin(euler.z / 2.0);
        var s3 = sin(euler.x / 2.0);
        return new Quaterion(
            x = s1 * c2 * c3 + c1 * s2 * s3,
            y = c1 * s2 * c3 - s1 * c2 * s3,
            z = c1 * c2 * s3 + s1 * s2 * c3,
            w = c1 * c2 * c3 - s1 * s2 * s3
        );
    }

    record M4x4 {
        var m00: real(64);
        var m01: real(64);
        var m02: real(64);
        var m03: real(64);
        var m10: real(64);
        var m11: real(64);
        var m12: real(64);
        var m13: real(64);
        var m20: real(64);
        var m21: real(64);
        var m22: real(64);
        var m23: real(64);
        var m30: real(64);
        var m31: real(64);
        var m32: real(64);
        var m33: real(64);
    }

    proc M4x4_identity() : M4x4 {
        return new M4x4(
            1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0
        );
    }

    proc M4x4.inverse() : M4x4 {
        var det = m00 * (m11 * m22 * m33 + m12 * m23 * m31 + m13 * m21 * m32 - m13 * m22 * m31 - m11 * m23 * m32 - m12 * m21 * m33)
                - m01 * (m10 * m22 * m33 + m12 * m23 * m30 + m13 * m20 * m32 - m13 * m22 * m30 - m10 * m23 * m32 - m12 * m20 * m33)
                + m02 * (m10 * m21 * m33 + m11 * m23 * m30 + m13 * m20 * m31 - m13 * m21 * m30 - m10 * m23 * m31 - m11 * m20 * m33)
                - m03 * (m10 * m21 * m32 + m11 * m22 * m30 + m12 * m20 * m31 - m12 * m21 * m30 - m10 * m22 * m31 - m11 * m20 * m32);
        // writeln("det= ", det);
        var invDet = 1.0 / det;
        return new M4x4(
            (m11 * m22 * m33 + m12 * m23 * m31 + m13 * m21 * m32 - m13 * m22 * m31 - m11 * m23 * m32 - m12 * m21 * m33) * invDet,
            (m01 * m23 * m32 + m02 * m21 * m33 + m03 * m22 * m31 - m03 * m21 * m32 - m01 * m22 * m33 - m02 * m23 * m31) * invDet,
            (m01 * m12 * m33 + m02 * m13 * m31 + m03 * m11 * m32 - m03 * m12 * m31 - m01 * m13 * m32 - m02 * m11 * m33) * invDet,
            (m01 * m13 * m22 + m02 * m11 * m23 + m03 * m12 * m21 - m03 * m11 * m22 - m01 * m12 * m23 - m02 * m13 * m21) * invDet,
            (m10 * m23 * m32 + m12 * m20 * m33 + m13 * m22 * m30 - m13 * m20 * m32 - m10 * m22 * m33 - m12 * m23 * m30) * invDet,
            (m00 * m22 * m33 + m02 * m23 * m30 + m03 * m20 * m32 - m03 * m22 * m30 - m00 * m23 * m32 - m02 * m20 * m33) * invDet,
            (m00 * m13 * m32 + m02 * m10 * m33 + m03 * m12 * m30 - m03 * m10 * m32 - m00 * m12 * m33 - m02 * m13 * m30) * invDet,
            (m00 * m12 * m23 + m02 * m13 * m20 + m03 * m10 * m22 - m03 * m12 * m20 - m00 * m13 * m22 - m02 * m10 * m23) * invDet,
            (m10 * m21 * m33 + m11 * m23 * m30 + m13 * m20 * m31 - m13 * m21 * m30 - m10 * m23 * m31 - m11 * m20 * m33) * invDet,
            (m00 * m23 * m31 + m01 * m20 * m33 + m03 * m21 * m30 - m03 * m20 * m31 - m00 * m21 * m33 - m01 * m23 * m30) * invDet,
            (m00 * m11 * m33 + m01 * m13 * m30 + m03 * m10 * m31 - m03 * m11 * m30 - m00 * m13 * m31 - m01 * m10 * m33) * invDet,
            (m00 * m13 * m21 + m01 * m10 * m23 + m03 * m11 * m20 - m03 * m10 * m21 - m00 * m11 * m23 - m01 * m13 * m20) * invDet,
            (m10 * m22 * m31 + m11 * m20 * m32 + m12 * m21 * m30 - m12 * m20 * m31 - m10 * m21 * m32 - m11 * m22 * m30) * invDet,
            (m00 * m21 * m32 + m01 * m22 * m30 + m02 * m20 * m31 - m02 * m21 * m30 - m00 * m22 * m31 - m01 * m20 * m32) * invDet,
            (m00 * m12 * m31 + m01 * m10 * m32 + m02 * m11 * m30 - m02 * m10 * m31 - m00 * m11 * m32 - m01 * m12 * m30) * invDet,
            (m00 * m11 * m22 + m01 * m12 * m20 + m02 * m10 * m21 - m02 * m11 * m20 - m00 * m12 * m21 - m01 * m10 * m22) * invDet
        );
    }

    proc M4x4_translation(translation: Vec3) : M4x4 {
        return new M4x4(
            1.0, 0.0, 0.0, translation.x,
            0.0, 1.0, 0.0, translation.y,
            0.0, 0.0, 1.0, translation.z,
            0.0, 0.0, 0.0, 1.0
        );
    }

    proc M4x4_scale(scale: Vec3) : M4x4 {
        return new M4x4(
            scale.x, 0.0, 0.0, 0.0,
            0.0, scale.y, 0.0, 0.0,
            0.0, 0.0, scale.z, 0.0,
            0.0, 0.0, 0.0, 1.0
        );
    }

    proc M4x4_scale(scale: real(64)) : M4x4 {
        return new M4x4(
            scale, 0.0, 0.0, 0.0,
            0.0, scale, 0.0, 0.0,
            0.0, 0.0, scale, 0.0,
            0.0, 0.0, 0.0, 1.0
        );
    }

    proc M4x4_rotation(axis: Vec3, angle: real(64)) : M4x4 {
        var halfAngle = angle / 2.0;
        var sinHalfAngle = sin(halfAngle);
        var cosHalfAngle = cos(halfAngle);
        var rX = axis.x * sinHalfAngle;
        var rY = axis.y * sinHalfAngle;
        var rZ = axis.z * sinHalfAngle;
        var rW = cosHalfAngle;
        var rX2 = rX + rX;
        var rY2 = rY + rY;
        var rZ2 = rZ + rZ;
        var rXX = rX * rX2;
        var rXY = rX * rY2;
        var rXZ = rX * rZ2;
        var rYY = rY * rY2;
        var rYZ = rY * rZ2;
        var rZZ = rZ * rZ2;
        var rWX = rW * rX2;
        var rWY = rW * rY2;
        var rWZ = rW * rZ2;
        return new M4x4(
            1.0 - (rYY + rZZ), rXY - rWZ, rXZ + rWY, 0.0,
            rXY + rWZ, 1.0 - (rXX + rZZ), rYZ - rWX, 0.0,
            rXZ - rWY, rYZ + rWX, 1.0 - (rXX + rYY), 0.0,
            0.0, 0.0, 0.0, 1.0
        );
    }

    proc M4x4_rotation(euler: Vec3) : M4x4 {
        var q = Quaternion_from_euler(euler);
        return M4x4_rotation(new Vec3(q.x, q.y, q.z), 2.0 * acos(q.w));
    }

    operator * (a: M4x4, b: M4x4) : M4x4 {
        return new M4x4(
            a.m00 * b.m00 + a.m01 * b.m10 + a.m02 * b.m20 + a.m03 * b.m30,
            a.m00 * b.m01 + a.m01 * b.m11 + a.m02 * b.m21 + a.m03 * b.m31,
            a.m00 * b.m02 + a.m01 * b.m12 + a.m02 * b.m22 + a.m03 * b.m32,
            a.m00 * b.m03 + a.m01 * b.m13 + a.m02 * b.m23 + a.m03 * b.m33,
            a.m10 * b.m00 + a.m11 * b.m10 + a.m12 * b.m20 + a.m13 * b.m30,
            a.m10 * b.m01 + a.m11 * b.m11 + a.m12 * b.m21 + a.m13 * b.m31,
            a.m10 * b.m02 + a.m11 * b.m12 + a.m12 * b.m22 + a.m13 * b.m32,
            a.m10 * b.m03 + a.m11 * b.m13 + a.m12 * b.m23 + a.m13 * b.m33,
            a.m20 * b.m00 + a.m21 * b.m10 + a.m22 * b.m20 + a.m23 * b.m30,
            a.m20 * b.m01 + a.m21 * b.m11 + a.m22 * b.m21 + a.m23 * b.m31,
            a.m20 * b.m02 + a.m21 * b.m12 + a.m22 * b.m22 + a.m23 * b.m32,
            a.m20 * b.m03 + a.m21 * b.m13 + a.m22 * b.m23 + a.m23 * b.m33,
            a.m30 * b.m00 + a.m31 * b.m10 + a.m32 * b.m20 + a.m33 * b.m30,
            a.m30 * b.m01 + a.m31 * b.m11 + a.m32 * b.m21 + a.m33 * b.m31,
            a.m30 * b.m02 + a.m31 * b.m12 + a.m32 * b.m22 + a.m33 * b.m32,
            a.m30 * b.m03 + a.m31 * b.m13 + a.m32 * b.m23 + a.m33 * b.m33
        );
    }

    operator * (vec: Vec3, mat: M4x4) : Vec3 {
        // assume the fourth element of the vector is 1
        return new Vec3(
            x = vec.x * mat.m00 + vec.y * mat.m01 + vec.z * mat.m02 + mat.m03,
            y = vec.x * mat.m10 + vec.y * mat.m11 + vec.z * mat.m12 + mat.m13,
            z = vec.x * mat.m20 + vec.y * mat.m21 + vec.z * mat.m22 + mat.m23
        );
    }

    operator * (mat: M4x4, vec: Vec3) : Vec3 {
        // assume the fourth element of the vector is 1
        return new Vec3(
            x = vec.x * mat.m00 + vec.y * mat.m10 + vec.z * mat.m20 + mat.m30,
            y = vec.x * mat.m01 + vec.y * mat.m11 + vec.z * mat.m21 + mat.m31,
            z = vec.x * mat.m02 + vec.y * mat.m12 + vec.z * mat.m22 + mat.m32
        );
    }
}