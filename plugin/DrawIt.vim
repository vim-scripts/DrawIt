" DrawIt.vim: a simple way to draw things in Vim -- just put this file in
"             your plugin directory, use \di to start (\ds to stop), and
"             just move about using the cursor keys.
"
"             You may also use visual-block mode to select endpoints and
"             draw lines, arrows, and ellipses.
"
" Last Change: Feb 24, 2003
" Maintainers:  Charles E. Campbell, Jr.  (Charles.E.Campbell.1@gsfc.nasa.gov)
"               Sylvain VIART             (molo@multimania.com)
"
" NOTE:        this script requires Vim 6.0k (or later)
"
" To Enable: simply put this plugin into your ~/.vim/plugin directory
"
" Usage:  (the backslash is actually whatever your leader character(s) is/are)
"    \di   : start DrawIt
"    \ds   : stop  DrawIt
"    call SetDrawIt('vertical','horizontal','crossing','\','/','X') :
"            set drawing characters for motions to the
"            |: up/down,
"            -: left/right,
"            +: |- crossing,
"            \: downright, and
"            /: downleft
"~           X: \/ crossing
"
"            The routines use a replace, move, and replace/insert
"            strategy.  The package also lets one...
"
"   <space>  toggle erase mode
"   >        insert a > and move right    (facilitates the drawing of arrows)
"   <        insert a < and move left
"   ^        insert a ^ and move up
"   v        insert a v and move down
"   <end>    replace with a \, move down and right, and insert a \
"   <pgup>   replace with a \, move up   and left,  and insert a \
"   <pgdn>   replace with a /, move down and left,  and insert a /
"   <home>   replace with a /, move up   and right, and insert a /
"   \>       fat arrowhead pointing right
"   \<       fat arrowhead pointing left
"   \^       fat arrowhead pointing up
"   \v       fat arrowhead pointing down
"
" Although a backslash is shown, actually <Leader> is used, so the
" user may specify the desired leader
"   \a : draw arrow from corners of visual-block selected region
"   \b : draw box on visual-block selected region
"   \e : draw an ellipse on visual-block selected region
"   \f : flood a region (boundaries composed of b:di... characters)
"   \h : holer : query user for qty, append qty of textwidth-spaced lines under cursor
"   \l : draw line from corners of visual-block selected region
"   \s : spacer: appends spaces up to the textwidth (default: 78)
"
" History:
"  02/21/03 : included flood function
"  12/11/02 : deletes trailing whitespace only if holer used
"   8/27/02 : fat arrowheads included
"           : shift-arrow keys move but don't modify

" Exit quickly when DrawIt has already been completely loaded or when 'compatible' is set
if &cp
 finish
endif
if exists("s:loaded_drawit")
 if s:loaded_drawit == 2
  finish
 endif
endif

" Deferred Loading (aka QuickLoad) Support
if !exists("s:loaded_drawit")
 let s:loaded_drawit= 1

 " DrChip menu support:
 if has("gui_running") && has("menu")
  if !exists("g:DrChipTopLvlMenu")
   let g:DrChipTopLvlMenu= "DrChip."
  endif
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Start\ DrawIt<tab>\\di		<Leader>di'
 endif

 " Temporary Public Interface
 if !hasmapto('<Plug>StartDrawIt')
   map <unique> <Leader>di <Plug>LoadDrawIt
 endif
 map <silent> <script> <Plug>LoadDrawIt  :set lz<CR>:call <SID>LoadDrawIt()<CR>:set nolz<CR>

" ---------------------------------------------------------------------
 " LoadDrawIt: this routine loads the rest of DrawIt
 fu! <SID>LoadDrawIt()
   runtime! plugin/DrawIt.vim
   let s:loaded_drawit= 2
   map <silent> <Leader>di <Plug>StartDrawIt
   set lz
   call <SID>StartDrawIt()
   set nolz
 endfunction
 finish
endif
" ---------------------------------------------------------------------

" Public Interface:
if !hasmapto('<Plug>StopDrawIt')
  map <unique> <Leader>ds <Plug>StopDrawIt
endif

" Global Maps:
map <silent> <script> <Plug>StartDrawIt  :set lz<CR>:call <SID>StartDrawIt()<CR>:set nolz<CR>
map <silent> <script> <Plug>StopDrawIt   :set lz<CR>:call <SID>StopDrawIt()<CR>:set nolz<CR>

" =====================================================================
" DrawIt Routines (Charles E. Campbell, Jr.)

" ---------------------------------------------------------------------

