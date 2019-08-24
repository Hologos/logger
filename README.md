# logger

A simple bash logger.

## Installation

Download `logger` file and place it within your project.

**Important:** bash v4.4 and higher is required

## Usage

```bash
# load the library
. "path/to/library/logger"

# first you have to initialize the logger
logger::init "N"

# now you can log your messages
logger::log "W" "This is a warning message."

# this message will not be seen
logger::log "D" "This is a debug message."
```

The above code will generate following output to `STDERR`:

```
[23.08.2019 18:04:57] W: This is a warning message.
```

You can also initialize logger to write log messages to a file.

```bash
logger::init "D" "/tmp/debug.log"

# log message will be writen to /tmp/debug.log
logger::log "D" "This is a debug message."
```

## Options

### Levels

Every message has to have one of the following levels associated with it:

| Code | Description |
| :---: | --- |
| T | trace |
| D | debug |
| I | information |
| N | notice |
| W | warning |
| E | error |
| C | critical |

You can pass following level to `logger::init()` to show all messages:

| Code | Description |
| :---: | --- |
| A | all messages |

Once you initialize the logger, all messages with the same level or higher (lower in the table) will get printed.

**Eg:** Initializing with level `N` will print only messages with level `N`, `W`, `E` and `C`.

## Examples

```bash
# set level according to environment variable
if [[ -z "${WATCHDOG_LOGGER_LEVEL+_}" ]]; then
    WATCHDOG_LOGGER_LEVEL="N"
fi

logger::init "${WATCHDOG_LOGGER_LEVEL}"
```

```bash
function watchdog::check_file_copy_states() {
    logger::log "D" "Checking file copy states."

    if [[ ${#states[@]} -eq 0 ]]; then
        logger::log "D" "No files are copying."
    else
        for state in "${states[@]}"; do
            if [[ "${state}" == "${WATCHDOG_STATE_FAILED}" ]]; then
                logger::log "C" "A file copy has failed."

                return 1
            fi
        done
    fi
}
```

```bash
declare -A __WATCHDOG_CONFIG

function watchdog::load_ini_file() {
    local filepath="${1}"

    logger::log "T" "Running ${FUNCNAME}():"
    logger::log "T" "   filepath=${filepath}"

    logger::log "D" "Loading file ${filepath}."

    if [[ ! -r "${filepath}" ]]; then
        watchdog::terminate "Cannot read ini file ${filepath}."
    fi

    local line=""
    local line_number=0

    while read line; do
        line_number="$(( ${line_number} + 1 ))"

        logger::log "D" "Reading line #${line_number} '${line}'."

        # skip lines beginning with ; (semicolon)
        # skip empty lines or containing only whitespaces
        if [[ "${line}" =~ ^\; ]] || [[ "${line}" =~ ^[[:space:]]*$ ]]; then
            logger::log "D" "Skipping line #${line_number} '${line}'."

            continue
        fi

        # key=value
        if ! [[ ${line} =~ ^[^=]+=[^=]+$ ]]; then
            watchdog::terminate "Malformed ini file ${filepath}, line #${line_number} '${line}'."
        fi

        local key="${line%=*}"
        local value="${line#*=}"

        logger::log "D" "key=${key}"
        logger::log "D" "value=${value}"

        __WATCHDOG_CONFIG[${key}]="${value}"
    done < "${filepath}"
}
```
