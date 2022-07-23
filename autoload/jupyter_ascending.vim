function! s:on_stdout(j, d, e)
  if len(a:d) > 0 && len(a:d[0]) > 0
    echom '[JupyterAscending]' a:d
  endif
endfunction

function! s:execute(command_string) abort
  if has('nvim')
    call jobstart(a:command_string, {
          \ 'on_stdout': funcref('s:on_stdout')
          \ })
  else
    call systemlist(a:command_string)
  end
endfunction

function! jupyter_ascending#sync() abort
  let file_name = expand("%:p")

  if match(file_name, g:jupyter_ascending_match_pattern) < 0
    return
  endif

  let command_string = printf(
        \ "%s -m jupyter_ascending.requests.sync --filename '%s'",
        \ g:jupyter_ascending_python_executable,
        \ file_name
        \ )

  call s:execute(command_string)
endfunction

function! jupyter_ascending#execute() abort
  let file_name = expand("%:p")

  if match(file_name, g:jupyter_ascending_match_pattern) < 0
    return
  endif

  let command_string = printf(
        \ "%s -m jupyter_ascending.requests.execute --filename '%s' --linenumber %s",
        \ g:jupyter_ascending_python_executable,
        \ file_name,
        \ line('.')
        \ )

  call s:execute(command_string)
endfunction

function! jupyter_ascending#execute_all() abort
  let file_name = expand("%:p")

  if match(file_name, g:jupyter_ascending_match_pattern) < 0
    return
  endif

  let command_string = printf(
        \ "%s -m jupyter_ascending.requests.execute_all --filename '%s'",
        \ g:jupyter_ascending_python_executable,
        \ file_name
        \ )

  call s:execute(command_string)
endfunction

function! jupyter_ascending#convert_all() abort 
  let dir_name = expand('%:p:h')
  let file_name = expand('%:p')
  let current_file = expand('%:t')
  let current_file_name = expand('%:t:r:r')

    echo 'Converting: '
    echo
    execute '!for FILE in ' . dir_name . '/*.sync.ipynb; do if [ "$(basename "$FILE")" \!= "*.sync.ipynb" ] && [ "$(basename "$FILE")" \!= "*' . current_file . '*" ]; then echo "$FILE"; fi; done;'

    silent execute '!for FILE in ' . dir_name . '/*.ipynb; do if [ "$(basename "$FILE")" \!= "*.sync.ipynb" ] && [ "$(basename "$FILE")" \!= "*' . current_file . '*" ]; then mv "$FILE" ' . dir_name . '/$(basename "$FILE" .ipynb).sync.ipynb; fi; done;'
    execute '!for FILE in ' . dir_name . '/*.sync.ipynb; do jupytext --to py:percent $FILE; done;'
    execute '!if "' . current_file . '" \!= "*.sync.ipynb"; then mv ' . file_name . ' ' . dir_name . '/' . current_file_name . '.sync.ipynb && jupytext --to py:percent ' . dir_name . '/' . current_file_name . '.sync.ipynb; fi;'
endfunction

function! jupyter_ascending#convert_current() abort 
  let file_name = expand('%:p')
  let extension = expand('%:e')
  let current_file = expand('%:t')
  let current_file_name = expand('%:t:r:r')
  let base_name = expand('%:p:r:r')

  if (extension == "ipynb") && (base_name != "*.sync.ipynb")
    echo 'Converting: ' . current_file_name . '.sync.ipynb'
    echo
    echo file_name . ' -> ' . base_name . '.sync.ipynb'

    silent execute '!mv ' . file_name . ' ' . base_name . '.sync.ipynb'
    execute '!jupytext --to py:percent ' . base_name . '.sync.ipynb'

  elseif extension == "py"
    echo 'Converting: ' . current_file_name . '.sync.ipynb'
    echo
    echo file_name . ' -> ' . base_name . '.sync.ipynb'

    silent execute '!mv ' . base_name . '.ipynb' . ' ' . base_name . '.sync.ipynb'
    execute '!jupytext --to py:percent ' . base_name . '.sync.ipynb'
  endif
endfunction

function! jupyter_ascending#restore_all() abort
    let dir_name = expand('%:p:h') 
    let file_name = expand('%:p')
    let current_file = expand('%:t')
    let current_file_name = expand('%:t:r:r')

    echo 'Restoring: '
    echo
    execute '!for FILE in ' . dir_name . '/*.sync.ipynb; do if [ "$(basename "$FILE")" \!= "*' . current_file . '*" ]; then echo "$FILE"; fi; done;'
    silent execute '!for FILE in ' . dir_name . '/*.sync.ipynb; do if [ "$(basename "$FILE")" \!= "*' . current_file . '*" ]; then mv "$FILE" ' . dir_name . '/$(basename "$FILE" .sync.ipynb).ipynb; fi; done;'
    silent execute '!if "' . current_file . '" == "*.ipynb"; then mv ' . file_name . ' ' . dir_name . '/' . current_file_name . '.ipynb; fi;'
endfunction 

function! jupyter_ascending#restore_current() abort 
  let file_name = expand('%:p')
  let extension = expand('%:e')
  let current_file = expand('%:t')
  let current_file_name = expand('%:t:r:r')
  let base_name = expand('%:p:r:r')

  if current_file =~ ".sync.ipynb"
    echo 'Restoring: ' . current_file_name . '.sync.ipynb'
    echo
    echo file_name . ' -> ' . base_name . '.ipynb'

    silent execute '!mv ' . file_name . ' ' . base_name '.ipynb'

  elseif extension == "py"
    echo 'Restoring: ' . current_file_name . '.sync.ipynb'
    echo
    echo file_name . ' -> ' . base_name . '.ipynb'

    silent execute '!mv ' . base_name . '.sync.ipynb'. ' ' . base_name . '.ipynb'
  endif
endfunction

function! jupyter_ascending#del_all_synced_py() abort
    let file_name = expand('%:p')
    let dir_name = expand('%:p:h') 
    let current_file = expand('%:t')
    let current_file_name = expand('%:t:r:r')

    echo '!for FILE in ' . dir_name . '/*.sync.py; do if [ "$(basename "$FILE")" \!= "*' . current_file . '*" ]; then echo "$FILE" '
    echo
    echo 'Continue? [y/n]'
    let input = input('')
    if input == 'y'
      echo
      echo 'Removing: '
      echo
      echo '!for FILE in ' . dir_name . '/*.sync.py; do if [ "$(basename "$FILE")" \!= "*' . current_file . '*" ]; then echo "$FILE" '
      silent execute '!for FILE in ' . dir_name . '/*.sync.py; do if [ "$(basename "$FILE")" \!= "*' . current_file . '*" ]; then rm "$FILE" ' . dir_name . '/"$FILE"; fi; done;'
      if current_file =~ ".sync.py"
        echo file_name 
      silent execute '!if "' . current_file . '" == "*.sync.py"; then rm ' . file_name . '; fi; done;'
      endif
    endif
endfunction 
