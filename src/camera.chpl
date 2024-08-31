module Camera {

    use Vector;
    use Ray;
    use Math;
    import Random;
    
    record Camera {
        var origin: Vec3;
    }

    proc Camera.ray(x: uint, y: real, width: uint, height: uint) : Ray {
        var aspect_ratio = width:real / height:real;
        var fov = 90.0;
        var scale = tan(fov * pi / 360.0);
        var rx = (2.0 * (x + 0.5) / width - 1.0) * aspect_ratio * scale;
        var ry = (1.0 - 2.0 * (y + 0.5) / height) * scale;
        var direction = new Vec3(rx, ry, 1.0);
        direction.normalise();
        var ray = new Ray(origin = this.origin, direction = direction);
        return ray;
    }

    // proc Camera.delta_x(width: uint) : real {
    //     var ray_at_0 = this.ray_unnormalised(0, 0, width, 1);
    //     var ray_at_1 = this.ray_unnormalised(1, 0, width, 1);
    //     return (ray_at_1.origin - ray_at_0.origin).length();
    // }

    // proc Camera.delta_y(height: uint) : real {
    //     var ray_at_0 = this.ray_unnormalised(0, 0, 1, height);
    //     var ray_at_1 = this.ray_unnormalised(0, 1, 1, height);
    //     return (ray_at_1.origin - ray_at_0.origin).length();
    // }

    proc Camera.slightly_random_ray(x: uint, y: uint, width: uint, height: uint) : Ray {
        var rand = new Random.randomStream(real);
        var rx = (2.0 * (x + rand.next(-0.5, 0.5)) / width - 1.0);
        var ry = (1.0 - 2.0 * (y + rand.next(-0.5, 0.5)) / height);
        var direction = new Vec3(rx, ry, 1.0);
        direction.normalise();
        return new Ray(origin = this.origin, direction = direction);
    }

    proc Camera.five_uniform_samples_rays(x: uint, y: uint, width: uint, height: uint) : [0..4] Ray {
        var rays: [0..4] Ray;

        var offsets = [[-0.5, -0.5], [0.5, -0.5], [-0.5, 0.5], [0.5, 0.5], [0.0, 0.0]];
        for i in 0..4 {
            var offset = offsets[i];
            var rx = (2.0 * (x + offset[0]) / width - 1.0);
            var ry = (1.0 - 2.0 * (y + offset[1]) / height);
            var direction = new Vec3(rx, ry, 1.0);
            direction.normalise();
            rays[i] = new Ray(origin = this.origin, direction = direction);
        }

        return rays;
    }

    proc Camera.one_ray(x: uint, y: uint, width: uint, height: uint) : [0..0] Ray {
        return [this.ray(x, y, width, height)];
    }

    proc Camera.n_random_rays(x: uint, y: uint, width: uint, height: uint, n: uint) : [] Ray {
        var rays: [1..n] Ray;
        for i in 1..n {
            rays[i] = this.slightly_random_ray(x, y, width, height);
        }
        return rays;
    }
}