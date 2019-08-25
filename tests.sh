#! /usr/bin/env bash

. "./assert.sh"
. "./logger"

# -- logger::init - should succeed tests --------------------------------------

assert_raises "logger::init 'A'" 0
assert_raises "logger::init 'T'" 0
assert_raises "logger::init 'D'" 0
assert_raises "logger::init 'I'" 0
assert_raises "logger::init 'N'" 0
assert_raises "logger::init 'W'" 0
assert_raises "logger::init 'E'" 0
assert_raises "logger::init 'C'" 0

assert_raises "logger::init 'N' '/tmp/debug.log'" 0

assert_end "logger::init() - should succeed"

# -- logger::init - should fail tests -----------------------------------------

assert_raises "logger::init 'X'" 1

assert_raises "logger::init 'N' '/usr'" 1
assert_raises "logger::init 'N' '/etc/passwd'" 1
assert_raises "logger::init 'N' '/usr/logger/debug.log'" 1
assert_raises "logger::init 'N' '/usr/debug.log'" 1

assert_end "logger::init() - should fail"

# -- logger::log - should succeed tests ---------------------------------------
assert "logger::log 'D' 'This is a debug message.' 2>&1" "[$(date +'%d.%m.%Y %H:%M:%S')] D: This is a debug message."
assert "{ logger::init 'N' && logger::log 'D' 'This is a debug message.'; } 2>&1" ""
assert "{ logger::init 'A' && logger::log 'D' 'This is a debug message.'; } 2>&1" "[$(date +'%d.%m.%Y %H:%M:%S')] D: This is a debug message."
assert "{ rm -f '/tmp/debug.log'; logger::init 'A' '/tmp/debug.log' && logger::log 'D' 'This is a debug message.' && cat '/tmp/debug.log'; } 2>&1" "[$(date +'%d.%m.%Y %H:%M:%S')] D: This is a debug message."

assert_end "logger::log() - should succeed"

# -- logger::log - should fail tests ------------------------------------------

assert_raises "logger::init 'D'; logger::log 'X' 'This is a message.'" 1
assert_raises "logger::init 'D'; logger::log 'A' 'This is a message.'" 1

assert "{ rm -rf '/tmp/trace.log' && logger::init 'T' '/tmp/trace.log' && rm -f '/tmp/trace.log' && mkdir '/tmp/trace.log' && LANG=en logger::log 'D' 'This is a debug message.'; } 2>&1" "./logger: line 45: /tmp/trace.log: Is a directory\n[$(date +'%d.%m.%Y %H:%M:%S')] C: Cannot write to log file '/tmp/trace.log' anymore.\n[$(date +'%d.%m.%Y %H:%M:%S')] D: This is a debug message."

assert_end "logger::log() - should fail"

# -- logger::level_is_lower - should succeed tests --------------------------------------

assert_raises "logger::level_is_lower 'D' 'C'" 0

assert_end "logger::level_is_lower() - should succeed"

# -- logger::level_is_lower - should fail tests -----------------------------------------

assert_raises "logger::level_is_lower 'X' 'D'" 1
assert_raises "logger::level_is_lower 'D' 'X'" 1

assert_raises "logger::level_is_lower 'C' 'C'" 1
assert_raises "logger::level_is_lower 'C' 'D'" 1

assert_end "logger::level_is_lower() - should fail"

# -- logger::level_is_equal - should succeed tests --------------------------------------

assert_raises "logger::level_is_equal 'D' 'D'" 0

assert_end "logger::level_is_equal() - should succeed"

# -- logger::level_is_equal - should fail tests -----------------------------------------

assert_raises "logger::level_is_equal 'X' 'D'" 1
assert_raises "logger::level_is_equal 'D' 'X'" 1

assert_raises "logger::level_is_equal 'D' 'A'" 1
assert_raises "logger::level_is_equal 'D' 'C'" 1

assert_end "logger::level_is_equal() - should fail"

# -- logger::level_is_greater - should succeed tests --------------------------------------

assert_raises "logger::level_is_greater 'C' 'D'" 0

assert_end "logger::level_is_greater() - should succeed"

# -- logger::level_is_greater - should fail tests -----------------------------------------

assert_raises "logger::level_is_greater 'X' 'C'" 1
assert_raises "logger::level_is_greater 'C' 'X'" 1

assert_raises "logger::level_is_greater 'C' 'C'" 1
assert_raises "logger::level_is_greater 'D' 'C'" 1

assert_end "logger::level_is_greater() - should fail"

# -- logger::get_global_level() - should succeed tests --------------------------------------

assert "logger::init 'N'; logger::get_global_level" 'N'
assert "logger::init 'N' '/tmp/debug.log'; logger::get_global_level" 'N'
assert "logger::get_global_level" 'A'
assert "logger::init 'N'; logger::init 'C'; logger::get_global_level" 'C'

assert_end "logger::get_global_level() - should succeed"
