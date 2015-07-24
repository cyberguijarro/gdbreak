if !has('python')
    finish
endif

if !has('signs')
    finish
endif

python << EOF
import vim

def readlines():
    try:
        with open('.gdbreak', 'rw+') as file:
            return file.readlines()
    except:
        return []

def writelines(lines):
    with open('.gdbreak', 'w+') as file:
        for line in lines:
            file.write(line)

vim.command(':sign define brk text=>> texthl=Search')
EOF

function! GdbToggle()
python << EOF
lines = readlines()

entry = 'break %s:%d\n' % (vim.current.buffer.name, vim.current.window.cursor[0])

if entry in lines:
    lines.remove(entry)
    print 'Breakpoint removed.'
else:
    lines.append(entry)
    print 'Breakpoint set.'

writelines(lines)
vim.command(':call GdbLoad()')
EOF
endfunc

function! GdbLoad()
python << EOF
lines = readlines()
vim.command(':sign unplace *')

for line in lines:
    path = line.split(' ')[1].split(':')[0]
    position = int(line.split(' ')[1].split(':')[1])
    id = 1

    if path == vim.current.buffer.name:
        vim.command(
            'sign place %d line=%d name=brk buffer=%d'
                % (id, position, vim.current.buffer.number)
        )
        id = id + 1
EOF
endfunc

function! GdbClear()
python << EOF
writelines([])
vim.command(':call GdbLoad()')
EOF
endfunc

command! GdbToggle call GdbToggle()
command! GdbLoad call GdbLoad()
command! GdbClear call GdbClear()

augroup doc
    autocmd!
    autocmd BufReadPost * :call GdbLoad()
augroup END

nnoremap <Leader>b :call GdbToggle()<CR>
