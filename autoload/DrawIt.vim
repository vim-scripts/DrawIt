" DrawIt.vim: a simple way to draw things in Vim -- just put this file in
"
" Maintainer:	Charles E. Campbell, Jr.  (Charles.E.Campbell.1@gsfc.nasa.gov)
" Authors:	Charles E. Campbell, Jr. (NdrchipO@ScampbellPfamily.AbizM - NOSPAM)
"   		Sylvain Viart (molo@multimania.com)
" Version:	7
" Date:		Apr 10, 2006
"
" Quick Setup: {{{1
"              tar -oxvf DrawIt.tar
"              Should put DrawItPlugin.vim in your .vim/plugin directory,
"                     put DrawIt.vim       in your .vim/autoload directory
"                     put DrawIt.txt       in your .vim/doc directory.
"             Then, use \di to start DrawIt,
"                       \ds to stop  Drawit, and
"                       draw by simply moving about using the cursor keys.
"
"             You may also use visual-block mode to select endpoints and
"             draw lines, arrows, and ellipses.
"
" Copyright:    Copyright (C) 1999-2005 Charles E. Campbell, Jr. {{{1
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               DrawIt.vim is provided *as is* and comes with no warranty
"               of any kind, either expressed or implied. By using this
"               plugin, you agree that in no event will the copyright
"               holder be liable for any damages resulting from the use
"               of this software.
"
" Required:		THIS SCRIPT REQUIRES VIM 7.0 (or later) {{{1
" GetLatestVimScripts: 40 1 :AutoInstall: DrawIt.vim
" GetLatestVimScripts: 1066 1 cecutil.vim
"
"  Woe to her who is rebellious and polluted, the oppressing {{{1
"  city! She didn't obey the voice. She didn't receive correction.
"  She didn't trust in Yahweh. She didn't draw near to her God. (Zeph 3:1,2 WEB)

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_DrawIt")
 finish
endif
let s:keepcpo= &cpo
set cpo&vim

" ---------------------------------------------------------------------
"  Script Variables: {{{1
if !exists("s:saveposn_count")
 let s:saveposn_count= 0
endif
let g:loaded_DrawIt= "v7"

" =====================================================================
" Drawit Functions: (by Charles E. Campbell, Jr.) {{{1
" =====================================================================

" ---------------------------------------------------------------------
" StartDrawIt: this function maps the cursor keys, sets up default {{{2
"              drawing characters, and makes some settings
fun! DrawIt#StartDrawIt()
"  call Dfunc("StartDrawIt()")

  " report on [DrawIt] mode {{{3
  if exists("b:dodrawit") && b:dodrawit == 1
   " already in DrawIt mode
    if exists("mapleader") && mapleader != ""
     let usermaplead= mapleader
    else
     let usermaplead= '\'
    endif
    echo "[DrawIt] (already on, use ".usermaplead."ds to stop)"
