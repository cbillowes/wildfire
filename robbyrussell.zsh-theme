local ret_status="%(?:%{$fg_bold[grey]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT='${ret_status} %{$fg[grey]%}%c%{$reset_color%} $(git_prompt_info)$(git_prompt_short_sha) ➜ '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg_bold[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg_bold[green]%}✔%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%}✚ "
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%}⚑ "
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}✖ "
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%}▴ "
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[cyan]%}§ "
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[white]%}◒ "

ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$fg[green]%}"
ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%{$fg[yellow]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$fg[red]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$fg[white]%}"

# Format for git_prompt_long_sha() and git_prompt_short_sha()
ZSH_THEME_GIT_PROMPT_SHA_BEFORE="%{$fg_bold[yellow]%}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$reset_color%}"


