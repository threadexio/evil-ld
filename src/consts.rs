macro_rules! env_or_default {
    ($var:literal, $default:expr) => {
        const {
            match ::core::option_env!($var) {
                Some(x) => x,
                None => $default,
            }
        }
    };
}

pub const NAME: &str = env!("CARGO_BIN_NAME");

pub const DEFAULT_LOADER: &str = env_or_default!("DEFAULT_LOADER", "/lib/ld-linux.so.2");