"   call Dret("StartDrawIt")
   return
  endif
  let b:dodrawit= 1

  " indicate in DrawIt mode
  echo "[DrawIt]"

  " turn on mouse {{{3
  if !exists("b:drawit_keep_mouse")
   let b:drawit_keep_mouse= &mouse
  endif
  set mouse=a

  " set up DrawIt commands
  com! -nargs=1 -range SetBrush <line1>,<line2>call DrawIt#SetBrush(<q-args>)

  " set up default drawing characters {{{3
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

  " option recording {{{3
  let b:di_aikeep    = &ai
  let b:di_cinkeep   = &cin
  let b:di_cpokeep   = &cpo
  let b:di_etkeep    = &et
  let b:di_fokeep    = &fo
  let b:di_gdkeep    = &gd
  let b:di_gokeep    = &go
  let b:di_magickeep = &magic
  let b:di_remapkeep = &remap
  let b:di_repkeep   = &report
  let b:di_sikeep    = &si
  let b:di_stakeep   = &sta
  let b:di_vekeep    = &ve
  set cpo&vim
  set nocin noai nosi nogd sta et ve="" report=10000
  set go-=aA
  set fo-=a
  set remap magic

  " save and unmap user maps {{{3
  let b:lastdir    = 1
  if exists("mapleader")
   let usermaplead  = mapleader
  else
   let usermaplead  = "\\"
  endif
  call SaveUserMaps("n","","><^v","DrawIt")
  call SaveUserMaps("v",usermaplead,"abeflsy","DrawIt")
  call SaveUserMaps("n",usermaplead,"h><v^","DrawIt")
  call SaveUserMaps("n","","<left>","DrawIt")
  call SaveUserMaps("n","","<right>","DrawIt")
  call SaveUserMaps("n","","<up>","DrawIt")
  call SaveUserMaps("n","","<down>","DrawIt")
  call SaveUserMaps("n","","<left>","DrawIt")
  call SaveUserMaps("n","","<s-right>","DrawIt")
  call SaveUserMaps("n","","<s-up>","DrawIt")
  call SaveUserMaps("n","","<s-down>","DrawIt")
  call SaveUserMaps("n","","<space>","DrawIt")
  call SaveUserMaps("n","","<home>","DrawIt")
  call SaveUserMaps("n","","<end>","DrawIt")
  call SaveUserMaps("n","","<pageup>","DrawIt")
  call SaveUserMaps("n","","<pagedown>","DrawIt")
  call SaveUserMaps("n","","<leftmouse>","DrawIt")
  call SaveUserMaps("n","","<middlemouse>","DrawIt")
  call SaveUserMaps("n","","<rightmouse>","DrawIt")
  call SaveUserMaps("n","","<leftdrag>","DrawIt")
  call SaveUserMaps("n","","<s-leftmouse>","DrawIt")
  call SaveUserMaps("n","","<s-leftdrag>","DrawIt")
  call SaveUserMaps("n","","<s-leftrelease>","DrawIt")
  call SaveUserMaps("n",usermaplead,"pa","DrawIt")
  call SaveUserMaps("n",usermaplead,"pb","DrawIt")
  call SaveUserMaps("n",usermaplead,"pc","DrawIt")
  call SaveUserMaps("n",usermaplead,"pd","DrawIt")
  call SaveUserMaps("n",usermaplead,"pe","DrawIt")
  call SaveUserMaps("n",usermaplead,"pf","DrawIt")
  call SaveUserMaps("n",usermaplead,"pg","DrawIt")
  call SaveUserMaps("n",usermaplead,"ph","DrawIt")
  call SaveUserMaps("n",usermaplead,"pi","DrawIt")
  call SaveUserMaps("n",usermaplead,"pj","DrawIt")
  call SaveUserMaps("n",usermaplead,"pk","DrawIt")
  call SaveUserMaps("n",usermaplead,"pl","DrawIt")
  call SaveUserMaps("n",usermaplead,"pm","DrawIt")
  call SaveUserMaps("n",usermaplead,"pn","DrawIt")
  call SaveUserMaps("n",usermaplead,"po","DrawIt")
  call SaveUserMaps("n",usermaplead,"pp","DrawIt")
  call SaveUserMaps("n",usermaplead,"pq","DrawIt")
  call SaveUserMaps("n",usermaplead,"pr","DrawIt")
  call SaveUserMaps("n",usermaplead,"ps","DrawIt")
  call SaveUserMaps("n",usermaplead,"pt","DrawIt")
  call SaveUserMaps("n",usermaplead,"pu","DrawIt")
  call SaveUserMaps("n",usermaplead,"pv","DrawIt")
  call SaveUserMaps("n",usermaplead,"pw","DrawIt")
  call SaveUserMaps("n",usermaplead,"px","DrawIt")
  call SaveUserMaps("n",usermaplead,"py","DrawIt")
  call SaveUserMaps("n",usermaplead,"pz","DrawIt")
  call SaveUserMaps("n",usermaplead,"ra","DrawIt")
  call SaveUserMaps("n",usermaplead,"rb","DrawIt")
  call SaveUserMaps("n",usermaplead,"rc","DrawIt")
  call SaveUserMaps("n",usermaplead,"rd","DrawIt")
  call SaveUserMaps("n",usermaplead,"re","DrawIt")
  call SaveUserMaps("n",usermaplead,"rf","DrawIt")
  call SaveUserMaps("n",usermaplead,"rg","DrawIt")
  call SaveUserMaps("n",usermaplead,"rh","DrawIt")
  call SaveUserMaps("n",usermaplead,"ri","DrawIt")
  call SaveUserMaps("n",usermaplead,"rj","DrawIt")
  call SaveUserMaps("n",usermaplead,"rk","DrawIt")
  call SaveUserMaps("n",usermaplead,"rl","DrawIt")
  call SaveUserMaps("n",usermaplead,"rm","DrawIt")
  call SaveUserMaps("n",usermaplead,"rn","DrawIt")
  call SaveUserMaps("n",usermaplead,"ro","DrawIt")
  call SaveUserMaps("n",usermaplead,"rp","DrawIt")
  call SaveUserMaps("n",usermaplead,"rq","DrawIt")
  call SaveUserMaps("n",usermaplead,"rr","DrawIt")
  call SaveUserMaps("n",usermaplead,"rs","DrawIt")
  call SaveUserMaps("n",usermaplead,"rt","DrawIt")
  call SaveUserMaps("n",usermaplead,"ru","DrawIt")
  call SaveUserMaps("n",usermaplead,"rv","DrawIt")
  call SaveUserMaps("n",usermaplead,"rw","DrawIt")
  call SaveUserMaps("n",usermaplead,"rx","DrawIt")
  call SaveUserMaps("n",usermaplead,"ry","DrawIt")
  call SaveUserMaps("n",usermaplead,"rz","DrawIt")
  if exists("g:drawit_insertmode") && g:drawit_insertmode
   call SaveUserMaps("i","","<left>","DrawIt")
   call SaveUserMaps("i","","<right>","DrawIt")
   call SaveUserMaps("i","","<up>","DrawIt")
   call SaveUserMaps("i","","<down>","DrawIt")
   call SaveUserMaps("i","","<left>","DrawIt")
   call SaveUserMaps("i","","<s-right>","DrawIt")
   call SaveUserMaps("i","","<s-up>","DrawIt")
   call SaveUserMaps("i","","<s-down>","DrawIt")
   call SaveUserMaps("i","","<home>","DrawIt")
   call SaveUserMaps("i","","<end>","DrawIt")
   call SaveUserMaps("i","","<pageup>","DrawIt")
   call SaveUserMaps("i","","<pagedown>","DrawIt")
   call SaveUserMaps("i","","<leftmouse>","DrawIt")
  endif
  call SaveUserMaps("n","",":\<c-v>","DrawIt")

  " DrawIt maps (Charles Campbell) {{{3
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

  " Set up insertmode maps {{{3
  if exists("g:drawit_insertmode") && g:drawit_insertmode
   imap <silent> <left>     <Esc><left>a
   imap <silent> <right>    <Esc><right>a
   imap <silent> <up>       <Esc><up>a
   imap <silent> <down>     <Esc><down>a
   imap <silent> <left>   <Esc><left>a
   imap <silent> <s-right>  <Esc><s-right>a
   imap <silent> <s-up>     <Esc><s-up>a
   imap <silent> <s-down>   <Esc><s-down>a
   imap <silent> <home>     <Esc><home>a
   imap <silent> <end>      <Esc><end>a
   imap <silent> <pageup>   <Esc><pageup>a
   imap <silent> <pagedown> <Esc><pagedown>a
  endif

  " set up drawing mode mappings (Sylvain Viart) {{{3
