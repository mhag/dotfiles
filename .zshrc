autoload -U compinit; compinit
export PATH=$PATH:/usr/sbin:~/bin:/usr/local/bin
export HOSTNAME=hostname

alias su='sudo su -s /bin/zsh'

HISTSIZE=5000
PROMPT='%{^39m%}%U$USER%{@^33m%}%m%{::^32m%}%~%%^m%}%u'

autoload -Uz vcs_info
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b|%a]'
precmd () {
    psvar=()
    LANG=en_US.UTF-8 vcs_info
    [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
}
RPROMPT="%1(v|%F{green}%1v%f|)"

autoload -Uz is-at-least
if is-at-least 4.3.11
then
  autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
  add-zsh-hook chpwd chpwd_recent_dirs
  zstyle ':chpwd:*' recent-dirs-max 5000
  zstyle ':chpwd:*' recent-dirs-default yes
  zstyle ':completion:*' recent-dirs-insert both
fi

zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                             /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

## 補完時に大小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select=1

#=============================================================#
if [ -f /sw/bin/init.sh ]; then
  source /sw/bin/init.sh
fi

#=============================================================#
# 履歴
HISTFILE=~/.zsh-history
HISTSIZE=1000000
SAVEHIST=1000000

# 複数の zsh を同時に使う時など history ファイルに上書きせず追加する
setopt append_history

# zsh の開始・終了時刻をヒストリファイルに書き込む
setopt extended_history

# 直前と同じコマンドラインはヒストリに追加しない
setopt hist_ignore_all_dups

# コマンドラインの先頭がスペースで始まる場合ヒストリに追加しない
setopt hist_ignore_space

# シェルのプロセスごとに履歴を共有
setopt share_history

# history (fc -l) コマンドをヒストリリストから取り除く。
setopt hist_no_store

# ヒストリを呼び出してから実行する間に一旦編集できる状態になる
setopt hist_verify

#=============================================================#


# 補完候補が複数ある時に、一覧表示する
setopt auto_list

# zsh: no matches found 対策
setopt nonomatch

# カッコの対応などを自動的に補完する
setopt auto_param_keys

# ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt auto_param_slash

# ビープ音を鳴らさないようにする
setopt NO_beep

# {a-c} を a b c に展開する機能を使えるようにする
setopt brace_ccl

# Ctrl+S/Ctrl+Q によるフロー制御を使わないようにする
setopt NO_flow_control

# シェルが終了しても裏ジョブに HUP シグナルを送らないようにする
setopt NO_hup

# Ctrl+D では終了しないようになる（exit, logout などを使う）
setopt ignore_eof

# コマンドラインでも # 以降をコメントと見なす
setopt interactive_comments

# auto_list の補完候補一覧で、ls -F のようにファイルの種別をマーク表示
setopt list_types

# 内部コマンド jobs の出力をデフォルトで jobs -l にする
setopt long_list_jobs

# コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
setopt magic_equal_subst

# ファイル名の展開でディレクトリにマッチした場合末尾に / を付加する
setopt mark_dirs

# 複数のリダイレクトやパイプなど、必要に応じて tee や cat の機能が使われる
setopt multios

# 8 ビット目を通すようになり、日本語のファイル名などを見れるようになる
setopt print_eightbit

# for, repeat, select, if, function などで簡略文法が使えるようになる
setopt short_loops

#
# set prompt
#
case ${UID} in
0)
    PROMPT="%B%{[31m%}%/#%{[m%}%b "
    PROMPT2="%B%{[31m%}%_#%{[m%}%b "
    SPROMPT="%B%{[31m%}%r is correct? [n,y,a,e]:%{[m%}%b "
    [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
        PROMPT="%{[37m%}${HOST%%.*} ${PROMPT}"
    ;;
*)
    PROMPT="%{[31m%}%/%%%{[m%} "
    PROMPT2="%{[31m%}%_%%%{[m%} "
    SPROMPT="%{[31m%}%r is correct? [n,y,a,e]:%{[m%} "
    [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
        PROMPT="%{[37m%}${HOST%%.*} ${PROMPT}"
    ;;
esac

# set terminal title including current directory
#
case "${TERM}" in
kterm*|xterm)
    precmd() {
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    }
    ;;
esac

# 色を使う
setopt prompt_subst

# 文字列末尾に改行コードが無い場合でも表示する
unsetopt promptcr

#コピペの時rpromptを非表示する
setopt transient_rprompt

# cd -[tab] でpushd
#setopt autopushd

# keychainの設定
# keychain ~/.ssh/id_rsa
# . ~/.keychain/$HOSTNAME-sh

# スクリーン上から補完する。Ctrl + o
HARDCOPYFILE=$HOME/tmp/screen-hardcopy
touch $HARDCOPYFILE

dabbrev-complete () {
        local reply lines=80 # 80行分
        screen -X eval "hardcopy -h $HARDCOPYFILE"
        reply=($(sed '/^$/d' $HARDCOPYFILE | sed '$ d' | tail -$lines))
        compadd - "${reply[@]%[*/=@|]}"
}

zle -C dabbrev-complete menu-complete dabbrev-complete
bindkey '^o' dabbrev-complete
bindkey '^o^_' reverse-menu-complete


# SSHコマンドはscreenの新しい窓で
function ssh_screen(){
 eval server=\${$#}
 screen -t $server ssh "$@"
}
if [ x$TERM = xscreen ]; then
  alias ssh=ssh_screen
fi

# 最後に打ったコマンドステータス行に
if [ "$TERM" = "screen" ]; then
        chpwd () { echo -n "_`dirs`\\" }
        preexec() {
                # see [zsh-workers:13180]
                # http://www.zsh.org/mla/workers/2000/msg03993.html
                emulate -L zsh
                local -a cmd; cmd=(${(z)2})
                case $cmd[1] in
                        fg)     if (( $#cmd == 1 )); then
                                        cmd=(builtin jobs -l %+)
                                else
                                        cmd=(builtin jobs -l $cmd[2])
                                fi
                                ;;
                        %*)
                                cmd=(builtin jobs -l $cmd[1])
                                ;;
                        cd)     if (( $#cmd == 2 )); then
                                        cmd[1]=$cmd[2]
                                fi
                                ;&
                        *)
                                echo -n "k$cmd[1]:t\\"
                                return
                                ;;
                esac

                local -A jt; jt=(${(kv)jobtexts})

                $cmd >>(read num rest
                        cmd=(${(z)${(e):-\$jt$num}})
                        echo -n "k$cmd[1]:t\\") 2>/dev/null
        }
        chpwd
fi

function peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(history -n 1 | \
        eval $tac | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history

bindkey '^r' peco-select-history

function peco-cdr () {
    local selected_dir=$(cdr -l | awk '{ print $2 }' | peco)
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N peco-cdr
bindkey '^x^r' peco-cdr

function peco-dfind() {
    local current_buffer=$BUFFER
    # .git系など不可視フォルダは除外
    local selected_dir="$(find . -maxdepth 5 -type d ! -path "*/.*"| peco)"
    if [ -d "$selected_dir" ]; then
        BUFFER="${current_buffer} \"${selected_dir}\""
        CURSOR=$#BUFFER
        # ↓決定時にそのまま実行するなら
        #zle accept-line
    fi
    zle clear-screen
}
zle -N peco-dfind
bindkey '^x^d' peco-dfind

case "${OSTYPE}" in
darwin*)
    alias ls='ls -G'
    eval "$(rbenv init -)"
    export JAVA_HOME=`/usr/libexec/java_home`
    ;;  
linux*)
    alias ls='ls --color=auto'
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
    alias be='bundle exec'
    ;;
esac

