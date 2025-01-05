# Nushell Environment Config File

# XDG Base Directories
$env.XDG_CONFIG_HOME = ($env.HOME | path join ".config")
$env.XDG_DATA_HOME = ($env.HOME | path join ".local" "share")
$env.XDG_CACHE_HOME = ($env.HOME | path join ".cache")
$env.XDG_STATE_HOME = ($env.HOME | path join ".local" "state")

# Setup mise
let mise_path = $nu.default-config-dir | path join mise.nu
^mise activate nu | save $mise_path --force

# Editor and basic tools
$env.EDITOR = "hx"
$env.VISUAL = "hx"
$env.TERMINAL = "foot"
$env.BROWSER = "firefox"

# Development paths & tools
$env.DOCKER_HOST = "unix:///var/run/docker.sock"
$env.PATH = ($env.PATH | 
    split row (char esep) | 
    prepend '/usr/bin' |
    prepend ($env.HOME | path join '.local' 'bin') |    # Local scripts
    prepend '~/.local/share/mise/shims'                 # mise-managed tools
)

# Language-specific configurations
# Uncomment as needed:
# $env.GOPATH = ($env.HOME | path join "dev" "go")
# $env.CARGO_HOME = ($env.XDG_DATA_HOME | path join "cargo")
# $env.RUSTUP_HOME = ($env.XDG_DATA_HOME | path join "rustup")
# $env.NODE_PATH = ($env.XDG_DATA_HOME | path join "node")
# $env.PNPM_HOME = ($env.XDG_DATA_HOME | path join "pnpm")


# Starship prompt setup
$env.STARSHIP_SHELL = "nu"

def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}

$env.PROMPT_COMMAND = { || create_left_prompt }
$env.STARSHIP_CONFIG = ($env.XDG_CONFIG_HOME | path join "starship" "starship.toml")
$env.PROMPT_COMMAND_RIGHT = ""
$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ": "
$env.PROMPT_INDICATOR_VI_NORMAL = "〉"
$env.PROMPT_MULTILINE_INDICATOR = "::: "

# Hook configurations
$env.config = ($env.config? | default {} | merge {
    hooks: {
        pre_prompt: [{
            null  # placeholder for pre-prompt hook
        }]
        env_change: {
            PWD: [{|before, after| null }]  # placeholder for PWD change hook
        }
    }
})

# Environment variable conversions
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# Search directories
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') 
    ($nu.default-config-dir | path join 'completions')       
]

# Plugin directories
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

# Append mise directory to NU_LIB_DIRS
$env.NU_LIB_DIRS = ($env.NU_LIB_DIRS | append ($mise_path | path dirname))
