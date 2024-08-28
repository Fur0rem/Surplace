module Camera {

    import Vector.Vec3;
    use Ray;
    use Math;
    
    record Camera {
        var origin: Vec3;
        var direction: Vec3;
    }

    proc Camera.ray(x: uint, y: uint, width: uint, height: uint) : Ray {
        var aspect_ratio = width:real / height:real;
        var fov = 90.0;
        var scale = tan(fov * pi / 360.0);
        var rx = (2.0 * (x + 0.5) / width - 1.0) * aspect_ratio * scale;
        var ry = (1.0 - 2.0 * (y + 0.5) / height) * scale;
        var direction = this.direction + new Vec3(rx, ry, 1.0);
        direction.normalise();
        return new Ray(origin = this.origin, direction = direction);
    }
}