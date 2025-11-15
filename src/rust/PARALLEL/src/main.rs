mod points;
mod skyline;

use std::thread;

fn main() {
    let pts = points::Points::read_from_input();
    
    // Use number of available CPUs
    let num_threads = thread::available_parallelism()
        .map(|n| n.get())
        .unwrap_or(1);
    
    skyline::parallel_skyline(pts, num_threads);
}
