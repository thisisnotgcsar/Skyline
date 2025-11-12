mod points;
mod skyline;

fn main() {
    let pts = points::Points::read_from_input();
    skyline::skyline(&pts);
    // skyline::print_skyline(&pts, &skyline);
}