" StartDrawIt: this function maps the cursor keys, sets up default
"              drawing characters, and makes some settings
function! <SID>StartDrawIt()
  if exists("b:dodrawit") && b:dodrawit == 1
   " already in DrawIt mode
    echo "[DrawIt]"
   return
  endif
  let b:dodrawit= 1

  " indicate in DrawIt mode
  echo "[DrawIt]"

  " set up default drawing characters
  if !exists("b:di_vert")
   let b:di_vert= "|"
  endif
  if !exists("b:di_horiz")
   let b:di_horiz= "-"
  endif
  if !exists("b:di_plus")
   let b:di_plus= "+"
  endif
  if !exists("b:di_upright")		" also downleft
   let b:di_upright= "/"
  endif
  if !exists("b:di_upleft")	" also downright
   let b:di_upleft= "\\"
  endif
  if !exists("b:di_cross")
   let b:di_cross= "X"
  endif

  " set up initial DrawIt behavior (as opposed to erase behavior)
  let b:di_erase= 0

  " option recording
  let b:aikeep = &ai
  let b:cinkeep= &cin
  let b:cpokeep= &cpo
  let b:etkeep = &et
  let b:gdkeep = &gd
  let b:sikeep = &si
  let b:stakeep= &sta
  let b:vekeep = &ve
  let b:gokeep = &go
  set nocin noai nosi nogd sta et ve=""
  set go-=aA
  set cpo&vim

  " save and unmap user maps
  let b:restoremap = ""
  let b:lastdir    = 1
  if exists("mapleader")
   let usermaplead  = mapleader
  else
   let usermaplead  = "\\"
  endif
  call <SID>SaveMap("n","","><^v")
  call <SID>SaveMap("v",usermaplead,"abefls")
  call <SID>SaveMap("n",usermaplead,"h><v^")
  call <SID>SaveMap("n","","<left>")
  call <SID>SaveMap("n","","<right>")
  call <SID>SaveMap("n","","<up>")
  call <SID>SaveMap("n","","<down>")
  call <SID>SaveMap("n","","<s-left>")
  call <SID>SaveMap("n","","<s-right>")
  call <SID>SaveMap("n","","<s-up>")
  call <SID>SaveMap("n","","<s-down>")
  call <SID>SaveMap("n","","<space>")
  call <SID>SaveMap("n","","<home>")
  call <SID>SaveMap("n","","<end>")
  call <SID>SaveMap("n","","<pageup>")
  call <SID>SaveMap("n","","<pagedown>")
  call <SID>SaveMap("n","","<s-leftmouse>")
  call <SID>SaveMap("n","","<LeftDrag>")
  let amap="\<c-v>"
  if maparg(amap,"n") != ""
   let b:restoremap= "nmap ".amap.amap." ".maparg(amap,"n")."|".b:restoremap
   exe "nunmap ".amap
  endif

  " DrawIt maps (Charles Campbell)
  nmap <silent> <left>     :set lz<CR>:silent! call <SID>DrawLeft()<CR>:set nolz<CR>
  nmap <silent> <right>    :set lz<CR>:silent! call <SID>DrawRight()<CR>:set nolz<CR>
  nmap <silent> <up>       :set lz<CR>:silent! call <SID>DrawUp()<CR>:set nolz<CR>
  nmap <silent> <down>     :set lz<CR>:silent! call <SID>DrawDown()<CR>:set nolz<CR>
  nmap <silent> <s-left>   :set lz<CR>:silent! call <SID>MoveLeft()<CR>:set nolz<CR>
  nmap <silent> <s-right>  :set lz<CR>:silent! call <SID>MoveRight()<CR>:set nolz<CR>
  nmap <silent> <s-up>     :set lz<CR>:silent! call <SID>MoveUp()<CR>:set nolz<CR>
  nmap <silent> <s-down>   :set lz<CR>:silent! call <SID>MoveDown()<CR>:set nolz<CR>
  nmap <silent> <space>    :set lz<CR>:silent! call <SID>DrawErase()<CR>:set nolz<CR>
  nmap <silent> >          :set lz<CR>:silent! call <SID>DrawSpace('>',1)<CR>:set nolz<CR>
  nmap <silent> <          :set lz<CR>:silent! call <SID>DrawSpace('<',2)<CR>:set nolz<CR>
  nmap <silent> ^          :set lz<CR>:silent! call <SID>DrawSpace('^',3)<CR>:set nolz<CR>
  nmap <silent> v          :set lz<CR>:silent! call <SID>DrawSpace('v',4)<CR>:set nolz<CR>
  nmap <silent> <home>     :set lz<CR>:silent! call <SID>DrawSlantUpLeft()<CR>:set nolz<CR>
  nmap <silent> <end>      :set lz<CR>:silent! call <SID>DrawSlantDownLeft()<CR>:set nolz<CR>
  nmap <silent> <pageup>   :set lz<CR>:silent! call <SID>DrawSlantUpRight()<CR>:set nolz<CR>
  nmap <silent> <pagedown> :set lz<CR>:silent! call <SID>DrawSlantDownRight()<CR>:set nolz<CR>
  nmap <silent> <Leader>>	:set lz<CR>:silent! call <SID>DrawFatRArrow()<CR>:set nolz<CR>
  nmap <silent> <Leader><	:set lz<CR>:silent! call <SID>DrawFatLArrow()<CR>:set nolz<CR>
  nmap <silent> <Leader>^	:set lz<CR>:silent! call <SID>DrawFatUArrow()<CR>:set nolz<CR>
  nmap <silent> <Leader>v	:set lz<CR>:silent! call <SID>DrawFatDArrow()<CR>:set nolz<CR>
  nmap <silent> <Leader>f  :call <SID>Flood()<cr>

  " set up drawing mode mappings (Sylvain Viart)
  nnoremap <silent> <c-v>      :call <SID>Drag_start()<CR><c-v>
  vmap     <silent> <Leader>a  :<c-u>call <SID>Call_corner('Arrow')<CR>
  vmap     <silent> <Leader>b  :<c-u>call <SID>Call_corner('Box')<cr>
  vmap     <silent> <Leader>e  :<c-u>call <SID>Call_corner('Ellipse')<CR>
  nmap              <Leader>h  :call <SID>Holer()<cr>
  vmap     <silent> <Leader>l  :<c-u>call <SID>Call_corner('DrawPlainLine')<CR>
  vmap     <silent> <Leader>s  :<c-u>call <SID>Spacer(line("'<"), line("'>"))<cr>

  " mouse maps  (Sylvain Viart)
  " start visual-block with s-LastMouse
  nnoremap <silent>  <s-leftmouse> <leftmouse><c-v>
  noremap  <silent>  <LeftDrag>    <LeftDrag>:<c-u>call <SID>Drag_start()<cr>

 " Menu support
 if has("gui_running") && has("menu")
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Start\ DrawIt'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Stop\ \ DrawIt<tab>\\ds				<Leader>ds'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Toggle\ Erase\ Mode<tab><space>	<space>'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Arrow<tab>\\a					<Leader>a'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Box<tab>\\b						<Leader>b'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Ellipse<tab>\\e					<Leader>e'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Flood<tab>\\e					<Leader>f'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Line<tab>\\l						<Leader>l'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Make\ Blank\ Zone<tab>\\h			<Leader>h'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Append\ Blanks<tab>\\s				<Leader>s'
 endif
