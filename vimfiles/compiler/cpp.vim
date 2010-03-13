set efm=

" A bunch of warnings which are benign.
let &efm .= '%-G%.%#UNIX_CXX_TEMP_DIR%.%#'
let &efm .= ',%-G%.%#undefined\ variable\ `DEBUG_FLAG%.%#'
let &efm .= ',%-G%.%#undefined\ variable\ `OBJ_DIR%.%#'
let &efm .= ',%-G%.%#undefined\ variable\ `VERBOSE%.%#'
let &efm .= ',%-G%.%#undefined\ variable\ `LIB_UT_LIB_DEPEND%.%#'
let &efm .= ',%-G%.%#undefined\ variable\ `BOLD_%.%#'
let &efm .= ',%-G%.%#javarules\.gnu\ is\ deprecated%.%#'
let &efm .= ',%-G%.%#msrc-action%.%#'
let &efm .= ',%-G%.%#Done\ prebuild%.%#'
let &efm .= ',%-G%.%#Done\ build%.%#'
let &efm .= ',%-G%.%#Running\ prebuild%.%#'
let &efm .= ',%-G%.%#Running\ build%.%#'
let &efm .= ',%-G%.%#is\ obsolete%.%#'
let &efm .= ',%-G%.%#include\ path\ is\ out-of-model%.%#'
let &efm .= ',%-G%.%#compflags\.gnu%.%#'
let &efm .= ',%-W%.%#compflags\.gnu%.%#'

let &efm .= ',%*[^"]"%f"%*\D%l: %m'
let &efm .= ',"%f"%*\D%l: %m'
let &efm .= ',%-G%f:%l: (Each undeclared identifier is reported only once'
let &efm .= ',%-G%f:%l: for each function it appears in.)'
let &efm .= ',%f:%l:%c:%m'
let &efm .= ',%f(%l):%m,%f:%l:%m,"%f"\, line %l%*\D%c%*[^ ] %m'
let &efm .= ',%-D%*\a[%*\d]: Entering directory `%f'."'"
let &efm .= ',%-D%*\a: Entering directory `%f'."'"
" let &efm .= ',%-X%*\a[%*\d]: Leaving directory `%f'."'"
" let &efm .= ',%-X%*\a: Leaving directory `%f'."'"
" let &efm .= ',%-G%*\a[%*\d]: Entering directory `%f'."'"
" let &efm .= ',%-G%*\a: Entering directory `%f'."'"
let &efm .= ',%-G%*\a[%*\d]: Leaving directory `%f'."'"
let &efm .= ',%-G%*\a: Leaving directory `%f'."'"
let &efm .= ',%-DMaking %*\a in %f'
let &efm .= ',%f|%l| %m '
let &efm .= ',%-G%.%#'