"  nnoremap <silent> <c-v>      :call <SID>LeftStart()<CR><c-v>
  nnoremap <silent> <c-v>      :call <SID>LeftStart()<CR><c-v>
  vmap     <silent> <Leader>a  :<c-u>call <SID>Call_corner('Arrow')<CR>
  vmap     <silent> <Leader>b  :<c-u>call <SID>Call_corner('Box')<cr>
  nmap              <Leader>h  :call <SID>Holer()<cr>
  vmap     <silent> <Leader>l  :<c-u>call <SID>Call_corner('DrawPlainLine')<CR>
  vmap     <silent> <Leader>s  :<c-u>call <SID>Spacer(line("'<"), line("'>"))<cr>

  " set up drawing mode mappings (Charles Campbell) {{{3
  " \pa ... \pb : blanks are transparent
  " \ra ... \rb : blanks copy over
  vmap <silent> <Leader>e   :<c-u>call <SID>Call_corner('Ellipse')<CR>
  
  let allreg= "abcdefghijklmnopqrstuvwxyz"
  while strlen(allreg) > 0
   let ireg= strpart(allreg,0,1)
   exe "nmap <silent> <Leader>p".ireg.'  :<c-u>set lz<cr>:silent! call <SID>PutBlock("'.ireg.'",0)<cr>:set nolz<cr>'
   exe "nmap <silent> <Leader>r".ireg.'  :<c-u>set lz<cr>:silent! call <SID>PutBlock("'.ireg.'",1)<cr>:set nolz<cr>'
   let allreg= strpart(allreg,1)
  endwhile

  " mouse maps  (Sylvain Viart) {{{3
  " start visual-block with leftmouse
  nnoremap <silent> <leftmouse>    <leftmouse>:call <SID>LeftStart()<CR><c-v>
  vnoremap <silent> <rightmouse>   <leftmouse>:<c-u>call <SID>RightStart(1)<cr>
  vnoremap <silent> <middlemouse>  <leftmouse>:<c-u>call <SID>RightStart(0)<cr>

  " mouse maps (Charles Campbell) {{{3
  " Draw with current brush
  nnoremap <silent> <s-leftmouse>  <leftmouse>:call <SID>SLeftStart()<CR><c-v>

 " Menu support {{{3
 if has("gui_running") && has("menu") && &go =~ 'm'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Stop\ \ DrawIt<tab>\\ds				<Leader>ds'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Toggle\ Erase\ Mode<tab><space>	<space>'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Arrow<tab>\\a					<Leader>a'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Box<tab>\\b						<Leader>b'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Ellipse<tab>\\e					<Leader>e'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Flood<tab>\\e					<Leader>f'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Line<tab>\\l						<Leader>l'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Make\ Blank\ Zone<tab>\\h			<Leader>h'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Append\ Blanks<tab>\\s				<Leader>s'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Start\ DrawIt'
 endif
" call Dret("StartDrawIt")
endfun

" ---------------------------------------------------------------------
" StopDrawIt: this function unmaps the cursor keys and restores settings {{{2
fun! DrawIt#StopDrawIt()
"  call Dfunc("StopDrawIt()")
 
  " report on [DrawIt off] mode {{{3
  if !exists("b:dodrawit")
   echo "[DrawIt off]"