endfunction

" ---------------------------------------------------------------------

" StopDrawIt: this function unmaps the cursor keys and restores settings
function! <SID>StopDrawIt()
  if !exists("b:dodrawit")
   echo "[DrawIt off]"
   return
  endif
  unlet b:dodrawit
  echo "[DrawIt off]"

  if exists("b:drawit_holer_used")
   " clean up trailing white space
   call s:DI_SavePosn()
   silent! %s/\s\+$//e
   unlet b:drawit_holer_used
   call s:DI_RestorePosn()
  endif

  " unmap DrawIt map interface
  nunmap <left>
  nunmap <right>
  nunmap <up>
  nunmap <down>
  nunmap <s-left>
  nunmap <s-right>
  nunmap <s-up>
  nunmap <s-down>
  nunmap <space>
  nunmap <
  nunmap >
  nunmap v
  nunmap ^
  nunmap <Leader><
  nunmap <Leader>>
  nunmap <Leader>v
  nunmap <Leader>^
  nunmap <home>
  nunmap <end>
  nunmap <pageup>
  nunmap <pagedown>
  nunmap <Leader>f

  " remove drawing mode maps
  vunmap <Leader>a
  vunmap <Leader>b
  vunmap <Leader>e
  nunmap <Leader>h
  vunmap <Leader>l
  vunmap <Leader>s
  nunmap <s-leftmouse>
  nunmap <c-v>

  " restore user map(s), if any
  if b:restoremap != ""
   exe b:restoremap
   unlet b:restoremap
  endif

  " restore user's options
  let &ai = b:aikeep
  let &cin= b:cinkeep
  let &cpo= b:cpokeep
  let &et = b:etkeep
  let &gd = b:gdkeep
  let &go = b:gokeep
  let &si = b:sikeep
  let &sta= b:stakeep
  let &ve = b:vekeep
  unlet b:aikeep
  unlet b:cinkeep
  unlet b:etkeep
  unlet b:sikeep
  unlet b:stakeep
  unlet b:vekeep

 " DrChip menu support:
 if has("gui_running") && has("menu")
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Stop\ \ DrawIt'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Toggle\ Erase\ Mode'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Arrow'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Box'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Ellipse'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Line'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Make\ Blank\ Zone'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Append\ Blanks'
  exe 'menu   '.g:DrChipTopLvlMenu.'DrawIt.Start\ DrawIt<tab>\\di		<Leader>di'
 endif
endfunction

" ---------------------------------------------------------------------

" SaveMap: this function sets up a buffer-variable (b:restoremap)
"          which will be used by StopDrawIt to restore user maps
"          mapchx: either <something>  which is handled as one map item
"                  or a string of single letters which are multiple maps
"                  ex.  mapchx="abc" and maplead='\': \a \b and \c are saved
fu! <SID>SaveMap(mapmode,maplead,mapchx)
  if strpart(a:mapchx,0,1) == '<'
   " save single map <something>
   if maparg(a:mapchx,a:mapmode) != ""
     let b:restoremap= a:mapmode."map ".a:mapchx." ".maparg(a:mapchx,a:mapmode)."|".b:restoremap
     exe a:mapmode."unmap ".a:mapchx
    endif
  else
   " save multiple maps
   let i= 1
   while i <= strlen(a:mapchx)
    let amap=a:maplead.strpart(a:mapchx,i-1,1)
    if maparg(amap,a:mapmode) != ""
     let b:restoremap= a:mapmode."map ".amap." ".maparg(amap,a:mapmode)."|".b:restoremap
     exe a:mapmode."unmap ".amap
    endif
    let i= i + 1
   endwhile
  endif
endfunction

" ---------------------------------------------------------------------

