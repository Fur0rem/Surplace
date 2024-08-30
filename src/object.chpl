module Object {
    use Vector;
    use Colour;
    use Transformation;
    use Ray;
    use Rendering;
    import Camera;
    use Time;

    enum Shape {
        Sphere,
        Cube,
    }

    record Object {
        var shape: Shape;
        var position: Point;
        var scale: Vec3;
        // var scale: real;
        var rotation: Vec3;
        var colour: Colour.RGB;
    }

    // Diameter of sphere is 1
    proc Sphere_distance(p: Point) : real {
        return p.length() - 0.5;
    }

    // Cube of side length 1 and centered at (0, 0, 0)
    proc Cube_distance(p: Point) : real {
        var q = p.abs() - 0.5;
        return max(max(q.x, q.y), q.z);
    }

    proc Object.distance(pos: Point) : real {
        select shape {
            when Shape.Sphere {
                return Sphere_distance(pos);
            }
            when Shape.Cube {
                return Cube_distance(pos);
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
        return p * inv_transform;
    }

    proc Object.distance_mapped(pos: Point) : real {
        var p = this.map_point(pos);
        var dist = this.distance(p);
        // return dist * (this.scale.x + this.scale.y + this.scale.z) / 3.0; // this is probably wrong lol, i hate scaling that's not uniform
        return dist * min(this.scale.x, min(this.scale.y, this.scale.z));
    }

    proc Object.normal(p: Point) : Vec3 {
        // Usual normal calculation
        const EPS: real = 0.002;
        
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

    record Scene {
        var D: domain(1);
        var objects: [D] Object;
    }

    proc Scene.init(objects: [?D] Object) {
        this.D = objects.domain;
        this.objects = objects;
    }

    record Hit {
        var did_hit: bool;
        var colour: Colour.RGB;
        var normal: Vec3;
    }

    proc Scene.ray_march(in ray: Ray, depth: uint) : Hit {
        param MAX_STEPS: uint = 500;
        param MAX_DIST: real = 300.0;
        param EPS: real = 0.002;

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
                // var ray_obj = ray;
                // ray_obj.advance(obj_dist);

                // // Transform the ray back into the space of the camera

                // // Compute the distance between those two rays
                // var delta = ray.origin - ray_obj.origin;
                // // var scale = M4x4_rotation(object.rotation);
                // var scale = M4x4_scale(object.scale);
                // delta = delta * scale;
                // const dist = delta.length();
                const dist = obj_dist * min(object.scale.x, min(object.scale.y, object.scale.z));

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

                // matte material
                var bounce_dir = randomVec3InHemisphere(normal);
                var bounce_origin = ray.origin;
                var bounce_ray = new Ray(origin = bounce_origin, direction = bounce_dir);
                bounce_ray.advance(0.01);
                var bounce_hit = this.ray_march(bounce_ray, depth - 1);
                return new Hit(
                    did_hit = true,
                    colour = new RGB(
                        r = bounce_hit.colour.r * 0.5,
                        g = bounce_hit.colour.g * 0.5,
                        b = bounce_hit.colour.b * 0.5
                    ),
                    normal = normal
                );

                return new Hit(
                    did_hit = true,
                    colour = min_hit.colour,
                    normal = normal
                );
            }

            ray.advance(min_dist);
        }

        var unit_dir = ray.direction;
        unit_dir.normalise();
        var a = (unit_dir.y + 1.0) / 2.0;
        var colour = (1.0 - a) * Colour.WHITE + a * (new RGB(r = 0.5, g = 0.7, b = 1.0));
        return new Hit(
            did_hit = false,
            colour = colour,
            normal = new Vec3(0.0, 0.0, 0.0)
        );
    }

    proc Scene.render(camera: Camera.Camera, width: uint, height: uint) : Render {
        var colour = new Image(width, height);
        var normal = new Image(width, height);
        var max_time_taken = 0.0;
        const samples = 10;
        for x in 0..<width {
            for y in 0..<height {
                for s in 1..samples {
                    var chrono: stopwatch;
                    chrono.start();
                    var ray = camera.slightly_random_ray(y, x, width, height); // idk why i have to swap x and y
                    var hit = this.ray_march(ray, 60);
                    colour.pixels[x, y] += hit.colour / (samples: real);
                    normal.pixels[x, y] += new RGB(
                        r = (1.0 + hit.normal.x) / 2.0,
                        g = (1.0 + hit.normal.y) / 2.0,
                        b = (1.0 + hit.normal.z) / 2.0
                    ) / (samples: real);
                    var time_taken = chrono.elapsed();
                    if time_taken > max_time_taken {
                        max_time_taken = time_taken;
                    }
                }
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

        return new Render(
            colour = colour,
            normal = normal
        );
    }
}