"   call Dret("StopDrawIt")
   return
  endif

  " restore mouse {{{3
  if exists("b:drawit_keep_mouse")
   let &mouse= b:drawit_keep_mouse
   unlet b:drawit_keep_mouse
  endif
  unlet b:dodrawit
  echo "[DrawIt off]"

  if exists("b:drawit_holer_used")
   " clean up trailing white space
   call s:SavePosn()
   silent! %s/\s\+$//e
   unlet b:drawit_holer_used
   call s:RestorePosn()
  endif

  " remove drawit commands {{{3
  delc SetBrush

  " insure that erase mode is off {{{3
  " (thanks go to Gary Johnson for this)
  if b:di_erase == 1
  	call s:DrawErase()
  endif

  " restore user map(s), if any {{{3
  call RestoreUserMaps("DrawIt")

  " restore user's options {{{3
  let &ai     = b:di_aikeep
  let &cin    = b:di_cinkeep
  let &cpo    = b:di_cpokeep
  let &et     = b:di_etkeep
  let &fo     = b:di_fokeep
  let &gd     = b:di_gdkeep
  let &go     = b:di_gokeep
  let &magic  = b:di_magickeep
  let &remap  = b:di_remapkeep
  let &report = b:di_repkeep
  let &si     = b:di_sikeep
  let &sta    = b:di_stakeep
  let &ve     = b:di_vekeep
  unlet b:di_aikeep  
  unlet b:di_cinkeep 
  unlet b:di_cpokeep 
  unlet b:di_etkeep  
  unlet b:di_fokeep  
  unlet b:di_gdkeep  
  unlet b:di_gokeep  
  unlet b:di_magickeep
  unlet b:di_remapkeep
  unlet b:di_repkeep
  unlet b:di_sikeep  
  unlet b:di_stakeep 
  unlet b:di_vekeep  

 " DrChip menu support: {{{3
 if has("gui_running") && has("menu") && &go =~ 'm'
  exe 'menu   '.g:DrChipTopLvlMenu.'DrawIt.Start\ DrawIt<tab>\\di		<Leader>di'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Stop\ \ DrawIt'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Toggle\ Erase\ Mode'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Arrow'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Box'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Ellipse'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Flood'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Line'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Make\ Blank\ Zone'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Append\ Blanks'
 endif
" call Dret("StopDrawIt")
endfun

" ---------------------------------------------------------------------
" SetDrawIt: this function allows one to change the drawing characters {{{2
fun! SetDrawIt(di_vert,di_horiz,di_plus,di_upleft,di_upright,di_cross)
"  call Dfunc("SetDrawIt(vert<".a:di_vert."> horiz<".a:di_horiz."> plus<".a:di_plus."> upleft<".a:di_upleft."> upright<".a:di_upright."> cross<".a:di_cross.">)")
  let b:di_vert    = a:di_vert
  let b:di_horiz   = a:di_horiz
  let b:di_plus    = a:di_plus
  let b:di_upleft  = a:di_upleft
  let b:di_upright = a:di_upright
  let b:di_cross   = a:di_cross
"  call Dret("SetDrawIt")
endfun

" =====================================================================
" DrawLeft: {{{2
fun! s:DrawLeft()
"  call Dfunc("DrawLeft()")
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
"  call Dret("DrawLeft")
endfun

" ---------------------------------------------------------------------
" DrawRight: {{{2
fun! s:DrawRight()
"  call Dfunc("DrawRight()")
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
"  call Dret("DrawRight")
endfun

" ---------------------------------------------------------------------
" DrawUp: {{{2
fun! s:DrawUp()
"  call Dfunc("DrawUp()")
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
"  call Dret("DrawUp")
endfun

" ---------------------------------------------------------------------
" DrawDown: {{{2
fun! s:DrawDown()
"  call Dfunc("DrawDown()")
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
"  call Dret("DrawDown")
endfun

" ---------------------------------------------------------------------
" DrawErase: toggle [DrawIt on] and [DrawIt erase] modes {{{2
fun! s:DrawErase()
"  call Dfunc("DrawErase() b:di_erase=".b:di_erase)
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
"  call Dret("DrawErase")
endfun

" ---------------------------------------------------------------------
" DrawSpace: clear character and move right {{{2
fun! s:DrawSpace(chr,dir)
"  call Dfunc("DrawSpace(chr<".a:chr."> dir<".a:dir.">)")
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
"  call Dret("DrawSpace")
endfun

" ---------------------------------------------------------------------
" DrawSlantDownLeft: / {{{2
fun! s:DrawSlantDownLeft()
"  call Dfunc("DrawSlantDownLeft()")
  call s:ReplaceDownLeft()		" replace
  call s:MoveDown()				" move
  call s:MoveLeft()				" move
  call s:ReplaceDownLeft()		" replace
"  call Dret("DrawSlantDownLeft")
endfun

" ---------------------------------------------------------------------
" DrawSlantDownRight: \ {{{2
fun! s:DrawSlantDownRight()
"  call Dfunc("DrawSlantDownRight()")
  call s:ReplaceDownRight()	" replace
  call s:MoveDown()			" move
  call s:MoveRight()		" move
  call s:ReplaceDownRight()	" replace
"  call Dret("DrawSlantDownRight")
endfun

" ---------------------------------------------------------------------
" DrawSlantUpLeft: \ {{{2
fun! s:DrawSlantUpLeft()
"  call Dfunc("DrawSlantUpLeft()")
  call s:ReplaceDownRight()	" replace
  call s:MoveUp()			" move
  call s:MoveLeft()			" move
  call s:ReplaceDownRight()	" replace
"  call Dret("DrawSlantUpLeft")
endfun

" ---------------------------------------------------------------------
" DrawSlantUpRight: / {{{2
fun! s:DrawSlantUpRight()
"  call Dfunc("DrawSlantUpRight()")
  call s:ReplaceDownLeft()	" replace
  call s:MoveUp()			" move
  call s:MoveRight()		" replace
  call s:ReplaceDownLeft()	" replace
"  call Dret("DrawSlantUpRight")
endfun

" ---------------------------------------------------------------------
" MoveLeft: {{{2
fun! s:MoveLeft()
"  call Dfunc("MoveLeft()")
  norm! h
  let b:lastdir= 2