" SetDrawIt: this function allows one to change the drawing characters
function! SetDrawIt(di_vert,di_horiz,di_plus,di_upleft,di_upright,di_cross)
  let b:di_vert    = a:di_vert
  let b:di_horiz   = a:di_horiz
  let b:di_plus    = a:di_plus
  let b:di_upleft  = a:di_upleft
  let b:di_upright = a:di_upright
  let b:di_cross   = a:di_cross
endfunction

" =====================================================================

" DrawLeft:
function! <SID>DrawLeft()
  let curline   = getline(".")
  let curcol    = col(".")
  let b:lastdir = 2

  if curcol > 0
    let curchar= strpart(curline,curcol-1,1)

    " replace
   if curchar == b:di_vert || curchar == b:di_plus
     exe "norm! r".b:di_plus
   else
     exe "norm! r".b:di_horiz
   endif

   " move and replace
   if curcol >= 2
    call s:MoveLeft()
    let curchar= strpart(curline,curcol-2,1)
    if curchar == b:di_vert || curchar == b:di_plus
     exe "norm! r".b:di_plus
    else
     exe "norm! r".b:di_horiz
    endif
   endif
  endif
endfunction

" ---------------------------------------------------------------------

" DrawRight:
function! <SID>DrawRight()
  let curline   = getline(".")
  let curcol    = col(".")
  let b:lastdir = 1

  " replace
  if curcol == col("$")
   exe "norm! a".b:di_horiz."\<Esc>"
  else
    let curchar= strpart(curline,curcol-1,1)
    if curchar == b:di_vert || curchar == b:di_plus
     exe "norm! r".b:di_plus
    else
     exe "norm! r".b:di_horiz
    endif
  endif

  " move and replace
  call s:MoveRight()
  if curcol == col("$")
   exe "norm! i".b:di_horiz."\<Esc>"
  else
   let curchar= strpart(curline,curcol,1)
   if curchar == b:di_vert || curchar == b:di_plus
    exe "norm! r".b:di_plus
   else
    exe "norm! r".b:di_horiz
   endif
  endif
endfunction

" ---------------------------------------------------------------------

" DrawUp:
function! <SID>DrawUp()
  let curline   = getline(".")
  let curcol    = col(".")
  let b:lastdir = 3

  " replace
  if curcol == 1 && col("$") == 1
   exe "norm! i".b:di_vert."\<Esc>"
  else
   let curchar= strpart(curline,curcol-1,1)
   if curchar == b:di_horiz || curchar == b:di_plus
    exe "norm! r".b:di_plus
   else
    exe "norm! r".b:di_vert
   endif
  endif

  " move and replace/insert
  call s:MoveUp()
  let curline= getline(".")
  let curchar= strpart(curline,curcol-1,1)

  if     curcol == 1 && col("$") == 1
   exe "norm! i".b:di_vert."\<Esc>"
  elseif curchar == b:di_horiz || curchar == b:di_plus
   exe "norm! r".b:di_plus
  else
   exe "norm! r".b:di_vert
   endif
  endif
endfunction

" ---------------------------------------------------------------------

" DrawDown:
function! <SID>DrawDown()
  let curline   = getline(".")
  let curcol    = col(".")
  let b:lastdir = 4

  " replace
  if curcol == 1 && col("$") == 1
   exe "norm! i".b:di_vert."\<Esc>"
  else
    let curchar= strpart(curline,curcol-1,1)
    if curchar == b:di_horiz || curchar == b:di_plus
     exe "norm! r".b:di_plus
    else
     exe "norm! r".b:di_vert
    endif
  endif

  " move and replace/insert
  call s:MoveDown()
  let curline= getline(".")
  let curchar= strpart(curline,curcol-1,1)
  if     curcol == 1 && col("$") == 1
   exe "norm! i".b:di_vert."\<Esc>"
  elseif curchar == b:di_horiz || curchar == b:di_plus
   exe "norm! r".b:di_plus
  else
   exe "norm! r".b:di_vert
  endif
endfunction

" ---------------------------------------------------------------------

" DrawErase: toggle [DrawIt on] and [DrawIt erase] modes
function! <SID>DrawErase()
  if b:di_erase == 0
   let b:di_erase= 1
   echo "[DrawIt erase]"
   let b:di_vert_save    = b:di_vert
   let b:di_horiz_save   = b:di_horiz
   let b:di_plus_save    = b:di_plus
   let b:di_upright_save = b:di_upright
   let b:di_upleft_save  = b:di_upleft
   let b:di_cross_save   = b:di_cross
   call SetDrawIt(' ',' ',' ',' ',' ',' ')
  else
   let b:di_erase= 0
   echo "[DrawIt]"
   call SetDrawIt(b:di_vert_save,b:di_horiz_save,b:di_plus_save,b:di_upleft_save,b:di_upright_save,b:di_cross_save)
  endif
endfunction

" ---------------------------------------------------------------------

" DrawSpace: clear character and move right
function! <SID>DrawSpace(chr,dir)
  let curcol= col(".")

  " replace current location with arrowhead/space
  if curcol == col("$")-1
   exe "norm! r".a:chr
  else
   exe "norm! r".a:chr
  endif

  if a:dir == 0
   let dir= b:lastdir
  else
   let dir= a:dir
  endif

  " perform specified move
  if dir == 1
   call s:MoveRight()
  elseif dir == 2
   call s:MoveLeft()
  elseif dir == 3
   call s:MoveUp()
  else
   call s:MoveDown()
  endif
