#[macro_use]
extern crate log;

use std::env::args_os;
use std::ffi::{CString, OsStr, OsString};
use std::io::{IsTerminal, stderr};
use std::os::unix::ffi::OsStrExt;
use std::path::{Path, PathBuf};

use clap::{ArgAction, Parser};
use log::{Level, LevelFilter};
use nix::sys::personality::{self, Persona};
use nix::unistd::{Uid, execv, setresuid};
use owo_colors::{OwoColorize, style};

mod consts;

use self::consts::*;

#[derive(Debug, Clone, Copy, PartialEq, Eq, clap::ValueEnum)]
enum Boolean {
    Yes,
    No,
}

impl From<Boolean> for bool {
    fn from(value: Boolean) -> Self {
        value == Boolean::Yes
    }
}

#[derive(Debug, Parser)]
struct Args {
    #[arg(
        short = 'v',
        help = "Be more verbose. Up to -vvv.",
        action = ArgAction::Count,
    )]
    verbose: u8,

    #[arg(
        long = "loader",
        help = "Run using this loader afterwards.",
        default_value = DEFAULT_LOADER
    )]
    real_loader: PathBuf,

    #[arg(
        long = "setuid",
        help = "Elevate privileges using the setuid bit.",
        default_value = "yes",
        value_name = "boolean",
        num_args = 0..=1,
        require_equals = true,
        default_missing_value = "yes",
    )]
    setuid: Boolean,

    #[arg(
        long = "no-aslr",
        help = "Disable Address Space Layout Randomization.",
        default_value = "yes",
        value_name = "boolean",
        num_args = 0..=1,
        require_equals = true,
        default_missing_value = "yes",
    )]
    no_aslr: Boolean,

    #[arg(trailing_var_arg = true)]
    target_args: Vec<OsString>,
}

impl Args {
    fn parse() -> Self {
        let mut args: Vec<_> = args_os().collect();
        debug!("argv: {args:?}");

        let arg0 = Path::new(&args[0]);
        // SAFETY: This is `arg0`. A file name *always* exists.
        let arg0_bin_name = arg0.file_name().unwrap();

        if arg0_bin_name != NAME {
            args.insert(0, NAME.into());
        }

        <Self as Parser>::parse_from(args)
    }
}

fn main() {
    let args = Args::parse();
    setup(&args);

    debug!("args = {args:#?}");

    if args.setuid.into() {
        trace!("elevating privileges with setuid");

        let target_uid = Uid::effective();
        setresuid(target_uid, target_uid, target_uid).unwrap();
    }

    if args.no_aslr.into() {
        trace!("disabling aslr");

        personality::set(Persona::ADDR_NO_RANDOMIZE).unwrap();
    }

    let exe = to_cstring(args.real_loader.as_os_str());
    let mut argv = Vec::with_capacity(args.target_args.len() + 1);

    argv.push(exe.clone());
    argv.extend(args.target_args.iter().map(|x| to_cstring(x)));
    debug!("target_argv = {argv:?}");

    execv(&exe, &argv).unwrap();
}

fn setup(args: &Args) {
    let out = stderr();

    owo_colors::set_override(out.is_terminal());

    let level_filter = match args.verbose {
        0 => LevelFilter::Warn,
        1 => LevelFilter::Info,
        2 => LevelFilter::Debug,
        _ => LevelFilter::Trace,
    };

    fern::Dispatch::new()
        .format(|out, message, record| {
            let level_symbol = match record.level() {
                Level::Trace => "!",
                Level::Debug => "*",
                Level::Info => "+",
                Level::Warn => "=",
                Level::Error => "x",
            };

            let level_style = match record.level() {
                Level::Trace => style().bold(),
                Level::Debug => style().dimmed(),
                Level::Info => style().bright_green().bold(),
                Level::Warn => style().bright_yellow().bold(),
                Level::Error => style().bright_red().bold(),
            };

            let level = level_symbol.style(level_style);

            out.finish(format_args!("[{} {}] {}", NAME.dimmed(), level, message))
        })
        .level(level_filter)
        .chain(out)
        .apply()
        .unwrap();
}

fn to_cstring(x: &OsStr) -> CString {
    let mut r = x.as_bytes().to_vec();
    r.push(0);

    // SAFETY: We only added one null byte.
    CString::from_vec_with_nul(r).unwrap()
}
