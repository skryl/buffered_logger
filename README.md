## About

*buffered_logger* is based on ActiveSupport::BufferedLogger and adds some much
needed enhancements.

## Features

- per thread indentation
- per thread auto flush setting
- temporary indentation blocks
- per severity formatting
- ansi color output formatting


## Usage

default initialization 

    l = BufferedLogger.new(STDOUT)

changing the severity level

    l.level = :warn
    l.level = 1

formatter constructor (initializes the master thread's formatters)

    l = BufferedLogger.new(STDOUT, :debug,  
                           { :info  => "$green INFO: $white %s",
                             :warn  => "$yellow WARNING: $white %s",
                             :error => "$red ERROR: $white %s" } )

setting formatting after initialization

    l.info_formatter  = "$green INFO: $white %s",    
    l.warn_formatter  = "$yellow WARNING: $white %s"
    l.error_formatter = "$red ERROR: $white %s"

checking the current thread's formatting

    l.info_formatter.to_s
    l.warn_formatter.to_s
    ...

checking the current thread's indentation

    l.padding.to_s

setting the current thread's indentation

    l.indent(4)                  # move cursor right 4 spaces
    l.indent(-2)                 # move cursor left 2 spaces
    l.indent(:reset)             # reset indentation

temporarily indenting using an indent block

    l.indent do
      l.info 'some info'
      ...
      l.info 'some more info'
    end

setting auto_flushing

    l.auto_flushing = 2


## Usage Details

Severity Levels

* severity level is optional and defaults to :debug
* severity level can be provided as an Integer or Symbol

      0 - DEBUG
      1 - INFO
      2 - WARN
      3 - ERROR
      4 - FATAL
      5 - UNKNOWN

ActiveSupport::BufferedLogger

* native buffered_logger functionality is preserved

ANSI Color

* colors are only supported when logging to STDOUT
* any ansi method may be used in a format string following a '$' symbol

    ["black", "on_yellow", "underscore", "rapid_blink", "white", "bold",
     "yellow", "on_cyan", "strikethrough", "on_green", "uncolored", "blink",
     "cyan", "reset", "green", "on_magenta", "clear", "concealed", "on_red",
     "dark", "underline", "magenta", "red", "on_blue", "negative", "on_black",
     "italic", "blue", "on_white"]

Indentation

* the padding is calculated on a per thread basis and each thread has an
  indentation counter which is shared across all severity levels

Formatting

* formatters are set on a per thread/per severity basis, meaning that every
  severity level for every thread allows for a custom formatter
* the formatter search order is as follows
  1. current thread's formatter for specified severity
  2. master thread's formatter for specified severity
  3. master thread's default formatter
    
Thread Buffering

* the auto_flushing setting is set per thread and each thread defaults to
  the autoflush setting of the master thread unless explicitly configured