endfunction

" ---------------------------------------------------------------------

" DrawSlantDownLeft: /
function! <SID>DrawSlantDownLeft()
  call s:ReplaceDownLeft()		" replace
  call s:MoveDown()				" move
  call s:MoveLeft()				" move
  call s:ReplaceDownLeft()		" replace
endfunction

" ---------------------------------------------------------------------

" DrawSlantDownRight: \
function! <SID>DrawSlantDownRight()
  call s:ReplaceDownRight()	" replace
  call s:MoveDown()				" move
  call s:MoveRight()				" move
  call s:ReplaceDownRight()	" replace
endfunction

" ---------------------------------------------------------------------

" DrawSlantUpLeft: \
function! <SID>DrawSlantUpLeft()
  call s:ReplaceDownRight()	" replace
  call s:MoveUp()					" move
  call s:MoveLeft()				" move
  call s:ReplaceDownRight()	" replace
endfunction

" ---------------------------------------------------------------------

" DrawSlantUpRight: /
function! <SID>DrawSlantUpRight()
  call s:ReplaceDownLeft()		" replace
  call s:MoveUp()					" move
  call s:MoveRight()				" replace
  call s:ReplaceDownLeft()		" replace
endfunction

" ---------------------------------------------------------------------

" MoveLeft:
fu! <SID>MoveLeft()
  norm! h
  let b:lastdir= 2
endfunction

" ---------------------------------------------------------------------

" MoveRight:
fu! <SID>MoveRight()
  if col(".") >= col("$") - 1
   exe "norm! A \<Esc>"
  else
   norm! l
  endif
  let b:lastdir= 1
endfunction

" ---------------------------------------------------------------------

" MoveUp:
fu! <SID>MoveUp()
  if line(".") == 1
   let curcol= col(".") - 1
   if curcol == 0 && col("$") == 1
     exe "norm! i \<Esc>"
   elseif curcol == 0
     exe "norm! YP:s/./ /ge\<CR>0r "
   else
     exe "norm! YP:s/./ /ge\<CR>0".curcol."lr "
   endif
  else
   let curcol= col(".")
   norm! k
   while col("$") <= curcol
     exe "norm! A \<Esc>"
   endwhile
  endif
  let b:lastdir= 3
endfunction

" ---------------------------------------------------------------------

" MoveDown:
fu! <SID>MoveDown()
  if line(".") == line("$")
   let curcol= col(".") - 1
   if curcol == 0 && col("$") == 1
    exe "norm! i \<Esc>"
   elseif curcol == 0
    exe "norm! Yp:s/./ /ge\<CR>0r "
   else
    exe "norm! Yp:s/./ /ge\<CR>0".curcol."lr "
   endif
  else
   let curcol= col(".")
   norm! j
   while col("$") <= curcol
    exe "norm! A \<Esc>"
   endwhile
  endif
  let b:lastdir= 4
endfunction

" ---------------------------------------------------------------------

" ReplaceDownLeft: / X  (upright)
fu! <SID>ReplaceDownLeft()
  let curcol = col(".")
  if curcol != col("$")
   let curchar= strpart(getline("."),curcol-1,1)
   if curchar == "\\" || curchar == "X"
    exe "norm! r".b:di_cross
   else
    exe "norm! r".b:di_upright
   endif
  else
   exe "norm! i".b:di_upright."\<Esc>"
  endif
endfunction

" ---------------------------------------------------------------------

" ReplaceDownRight: \ X  (upleft)
fu! <SID>ReplaceDownRight()
  let curcol = col(".")
  if curcol != col("$")
   let curchar= strpart(getline("."),curcol-1,1)
   if curchar == "/" || curchar == "X"
    exe "norm! r".b:di_cross
   else
    exe "norm! r".b:di_upleft
   endif
  else
   exe "norm! i".b:di_upleft."\<Esc>"
  endif
endfunction

" ---------------------------------------------------------------------

" DrawFatRArrow: ----|>
fu! <SID>DrawFatRArrow()
  call s:MoveRight()
  norm! r|
  call s:MoveRight()
  norm! r>
endfunction

" ---------------------------------------------------------------------

" DrawFatLArrow: <|----
fu! <SID>DrawFatLArrow()
  call s:MoveLeft()
  norm! r|
  call s:MoveLeft()
  norm! r<
endfunction

" ---------------------------------------------------------------------
"                 .
" DrawFatUArrow: /_\
"                 |
fu! <SID>DrawFatUArrow()
  call s:MoveUp()
  norm! r_
  call s:MoveRight()
  norm! r\
  call s:MoveLeft()
  call s:MoveLeft()
  norm! r/
  call s:MoveRight()
  call s:MoveUp()
  norm! r.
endfunction

" ---------------------------------------------------------------------

