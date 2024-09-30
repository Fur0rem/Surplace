module Ray {

    import Vector.Point;
    import Vector.Vec3;
    use Random;

    record Ray {
        var origin: Point;
        var direction: Vec3;
    }

    proc Ray.at(t: real(64)) : Point {
        return origin + t * direction;
    }

    proc sample_square() : Vec3 {
        var rand = new randomStream(real(64));
        return new Vec3(
            x = rand.next(-0.5, 0.5),
            y = rand.next(-0.5, 0.5),
            z = 0.0
        );
    }

    proc ref Ray.advance(t: real(64)) {
        this.origin = this.at(t);
    }

}