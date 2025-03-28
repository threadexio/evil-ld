#[macro_use]
extern crate log;

use std::env::args_os;
use std::io::{IsTerminal, stderr};

use log::Level;
use owo_colors::{OwoColorize, style};

fn main() {
    setup();

    info!("Hello, world!");

    let argv = args_os().collect::<Vec<_>>();
    trace!("linker argv: {argv:?}");
}

fn setup() {
    let out = stderr();

    owo_colors::set_override(out.is_terminal());

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

            out.finish(format_args!(
                "[{} {}] {}",
                env!("CARGO_BIN_NAME").dimmed(),
                level,
                message
            ))
        })
        .level(log::LevelFilter::Trace)
        .chain(out)
        .apply()
        .unwrap();
}