" DrawFatDArrow: _|_
"                \ /
"                 '
fu! <SID>DrawFatDArrow()
  call s:MoveRight()
  norm! r_
  call s:MoveLeft()
  call s:MoveLeft()
  norm! r_
  call s:MoveDown()
  norm! r\
  call s:MoveRight()
  call s:MoveRight()
  norm! r/
  call s:MoveDown()
  call s:MoveLeft()
  norm! r'
endfunction

" =====================================================================

" DrawEllipse: Bresenham-like ellipse drawing algorithm
"      2   2      can
"     x   y       be             2 2   2 2   2 2
"     - + - = 1   rewritten     b x + a y = a b
"     a   b       as
"
"     Take step which has minimum error
"     (x,y-1)  (x+1,y)  (x+1,y-1)
"
"             2 2   2 2   2 2
"     Ei = | b x + a y - a b |
"
"     Algorithm only draws arc from (0,b) to (a,0) and uses
"     DrawFour() to reflect points to other three quadrants
func! <SID>Ellipse(x0,y0,x1,y1)
   let x0   = a:x0
   let y0   = a:y0
   let x1   = a:x1
   let y1   = a:y1
   let xoff = (x0+x1)/2
   let yoff = (y0+y1)/2
   let a    = <SID>Abs(x1-x0)/2
   let b    = <SID>Abs(y1-y0)/2
   let a2   = a*a
   let b2   = b*b
   let twoa2= a2 + a2
   let twob2= b2 + b2

   let xi= 0
   let yi= b
   let ei= 0
   call <SID>DrawFour(xi,yi,xoff,yoff,a,b)
   while xi <= a && yi >= 0

      let dy= a2 - twoa2*yi
      let ca= ei + twob2*xi + b2
      let cb= ca + dy
      let cc= ei + dy

      let aca= <SID>Abs(ca)
      let acb= <SID>Abs(cb)
      let acc= <SID>Abs(cc)

      " pick case: (xi+1,yi) (xi,yi-1) (xi+1,yi-1)
      if aca <= acb && aca <= acc
         let xi= xi + 1
         let ei= ca
      elseif acb <= aca && acb <= acc
         let ei= cb
         let xi= xi + 1
         let yi= yi - 1
      else
         let ei= cc
         let yi= yi - 1
      endif
      if xi > a:x1
         break
      endif
      call <SID>DrawFour(xi,yi,xoff,yoff,a,b)
   endw
endf

" ---------------------------------------------------------------------

" DrawFour: reflect a point to four quadrants
func! <SID>DrawFour(x,y,xoff,yoff,a,b)
   let x  = a:xoff + a:x
   let y  = a:yoff + a:y
   let lx = a:xoff - a:x
   let by = a:yoff - a:y
   call <SID>SetCharAt('*',  x, y)
   call <SID>SetCharAt('*', lx, y)
   call <SID>SetCharAt('*', lx,by)
   call <SID>SetCharAt('*',  x,by)
endf

" =====================================================================
"  Drawing Routines (Sylvain VIART)

" fill end of line with space until textwidth.
func! <SID>Spacer(debut, fin)
   let l   = a:debut
   let max = &textwidth
   if max <= 0
      let max= 78
   endif
   while l <= a:fin
      let content = getline(l)
      let long    = strlen(content)
      let i       = long
      let space   = ''
      while i < max
         let space = space . ' '
         let i     = i + 1
      endw
      call setline(l, content.space)
      let l = l + 1
   endw
endf

" ---------------------------------------------------------------------

func! <SID>Holer()
   let nb = input("how many lines under the cursor? ")
   exe "norm ".nb."o\e"
   let fin = line('.')
   call <SID>Spacer(fin-nb+1, fin)
   exe "norm ".(nb-1)."k"
   let b:drawit_holer_used= 1
endf

" ---------------------------------------------------------------------

func! <SID>Box(x0, y0, x1, y1)
   " loop each line
   let l = a:y0
   while l <= a:y1
      let c = a:x0
      while c <= a:x1
         if l == a:y0 || l == a:y1
            let remp = '-'
            if c == a:x0 || c == a:x1
               let remp = '+'
            endif
         else
            let remp = '|'
            if c != a:x0 && c != a:x1
               let remp = '.'
            endif
         endif

         if remp != '.'
            call <SID>SetCharAt(remp, c, l)
         endif
         let c  = c + 1
      endw
      let l = l + 1
   endw
endf

" ---------------------------------------------------------------------

" SetCharAt: set the character at the specified position (must exist)
func! <SID>SetCharAt(char, x, y)
   let content = getline(a:y)
   let long    = strlen(content)
   let deb     = strpart(content, 0, a:x - 1)
   let fin     = strpart(content, a:x, long)
   call setline(a:y, deb.a:char.fin)
endf

" ---------------------------------------------------------------------

