# Nushell Config File
use ($nu.default-config-dir | path join mise.nu)

# Define aliases
alias .. = cd ..
alias ... = cd ../..
alias ll = ls -l
alias la = ls -a

# Development directories
alias dev = cd ~/dev
alias work = cd ~/dev/work
alias oss = cd ~/dev/oss
alias lab = cd ~/dev/lab
alias rice = cd ~/dev/rice

# Development tools
# alias hx = helix
alias g = git
alias gst = git status
alias gd = git diff
alias gc = git commit
alias gp = git push
alias gl = git log --graph --abbrev-commit --decorate --format=format:"%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)" --all

# System update alias (distro-aware)
def update [] {
    if (which yay | is-empty) == false {
        run-external "sudo" "eos-rankmirrors"
        run-external "yay" "--noconfirm"
    } else if (which apt | is-empty) == false {
        run-external "sudo" "apt" "update"
        run-external "sudo" "apt" "upgrade"
    }
}

def hx [...args] {
    if (which hx | is-empty) {
       ^hx ...$args
    } else {
        ^helix ...$args
    }
}

# Theme
let dark_theme = {
    # Base formatting
    separator: white
    leading_trailing_space_bg: { attr: n }
    header: green_bold
    empty: blue
    
    # Basic types
    bool: light_cyan
    int: white
    filesize: cyan
    duration: white
    date: purple
    range: white
    float: white
    string: white
    nothing: white
    binary: white
    
    # Shell elements
    cell-path: white
    row_index: green_bold
    record: white
    list: white
    block: white
    hints: dark_gray
    
    # Search
    search_result: { bg: red fg: white }
    
    # Shapes (syntax highlighting)
    shape_and: purple_bold
    shape_binary: purple_bold
    shape_block: blue_bold
    shape_bool: light_cyan
    shape_closure: green_bold
    shape_custom: green
    shape_datetime: cyan_bold
    shape_directory: cyan
    shape_external: cyan
    shape_externalarg: green_bold
    shape_filepath: cyan
    shape_flag: blue_bold
    shape_float: purple_bold
    shape_garbage: { fg: white bg: red attr: b }
    shape_globpattern: cyan_bold
    shape_int: purple_bold
    shape_internalcall: cyan_bold
    shape_keyword: cyan_bold
    shape_list: cyan_bold
    shape_literal: blue
    shape_nothing: light_cyan
    shape_operator: yellow
    shape_pipe: purple_bold
    shape_range: yellow_bold
    shape_record: cyan_bold
    shape_string: green
    shape_string_interpolation: cyan_bold
    shape_table: blue_bold
    shape_variable: purple
}

# Base configuration
$env.config = {
    show_banner: false
    
    # Basic shell behavior
    ls: {
        use_ls_colors: true
        clickable_links: true
    }
    rm: {
        always_trash: false
    }
    table: {
        mode: rounded
        index_mode: always
        padding: { left: 1, right: 1 }
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
            truncating_suffix: "..."
        }
    }
    
    # History
    history: {
        max_size: 10000
        sync_on_enter: true
        file_format: "plaintext"
        isolation: false
    }
    
    # Completions
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "prefix"
        external: {
            enable: true
            max_results: 25
        }
        use_ls_colors: true
    }
    
    # Appearance
    cursor_shape: {
        emacs: block  # Block cursor for better visibility
        vi_insert: block 
        vi_normal: block
    }
    color_config: $dark_theme
    use_ansi_coloring: true
    
    # Core settings
    buffer_editor: "hx"  # Use helix as buffer editor
    edit_mode:  emacs    # Emacs keybindings for minimal shell editing
    
    # Keybindings - Pro setup
    keybindings: [
        # Essential operations
        {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: completion_menu }
                    { send: menunext }
                    { edit: complete }
                ]
            }
        }
        {
            name: cancel_command
            modifier: control
            keycode: char_c
            mode: [emacs, vi_normal, vi_insert]
            event: { send: ctrlc }
        }
        {
            name: quit_shell
            modifier: control
            keycode: char_d
            mode: [emacs, vi_normal, vi_insert]
            event: { send: ctrld }
        }
        {
            name: clear_screen
            modifier: control
            keycode: char_l
            mode: [emacs, vi_normal, vi_insert]
            event: { send: clearscreen }
        }
        {
            name: search_history
            modifier: control
            keycode: char_r
            mode: [emacs, vi_normal, vi_insert]
            event: { send: searchhistory }
        }
        # Clipboard operations
        {
            name: copy_selection
            modifier: control_shift
            keycode: char_c
            mode: emacs
            event: { edit: copyselection }
        }
        {
            name: cut_selection
            modifier: control_shift
            keycode: char_x
            mode: emacs
            event: { edit: cutselection }
        }
        # Navigation
        {
            name: move_up
            modifier: none
            keycode: up
            mode: [emacs, vi_normal, vi_insert]
            event: { 
                until: [
                    { send: menuup }
                    { send: up }
                ]
            }
        }
        {
            name: move_down
            modifier: none
            keycode: down
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: menudown }
                    { send: down }
                ]
            }
        }
        {
            name: move_left
            modifier: none
            keycode: left
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: moveleft }
        }
        {
            name: move_right
            modifier: none
            keycode: right
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: moveright }
        }
        # Line editing
        {
            name: delete_one_character_backward
            modifier: none
            keycode: backspace
            mode: [emacs, vi_insert]
            event: { edit: backspace }
        }
        {
            name: delete_one_character_forward
            modifier: none
            keycode: delete
            mode: [emacs, vi_insert]
            event: { edit: delete }
        }
        {
            name: move_to_line_start
            modifier: control
            keycode: char_a
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: movetolinestart }
        }
        {
            name: move_to_line_end
            modifier: control
            keycode: char_e
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: movetolineend }
        }
        # Word operations
        {
            name: move_word_left
            modifier: control
            keycode: left
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: movewordleft }
        }
        {
            name: move_word_right
            modifier: control
            keycode: right
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: movewordright }
        }
        {
            name: delete_word_backward
            modifier: control
            keycode: backspace
            mode: [emacs, vi_insert]
            event: { edit: backspaceword }
        }
        {
            name: delete_word_forward
            modifier: control
            keycode: delete
            mode: [emacs, vi_insert]
            event: { edit: deleteword }
        }
    ]
}

# use '/home/animal/.config/broot/launcher/nushell/br' *
