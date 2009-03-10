import sys
import vim

def findInProj(args):
    out = vim.eval(r'Project_GetAllFnames(1, line("."), "\n")')
    open('/tmp/file_list_grep.txt', 'w').write(out)
    # grep_args = raw_input('Enter pattern/options to search for: ')
    # vim.command(r'grep %s' % grep_args)
