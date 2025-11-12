mod points;
mod skyline;

fn main() {
    let pts = points::Points::read_from_input();
    let skyline = skyline::skyline(&pts);
    skyline::print_skyline(&pts, &skyline);
}
