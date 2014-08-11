peco-snippets() {
  local name="peco-snippets"
  local snippets="${HOME}/.snippets"

  local command="$1"

  _trim() {
    sed -i '' -E 's/^[[:blank:]]+//;s/[[:blank:]]+$//' "$snippets"
    sort -u -o "$snippets" "$snippets"
  }

  _peco_snippets() {
    _trim
    grep -v "^#" "$snippets" | peco
  }

  if [ "$command" = "add" ] ; then
    local NUM=$(history | wc -l)
    local FIRST=$((-1*(NUM-1)))

    if [ $FIRST -eq 0 ] ; then
      echo "No history" >&2
      return 1
    fi

    fc -l $FIRST | sort -k 2 -k 1nr | uniq -f 1 | sort -nr | sed -E 's/^[0-9]+[[:blank:]]+//' | peco >> "$snippets"

    _trim
    return
  fi

  if [ "$command" = "rm" ] ; then
    local lines=$(_peco_snippets)

    local IFS=$'\n'

    for line in $lines ; do
      line=${line//\//\\\/}
      IFS=" "; sed -i '' -E "/^${line}$/d" "$snippets"
    done

    return
  fi

  if [ "$command" = "list" ] ; then
    cat "$snippets"
    return
  fi

  if [ "$command" = "help" ] ; then
    cat <<EOF
Usage: $name [command]

Select a snippet in the snippets file ($snippets) using peco

command:
  add   Add the selected command history to the snippets file
  rm    Remove the selected snippets from the snippets file
  list  List snippets in the snippets file

  help  Show this message
EOF
    return
  fi

  local line=$(_peco_snippets | head -n 1)

  if [ -n "$line" ] ; then
    # Replace the last entry, "peco-snippets", with $line
    history -s $line

    if type osascript > /dev/null 2>&1 ; then
      # Send UP keystroke to console
      (osascript -e 'tell application "System Events" to keystroke (ASCII character 30)' &)
    fi
  fi
}