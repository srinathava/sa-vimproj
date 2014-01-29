" def addSandboxTags {{{
if has('python')
python <<EOF
import sys
import os
from os import path

try:
    from getProjSettings import getProjSettings
    from sbtools import getRootDir

    def addSandboxTags(fname):
        rootDir = getRootDir()
        if not rootDir:
            return

        soln = getProjSettings()
        if not soln:
            return

        soln.setRootDir(rootDir)

        for proj in soln.projects:
            if proj.includesFile(fname):
                # add project tags
                for inc in proj.includes:
                    vim.command("let &l:tags .= ',%s'" % path.join(rootDir, inc['path'], inc['tagsFile']))

                # add imported header tags.
                for dep in proj.depends:
                    dep_proj = soln.getProjByName(dep)
                    for inc in dep_proj.exports:
                        vim.command("let &l:tags .= ',%s'" % path.join(rootDir, inc['path'], inc['tagsFile']))


    def getTagFiles(fname):
        rootDir = getRootDir()
        if not rootDir:
            return

        soln = getProjSettings()
        if not soln:
            return

        soln.setRootDir(rootDir)

        for proj in soln.projects:
            if proj.includesFile(fname):
                for inc in proj.includes:
                    tagsFileFullPath = path.join(rootDir, inc['path'], inc['tagsFile'])
                    vim.command(r'''let tagsFile = "%s"''' % tagsFileFullPath)
                    return

except ImportError:
    def addSandboxTags(fname):
        pass

    pass
EOF
endif
" }}}

let s:path = expand('<sfile>:p:h')
" mw#tag#AddSandboxTags: add all tags for a given C/C++ file {{{
function! mw#tag#AddSandboxTags(fname)
    if !has('python')
        return
    endif
    let &l:tags = s:.path.'/cpp_std.tags'
    exec 'python addSandboxTags(r"'.a:fname.'")'
endfunction " }}}
" mw#tag#InitVimTags:  {{{
" Description: 
function! mw#tag#InitVimTags()
    if !has('python')
        return
    endif
    !genVimTags.py
    call mw#tag#AddSandboxTags(expand('%:p'))
endfunction " }}}
" mw#tag#SelectTag: select a tag from this project {{{
" Description: 
function! mw#tag#SelectTag(fname)
    if !has('python')
        return
    endif
    exec 'python getTagFiles(r"'.a:fname.'")'
    let output = system('selectTag.py '.tagsFile)
    let [tagName, fileName, tagPattern] = split(output, "\n")

    let tagsFilePath = fnamemodify(tagsFile, ':p:h')
    let fileName = tagsFilePath . '/' . fileName

    exec 'drop '.fileName
    let tagPattern = escape(tagPattern, '*[]')
    exec tagPattern
endfunction " }}}
