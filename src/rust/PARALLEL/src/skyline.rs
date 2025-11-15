use crate::points::Points;
use std::sync::Arc;
use std::thread;

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

/// Print the coordinates of points belonging to the skyline.
/// Output format: first line is dimension, second line is number of skyline points, then the points.
pub fn print_skyline(points: &Points, skyline: &(Vec<bool>, usize)) {
    println!("{}", points.d);
    println!("{}", skyline.1);
    for (point, &is_skyline) in points.p.iter().zip(skyline.0.iter()) {
        if is_skyline {
            for coord in point {
                // Round to nearest 6th decimal digit, print as float with 6 decimal digits
                print!("{:.6} ", coord);
            }
            println!();
        }
    }
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

/// Compute the local skyline for a range of points [start..end).
/// Returns a Vec of point indices (relative to the original Points) that belong to the local skyline.
pub fn local_skyline(points: Arc<Points>, start: usize, end: usize) -> Vec<usize> {
    let mut local_sky = Vec::new();
    
    for i in start..end {
        let mut dominated = false;
        
        // Check if point i is dominated by any point in the local range
        for j in start..end {
            if i != j && dominates(&points.p[j], &points.p[i]) {
                dominated = true;
                break;
            }
        }
        
        if !dominated {
            local_sky.push(i);
        }
    }
    
    local_sky
}

// Parallel skyline using native threads, sharing Points via Arc (no deep copy)
pub fn parallel_skyline(points: Points, num_threads: usize) -> (Vec<bool>, usize) {
    if points.n == 0 {
        return (Vec::new(), 0);
    }

    let num_threads = num_threads.max(1);
    let chunk_size = (points.n + num_threads - 1) / num_threads;

    // Wrap points in Arc to share immutable access across threads (no copy)
    let arc_points = Arc::new(points);
    let mut handles = vec![];

    // Spawn threads to compute local skylines
    for i in 0..num_threads {
        let points_clone = Arc::clone(&arc_points);
        let start = i * chunk_size;
        let end = ((i + 1) * chunk_size).min(points_clone.n);

        if start >= points_clone.n {
            break;
        }

        let handle = thread::spawn(move || {
            local_skyline(points_clone, start, end)
        });

        handles.push(handle);
    }

    // Collect all local skyline point indices
    let mut merged_indices = Vec::new();
    for handle in handles {
        if let Ok(local_sky) = handle.join() {
            merged_indices.extend(local_sky);
        }
    }

    // After threads finish, main thread can still access points_arc (Arc keeps data alive)
    // Create Points struct with only the merged skyline points
    let merged_points = Points {
        p: merged_indices.iter().map(|&idx| arc_points.p[idx].clone()).collect(),
        n: merged_indices.len(),
        d: arc_points.d,
    };

    // Compute final skyline on merged points
    let (final_sky, final_r) = skyline(&merged_points);

    // Map back to original indices
    let mut result = vec![false; arc_points.n];
    for (i, &s) in final_sky.iter().enumerate() {
        if s {
            result[merged_indices[i]] = true;
        }
    }
    let r = result.clone();
    print_skyline(&arc_points, &(result, final_r));
    (r, final_r)
}