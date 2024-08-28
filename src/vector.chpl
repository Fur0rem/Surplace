module Vector {
    record Vec3 {
        var x: real;
        var y: real;
        var z: real;
    }

    operator + (a: Vec3, b: Vec3) : Vec3 {
        return new Vec3(a.x + b.x, a.y + b.y, a.z + b.z);
    }

    operator - (a: Vec3, b: Vec3) : Vec3 {
        return new Vec3(a.x - b.x, a.y - b.y, a.z - b.z);
    }

    operator * (a: Vec3, b: real) : Vec3 {
        return new Vec3(a.x * b, a.y * b, a.z * b);
    }

    operator * (a: real, b: Vec3) : Vec3 {
        return new Vec3(a * b.x, a * b.y, a * b.z);
    }

    operator - (a: Vec3) : Vec3 {
        return new Vec3(-a.x, -a.y, -a.z);
    }

    operator + (v: Vec3, b: real) : Vec3 {
        return new Vec3(v.x + b, v.y + b, v.z + b);
    }

    operator - (v: Vec3, b: real) : Vec3 {
        return new Vec3(v.x - b, v.y - b, v.z - b);
    }

    operator / (v: Vec3, b: real) : Vec3 {
        return new Vec3(v.x / b, v.y / b, v.z / b);
    }

    proc Vec3.length() : real {
        return sqrt(x**2 + y**2 + z**2);
    }

    proc Vec3.dot(other: Vec3) : real {
        return this.x * other.x 
                + this.y * other.y 
                + this.z * other.z;
    }

    proc Vec3.cross(other: Vec3) : Vec3 {
        return new Vec3(
            x = this.y * other.z - this.z * other.y,
            y = this.z * other.x - this.x * other.z,
            z = this.x * other.y - this.y * other.x
        );
    }

    proc ref Vec3.normalise() {
        var length = this.length();
        this.x /= length;
        this.y /= length;
        this.z /= length;
    }

    proc Vec3.abs() : Vec3 {
        return new Vec3(
            // I can't use abs() here because otherwise Chapel thinks I'm calling this.abs()
            x = if this.x < 0 then -this.x else this.x,
            y = if this.y < 0 then -this.y else this.y,
            z = if this.z < 0 then -this.z else this.z
        );
    }

    type Point = Vec3;
}