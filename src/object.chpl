module Object {
    use Vector;
    use Colour;
    use Transformation;
    use Ray;
    use Rendering;
    import Camera;
    use Time;
    use Math;
    use MaterialModule;

    enum ShapeTag {
        Sphere,
        Cube,
        Mandelbulb
    }

    union ShapeValue {
        var sphere: nothing;
        var cube: nothing;
        var mandelbulb: (uint, real(64));
    }

    record Object {
        var shape_tag: ShapeTag;
        var shape_value: ShapeValue;
        var position: Point;
        var scale: Vec3;
        // var scale: real(64);
        var rotation: Vec3;
        var material: Material;
        var ignored: bool;
    }

    // Diameter of sphere is 1
    proc Sphere_distance(p: Point) : real(64) {
        // writeln("COmputing distance for sphere at ", p);
        return p.length() - 0.5;
    }

    // Cube of side length 1 and centered at (0, 0, 0)
    proc Cube_distance(p: Point) : real(64) {
        var q = p.abs() - 0.5;
        return max(max(q.x, q.y), q.z);
    }

    /*
    Shape::Mandelbulb { iterations, power } => {
        let mut z = point;
        let mut dr = 1.0;
        let mut r = 0.0;

        for _ in 0..iterations {
            r = z.length();
            if r > 2.0 {
                break;
            }

            // Convert to polar coordinates
            let mut theta = (z.z / r).acos();
            let mut phi = z.y.atan2(z.x);
            dr = r.powf(power - 1.0) * power * dr + 1.0;

            // Scale and rotate the point
            let zr = r.powf(power);
            theta *= power;
            phi *= power;

            // Convert back to cartesian coordinates
            z = Vec3 {
                x: zr * theta.sin() * phi.cos(),
                y: zr * theta.sin() * phi.sin(),
                z: zr * theta.cos(),
            } + point;

            z = z * self.scale;
        }

        0.5 * r.ln() * r / dr
    */
    proc Mandelbulb_distance(p: Point, nb_it: uint, power: real(64)) : real(64) {
        var z = p;
        var dr = 1.0;
        var r = 0.0;

        for x in 1..nb_it {
            r = z.length();
            if (r > 2.0) {
                break;
            }

            var theta = acos(z.z / r);
            var phi = atan2(z.y, z.x);
            dr = (r ** (power - 1.0)) * power * dr + 1.0;

            var zr = r**power;
            theta *= power;
            phi *= power;
            
            z = new Vec3(
                x = zr * sin(theta) * cos(phi),
                y = zr * sin(theta) * sin(phi),
                z = zr * cos(theta)
            ) + p;
        }

        return (0.5 * ln(r) * r) / dr;
    }

    proc Object.distance(pos: Point) : real(64) {
        if (this.ignored) {
            return 99999; // can't put +inf otherwise minimum will fail or some shit, fuck floats
        }
        
        select this.shape_tag {
            when ShapeTag.Sphere {
                return Sphere_distance(pos);
            }
            when ShapeTag.Cube {
                return Cube_distance(pos);
            }
            when ShapeTag.Mandelbulb {
                const (iterations, power) = this.shape_value.mandelbulb;
                return Mandelbulb_distance(pos, iterations, power);
            }
        }
        // Unreachable
        return +inf;
    }

    proc Object.map_point(p: Point) : Point {
        // map the point to the object's space (scale, rotation, translation)
        var translate = M4x4_translation(this.position);
        var scale = M4x4_scale(this.scale);
        var rotate = M4x4_rotation(this.rotation);
        var transform = translate * rotate * scale;
        var inv_transform = transform.inverse();
        // writeln("transform = ", transform);
        // writeln("inv_transform = ", inv_transform);
        // writeln("p * inv_transform = ", p * inv_transform);
        return p * inv_transform;
    }

    proc Object.distance_mapped(pos: Point) : real(64) {
        var p = this.map_point(pos);
        var dist = this.distance(p);
        // return dist * (this.scale.x + this.scale.y + this.scale.z) / 3.0; // this is probably wrong lol, i hate scaling that's not uniform
        return dist * min(this.scale.x, min(this.scale.y, this.scale.z));
    }

    proc Object.normal(p: Point) : Vec3 {
        // Usual normal calculation
        const EPS: real(64) = 0.002;
        
        // map the the point to the object's space (scale, rotation, translation)
        const x = this.distance_mapped(new Point(p.x + EPS, p.y, p.z)) - this.distance_mapped(new Point(p.x - EPS, p.y, p.z));
        const y = this.distance_mapped(new Point(p.x, p.y + EPS, p.z)) - this.distance_mapped(new Point(p.x, p.y - EPS, p.z));
        const z = this.distance_mapped(new Point(p.x, p.y, p.z + EPS)) - this.distance_mapped(new Point(p.x, p.y, p.z - EPS));
        var vec = new Vec3(x, y, z);
        vec.normalise();

        // Since all objects are spheres, we can use the usual normal calculation for spheres
        // var normal = p - this.position;
        // normal.normalise();
        return vec;

        // writeln("normal = ", normal, " vec = ", vec);
        // return vec;
    }

    record LinearScene {
        var D: domain(1);
        var objects: [D] Object;
    }

    proc LinearScene.init(objects: [?D] Object) {
        this.D = objects.domain;
        this.objects = objects;
    }

    record Hit {
        var did_hit: bool;
        var colour: Colour.RGB;
        var steps_taken: uint;
        var normal: Vec3;
        var alpha_acc: real(64);
    }

    proc ref Hit.hit_after_transparent(mat: Material) {
        // blend the colours
        this.colour = this.colour * this.alpha_acc + mat.col * (1.0 - this.alpha_acc);
        this.alpha_acc += mat.alpha;
        if this.alpha_acc >= 1.0 {
            this.alpha_acc = 1.0;
        }
    }

    param MAX_STEPS: uint = 400;
    param MAX_DIST: real(64) = 300.0;
    param EPS: real(64) = 0.002;

    proc LinearScene.ray_march(in ray: Ray, depth: uint) : Hit {

        const no_hit = new Hit(
            did_hit = false,
            colour = Colour.LIGHT_BLUE,
            normal = new Vec3(0.0, 0.0, 0.0)
        );

        if depth == 0 {
            return new Hit(
                did_hit = false,
                colour = Colour.BLACK,
                normal = new Vec3(0.0, 0.0, 0.0)
            );
        } 

        // var end_ray = ray;
        for i in 0..MAX_STEPS {
            var min_hit = this.objects[0];
            var min_dist = MAX_DIST;
            for object in this.objects {

                // map the the point to the object's space (scale, rotation, translation)
                // FIXME: issue with coordinate system
                var p = object.map_point(ray.origin);
                const obj_dist = object.distance(p);
                // Retransform back into the space of the camera
                // Create a new ray transformed into the space of the object
                var ray_obj = ray;
                ray_obj.advance(obj_dist);

                // Transform the ray back into the space of the camera

                // Compute the distance between those two rays
                var delta = ray.origin - ray_obj.origin;
                // var scale = M4x4_rotation(object.rotation);
                var scale = M4x4_scale(object.scale);
                delta = delta * scale;
                const dist = delta.length();
                // const dist = obj_dist * min(object.scale.x, min(object.scale.y, object.scale.z));

                if dist < min_dist {
                    min_hit = object;
                    min_dist = dist;
                }
            }
            if min_dist > MAX_DIST {
                return no_hit;
            }
            if min_dist < EPS {
                ray.advance(min_dist);
                var normal = min_hit.normal(ray.origin);

                // // matte material
                // var bounce_dir = randomVec3InHemisphere(normal);
                // // var bounce_dir = normal + randomVec3Unit();
                // var bounce_origin = ray.origin;
                // var bounce_ray = new Ray(origin = bounce_origin, direction = bounce_dir);
                // bounce_ray.advance(0.005);
                // var bounce_hit = this.ray_march(bounce_ray, depth - 1);
                // return new Hit(
                //     did_hit = true,
                //     colour = new RGB(
                //         r = bounce_hit.colour.r * 0.5,
                //         g = bounce_hit.colour.g * 0.5,
                //         b = bounce_hit.colour.b * 0.5
                //     ),
                //     normal = normal
                // );

                return new Hit(
                    did_hit = true,
                    colour = min_hit.colour,
                    normal = normal
                );

                // var results: [1..3] Hit;
                // const bounce_samples = vecs_in_hemisphere_uniform(normal, 3);
                // for i in 1..3 {
                //     var bounce_ray = new Ray(origin = ray.origin, direction = bounce_samples[i]);
                //     bounce_ray.advance(0.005);
                //     results[i] = this.ray_march(bounce_ray, depth - 1);
                // }
                // var colour = new RGB(0.0, 0.0, 0.0);
                // for i in 1..3 {
                //     colour += results[i].colour;
                // }
                // colour /= 3.0;
                // return new Hit(
                //     did_hit = true,
                //     colour = colour,
                //     normal = normal
                // );
            }

            ray.advance(min_dist);
        }

        return no_hit;
    }

    proc LinearScene.render(camera: Camera.Camera, width: uint, height: uint) : Render {
        var colour = new Image(width, height);
        var normal = new Image(width, height);
        var times: [0..width, 0..height] real(64);
        var max_time_taken = 0.0;
        for x in 0..<width {
            for y in 0..<height {
                var chrono: stopwatch;
                chrono.start();
                const samples = camera.one_ray(y, x, width, height); // I don't know why I have to swap x and y
                const nb_samples = samples.domain.size: real(64);
                for ray in samples {
                    var hit = this.ray_march(ray, 5);
                    colour.pixels[x, y] += hit.colour / nb_samples;
                    normal.pixels[x, y] += new RGB(
                        r = (1.0 + hit.normal.x) / 2.0,
                        g = (1.0 + hit.normal.y) / 2.0,
                        b = (1.0 + hit.normal.z) / 2.0
                    ) / nb_samples;
                }
                var time_taken = chrono.elapsed();
                if time_taken > max_time_taken {
                    max_time_taken = time_taken;
                }
                times[x, y] += time_taken;
                // var ray = camera.ray(x, y, width, height);
                // var hit = this.ray_march(ray, 10);
                // colour.pixels[x, y] = hit.colour;
                // normal.pixels[x, y] = new RGB(r = hit.normal.x, g = hit.normal.y, b = hit.normal.z);
                // // writeln("y = ", y);
                // // writeln("hit = ", hit);
            }
            writeln("x = ", x);
        }

        writeln("Max time taken: ", max_time_taken * 1000, " ms");

        // normalise the time taken
        for x in 0..<width {
            for y in 0..<height {
                times[x, y] /= max_time_taken;
                if times[x, y] > 1.0 {
                    times[x, y] = 1.0;
                }
            }
        }

        var time_image = new Image(width, height);
        for x in 0..<width {
            for y in 0..<height {
                time_image.pixels[x, y] = new RGB(
                    r = times[x, y],
                    g = 0.0,
                    b = 0.0
                );
                if times[x, y] > 0.9 {
                    time_image.pixels[x, y].g = 1.0;
                }
            }
        }

        return new Render(
            colour = colour,
            normal = normal,
            time_taken = time_image
        );
    }
}