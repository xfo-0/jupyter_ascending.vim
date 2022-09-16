let g:jupyter_ascending_python_executable = get(g:, 'jupyter_ascending_python_executable', 'python')
let g:jupyter_ascending_match_pattern     = get(g:, 'jupyter_ascending_match_pattern', '.sync.py')
let g:jupyter_ascending_auto_write        = get(g:, 'jupyter_ascending_auto_write', v:true)

let g:jupyter_ascending_make_pair = get(g:, 'jupyter_ascending#make_pair')

let g:jupyter_ascending_convert_all       = get(g:, 'jupyter_ascending#convert_all')
let g:jupyter_ascending_convert_current   = get(g:, 'jupyter_ascending#convert_current')

let g:jupyter_ascending_restore_all       = get(g:, 'jupyter_ascending#restore_all')
let g:jupyter_ascending_restore_current   = get(g:, 'jupyter_ascending#restore_current')

let g:jupyter_ascending_del_all_synced_py = get(g:, 'jupyter_ascending#del_all_synced_py')

augroup JupyterAscending
  au!

  if g:jupyter_ascending_auto_write
    autocmd BufWritePost * :call jupyter_ascending#sync()
  endif
augroup END


nnoremap <Plug>JupyterExecute    :call jupyter_ascending#execute()<CR>
nnoremap <Plug>JupyterExecuteAll :call jupyter_ascending#execute_all()<CR>

nnoremap <Plug>JupyterMakePair    :call jupyter_ascending#make_pair()<CR>

nnoremap <Plug>JupyterConvertCurrent :call jupyter_ascending#convert_current()<CR>
nnoremap <Plug>JupyterConvertAll     :call jupyter_ascending#convert_all()<CR>

nnoremap <Plug>JupyterRestoreAll :call jupyter_ascending#restore_all()<CR>
nnoremap <Plug>JupyterRestoreCurrent :call jupyter_ascending#restore_current()<CR>

nnoremap <Plug>JupyterDelAllPy :call jupyter_ascending#del_all_synced_py()<CR>

if get(g:, 'jupyter_ascending_default_mappings', v:true)
  nmap <space><space>x <Plug>JupyterExecute
  nmap <space><space>X <Plug>JupyterExecuteAll
endif
