module Object {
    use Vector;
    use Colour;
    use Transformation;
    use Ray;
    use Rendering;

    enum Shape {
        Sphere,
        Cube,
    }

    record Object {
        var shape: Shape;
        var position: Point;
        var scale: Vec3;
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
        // map the the point to the object's space (scale, rotation, translation)
        var translate = M4x4_translation(this.position);
        var scale = M4x4_scale(this.scale);
        var rotate = M4x4_rotation(this.rotation);
        var transform = translate * scale * rotate;
        transform = transform.inverse();
        var p = pos * transform;
        select shape {
            when Shape.Sphere {
                return Sphere_distance(p);
            }
            when Shape.Cube {
                return Cube_distance(p);
            }
        }
        // Unreachable
        return +inf;
    }

    proc Object.normal(p: Point) : Vec3 {
        const EPS: real = 0.001;
        const x = this.distance(new Point(p.x + EPS, p.y, p.z)) - this.distance(new Point(p.x - EPS, p.y, p.z));
        const y = this.distance(new Point(p.x, p.y + EPS, p.z)) - this.distance(new Point(p.x, p.y - EPS, p.z));
        const z = this.distance(new Point(p.x, p.y, p.z + EPS)) - this.distance(new Point(p.x, p.y, p.z - EPS));
        var vec = new Vec3(x, y, z);
        vec.normalise();
        return vec;
    }

    record Scene {
        var D: domain(1);
        var objects: [D] Object;
    }

    proc Scene.init(objects: [?D] Object) {
        this.D = objects.domain;
        this.objects = objects;
    }

    proc Scene.ray_march(in ray: Ray, ref render: Render, x: uint, y: uint) {
        param MAX_STEPS: uint = 100;
        param MAX_DIST: real = 100.0;
        param EPS: real = 0.001;

        for i in 0..MAX_STEPS {
            var min_hit = this.objects[0];
            var min_dist = 999.9;
            for object in this.objects {
                const dist = object.distance(ray.origin);
                if dist < min_dist {
                    min_hit = object;
                    min_dist = dist;
                }
            }
            if min_dist > MAX_DIST {
                render.colour.pixels[x, y] = Colour.LIGHT_BLUE;
                return;
            }
            if min_dist < EPS {
                var normals = min_hit.normal(ray.origin);
                normals = (normals + 1.0) / 2;
                const rgb_normals = new RGB(r = normals.x, g = normals.y, b = normals.z);
                render.colour.pixels[x, y] = min_hit.colour;
                render.normal.pixels[x, y] = rgb_normals;
                return;
            }

            ray.advance(min_dist);
        }

        render.colour.pixels[x, y] = Colour.LIGHT_BLUE;
    }
}