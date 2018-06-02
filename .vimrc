if exists("did_load_filetypes")
    finish
endif
augroup filetypedetect
    au! BufNewFile,BufRead ~/.dotfiles/bash/* setf bash
augroup END