" Bresenham line-drawing algorithm
" taken from :
" http://www.graphics.lcs.mit.edu/~mcmillan/comp136/Lecture6/Lines.html
func! <SID>DrawLine(x0, y0, x1, y1, horiz)

   if ( a:x0 < a:x1 && a:y0 > a:y1 ) || ( a:x0 > a:x1 && a:y0 > a:y1 )
     " swap direction
     let x0   = a:x1
     let y0   = a:y1
     let x1   = a:x0
     let y1   = a:y0
   else
     let x0 = a:x0
     let y0 = a:y0
     let x1 = a:x1
     let y1 = a:y1
   endif
   let dy = y1 - y0
   let dx = x1 - x0

   if dy < 0
      let dy    = -dy
      let stepy = -1
   else
      let stepy = 1
   endif

   if dx < 0
      let dx    = -dx
      let stepx = -1
   else
      let stepx = 1
   endif

   let dy = 2*dy
   let dx = 2*dx

   if dx > dy
      " move under x
      let char = a:horiz
      call <SID>SetCharAt(char, x0, y0)
      let fraction = dy - (dx / 2)  " same as 2*dy - dx
      while x0 != x1
         let char = a:horiz
         if fraction >= 0
            if stepx > 0
               let char = '\'
            else
               let char = '/'
            endif
            let y0 = y0 + stepy
            let fraction = fraction - dx    " same as fraction -= 2*dx
         endif
         let x0 = x0 + stepx
         let fraction = fraction + dy	" same as fraction = fraction - 2*dy
         call <SID>SetCharAt(char, x0, y0)
      endw
   else
      " move under y
      let char = '|'
      call <SID>SetCharAt(char, x0, y0)
      let fraction = dx - (dy / 2)
      while y0 != y1
         let char = '|'
         if fraction >= 0
            if stepy > 0 || stepx < 0
               let char = '\'
            else
               let char = '/'
            endif
            let x0 = x0 + stepx
            let fraction = fraction - dy
         endif
         let y0 = y0 + stepy
         let fraction = fraction + dx
         call <SID>SetCharAt(char, x0, y0)
      endw
   endif
endf

" ---------------------------------------------------------------------

" Arrow:
func! <SID>Arrow(x0, y0, x1, y1)
   call <SID>DrawLine(a:x0, a:y0, a:x1, a:y1,'-')

   let dy = a:y1 - a:y0
   let dx = a:x1 - a:x0
   if <SID>Abs(dx) > <SID>Abs(dy)
      " move x
      if dx > 0
         call <SID>SetCharAt('>', a:x1, a:y1)
      else
         call <SID>SetCharAt('<', a:x1, a:y1)
      endif
   else
      " move y
      if dy > 0
         call <SID>SetCharAt('v', a:x1, a:y1)
      else
         call <SID>SetCharAt('^', a:x1, a:y1)
      endif
   endif
endf

" ---------------------------------------------------------------------

" Abs: return absolute value
func! <SID>Abs(val)
   if a:val < 0
      return - a:val
   else
      return a:val
   endif
endf

" ---------------------------------------------------------------------

" Drag_start: Read visual drag mapping
" The visual start point is saved in b:x_drag and b:y_drag
" The event <LeftDrag> is sent when the window is resized,
" we must disable this feature
func! <SID>Drag_start()
   if visualmode() != "\<c-v>"
	 exe "norm! \<c-v>"
	endif
   silent! unmap <LeftDrag>
   let b:x_drag    = col('.')
   let b:y_drag    = line('.')
   let b:winheight = winheight(0)
   noremap <LeftRelease> <LeftRelease>:<c-u>call <SID>Drag_end()<cr>
endf!

" ---------------------------------------------------------------------

" Drag_end:
func! <SID>Drag_end()
   unmap <LeftRelease>
   noremap <LeftDrag> <LeftDrag>:<c-u>call <SID>Drag_start()<cr>
   if b:winheight == winheight(0)
      norm gv
   endif
endf

" ---------------------------------------------------------------------

" Call_corner: call the specified function with the corner position of
" the current visual selection.
func! <SID>Call_corner(func_name)
   let xdep = b:x_drag
   let ydep = b:y_drag

   let x0 = col("'<")
   let y0 = line("'<")
   let x1 = col("'>")
   let y1 = line("'>")

   if x1 == xdep && y1 ==ydep
      let x1 = x0
      let y1 = y0
      let x0 = xdep
      let y0 = ydep
   endif

"   echo a:func_name.": ".xdep.','.ydep.','.x0.','.y0.','.x1.','.y1
   exe "call <SID>".a:func_name."(".x0.','.y0.','.x1.','.y1.")"

   let b:x_drag= 0
   let b:y_drag= 0
endf

" ---------------------------------------------------------------------

" DrawPlainLine:
func! <SID>DrawPlainLine(x0,y0,x1,y1)
   exe "call <SID>DrawLine(".a:x0.','.a:y0.','.a:x1.','.a:y1.',"_")'
endf

" ---------------------------------------------------------------------

" DI_SavePosn: saves position of cursor on screen so NetWrite can restore it
function! s:DI_SavePosn()
  " Save current line and column
  let b:drawit_line = line(".")
  let b:drawit_col  = col(".") - 1

  " Save top-of-screen line
  norm! H
  let b:drawit_hline= line(".")

  call s:DI_RestorePosn()
endfunction

" ------------------------------------------------------------------------

" DI_RestorePosn:
fu! s:DI_RestorePosn()
  " restore top-of-screen line
  exe "norm! ".b:drawit_hline."G0z\<CR>"

  " restore position
  if b:drawit_col == 0
   exe "norm! ".b:drawit_line."G0"
  else
   exe "norm! ".b:drawit_line."G0".b:drawit_col."l"
  endif
