function peco-process-kill() {
  for pid in `ps aux | peco | awk '{ print $2 }'`
  do
    kill $pid
    echo "Killed ${pid}"
  done
}
zle -N peco-process-kill