"  call Dret("MoveLeft : b:lastdir=".b:lastdir)
endfun

" ---------------------------------------------------------------------
" MoveRight: {{{2
fun! s:MoveRight()
"  call Dfunc("MoveRight()")
  if col(".") >= col("$") - 1
   exe "norm! A \<Esc>"
  else
   norm! l
  endif
  let b:lastdir= 1
"  call Dret("MoveRight : b:lastdir=".b:lastdir)
endfun

" ---------------------------------------------------------------------
" MoveUp: {{{2
fun! s:MoveUp()
"  call Dfunc("MoveUp()")
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
"  call Dret("MoveUp : b:lastdir=".b:lastdir)
endfun

" ---------------------------------------------------------------------
" MoveDown: {{{2
fun! s:MoveDown()
"  call Dfunc("MoveDown()")
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
"  call Dret("MoveDown : b:lastdir=".b:lastdir)
endfun

" ---------------------------------------------------------------------
" ReplaceDownLeft: / X  (upright) {{{2
fun! s:ReplaceDownLeft()
"  call Dfunc("ReplaceDownLeft()")
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
"  call Dret("ReplaceDownLeft")
endfun

" ---------------------------------------------------------------------
" ReplaceDownRight: \ X  (upleft) {{{2
fun! s:ReplaceDownRight()
"  call Dfunc("ReplaceDownRight()")
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
"  call Dret("ReplaceDownRight")
endfun

" ---------------------------------------------------------------------
" DrawFatRArrow: ----|> {{{2
fun! s:DrawFatRArrow()
"  call Dfunc("DrawFatRArrow()")
  call s:MoveRight()
  norm! r|
  call s:MoveRight()
  norm! r>
"  call Dret("DrawFatRArrow")
endfun

" ---------------------------------------------------------------------
" DrawFatLArrow: <|---- {{{2
fun! s:DrawFatLArrow()
"  call Dfunc("DrawFatLArrow()")
  call s:MoveLeft()
  norm! r|
  call s:MoveLeft()
  norm! r<
"  call Dret("DrawFatLArrow")
endfun

" ---------------------------------------------------------------------
"                 .
" DrawFatUArrow: /_\ {{{2
"                 |
fun! s:DrawFatUArrow()
"  call Dfunc("DrawFatUArrow()")
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
"  call Dret("DrawFatUArrow")
endfun

" ---------------------------------------------------------------------
" DrawFatDArrow: _|_ {{{2
"                \ /
"                 '
fun! s:DrawFatDArrow()
"  call Dfunc("DrawFatDArrow()")
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
"  call Dret("DrawFatDArrow")
endfun

" ---------------------------------------------------------------------
" DrawEllipse: Bresenham-like ellipse drawing algorithm {{{2
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
fun! s:Ellipse(x0,y0,x1,y1)
"  call Dfunc("Ellipse(x0=".a:x0." y0=".a:y0." x1=".a:x1." y1=".a:y1.")")
  let x0   = a:x0
  let y0   = a:y0
  let x1   = a:x1
  let y1   = a:y1
  let xoff = (x0+x1)/2
  let yoff = (y0+y1)/2
  let a    = s:Abs(x1-x0)/2
  let b    = s:Abs(y1-y0)/2
  let a2   = a*a
  let b2   = b*b
  let twoa2= a2 + a2
  let twob2= b2 + b2

  let xi= 0
  let yi= b
  let ei= 0
  call s:DrawFour(xi,yi,xoff,yoff,a,b)
  while xi <= a && yi >= 0

     let dy= a2 - twoa2*yi
     let ca= ei + twob2*xi + b2
     let cb= ca + dy
     let cc= ei + dy

     let aca= s:Abs(ca)
     let acb= s:Abs(cb)
     let acc= s:Abs(cc)

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
     call s:DrawFour(xi,yi,xoff,yoff,a,b)
  endw
"  call Dret("Ellipse")
endf

" ---------------------------------------------------------------------
" DrawFour: reflect a point to four quadrants {{{2
fun! s:DrawFour(x,y,xoff,yoff,a,b)
"  call Dfunc("DrawFour(xy[".a:x.",".a:y."] off[".a:xoff.",".a:yoff."] a=".a:a." b=".a:b.")")
  let x  = a:xoff + a:x
  let y  = a:yoff + a:y
  let lx = a:xoff - a:x
  let by = a:yoff - a:y
  call s:SetCharAt('*',  x, y)
  call s:SetCharAt('*', lx, y)
  call s:SetCharAt('*', lx,by)
  call s:SetCharAt('*',  x,by)
"  call Dret("DrawFour")
endf

" ---------------------------------------------------------------------
" SavePosn: saves position of cursor on screen so NetWrite can restore it {{{2
fun! s:SavePosn()
"  call Dfunc("SavePosn() saveposn_count=".s:saveposn_count)
  let s:saveposn_count= s:saveposn_count + 1

  " Save current line and column
  let b:drawit_line_{s:saveposn_count} = line(".")
  let b:drawit_col_{s:saveposn_count}  = col(".") - 1

  " Save top-of-screen line
  norm! H
  let b:drawit_hline_{s:saveposn_count}= line(".")

  " restore position
  exe "norm! ".b:drawit_hline_{s:saveposn_count}."G0z\<CR>"
  if b:drawit_col_{s:saveposn_count} == 0
   exe "norm! ".b:drawit_line_{s:saveposn_count}."G0"
  else
   exe "norm! ".b:drawit_line_{s:saveposn_count}."G0".b:drawit_col_{s:saveposn_count}."l"
  endif