endfunction

" ------------------------------------------------------------------------

" Flood: this function begins a flood of a region
"        based on b:di... characters as boundaries
"        and starting at the current cursor location.
fu! <SID>Flood()
  let s:bndry  = b:di_vert.b:di_horiz.b:di_plus.b:di_upright.b:di_upleft.b:di_cross
  let row      = line(".")
  let col      = virtcol(".")
  let athold   = @0
  let s:DIrows = line("$")
  call s:DI_SavePosn()

  " get fill character from user
  " Put entire fillchar string into the s:bndry (boundary characters),
  " although only use the first such character for filling
  call inputsave()
  let s:fillchar= input("Enter fill character: ")
  call inputrestore()
  let s:bndry= "[".escape(s:bndry.s:fillchar,'\-]^')."]"
  if strlen(s:fillchar) > 1
   let s:fillchar= strpart(s:fillchar,0,1)
  endif

  " flood the region
  call s:DI_Flood(row,col)

  " restore
  call s:DI_RestorePosn()
  let @0= athold
  unlet s:DIrows s:bndry s:fillchar
endfunction

" ------------------------------------------------------------------------

" DI_Flood: fill up to the boundaries all characters to the left and right.
"           Then, based on the left/right column extents reached, check
"           adjacent rows to see if any characters there need filling.
fu! <SID>DI_Flood(frow,fcol)
  if a:frow <= 0 || a:fcol <= 0 || s:DI_Posn(a:frow,a:fcol) || s:IsBoundary(a:frow,a:fcol)
   return
  endif

  " fill current line
  let colL= s:DI_FillLeft(a:frow,a:fcol)
  let colR= s:DI_FillRight(a:frow,a:fcol+1)

  " do a filladjacent on the next line up
  if a:frow > 1
   call s:DI_FillAdjacent(a:frow-1,colL,colR)
  endif

  " do a filladjacent on the next line down
  if a:frow < s:DIrows
   call s:DI_FillAdjacent(a:frow+1,colL,colR)
  endif

endfunction

" ------------------------------------------------------------------------

"  DI_FillLeft: Starting at (frow,fcol), non-boundary locations are
"               filled with the fillchar.  The leftmost extent reached
"               is returned.
fu! <SID>DI_FillLeft(frow,fcol)
  if s:DI_Posn(a:frow,a:fcol)
   return a:fcol
  endif

  let Lcol= a:fcol
  while Lcol >= 1
   if !s:IsBoundary(a:frow,Lcol)
    exe  "silent! norm! r".s:fillchar."h"
   else
    break
   endif
   let Lcol= Lcol - 1
  endwhile

 let Lcol= (Lcol < 1)? 1 : Lcol + 1
 return Lcol
endfunction

" ---------------------------------------------------------------------

"  DI_FillRight: Starting at (frow,fcol), non-boundary locations are
"                filled with the fillchar.  The rightmost extent reached
"                is returned.
fu! <SID>DI_FillRight(frow,fcol)
  if s:DI_Posn(a:frow,a:fcol)
   return a:fcol
  endif

  let Rcol   = a:fcol
  while Rcol <= virtcol("$")
   if !s:IsBoundary(a:frow,Rcol)
    exe "silent! norm! r".s:fillchar."l"
   else
    break
   endif
   let Rcol= Rcol + 1
  endwhile

  let DIcols = virtcol("$")
  let Rcol   = (Rcol > DIcols)? DIcols : Rcol - 1
  return Rcol
endfunction

" ---------------------------------------------------------------------

"  DI_FillAdjacent:
"     DI_Flood does FillLeft and FillRight, so the run from left to right
"    (fcolL to fcolR) is known to have been filled.  FillAdjacent is called
"    from (fcolL to fcolR) on the lines one row up and down; if any character
"    on the run is not a boundary character, then a flood is needed on that
"    location.
fu! <SID>DI_FillAdjacent(frow,fcolL,fcolR)
  let icol  = a:fcolL
  while icol <= a:fcolR
	if !s:IsBoundary(a:frow,icol)
	 call s:DI_Flood(a:frow,icol)
	endif
   let icol= icol + 1
  endwhile
endfunction

" ---------------------------------------------------------------------

" DI_Posn: put cursor into given position on screen
"    srow,scol: -s-creen    row and column
"   Returns  1 : failed sanity check
"            0 : otherwise
fu! <SID>DI_Posn(row,col)
  " sanity checks
  if a:row < 1
   return 1
  endif
  if a:col < 1
   return 1
  endif
  exe "norm! ".a:row."G".a:col."\<Bar>"
  return 0
endfunction

" ---------------------------------------------------------------------

" IsBoundary: returns 0 if not on boundary, 1 if on boundary
"             The "boundary" also includes the fill character.
fu! <SID>IsBoundary(row,col)
  let orow= line(".")
  let ocol= virtcol(".")
  exe "norm! ".a:row."G".a:col."\<Bar>"
  norm! vy
  let ret= @0 =~ s:bndry
  if a:row != orow || a:col != ocol
   exe "norm! ".orow."G".ocol."\<Bar>"
  endif
  return ret
endfunction

" ------------------------------------------------------------------------
" vim: set ts=3 sw=3:
