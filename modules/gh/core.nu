use std/log
const command_base = 'gh core'

def is_ci [message?: string] {
    if ($env.GITHUB_ACTION? != null) { return true }
    if ($message != null) {
        log debug $"=> ($command_base) ($message)"
    } else {
        log debug $"=> ($command_base) command skips exection \(not running in Github Action)"
    }
    false
}

# Github action core debug command
export def debug [
    message: string     # A message
] {
    if not (is_ci $"debug: ($message)") { return }
    print $"::debug::($message)"
}

# Github action core notice command
export def notice [
    message: string     # A message
    --params: record    # Record with parameters (file, line, endLine and title)
] {
    if not (is_ci $"notice: ($message)") { return }
    mut sparams = ""
    if ($params | is-not-empty) {
        $params | transpose key value | each {|e| $"($e.key)=($e.value)"} | str join ','
        | $sparams = $in
    }
    print $"::notice ($sparams)::($message)"
}

# Alias to notice command
export alias info = notice

# Github action core error command
export def error [
    message: string     # A message
    --params: record    # Record with parameters (file, line, endLine and title)
] {
    if not (is_ci $"error: ($message)") { return }
    mut sparams = ""
    if ($params | is-not-empty) {
        $params | transpose key value | each {|e| $"($e.key)=($e.value)"} | str join ','
        | $sparams = $in
    }
    print $"::error ($sparams)::($message)"
}

# Github action core setFailed (error + exit 1)
export def setFailed [
    message: string     # A message
    --params: record    # Record with parameters (file, line, endLine and title)
] {
    error $message --params=$params
    exit 1
}

# Github action core warning command
export def warning [
    message: string     # A message
    --params: record    # Record with parameters (file, line, endLine and title)
] {
    if not (is_ci $"warning: ($message)") { return }
    mut sparams = ""
    if ($params | is-not-empty) {
        $params | transpose key value | each {|e| $"($e.key)=($e.value)"} | str join ','
        | $sparams = $in
    }
    print $"::warning ($sparams)::($message)"
}

# Github action core isDebug
export def isDebug [] {
    if not (is_ci) { return }
    ($env.RUNNER_DEBUG? | default "false") == "true"
}

# Github action core getInput
export def getInput [
    name: string    # Input name
] {
    if not (is_ci) { return }
    let input = $name | str replace -a -r ' ' '_' | str upcase | $'INPUT_($in)'
    $env | get -i $input
}

# Github action core setOutput
export def setOutput [
    name: string    # Output name
    value?: string  # Output value
] {
    if not (is_ci) { return }
    $"($name)=($value)\n" | save --append $env.GITHUB_OUTPUT
}

# Github action core exportVariable
export def exportVariable [
    name: string    # Variable name
    value?: string  # Variable value
] {
    if not (is_ci) { return }
    $"($name)=($value)\n" | save --append $env.GITHUB_ENV
}

# Github action core setSecret (masks secret )
export def setSecret [
    secret: string      # Secret value
] {
    if not (is_ci) { return }
    print $"::add-mask::($secret)"
}