"  call Dret("SavePosn : saveposn_count=".s:saveposn_count)
endfun

" ------------------------------------------------------------------------
" RestorePosn: {{{2
fun! s:RestorePosn()
"  call Dfunc("RestorePosn() saveposn_count=".s:saveposn_count)
  if s:saveposn_count <= 0
  	return
  endif
  " restore top-of-screen line
  exe "norm! ".b:drawit_hline_{s:saveposn_count}."G0z\<CR>"

  " restore position
  if b:drawit_col_{s:saveposn_count} == 0
   exe "norm! ".b:drawit_line_{s:saveposn_count}."G0"
  else
   exe "norm! ".b:drawit_line_{s:saveposn_count}."G0".b:drawit_col_{s:saveposn_count}."l"
  endif
  if s:saveposn_count > 0
	unlet b:drawit_hline_{s:saveposn_count}
	unlet b:drawit_line_{s:saveposn_count}
	unlet b:drawit_col_{s:saveposn_count}
   let s:saveposn_count= s:saveposn_count - 1
  endif
"  call Dret("RestorePosn : saveposn_count=".s:saveposn_count)
endfun

" ------------------------------------------------------------------------
" Flood: this function begins a flood of a region {{{2
"        based on b:di... characters as boundaries
"        and starting at the current cursor location.
fun! s:Flood()
"  call Dfunc("Flood()")

  let s:bndry  = b:di_vert.b:di_horiz.b:di_plus.b:di_upright.b:di_upleft.b:di_cross
  let row      = line(".")
  let col      = virtcol(".")
  let athold   = @0
  let s:DIrows = line("$")
  call s:SavePosn()

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
  call s:RestorePosn()
  let @0= athold
  unlet s:DIrows s:bndry s:fillchar

"  call Dret("Flood")
endfun

" ------------------------------------------------------------------------
" DI_Flood: fill up to the boundaries all characters to the left and right. {{{2
"           Then, based on the left/right column extents reached, check
"           adjacent rows to see if any characters there need filling.
fun! s:DI_Flood(frow,fcol)
"  call Dfunc("DI_Flood(frow=".a:frow." fcol=".a:fcol.")")
  if a:frow <= 0 || a:fcol <= 0 || s:SetPosn(a:frow,a:fcol) || s:IsBoundary(a:frow,a:fcol)
"   call Dret("DI_Flood")
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

"  call Dret("DI_Flood")
endfun

" ------------------------------------------------------------------------
"  DI_FillLeft: Starting at (frow,fcol), non-boundary locations are {{{2
"               filled with the fillchar.  The leftmost extent reached
"               is returned.
fun! s:DI_FillLeft(frow,fcol)
"  call Dfunc("DI_FillLeft(frow=".a:frow." fcol=".a:fcol.")")
  if s:SetPosn(a:frow,a:fcol)
"   call Dret("DI_FillLeft ".a:fcol)
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

" call Dret("DI_FillLeft ".Lcol)
 return Lcol
endfun

" ---------------------------------------------------------------------
"  DI_FillRight: Starting at (frow,fcol), non-boundary locations are {{{2
"                filled with the fillchar.  The rightmost extent reached
"                is returned.
fun! s:DI_FillRight(frow,fcol)
"  call Dfunc("DI_FillRight(frow=".a:frow." fcol=".a:fcol.")")
  if s:SetPosn(a:frow,a:fcol)
"   call Dret("DI_FillRight ".a:fcol)
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

"  call Dret("DI_FillRight ".Rcol)
  return Rcol
endfun

" ---------------------------------------------------------------------
"  DI_FillAdjacent: {{{2
"     DI_Flood does FillLeft and FillRight, so the run from left to right
"    (fcolL to fcolR) is known to have been filled.  FillAdjacent is called
"    from (fcolL to fcolR) on the lines one row up and down; if any character
"    on the run is not a boundary character, then a flood is needed on that
"    location.
fun! s:DI_FillAdjacent(frow,fcolL,fcolR)
"  call Dfunc("DI_FillAdjacent(frow=".a:frow." fcolL=".a:fcolL." fcolR=".a:fcolR.")")

  let icol  = a:fcolL
  while icol <= a:fcolR
	if !s:IsBoundary(a:frow,icol)
	 call s:DI_Flood(a:frow,icol)
	endif
   let icol= icol + 1
  endwhile

"  call Dret("DI_FillAdjacent")
endfun

" ---------------------------------------------------------------------
" SetPosn: set cursor to given position on screen {{{2
"    srow,scol: -s-creen    row and column
"   Returns  1 : failed sanity check
"            0 : otherwise
fun! s:SetPosn(row,col)
"  call Dfunc("SetPosn(row=".a:row." col=".a:col.")")
  " sanity checks
  if a:row < 1
"   call Dret("SetPosn 1")
   return 1
  endif
  if a:col < 1
"   call Dret("SetPosn 1")
   return 1
  endif

  exe "norm! ".a:row."G".a:col."\<Bar>"

"  call Dret("SetPosn 0")
  return 0
