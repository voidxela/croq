croque::prepare-git() {
  croque prepare git
}

croque::prepare-git-async::callback() {
  __croque_git_info="$3"
  zle reset-prompt
}

croque::prepare-git-async() {
  async_stop_worker croque_async_git_worker
  async_start_worker croque_async_git_worker -n
  async_register_callback croque_async_git_worker croque::prepare-git-async::callback
  async_job croque_async_git_worker croque::prepare-git
}

croque::prepare() {
  if (( ${+ASYNC_VERSION} )); then
    async_init
    croque::prepare-git-async
  else
    __croque_git_info="$(croque::prepare-git)"
  fi
}

croque::chpwd() {
  unset __croque_git_info
}

croque::preexec() {
  __croque_start="$EPOCHREALTIME"
}

croque::precmd() {
  __croque_exit_status="$?"
  __croque_jobs="$#jobstates"
  local end="$EPOCHREALTIME"
  __croque_duration="$(($end - ${__croque_start:-$end}))"
  unset __croque_start

  croque::prepare
}

croque::prompt() {
  croque prompt --exit-status="$__croque_exit_status" --jobs="$__croque_jobs" --duration="$__croque_duration" --width="$COLUMNS" --data.git="$__croque_git_info" zsh
}

croque::rprompt() {
  croque prompt --right --exit-status="$__croque_exit_status" --jobs="$__croque_jobs" --duration="$__croque_duration" --width="$COLUMNS" --data.git="$__croque_git_info" zsh
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd croque::chpwd
add-zsh-hook precmd croque::precmd
add-zsh-hook preexec croque::preexec

setopt prompt_subst
PROMPT='$(croque::prompt)'
RPROMPT='$(croque::rprompt)'
