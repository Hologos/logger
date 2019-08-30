#! /usr/bin/env bash

. "vendor/lehmannro/assert.sh/assert.sh"
. "./logger"

# -- logger::init() - should succeed tests ------------------------------------

assert_raises "logger::init 'A'" 0
assert_raises "logger::init 'T'" 0
assert_raises "logger::init 'D'" 0
assert_raises "logger::init 'I'" 0
assert_raises "logger::init 'N'" 0
assert_raises "logger::init 'W'" 0
assert_raises "logger::init 'E'" 0
assert_raises "logger::init 'C'" 0

assert_raises "logger::init 'N' '/tmp/debug.log'" 0

assert_raises "logger::init 'DEBUG_LOG' 'D' '/tmp/debug.log'" 0

assert_end "logger::init() - should succeed"

# -- logger::init() - should fail tests ---------------------------------------

assert_raises "logger::init" 1

assert_raises "logger::init 'X'" 1

assert_raises "logger::init 'N' '/usr'" 1
assert_raises "logger::init 'N' '/etc/passwd'" 1
assert_raises "logger::init 'N' '/usr/logger/debug.log'" 1
assert_raises "logger::init 'N' '/usr/debug.log'" 1

assert_raises "logger::init 'MAIN_LOG' 'I' '/tmp/debug.log' ''" 1

assert_end "logger::init() - should fail"

# -- logger::log() - should succeed tests -------------------------------------

assert "logger::log 'D' 'This is a debug message.' 2>&1" "[$(date +'%d.%m.%Y %H:%M:%S')] D: This is a debug message."
assert "{ logger::init 'N' && logger::log 'D' 'This is a debug message.'; } 2>&1" ""
assert "{ logger::init 'A' && logger::log 'D' 'This is a debug message.'; } 2>&1" "[$(date +'%d.%m.%Y %H:%M:%S')] D: This is a debug message."
assert "{ rm -f '/tmp/debug.log'; logger::init 'A' '/tmp/debug.log' && logger::log 'D' 'This is a debug message.' && cat '/tmp/debug.log'; } 2>&1" "[$(date +'%d.%m.%Y %H:%M:%S')] D: This is a debug message."

assert 'params=("1" "2" "3"); logger::log "D" "Input parameters: ${params[*]}" 2>&1' "[$(date +'%d.%m.%Y %H:%M:%S')] D: Input parameters: 1 2 3"

assert "{ rm -f '/tmp/debug.log'; logger::init 'DEBUG' 'D' '/tmp/debug.log' && logger::log 'DEBUG' 'D' 'This is a debug message.' && cat '/tmp/debug.log'; } 2>&1" "[$(date +'%d.%m.%Y %H:%M:%S')] D: This is a debug message."

assert "{ \
            rm -f '/tmp/debug.log'; \
            logger::init 'DEBUG' 'D' '/tmp/debug.log' && \
            logger::log 'DEBUG' 'D' 'This is a debug message.' && \
            cat '/tmp/debug.log'; \
        } 2>&1" "[$(date +'%d.%m.%Y %H:%M:%S')] D: This is a debug message."

assert "{ \
            rm -f '/tmp/debug.log'; \
            rm -f '/tmp/debug-different.log'; \
            rm -f '/tmp/program.log'; \
            logger::init 'DEBUG' 'D' '/tmp/debug.log' && \
            logger::init 'I' '/tmp/program.log' && \
            logger::log 'DEBUG' 'D' 'This is a debug message.' && \
            logger::log 'C' 'This is a critical message.' && \
            logger::init 'DEBUG' 'D' '/tmp/debug-different.log' && \
            logger::log 'DEBUG' 'D' 'This is yet another debug message.' && \
            echo '-- debug.log --'; \
            cat '/tmp/debug.log'; \
            echo '-- debug-different.log --'; \
            cat '/tmp/debug-different.log'; \
            echo '-- program.log --'; \
            cat '/tmp/program.log'; \
            echo '----';
        } 2>&1" "-- debug.log --\n[$(date +'%d.%m.%Y %H:%M:%S')] D: This is a debug message.\n-- debug-different.log --\n[$(date +'%d.%m.%Y %H:%M:%S')] D: This is yet another debug message.\n-- program.log --\n[$(date +'%d.%m.%Y %H:%M:%S')] C: This is a critical message.\n----"

assert_end "logger::log() - should succeed"

# -- logger::log() - should fail tests ----------------------------------------

assert_raises "logger::init 'D'; logger::log 'X' 'This is a message.'" 1
assert_raises "logger::init 'D'; logger::log 'A' 'This is a message.'" 1
assert_raises 'params=("1" "2" "3"); logger::log "D" "Input parameters: ${params[@]}"' 1