endfun

" ---------------------------------------------------------------------
" IsBoundary: returns 0 if not on boundary, 1 if on boundary {{{2
"             The "boundary" also includes the fill character.
fun! s:IsBoundary(row,col)
"  call Dfunc("IsBoundary(row=".a:row." col=".a:col.")")

  let orow= line(".")
  let ocol= virtcol(".")
  exe "norm! ".a:row."G".a:col."\<Bar>"
  norm! vy
  let ret= @0 =~ s:bndry
  if a:row != orow || a:col != ocol
   exe "norm! ".orow."G".ocol."\<Bar>"
  endif

"  call Dret("IsBoundary ".ret)
  return ret
endfun

" ---------------------------------------------------------------------
" PutBlock: puts a register's contents into the text at the current {{{2
"           cursor location
"              replace= 0: Blanks are transparent
"                     = 1: Blanks copy over
"                     = 2: Erase all drawing characters
fun! s:PutBlock(block,replace)
"  call Dfunc("PutBlock(block<".a:block."> replace=".a:replace.")")
  let keep_ve= &ve
  set ve=
  call s:SavePosn()
  exe "let block  = @".a:block
  let blocklen    = strlen(block)
  let drawit_line = line('.')
  let drawchars   = '['.escape(b:di_vert.b:di_horiz.b:di_plus.b:di_upright.b:di_upleft.b:di_cross,'\-').']'

  let iblock      = 0
  while iblock < blocklen
  	let chr= strpart(block,iblock,1)

	if char2nr(chr) == 10
	 " handle newline
	 let drawit_line= drawit_line + 1
    if b:drawit_col_{s:saveposn_count} == 0
     exe "norm! ".drawit_line."G0"
    else
     exe "norm! ".drawit_line."G0".b:drawit_col_{s:saveposn_count}."l"
    endif

	elseif a:replace == 2
	 " replace all drawing characters with blanks
	 if match(chr,drawchars) != -1
	  norm! r l
	 else
	  norm! l
	 endif

	elseif chr == ' ' && a:replace == 0
	 " allow blanks to be transparent
	 norm! l

	else
	 " usual replace character
	 exe "norm! r".chr."l"
	endif
  	let iblock = iblock + 1
  endwhile
  call s:RestorePosn()

  let &ve= keep_ve
"  call Dret("PutBlock")
endfun

" =====================================================================
"  Drawit Functions: (by Sylvain Viart) {{{1
" =====================================================================

" Spacer: fill end of line with space until textwidth. {{{2
fun! s:Spacer(debut, fin)
"  call Dfunc("Spacer(debut<".a:debut."> fin<".a:fin.">)")

  let l   = a:debut
  let max = &textwidth
  if max <= 0
     let max= &columns
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

"  call Dret("Spacer")
endf

" ---------------------------------------------------------------------
" Holer: {{{2
fun! s:Holer()
"  call Dfunc("Holer()")

  let nb = input("how many lines under the cursor? ")
  exe "norm ".nb."o\e"
  let fin = line('.')
  call s:Spacer(fin-nb+1, fin)
  exe "norm ".(nb-1)."k"
  let b:drawit_holer_used= 1

"  call Dret("Holer")
endf

