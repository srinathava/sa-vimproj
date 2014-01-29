" ==============================================================================
" Sandbox utility functions
" ============================================================================== 
" mw#utils#GetRootDir: gets the directory above this one where battree resides {{{
function! mw#utils#GetRootDir()
    let battreePath = findfile('battree', '.;')
    if battreePath != ''
        return fnamemodify(battreePath, ':p:h')
    endif

    let projpath = findfile('.vimproj.xml', '.;')
    if projpath != ''
        return fnamemodify(projpath, ':p:h')
    end

    return ''
endfunction " }}}
" mw#utils#GetOtherFileName: gets equivalent file in other sandbox {{{
function! mw#utils#GetOtherFileName(otherDir)
	let presRoot = mw#utils#GetRootDir()
    
	let presFileName = expand('%:p')
	let relPath = strpart(presFileName, strlen(presRoot))

	let otherFileName = a:otherDir.relPath
	if !filereadable(otherFileName)
        return ''
	endif

    return otherFileName
endfunction " }}}
" mw#utils#NormalizeSandbox: normalizes the name of a sandbox {{{
" Description: understands things like "archive"
function! mw#utils#NormalizeSandbox(sb)
    let sb = expand(a:sb)
    if filereadable(sb.'/battree')
        return sb
    end
    if sb == 'archive'
        let output = system('sbver')
        let archivedir = matchstr(output, 'SyncFrom: \zs\(\S\+\)\zePerfect')
        return archivedir[0:(len(archivedir)-2)]
    else
        return ''
    endif
endfunction " }}}

" ==============================================================================
" General utility functions
" ============================================================================== 
" mw#utils#AssertError: produces an error if condition is untrue  {{{
function! mw#utils#AssertError(condition, message)
    if !a:condition
        throw a:message
    endif
endfunction " }}}
" mw#utils#SaveSettings: gets the current settings. {{{
function! mw#utils#SaveSettings(settingsList)
    let g:MW_SavedSettings = a:settingsList
    let g:MW_SavedSettingValues = []
    for s in g:MW_SavedSettings
        call add(g:MW_SavedSettingValues, getbufvar('%', '&'.s))
    endfor
endfunction " }}}
" mw#utils#RestoreSettings: resets the settings {{{
function! mw#utils#RestoreSettings()
    for i in range(len(g:MW_SavedSettings))
        call setbufvar('%', '&'.g:MW_SavedSettings[i], g:MW_SavedSettingValues[i])
    endfor
endfunction " }}}

" vim: fdm=marker