assert "{ rm -rf '/tmp/trace.log' && logger::init 'T' '/tmp/trace.log' && rm -f '/tmp/trace.log' && mkdir '/tmp/trace.log' && LANG=en logger::log 'D' 'This is a debug message.'; } 2>&1" "./logger: line 48: /tmp/trace.log: Is a directory\n[$(date +'%d.%m.%Y %H:%M:%S')] C: Cannot write to log file '/tmp/trace.log' anymore.\n[$(date +'%d.%m.%Y %H:%M:%S')] D: This is a debug message."

assert_raises "logger::log 'DEBUG' 'D' 'This is a debug message.'" 1

assert_end "logger::log() - should fail"

# -- logger::level_is_lower() - should succeed tests --------------------------

assert_raises "logger::level_is_lower 'D' 'C'" 0

assert_end "logger::level_is_lower() - should succeed"

# -- logger::level_is_lower() - should fail tests -----------------------------

assert_raises "logger::level_is_lower 'X' 'D'" 1
assert_raises "logger::level_is_lower 'D' 'X'" 1

assert_raises "logger::level_is_lower 'C' 'C'" 1
assert_raises "logger::level_is_lower 'C' 'D'" 1

assert_end "logger::level_is_lower() - should fail"

# -- logger::level_is_equal() - should succeed tests --------------------------

assert_raises "logger::level_is_equal 'D' 'D'" 0

assert_end "logger::level_is_equal() - should succeed"

# -- logger::level_is_equal() - should fail tests -----------------------------

assert_raises "logger::level_is_equal 'X' 'D'" 1
assert_raises "logger::level_is_equal 'D' 'X'" 1

assert_raises "logger::level_is_equal 'D' 'A'" 1
assert_raises "logger::level_is_equal 'D' 'C'" 1

assert_end "logger::level_is_equal() - should fail"

# -- logger::level_is_greater() - should succeed tests ------------------------

assert_raises "logger::level_is_greater 'C' 'D'" 0

assert_end "logger::level_is_greater() - should succeed"

# -- logger::level_is_greater() - should fail tests ---------------------------

assert_raises "logger::level_is_greater 'X' 'C'" 1
assert_raises "logger::level_is_greater 'C' 'X'" 1

assert_raises "logger::level_is_greater 'C' 'C'" 1
assert_raises "logger::level_is_greater 'D' 'C'" 1

assert_end "logger::level_is_greater() - should fail"

# -- logger::get_level() - should succeed tests -------------------------------

assert "{ logger::init 'N'; logger::get_level; } 2>&1" 'N'
assert "{ logger::init 'N' '/tmp/debug.log'; logger::get_level; } 2>&1" 'N'
assert "logger::get_level 2>&1" 'A'
assert "{ logger::init 'N'; logger::init 'C'; logger::get_level; } 2>&1" 'C'
assert "{ logger::init 'N'; logger::get_level; logger::init 'C'; logger::get_level; } 2>&1" 'NC'
assert "{ logger::init 'D' '/tmp/debug.log'; logger::init 'MAIN' 'I' '/tmp/program.log'; logger::get_level; logger::get_level 'MAIN'; } 2>&1" 'DI'

assert_end "logger::get_level() - should succeed"

# -- logger::get_level() - should fail tests ----------------------------------

assert_raises "logger::get_level 'NOT_WORKING'" 1

assert_end "logger::get_level() - should fail"

# -- logger::get_filepath() - should succeed tests ----------------------------

assert "{ logger::init 'D' '/tmp/debug.log'; logger::get_filepath; } 2>&1" "/tmp/debug.log"
assert "{ logger::init 'DEBUG' 'D' '/tmp/debug.log'; logger::get_filepath 'DEBUG'; } 2>&1" "/tmp/debug.log"
assert "{ logger::init 'MAIN' 'I' '/tmp/program.log'; logger::init 'DEBUG' 'D' '/tmp/debug.log'; logger::get_filepath 'DEBUG'; logger::get_filepath 'MAIN'; } 2>&1" "/tmp/debug.log/tmp/program.log"
assert "{ logger::init 'MAIN' 'I' '/tmp/program.log'; logger::get_filepath 'MAIN'; logger::init 'MAIN' 'I' '/tmp/main.log'; logger::get_filepath 'MAIN'; } 2>&1" "/tmp/program.log/tmp/main.log"

assert_end "logger::get_filepath() - should succeed"

# -- logger::get_filepath() - should fail tests -------------------------------

assert_raises "logger::get_filepath" 1
assert_raises "logger::get_filepath 'DEBUG'" 1
assert_raises "logger::init 'N'; logger::get_filepath" 1
assert_raises "logger::init 'D'; logger::get_filepath 'DEBUG'" 1
assert_raises "logger::init 'D' '/tmp/debug.log'; logger::get_filepath; logger::init 'D'; logger::get_filepath" 1

assert_end "logger::get_filepath() - should fail"