" ---------------------------------------------------------------------
" Box: {{{2
fun! s:Box(x0, y0, x1, y1)
"  call Dfunc("Box(xy0[".a:x0.",".a:y0." xy1[".a:x1.",".a:y1."])")
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
            call s:SetCharAt(remp, c, l)
         endif
         let c  = c + 1
      endw
      let l = l + 1
   endw

"  call Dret("Box")
endf

" ---------------------------------------------------------------------
" SetCharAt: set the character at the specified position (must exist) {{{2
fun! s:SetCharAt(char, x, y)
"  call Dfunc("SetCharAt(char<".a:char."> xy[".a:x.",".a:y."])")

  let content = getline(a:y)
  let long    = strlen(content)
  let deb     = strpart(content, 0, a:x - 1)
  let fin     = strpart(content, a:x, long)
  call setline(a:y, deb.a:char.fin)

"  call Dret("SetCharAt")
endf

" ---------------------------------------------------------------------
" Bresenham line-drawing algorithm {{{2
" taken from :
" http://www.graphics.lcs.mit.edu/~mcmillan/comp136/Lecture6/Lines.html
fun! s:DrawLine(x0, y0, x1, y1, horiz)
"  call Dfunc("DrawLine(xy0[".a:x0.",".a:y0."] xy1[".a:x1.",".a:y1."] horiz=".a:horiz.")")

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
     call s:SetCharAt(char, x0, y0)
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
        call s:SetCharAt(char, x0, y0)
     endw
  else
     " move under y
     let char = '|'
     call s:SetCharAt(char, x0, y0)
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
        call s:SetCharAt(char, x0, y0)
     endw
  endif

"  call Dret("DrawLine")
endf

" ---------------------------------------------------------------------
" Arrow: {{{2
fun! s:Arrow(x0, y0, x1, y1)
"  call Dfunc("Arrow(xy0[".a:x0.",".a:y0."] xy1[".a:x1.",".a:y1."])")

  call s:DrawLine(a:x0, a:y0, a:x1, a:y1,'-')
  let dy = a:y1 - a:y0
  let dx = a:x1 - a:x0
  if s:Abs(dx) > <SID>Abs(dy)
     " move x
     if dx > 0
        call s:SetCharAt('>', a:x1, a:y1)
     else
        call s:SetCharAt('<', a:x1, a:y1)
     endif
  else
     " move y
     if dy > 0
        call s:SetCharAt('v', a:x1, a:y1)
     else
        call s:SetCharAt('^', a:x1, a:y1)
     endif
  endif

"  call Dret("Arrow")
endf

" ---------------------------------------------------------------------
" Abs: return absolute value {{{2
fun! s:Abs(val)
  if a:val < 0
   return - a:val
  else
   return a:val
  endif
endf

" ---------------------------------------------------------------------
" Call_corner: call the specified function with the corner position of {{{2
" the current visual selection.
fun! s:Call_corner(func_name)
"  call Dfunc("Call_corner(func_name<".a:func_name.">)")

  let xdep = b:xmouse_start
  let ydep = b:ymouse_start
  let x0   = col("'<")
  let y0   = line("'<")
  let x1   = col("'>")
  let y1   = line("'>")

  if x1 == xdep && y1 ==ydep
     let x1 = x0
     let y1 = y0
     let x0 = xdep
     let y0 = ydep
  endif

"  call Decho("exe call s:".a:func_name."(".x0.','.y0.','.x1.','.y1.")")
  exe "call s:".a:func_name."(".x0.','.y0.','.x1.','.y1.")"
  let b:xmouse_start= 0
  let b:ymouse_start= 0

"  call Dret("Call_corner")
endf

" ---------------------------------------------------------------------
" DrawPlainLine: {{{2
fun! s:DrawPlainLine(x0,y0,x1,y1)
"  call Dfunc("DrawPlainLine(xy0[".a:x0.",".a:y0."] xy1[".a:x1.",".a:y1."])")

"   call Decho("exe call s:DrawLine(".a:x0.','.a:y0.','.a:x1.','.a:y1.',"_")')
   exe "call s:DrawLine(".a:x0.','.a:y0.','.a:x1.','.a:y1.',"_")'

"  call Dret("DrawPlainLine")
endf

" =====================================================================
"  Mouse Functions: {{{1
" =====================================================================

" LeftStart: Read visual drag mapping {{{2
" The visual start point is saved in b:xmouse_start and b:ymouse_start
fun! s:LeftStart()
"  call Decho("LeftStart()")
  let b:xmouse_start = col('.')
  let b:ymouse_start = line('.')
  vnoremap <silent> <leftrelease> <leftrelease>:<c-u>call <SID>LeftRelease()<cr>
"  call Decho("LeftStart()")
endf!

" ---------------------------------------------------------------------
" LeftRelease: {{{2
fun! s:LeftRelease()
"  call Dfunc("LeftRelease()")
  vunmap <leftrelease>
  norm! gv
"  call Dret("LeftRelease")
endf

" ---------------------------------------------------------------------
" SLeftStart: begin drawing with a brush {{{2
fun! s:SLeftStart()
  if !exists("b:drawit_brush")
   let b:drawit_brush= "a"
  endif
"  call Dfunc("SLeftStart() brush=".b:drawit_brush)
  noremap <silent> <s-leftdrag>    <leftmouse>:<c-u>call <SID>SLeftDrag()<cr>
  noremap <silent> <s-leftrelease> <leftmouse>:<c-u>call <SID>SLeftRelease()<cr>
"  call Dret("SLeftStart")
endfun

" ---------------------------------------------------------------------
" SLeftDrag: {{{2
fun! s:SLeftDrag()
"  call Dfunc("SLeftDrag()")
  call s:SavePosn()
  call s:PutBlock(b:drawit_brush,0)
  call s:RestorePosn()
"  call Dret("SLeftDrag")
endfun

" ---------------------------------------------------------------------
" SLeftRelease: {{{2
fun! s:SLeftRelease()
"  call Dfunc("SLeftRelease()")
  call s:SLeftDrag()
  nunmap <s-leftdrag>
  nunmap <s-leftrelease>
"  call Dret("SLeftRelease")
endfun

" ---------------------------------------------------------------------
" DrawIt#SetBrush: {{{2
fun! DrawIt#SetBrush(brush) range
"  call Dfunc("DrawIt#SetBrush(brush<".a:brush.">)")
  let b:drawit_brush= a:brush
"  call Decho("visualmode<".visualmode()."> range[".a:firstline.",".a:lastline."] visrange[".line("'<").",".line("'>")."]")
  if visualmode() == "\<c-v>" && ((a:firstline == line("'>") && a:lastline == line("'<")) || (a:firstline == line("'<") && a:lastline == line("'>")))
   " last visual mode was visual block mode, and
   " either [firstline,lastline] == ['<,'>] or ['>,'<]
   " Assuming that SetBrush called from a visual-block selection!
   " Yank visual block into selected register (brush)
"   call Decho("yanking visual block into register ".b:drawit_brush)
   exe 'norm! gv"'.b:drawit_brush.'y'
  endif
"  call Dret("DrawIt#SetBrush : b:drawit_brush=".b:drawit_brush)
endfun

" ------------------------------------------------------------------------
" Modelines: {{{1
" vim: fdm=marker
let &cpo= s:keepcpo
unlet s:keepcpo
