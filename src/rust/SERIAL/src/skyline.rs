use crate::points::Points;

pub fn dominates(p: &[f32], q: &[f32]) -> bool {
    let mut dominated: bool = false;
    for k in 0..p.len() {
        if p[k] < q[k] {
            return false;
        }
        if p[k] > q[k] {
            dominated = true;
        }
    }
    dominated
}

/// Compute the skyline of `points`.
/// Returns a Vec<bool> where s[i] == true iff point i belongs to the skyline.
/// The algorithm is O(N^2 * D) where N is the number of points and D is the dimension.
pub fn skyline(points: &Points) -> (Vec<bool>, usize) {
    let mut s = vec![true; points.n];
    let mut r = points.n;

    for i in 0..points.n {
        if s[i] {
            for j in 0..points.n {
                if s[j] && dominates(&points.p[i], &points.p[j]) {
                    s[j] = false;
                    r -= 1;
                }
            }
        }
    }
    (s, r)
}

/// Print the coordinates of points belonging to the skyline.
/// Output format: first line is dimension, second line is number of skyline points, then the points.
pub fn print_skyline(points: &Points, skyline: &(Vec<bool>, usize)) {
    println!("{}", points.d);
    println!("{}", skyline.1);
    for (point, &is_skyline) in points.p.iter().zip(skyline.0.iter()) {
        if is_skyline {
            for coord in point {
                print!("{} ", coord);
            }
            println!();
        }
    }
}