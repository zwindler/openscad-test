\$fn = 80;
body_radius = 12;
nose_height = 35;
rho = (body_radius * body_radius + nose_height * nose_height) / (2 * body_radius);
rotate_extrude()
    polygon(points=concat(
        [[0, 0]],
        [ for (i = [0 : 50])
            let(
                t = i / 50,
                y = t * nose_height,
                r = sqrt(rho*rho - (nose_height - y) * (nose_height - y)) - (rho - body_radius)
            )
            [max(r, 0), y]
        ],
        [[0, nose_height]]
    ));
