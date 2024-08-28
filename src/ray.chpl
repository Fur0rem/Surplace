module Ray {

    import Vector.Point;
    import Vector.Vec3;

    record Ray {
        var origin: Point;
        var direction: Vec3;
    }

    proc Ray.at(t: real) : Point {
        return origin + t * direction;
    }

    proc ref Ray.advance(t: real) {
        this.origin = this.at(t);
    }

}