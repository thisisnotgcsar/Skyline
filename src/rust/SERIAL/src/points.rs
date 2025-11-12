/// Points constituting the Skyline
pub struct Points {
    pub p: Vec<Vec<f32>>, // points of D dimensions
    pub n: usize,           // number of points
    pub d: usize,           // dimensionality
}

impl Points {
    /// Construct the buildings by reading the criticl points from stdin
    /// 
    /// Read input from stdin. Input format is:
    ///
    /// d [other ignored stuff]
    /// N
    /// p0,0 p0,1 ... p0,d-1
    /// p1,0 p1,1 ... p1,d-1
    /// ...
    /// pn-1,0 pn-1,1 ... pn-1,d-1
    pub fn read_from_input() -> Self {
        use std::io::{self, BufRead};
        use std::process;

        let stdin = io::stdin();
        let mut lines = stdin.lock().lines();

        // Read dimension (D)
        let d: usize = match lines.next().and_then(|line| line.ok()) {
            Some(line) => line
                .split_whitespace()
                .next()
                .and_then(|token| token.parse().ok())
                .unwrap_or_else(|| {
                    eprintln!("FATAL: cannot read the dimension");
                    std::process::exit(1);
                }),
            None => {
                eprintln!("FATAL: cannot read the dimension");
                std::process::exit(1);
            }
        };
        assert!(d >= 2, "FATAL: dimension must be at least 2");

        // Read number of points (N)
        let n: usize = match lines.next().and_then(|line| line.ok()) {
            Some(line) => line.trim().parse().unwrap_or_else(|_| {
                eprintln!("FATAL: cannot read the number of points");
                process::exit(1);
            }),
            None => {
                eprintln!("FATAL: cannot read the number of points");
                process::exit(1);
            }
        };

        // Read points
        let mut p = Vec::with_capacity(n);
        for i in 0..n {
            let line = match lines.next().and_then(|line| line.ok()) {
                Some(line) => line,
                None => {
                    eprintln!("FATAL: failed to read point {}", i);
                    process::exit(1);
                }
            };
            let coords: Vec<f32> = line
                .split_whitespace()
                .map(|coord| coord.parse().unwrap_or_else(|_| {
                    eprintln!("FATAL: failed to parse coordinate of point {}", i);
                    process::exit(1);
                }))
                .collect();
            if coords.len() != d {
                eprintln!(
                    "FATAL: expected {} coordinates for point {}, got {}",
                    d, i, coords.len()
                );
                process::exit(1);
            }
            p.push(coords);
        }

        Points {p,n,d}
    }
}