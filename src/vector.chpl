module Vector {

    import Random;

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

    proc Vec3.length_squared() : real {
        return x**2 + y**2 + z**2;
    }

    proc Vec3.length() : real {
        return sqrt(this.length_squared());
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

    proc randomVec3() : Vec3 {
        var randStream = new Random.randomStream(real);
        return new Vec3(
            x = randStream.next(),
            y = randStream.next(),
            z = randStream.next()
        );
    }

    proc randomVec3(min: real, max: real) : Vec3 {
        var randStream = new Random.randomStream(real);
        return new Vec3(
            x = randStream.next(min, max),
            y = randStream.next(min, max),
            z = randStream.next(min, max)
        );
    }

    proc randomVec3InUnitSphere() : Vec3 {
        while true {
            var p = randomVec3(-1.0, 1.0);
            if p.length_squared() < 1.0 {
                return p;
            }
        }
        // Unreachable
        return new Vec3(0.0, 0.0, 0.0);
    }

    proc randomVec3Unit() : Vec3 {
        var vec = randomVec3InUnitSphere();
        vec.normalise();
        return vec;
    }

    proc randomVec3InHemisphere(normal: Vec3) : Vec3 {
        var inUnitSphere = randomVec3Unit();
        if inUnitSphere.dot(normal) > 0.0 {
            return inUnitSphere;
        } else {
            return -inUnitSphere;
        }
    }

    proc vecs_in_hemisphere_uniform(normal: Vec3, nb_vecs: uint) : [] Vec3 {
        var vecs: [1..nb_vecs] Vec3;
        vecs[1] = normal;
        for i in 2..nb_vecs {
            vecs[i] = randomVec3InHemisphere(normal);
        }
        return vecs;
    }

    type Point = Vec3;
}