" DrawIt.vim: a simple way to draw things in Vim
"
" Maintainer:	Charles E. Campbell
" Authors:		Charles E. Campbell <NdrOchipS@PcampbellAfamily.Mbiz> - NOSPAM
"   			Sylvain Viart (molo@multimania.com)
" Version:		13
" Date:			Nov 25, 2013
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
" Copyright:    Copyright (C) 1999-2012 Charles E. Campbell {{{1
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
let g:loaded_DrawIt= "v13"
if v:version < 700
 echohl WarningMsg
 echo "***warning*** this version of DrawIt needs vim 7.0"
 echohl Normal
 finish
endif
let s:keepcpo= &cpo
set cpo&vim
scriptencoding utf-8

" ---------------------------------------------------------------------
"  Script Variables: {{{1
if !exists("g:drawit_xstrlen")
 if exists("g:Align_xstrlen")
  let g:drawit_xstrlen= g:Align_xstrlen
 elseif exists("g:netrw_xstrlen")
  let g:drawit_xstrlen= g:netrw_xstrlen
 elseif &enc == "latin1" || !has("multi_byte")
  let g:drawit_xstrlen= 0
 else
  let g:drawit_xstrlen= 1
 endif
endif
if !exists("g:drawit_mode")
 let g:drawit_mode= 'N' " other options: =S (single-line utf-*,cp437) or =D (double-line utf-*,cp437)
endif
if !exists("s:saveposn_count")
 let s:saveposn_count= 0
endif
"DechoTabOn

" =====================================================================
" DrawIt Functions: (by Charles E. Campbell) {{{1
" =====================================================================

" ---------------------------------------------------------------------
" DrawIt#DrawItStart: this function maps the cursor keys, sets up default {{{2
"              drawing characters, and makes some settings
fun! DrawIt#DrawItStart(...)
"  call Dfunc("DrawItStart()")

  if a:0 > 0
   if     exists("b:di_gfxchr") && b:di_gfxchr && (a:1 == 'S' || a:1 == 's')
	DIsngl
   elseif exists("b:di_gfxchr") && b:di_gfxchr && (a:1 == 'D' || a:1 == 'd')
	DIdbl
   elseif !exists("g:drawit_mode")
	let g:drawit_mode= 'N'
   endif
  endif

  " DrawItStart: report on [DrawIt] mode {{{3
  if exists("b:dodrawit") && b:dodrawit == 1
   " already in DrawIt mode
    echo "[DrawIt] (already on, use ".((exists("mapleader") && mapleader != "")? mapleader : '\')."ds to stop)"
"   call Dret("DrawItStart")
   return
  endif
  let b:dodrawit= 1

  " indicate in DrawIt mode
  echo "[DrawIt]"

  " DrawItStart: turn on mouse {{{3
  if !exists("b:drawit_keep_mouse")
   let b:drawit_keep_mouse= &mouse
  endif
  setl mouse=a

  " DrawItStart: set up DrawIt commands {{{3
  com! -nargs=1 -range SetBrush <line1>,<line2>call DrawIt#SetBrush(<q-args>)
  com! -count Canvas call s:Spacer(line("."),line(".") + <count> - 1,0)

  " DrawItStart: set up default drawing characters {{{3
  if !exists("b:di_vert")   |let b:di_vert    = "|" |endif
  if !exists("b:di_horiz")  |let b:di_horiz   = "-" |endif
  if !exists("b:di_plus")   |let b:di_plus    = "+" |endif
  if !exists("b:di_upright")|let b:di_upright = "/" |endif  " same as downleft
  if !exists("b:di_upleft") |let b:di_upleft  = "\\"|endif  " same as downright
  if !exists("b:di_cross")  |let b:di_cross   = "X" |endif
  if !exists("b:di_ellipse")|let b:di_ellipse = '*' |endif

  let b:di_gfxchr= 1
  if &enc == 'utf-8' || &enc == 'utf-16' || &enc == "ucs-4"
   " Box drawing characters using unicode
   " │ ─ ┌ ┐ └ ┘ ┬ ┴ ├ ┤ ┼ ╱ ╲ ╳
   " ║ ═ ╔ ╗ ╚ ╝ ╦ ╩ ╠ ╣ ╬      
"   call Decho("box drawing characters using unicode")
   if !exists("b:di_Svert")   |let b:di_Svert   = '│' |endif
   if !exists("b:di_Dvert")   |let b:di_Dvert   = '║' |endif
   if !exists("b:di_Shoriz")  |let b:di_Shoriz  = '─' |endif
   if !exists("b:di_Dhoriz")  |let b:di_Dhoriz  = '═' |endif
   if !exists("b:di_Sulcorn") |let b:di_Sulcorn = '┌' |endif
   if !exists("b:di_Dulcorn") |let b:di_Dulcorn = '╔' |endif
   if !exists("b:di_Surcorn") |let b:di_Surcorn = '┐' |endif
   if !exists("b:di_Durcorn") |let b:di_Durcorn = '╗' |endif
   if !exists("b:di_Sllcorn") |let b:di_Sllcorn = '└' |endif
   if !exists("b:di_Dllcorn") |let b:di_Dllcorn = '╚' |endif
   if !exists("b:di_Slrcorn") |let b:di_Slrcorn = '┘' |endif
   if !exists("b:di_Dlrcorn") |let b:di_Dlrcorn = '╝' |endif
   if !exists("b:di_Splus")   |let b:di_Splus   = '┼' |endif
   if !exists("b:di_Dplus")   |let b:di_Dplus   = '╬' |endif
   if !exists("b:di_Sdnplus") |let b:di_Sdnplus = '┬' |endif
   if !exists("b:di_Ddnplus") |let b:di_Ddnplus = '╦' |endif
   if !exists("b:di_Supplus") |let b:di_Supplus = '┴' |endif
   if !exists("b:di_Dupplus") |let b:di_Dupplus = '╩' |endif
   if !exists("b:di_Slplus")  |let b:di_Slplus  = '┤' |endif
   if !exists("b:di_Dlplus")  |let b:di_Dlplus  = '╣' |endif
   if !exists("b:di_Srplus")  |let b:di_Srplus  = '├' |endif
   if !exists("b:di_Drplus")  |let b:di_Drplus  = '╠' |endif
   if !exists("b:di_Supright")|let b:di_Supright= "╱" |endif  " same as Sdownleft
   if !exists("b:di_Supleft") |let b:di_Supleft = "╲" |endif  " same as Sdownright
   if !exists("b:di_Scross")  |let b:di_Scross  = "╳" |endif
 
   " Mixed Single-Double unicode box drawing characters
   " ╞ ╟ ╡ ╢ ╤ ╥ ╧ ╪ ╫
   if !exists("b:di_DhSd")  |let b:di_DhSd = '╤' |endif
   if !exists("b:di_DhSu")  |let b:di_DhSu = '╧' |endif
   if !exists("b:di_DuSl")  |let b:di_DuSl = '╢' |endif
   if !exists("b:di_DuSlr") |let b:di_DuSlr= '╫' |endif
   if !exists("b:di_DuSr")  |let b:di_DuSr = '╟' |endif
   if !exists("b:di_ShDd")  |let b:di_ShDd = '╥' |endif
   if !exists("b:di_ShDu")  |let b:di_ShDu = '╨' |endif
   if !exists("b:di_SuDl")  |let b:di_SuDl = '╡' |endif
   if !exists("b:di_SuDlr") |let b:di_SuDlr= '╪' |endif
   if !exists("b:di_SdDh")  |let b:di_SdDh = '╤' |endif
   if !exists("b:di_SuDh")  |let b:di_SuDh = '╧' |endif
   if !exists("b:di_SuDr")  |let b:di_SuDr = '╞' |endif
 
   " Mixed Single-Double unicode box drawing corner characters
   " ╒ ╓ ╕ ╖ ╘ ╙ ╛ ╜
   if !exists("b:di_cSdDr")| let b:di_cSdDr= '╒'| endif
   if !exists("b:di_cDdSr")| let b:di_cDdSr= '╓'| endif
   if !exists("b:di_cDlSd")| let b:di_cDlSd= '╕'| endif
   if !exists("b:di_cSlDd")| let b:di_cSlDd= '╖'| endif
   if !exists("b:di_cDrSu")| let b:di_cDrSu= '╘'| endif
   if !exists("b:di_cSrDu")| let b:di_cSrDu= '╙'| endif
   if !exists("b:di_cDlSu")| let b:di_cDlSu= '╛'| endif
   if !exists("b:di_cSlDu")| let b:di_cSlDu= '╜'| endif

  elseif &enc == 'cp437'
   " Box drawing characters using cp437 (dos)
"   call Decho("box drawing characters using cp437")
   if !exists("b:di_Svert")   |let b:di_Svert   = nr2char(179) |endif   " │
   if !exists("b:di_Dvert")   |let b:di_Dvert   = nr2char(186) |endif   " ║
   if !exists("b:di_Shoriz")  |let b:di_Shoriz  = nr2char(196) |endif   " ─
   if !exists("b:di_Dhoriz")  |let b:di_Dhoriz  = nr2char(205) |endif   " ═
   if !exists("b:di_Sulcorn") |let b:di_Sulcorn = nr2char(218) |endif   " ┌
   if !exists("b:di_Dulcorn") |let b:di_Dulcorn = nr2char(201) |endif   " ╔
   if !exists("b:di_Surcorn") |let b:di_Surcorn = nr2char(191) |endif   " ┐
   if !exists("b:di_Durcorn") |let b:di_Durcorn = nr2char(187) |endif   " ╗
   if !exists("b:di_Sllcorn") |let b:di_Sllcorn = nr2char(192) |endif   " └
   if !exists("b:di_Dllcorn") |let b:di_Dllcorn = nr2char(200) |endif   " ╚
   if !exists("b:di_Slrcorn") |let b:di_Slrcorn = nr2char(217) |endif   " ┘
   if !exists("b:di_Dlrcorn") |let b:di_Dlrcorn = nr2char(188) |endif   " ╝
   if !exists("b:di_Splus")   |let b:di_Splus   = nr2char(197) |endif   " ┼
   if !exists("b:di_Dplus")   |let b:di_Dplus   = nr2char(206) |endif   " ╬
   if !exists("b:di_Sdnplus") |let b:di_Sdnplus = nr2char(194) |endif   " ┬
   if !exists("b:di_Ddnplus") |let b:di_Ddnplus = nr2char(203) |endif   " ╦
   if !exists("b:di_Supplus") |let b:di_Supplus = nr2char(193) |endif   " ┴
   if !exists("b:di_Dupplus") |let b:di_Dupplus = nr2char(202) |endif   " ╩
   if !exists("b:di_Slplus")  |let b:di_Slplus  = nr2char(180) |endif   " ┤
   if !exists("b:di_Dlplus")  |let b:di_Dlplus  = nr2char(185) |endif   " ╣
   if !exists("b:di_Srplus")  |let b:di_Srplus  = nr2char(195) |endif   " ├
   if !exists("b:di_Drplus")  |let b:di_Drplus  = nr2char(204) |endif   " ╠
   if !exists("b:di_Supright")|let b:di_Supright= '/'          |endif   " ╱
   if !exists("b:di_Supleft") |let b:di_Supleft = '\'          |endif   " ╲
   if !exists("b:di_Scross")  |let b:di_Scross  = 'X'          |endif   " ╳
 
   " Mixed Single-Double cp437 box drawing characters
   if !exists("b:di_DhSd")  |let b:di_DhSd = nr2char(209)|endif     " ╤
   if !exists("b:di_DhSu")  |let b:di_DhSu = nr2char(207)|endif     " ╧
   if !exists("b:di_DuSl")  |let b:di_DuSl = nr2char(182)|endif     " ╢
   if !exists("b:di_DuSlr") |let b:di_DuSlr= nr2char(215)|endif     " ╫
   if !exists("b:di_DuSr")  |let b:di_DuSr = nr2char(199)|endif     " ╟
   if !exists("b:di_ShDd")  |let b:di_ShDd = nr2char(210)|endif     " ╥
   if !exists("b:di_ShDu")  |let b:di_ShDu = nr2char(208)|endif     " ╨
   if !exists("b:di_SuDl")  |let b:di_SuDl = nr2char(181)|endif     " ╡
   if !exists("b:di_SuDlr") |let b:di_SuDlr= nr2char(216)|endif     " ╪
   if !exists("b:di_SdDh")  |let b:di_SdDh = nr2char(209)|endif     " ╤
   if !exists("b:di_SuDh")  |let b:di_SuDh = nr2char(207)|endif     " ╧
   if !exists("b:di_SuDr")  |let b:di_SuDr = nr2char(198)|endif     " ╞
 
   " Mixed Single-Double cp437 box drawing corner characters
   if !exists("b:di_cSdDr")| let b:di_cSdDr= nr2char(213)| endif    " ╒
   if !exists("b:di_cDdSr")| let b:di_cDdSr= nr2char(214)| endif    " ╓
   if !exists("b:di_cDlSd")| let b:di_cDlSd= nr2char(184)| endif    " ╕
   if !exists("b:di_cSlDd")| let b:di_cSlDd= nr2char(183)| endif    " ╖
   if !exists("b:di_cDrSu")| let b:di_cDrSu= nr2char(212)| endif    " ╘
   if !exists("b:di_cSrDu")| let b:di_cSrDu= nr2char(211)| endif    " ╙
   if !exists("b:di_cDlSu")| let b:di_cDlSu= nr2char(190)| endif    " ╛
   if !exists("b:di_cSlDu")| let b:di_cSlDu= nr2char(189)| endif    " ╜

  else
"   call Decho("regular box drawing characters only")
   let b:di_gfxchr = 0
  endif

  " set up initial DrawIt behavior (as opposed to erase behavior)
  let b:di_erase     = 0

  call s:DrawItSaveUserSettings()

  " DrawItStart: save and unmap user maps {{{3
  let b:lastdir    = 1
  if exists("mapleader")
   let usermaplead  = mapleader
  else
   let usermaplead  = "\\"
  endif
  call SaveUserMaps("bn","","><^v","DrawIt")
  call SaveUserMaps("bv",usermaplead,"abceflsy","DrawIt")
  call SaveUserMaps("bn","","<c-v>","DrawIt")
  call SaveUserMaps("bn",usermaplead,"h><v^","DrawIt")
  call SaveUserMaps("bn","","<left>","DrawIt")
  call SaveUserMaps("bn","","<right>","DrawIt")
  call SaveUserMaps("bn","","<up>","DrawIt")
  call SaveUserMaps("bn","","<down>","DrawIt")
  call SaveUserMaps("bn","","<left>","DrawIt")
  call SaveUserMaps("bn","","<s-right>","DrawIt")
  call SaveUserMaps("bn","","<s-up>","DrawIt")
  call SaveUserMaps("bn","","<s-down>","DrawIt")
  call SaveUserMaps("bn","","<space>","DrawIt")
  call SaveUserMaps("bn","","<home>","DrawIt")
  call SaveUserMaps("bn","","<end>","DrawIt")
  call SaveUserMaps("bn","","<pageup>","DrawIt")
  call SaveUserMaps("bn","","<pagedown>","DrawIt")
  call SaveUserMaps("bn","","<c-leftdrag>","DrawIt")
  call SaveUserMaps("bn","","<c-leftmouse>","DrawIt")
  call SaveUserMaps("bn","","<c-leftrelease>","DrawIt")
  call SaveUserMaps("bn","","<leftdrag>","DrawIt")
  call SaveUserMaps("bn","","<leftmouse>","DrawIt")
  call SaveUserMaps("bn","","<middlemouse>","DrawIt")
  call SaveUserMaps("bn","","<rightmouse>","DrawIt")
  call SaveUserMaps("bn","","<s-leftdrag>","DrawIt")
  call SaveUserMaps("bn","","<s-leftmouse>","DrawIt")
  call SaveUserMaps("bn","","<s-leftrelease>","DrawIt")
  call SaveUserMaps("bv","","<c-leftmouse>","DrawIt")
  call SaveUserMaps("bv","","<leftmouse>","DrawIt")
  call SaveUserMaps("bv","","<middlemouse>","DrawIt")
  call SaveUserMaps("bv","","<rightmouse>","DrawIt")
  call SaveUserMaps("bv","","<s-leftmouse>","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pa","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pb","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pc","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pd","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pe","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pf","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pg","DrawIt")
  call SaveUserMaps("bn",usermaplead,":ph","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pi","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pj","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pk","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pl","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pm","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pn","DrawIt")
  call SaveUserMaps("bn",usermaplead,":po","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pp","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pq","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pr","DrawIt")
  call SaveUserMaps("bn",usermaplead,":ps","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pt","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pu","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pv","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pw","DrawIt")
  call SaveUserMaps("bn",usermaplead,":px","DrawIt")
  call SaveUserMaps("bn",usermaplead,":py","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pz","DrawIt")
  call SaveUserMaps("bn",usermaplead,":ra","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rb","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rc","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rd","DrawIt")
  call SaveUserMaps("bn",usermaplead,":re","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rf","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rg","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rh","DrawIt")
  call SaveUserMaps("bn",usermaplead,":ri","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rj","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rk","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rl","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rm","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rn","DrawIt")
  call SaveUserMaps("bn",usermaplead,":ro","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rp","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rq","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rr","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rs","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rt","DrawIt")
  call SaveUserMaps("bn",usermaplead,":ru","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rv","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rw","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rx","DrawIt")
  call SaveUserMaps("bn",usermaplead,":ry","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rz","DrawIt")
  if exists("g:drawit_insertmode") && g:drawit_insertmode
   call SaveUserMaps("bi","","<left>","DrawIt")
   call SaveUserMaps("bi","","<right>","DrawIt")
   call SaveUserMaps("bi","","<up>","DrawIt")
   call SaveUserMaps("bi","","<down>","DrawIt")
   call SaveUserMaps("bi","","<left>","DrawIt")
   call SaveUserMaps("bi","","<s-right>","DrawIt")
   call SaveUserMaps("bi","","<s-up>","DrawIt")
   call SaveUserMaps("bi","","<s-down>","DrawIt")
   call SaveUserMaps("bi","","<home>","DrawIt")
   call SaveUserMaps("bi","","<end>","DrawIt")
   call SaveUserMaps("bi","","<pageup>","DrawIt")
   call SaveUserMaps("bi","","<pagedown>","DrawIt")
   call SaveUserMaps("bi","","<leftmouse>","DrawIt")
  endif
  call SaveUserMaps("bn","",":\<c-v>","DrawIt")

  " DrawItStart: DrawIt maps (Charles Campbell) {{{3
  nmap <silent> <buffer> <script> <left>		:set lz<CR>:silent! call <SID>DrawLeft()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <right>		:set lz<CR>:silent! call <SID>DrawRight()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <up>			:set lz<CR>:silent! call <SID>DrawUp()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <down>		:set lz<CR>:silent! call <SID>DrawDown()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <s-left>		:set lz<CR>:silent! call <SID>MoveLeft()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <s-right>		:set lz<CR>:silent! call <SID>MoveRight()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <s-up>		:set lz<CR>:silent! call <SID>MoveUp()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <s-down>		:set lz<CR>:silent! call <SID>MoveDown()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <space>		:set lz<CR>:silent! call <SID>DrawErase()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> >				:set lz<CR>:silent! call <SID>DrawSpace('>',1)<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <				:set lz<CR>:silent! call <SID>DrawSpace('<',2)<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> ^				:set lz<CR>:silent! call <SID>DrawSpace('^',3)<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> v				:set lz<CR>:silent! call <SID>DrawSpace('v',4)<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <home>		:set lz<CR>:silent! call <SID>DrawSlantUpLeft()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <end>			:set lz<CR>:silent! call <SID>DrawSlantDownLeft()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <pageup>		:set lz<CR>:silent! call <SID>DrawSlantUpRight()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <pagedown>	:set lz<CR>:silent! call <SID>DrawSlantDownRight()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <Leader>>		:set lz<CR>:silent! call <SID>DrawFatRArrow()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <Leader><		:set lz<CR>:silent! call <SID>DrawFatLArrow()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <Leader>^		:set lz<CR>:silent! call <SID>DrawFatUArrow()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <Leader>v		:set lz<CR>:silent! call <SID>DrawFatDArrow()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <Leader>f		:call <SID>Flood()<cr>

  " DrawItStart: Set up insertmode maps {{{3
  if exists("g:drawit_insertmode") && g:drawit_insertmode
   imap <silent> <buffer> <script> <left>     <Esc><left>a
   imap <silent> <buffer> <script> <right>    <Esc><right>a
   imap <silent> <buffer> <script> <up>       <Esc><up>a
   imap <silent> <buffer> <script> <down>     <Esc><down>a
   imap <silent> <buffer> <script> <left>     <Esc><left>a
   imap <silent> <buffer> <script> <s-right>  <Esc><s-right>a
   imap <silent> <buffer> <script> <s-up>     <Esc><s-up>a
   imap <silent> <buffer> <script> <s-down>   <Esc><s-down>a
   imap <silent> <buffer> <script> <home>     <Esc><home>a
   imap <silent> <buffer> <script> <end>      <Esc><end>a
   imap <silent> <buffer> <script> <pageup>   <Esc><pageup>a
   imap <silent> <buffer> <script> <pagedown> <Esc><pagedown>a
  endif

  " DrawItStart: set up drawing mode mappings (Sylvain Viart) {{{3
  nnoremap <silent> <buffer> <script> <c-v>      :call <SID>LeftStart()<CR><c-v>
  vmap     <silent> <buffer> <script> <Leader>a  :<c-u>call <SID>CallBox('Arrow')<CR>
  vmap     <silent> <buffer> <script> <Leader>b  :<c-u>call <SID>CallBox('DrawBox')<cr>
  nmap              <buffer> <script> <Leader>c  :call <SID>Canvas()<cr>
  vmap     <silent> <buffer> <script> <Leader>l  :<c-u>call <SID>CallBox('DrawPlainLine')<CR>
  vmap     <silent> <buffer> <script> <Leader>s  :<c-u>call <SID>Spacer(line("'<"), line("'>"),0)<cr>

  " DrawItStart: set up drawing mode mappings (Charles Campbell) {{{3
  " \pa ... \pz : blanks are transparent
  " \ra ... \rz : blanks copy over
  vmap <buffer> <silent> <Leader>e   :<c-u>call <SID>CallBox('DrawEllipse')<CR>
  
  let allreg= "abcdefghijklmnopqrstuvwxyz"
  while strlen(allreg) > 0
   let ireg= strpart(allreg,0,1)
   exe "nmap <silent> <buffer> <Leader>p".ireg.'  :<c-u>set lz<cr>:silent! call <SID>PutBlock("'.ireg.'",0)<cr>:set nolz<cr>'
   exe "nmap <silent> <buffer> <Leader>r".ireg.'  :<c-u>set lz<cr>:silent! call <SID>PutBlock("'.ireg.'",1)<cr>:set nolz<cr>'
   let allreg= strpart(allreg,1)
  endwhile

  " DrawItStart: mouse maps  (Sylvain Viart) {{{3
  " start visual-block with leftmouse
  nnoremap <silent> <buffer> <script> <leftmouse>    <leftmouse>:call <SID>LeftStart()<CR><c-v>
  vnoremap <silent> <buffer> <script> <rightmouse>   <leftmouse>:<c-u>call <SID>RightStart(1)<cr>
  vnoremap <silent> <buffer> <script> <middlemouse>  <leftmouse>:<c-u>call <SID>RightStart(0)<cr>
  vnoremap <silent> <buffer> <script> <c-leftmouse>  <leftmouse>:<c-u>call <SID>CLeftStart()<cr>

  " DrawItStart: mouse maps (Charles Campbell) {{{3
  " Draw with current brush
  nnoremap <silent> <buffer> <script> <s-leftmouse>  <leftmouse>:call <SID>SLeftStart()<CR><c-v>
  nnoremap <silent> <buffer> <script> <c-leftmouse>  <leftmouse>:call <SID>CLeftStart()<CR><c-v>

 " DrawItStart: Menu support {{{3
 if has("gui_running") && has("menu") && &go =~# 'm'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Stop\ \ DrawIt<tab>\\ds				<Leader>ds'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Toggle\ Erase\ Mode<tab><space>	<space>'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Arrow<tab>\\a					<Leader>a'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Box<tab>\\b						<Leader>b'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Make\ Blank\ Zone<tab>\\c			<Leader>c'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Ellipse<tab>\\e					<Leader>e'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Flood<tab>\\e					<Leader>f'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Line<tab>\\l						<Leader>l'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Append\ Blanks<tab>\\s				<Leader>s'
  exe 'silent! unmenu '.g:DrChipTopLvlMenu.'DrawIt.Start\ DrawIt'
 endif
" call Dret("DrawItStart")
endfun

" ---------------------------------------------------------------------
" DrawIt#DrawItStop: this function unmaps the cursor keys and restores settings {{{2
fun! DrawIt#DrawItStop()
"  call Dfunc("DrawItStop()")
 
  " DrawItStop: report on [DrawIt off] mode {{{3
  if !exists("b:dodrawit")
   echo "[DrawIt off]"
"   call Dret("DrawItStop")
   return
  endif

  " DrawItStop: restore mouse {{{3
  if exists("b:drawit_keep_mouse")
   let &mouse= b:drawit_keep_mouse
   unlet b:drawit_keep_mouse
  endif
  unlet b:dodrawit
  echo "[DrawIt off]"

  if exists("b:drawit_canvas_used")
   " DrawItStop: clean up trailing white space {{{3
   call s:SavePosn()
   silent! %s/\s\+$//e
   unlet b:drawit_canvas_used
   call s:RestorePosn()
  endif

  " DrawItStop: remove drawit commands {{{3
  delc SetBrush

  " DrawItStop: insure that erase mode is off {{{3
  " (thanks go to Gary Johnson for this)
  if b:di_erase == 1
  	call s:DrawErase()
  endif

  " DrawItStop: restore user map(s), if any {{{3
  call RestoreUserMaps("DrawIt")

  call s:DrawItRestoreUserSettings()

 " DrawItStop: DrChip menu support: {{{3
 if has("gui_running") && has("menu") && &go =~# 'm'
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
" call Dret("DrawItStop")
endfun

" ---------------------------------------------------------------------
" s:DrawItSaveUserSettings: saves user settings, changes them to be safe for DrawIt {{{2
"                           Use s:DrawItRestoreUserSettings() to restore.
fun! s:DrawItSaveUserSettings()
"  call Dfunc("s:DrawItSaveUserSettings()")
  " save user settings
  let b:di_aikeep    = &l:ai
  let b:di_cedit     = &cedit
  let b:di_cinkeep   = &l:cin
  let b:di_cpokeep   = &l:cpo
  let b:di_etkeep    = &l:et
  let b:di_fokeep    = &l:fo
  let b:di_gdkeep    = &l:gd
  let b:di_gokeep    = &l:go
  let b:di_magickeep = &l:magic
  let b:di_remapkeep = &l:remap
  let b:di_repkeep   = &l:report
  let b:di_sikeep    = &l:si
  let b:di_stakeep   = &l:sta
  let b:di_vekeep    = &l:ve

  " change user settings to something safe for DrawIt
  setl cpo&vim
  setl nocin noai nosi nogd sta et ve=all report=10000
  setl go-=aA
  setl fo-=a
  setl remap magic
  set  cedit&
"  call Dret("s:DrawItSaveUserSettings")
endfun

" ---------------------------------------------------------------------
" s:DrawItRestoreUserSettings: restore user settings {{{2
fun! s:DrawItRestoreUserSettings()
"  call Dfunc("s:DrawItRestoreUserSettings()")

  " restore user's settings
  let &l:ai     = b:di_aikeep
  let &l:cin    = b:di_cinkeep
  let &l:cpo    = b:di_cpokeep
  let &l:et     = b:di_etkeep
  let &l:fo     = b:di_fokeep
  let &l:gd     = b:di_gdkeep
  let &l:go     = b:di_gokeep
  let &l:magic  = b:di_magickeep
  let &l:remap  = b:di_remapkeep
  let &l:report = b:di_repkeep
  let &l:si     = b:di_sikeep
  let &l:sta    = b:di_stakeep
  let &l:ve     = b:di_vekeep
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
"  call Dret("s:DrawItRestoreUserSettings")
endfun

" ---------------------------------------------------------------------
" DrawIt#SetMode: sets normal, single, double drawing mode, and ensures that DrawIt mode is on {{{2
fun! DrawIt#SetMode(mode)
"  call Dfunc("DrawIt#SetMode(mode=".a:mode.")")
  if &enc == 'utf-8' || &enc == 'cp437' || &enc == 'utf-16' || &enc == 'ucs-4'
   let b:di_gfxchr= 1
  else
   let b:di_gfxchr= 0
  endif
  if b:di_gfxchr == 0
   let g:drawit_mode= 'N'
  elseif &enc != 'utf-8' && &enc != 'cp437' && &enc != 'utf-16' && &enc != 'ucs-4'
   let g:drawit_mode = 'N'
   let b:di_gfxchr   = 0
  elseif a:mode =~ '^[sS]$'
   let g:drawit_mode= 'S'
  elseif a:mode =~ '^[dD]$'
   let g:drawit_mode= 'D'
  else
   let g:drawit_mode = 'N'
   let b:di_gfxchr   = 0
  endif
  if !exists("b:dodrawit") || b:dodrawit == 0
   call DrawIt#DrawItStart()
  endif
"  call Dret("DrawIt#SetMode")
endfun

" ---------------------------------------------------------------------
" SetDrawIt: this function allows one to change the drawing characters {{{2
fun! SetDrawIt(di_vert,di_horiz,di_plus,di_upleft,di_upright,di_cross,di_ellipse)
"  call Dfunc("SetDrawIt(vert<".a:di_vert."> horiz<".a:di_horiz."> plus<".a:di_plus."> upleft<".a:di_upleft."> upright<".a:di_upright."> cross<".a:di_cross."> ellipse<".a:di_ellipse.">)")
  let b:di_vert    = a:di_vert
  let b:di_horiz   = a:di_horiz
  let b:di_plus    = a:di_plus
  let b:di_upleft  = a:di_upleft
  let b:di_upright = a:di_upright
  let b:di_cross   = a:di_cross
  let b:di_ellipse = a:di_ellipse
"  call Dret("SetDrawIt")
endfun

" =====================================================================
" s:DrawLeft: {{{2
fun! s:DrawLeft()
"  call Dfunc("s:DrawLeft()")
  let curline   = getline(".")
  let curcol    = virtcol(".")
  let b:lastdir = 2
  let keepatat  = @@
"  call Decho("curcol#".curcol." curline<".curline.">")

  if curcol > 0
   norm! vy
   let curchar= @@
"   call Decho("curchar<".curchar.">")
"   let curchar = strpart(curline,curcol-1,1)

   " step1: Replace
   " step2: Move and Replace
   let step= 1
   while step <= 2
"	call Decho("step#".step)

	if step == 2
	 if curcol < 2
	  break
	 endif
"	 call Decho("move and replace: curchar<".curchar."> mode<".g:drawit_mode.">")
     call s:MoveLeft()
     norm! vy
     let curchar= @@
"     call Decho("curchar<".curchar.">")
	else
"	 call Decho("replace: curchar<".curchar."> mode<".g:drawit_mode.">")
	endif

	if s:IsDrawItH(curchar)
     if g:drawit_mode == 'S'
	  exe "norm! r".b:di_Splus
	 elseif g:drawit_mode == 'D'
	  exe "norm! r".b:di_Dplus
     else
	  exe "norm! r".b:di_plus
     endif

	else

     if g:drawit_mode == 'S'
	  exe "norm! r".b:di_Shoriz
	 elseif g:drawit_mode == 'D'
	  exe "norm! r".b:di_Dhoriz
     else
	  exe "norm! r".b:di_horiz
     endif

	endif
	let step= step + 1
   endwhile

   norm! l
   call s:DrawCorner()
   norm! h
   call s:DrawCorner()
  endif
  let @@= keepatat
"  call Dret("s:DrawLeft")
endfun

" ---------------------------------------------------------------------
" s:DrawRight: {{{2
fun! s:DrawRight()
"  call Dfunc("s:DrawRight()")
  let curline   = getline(".")
  let curcol    = virtcol(".")
  let b:lastdir = 1
  let keepatat  = @@
  norm! vy
  let curchar= @@
"  call Decho("curchar<".curchar.">")

  " replace
  if curcol == virtcol("$")
   if g:drawit_mode == 'S'
    exe "norm! a".b:di_Shoriz."\<Esc>"
   elseif g:drawit_mode == 'D'
    exe "norm! a".b:di_Dhoriz."\<Esc>"
   else
    exe "norm! a".b:di_horiz."\<Esc>"
   endif
  else
   if s:IsDrawItH(curchar)
    if g:drawit_mode == 'S'
	 exe "norm! r".b:di_Splus
	elseif g:drawit_mode == 'D'
	 exe "norm! r".b:di_Dplus
    else
	 exe "norm! r".b:di_plus
    endif
   else
    if g:drawit_mode == 'S'
     exe "norm! r".b:di_Shoriz
    elseif g:drawit_mode == 'D'
     exe "norm! r".b:di_Dhoriz
    else
     exe "norm! r".b:di_horiz
    endif
   endif
  endif

  " move and replace
  call s:MoveRight()
  if curcol == virtcol("$")
   if g:drawit_mode == 'S'
    exe "norm! i".b:di_Shoriz."\<Esc>"
   elseif g:drawit_mode == 'D'
    exe "norm! i".b:di_Dhoriz."\<Esc>"
   else
    exe "norm! i".b:di_horiz."\<Esc>"
   endif
  else
   norm! vy
   let curchar= @@
"   call Decho("curchar<".curchar.">")
   if s:IsDrawItH(curchar)
    if g:drawit_mode == 'S'
	 exe "norm! r".b:di_Splus
	elseif g:drawit_mode == 'D'
	 exe "norm! r".b:di_Dplus
    else
	 exe "norm! r".b:di_plus
    endif
   else
    if g:drawit_mode == 'S'
     exe "norm! r".b:di_Shoriz
    elseif g:drawit_mode == 'D'
     exe "norm! r".b:di_Dhoriz
    else
     exe "norm! r".b:di_horiz
    endif
   endif
  endif

  norm! h
  call s:DrawCorner()
  norm! l
  call s:DrawCorner()

  let @@= keepatat
"  call Dret("s:DrawRight")
endfun

" ---------------------------------------------------------------------
" s:DrawUp: {{{2
fun! s:DrawUp()
"  call Dfunc("s:DrawUp()")
  let curline   = getline(".")
  let curcol    = virtcol(".")
  let b:lastdir = 3
  let keepatat  = @@
  norm! vy
  let curchar   = @@
"  call Decho("curchar<".curchar.">")

  " replace
  if curcol == 1 && virtcol("$") == 1
"   call Decho("case curcol#".curcol."==virtcol($): insert")
   if g:drawit_mode == 'S'
    exe "norm! i".b:di_Svert."\<Esc>"
   elseif g:drawit_mode == 'D'
    exe "norm! i".b:di_Dvert."\<Esc>"
   else
    exe "norm! i".b:di_vert."\<Esc>"
   endif
  else
"   call Decho("case curcol#".curcol."!=virtcol($) curchar<".curchar.">: replace")
   if s:IsDrawItV(curchar)
    if g:drawit_mode == 'S'
     exe "norm! r".b:di_Splus
    elseif g:drawit_mode == 'D'
     exe "norm! r".b:di_Dplus
    else
     exe "norm! r".b:di_plus
    endif
   else
    if g:drawit_mode == 'S'
     exe "norm! r".b:di_Svert
    elseif g:drawit_mode == 'D'
     exe "norm! r".b:di_Dvert
    else
     exe "norm! r".b:di_vert
    endif
   endif
  endif

  " move and replace/insert
  call s:MoveUp()
  let curline= getline(".")
"  let curchar= strpart(curline,curcol-1,1)
  norm! vy
  let curchar= @@

  if     curcol == 1 && virtcol("$") == 1
   if g:drawit_mode == 'S'
    exe "norm! i".b:di_Svert."\<Esc>"
   elseif g:drawit_mode == 'D'
    exe "norm! i".b:di_Dvert."\<Esc>"
   else
    exe "norm! i".b:di_vert."\<Esc>"
   endif
  elseif s:IsDrawItV(curchar)
    if g:drawit_mode == 'S'
     exe "norm! r".b:di_Splus
    elseif g:drawit_mode == 'D'
     exe "norm! r".b:di_Dplus
    else
     exe "norm! r".b:di_plus
    endif
  else
   if g:drawit_mode == 'S'
    exe "norm! r".b:di_Svert
   elseif g:drawit_mode == 'D'
    exe "norm! r".b:di_Dvert
   else
    exe "norm! r".b:di_vert
   endif

  endif

  norm! j
  call s:DrawCorner()
  norm! k
  call s:DrawCorner()

  let @@= keepatat
"  call Dret("s:DrawUp")
endfun

" ---------------------------------------------------------------------
" s:DrawDown: {{{2
fun! s:DrawDown()
"  call Dfunc("s:DrawDown()")
  let curline   = getline(".")
  let curcol    = virtcol(".")
  let keepatat  = @@
  norm! vy
  let curchar   = @@
"  call Decho("curchar<".curchar.">")
  let b:lastdir = 4

  " replace
  if curcol == 1 && virtcol("$") == 1
"   call Decho("curcol=".curcol." $=1"
   if g:drawit_mode == 'S'
    exe "norm! i".b:di_Svert."\<Esc>"
   elseif g:drawit_mode == 'D'
    exe "norm! i".b:di_Dvert."\<Esc>"
   else
    exe "norm! i".b:di_vert."\<Esc>"
   endif
  else
    norm! vy
    let curchar= @@
"    call Decho("curchar<".curchar.">")
	if s:IsDrawItV(curchar)
    if g:drawit_mode == 'S'
     exe "norm! r".b:di_Splus
    elseif g:drawit_mode == 'D'
     exe "norm! r".b:di_Dplus
    else
     exe "norm! r".b:di_plus
    endif
   else
    if g:drawit_mode == 'S'
     exe "norm! r".b:di_Svert
    elseif g:drawit_mode == 'D'
     exe "norm! r".b:di_Dvert
    else
     exe "norm! r".b:di_vert
    endif
   endif
  endif

  " move and replace/insert
  call s:MoveDown()
  let curline= getline(".")
  norm! vy
  let curchar= @@
"  call Decho("curchar<".curchar.">")
  if     curcol == 1 && virtcol("$") == 1
   if g:drawit_mode == 'S'
    exe "norm! i".b:di_Svert."\<Esc>"
   elseif g:drawit_mode == 'D'
    exe "norm! i".b:di_Dvert."\<Esc>"
   else
    exe "norm! i".b:di_vert."\<Esc>"
   endif
  elseif s:IsDrawItV(curchar)
    if g:drawit_mode == 'S'
     exe "norm! r".b:di_Splus
    elseif g:drawit_mode == 'D'
     exe "norm! r".b:di_Dplus
    else
     exe "norm! r".b:di_plus
    endif
  else
   if g:drawit_mode == 'S'
    exe "norm! r".b:di_Svert
   elseif g:drawit_mode == 'D'
    exe "norm! r".b:di_Dvert
   else
    exe "norm! r".b:di_vert
   endif

  endif

  norm! k
  call s:DrawCorner()
  norm! j
  call s:DrawCorner()

  let @@= keepatat
"  call Dret("s:DrawDown")
endfun

" ---------------------------------------------------------------------
" s:DrawCorner: change a ┼ or a ╬ into an appropriate corner {{{2
fun! s:DrawCorner()
"  call Dfunc("s:DrawCorner()")
  let keepatat= @@
  norm! vy
  let ctr= @@
  if ctr != b:di_Splus   && ctr != b:di_Dplus
   let @@= keepatat
"   call Dret("s:DrawCorner : ctr<".ctr.">  (quick return)")
   return
  endif

  " cleft: Grab a copy of the character to the left of the cursor
  if virtcol(".") > 1
   norm! hvyl
   let cleft= @@
  else
   let cleft= " "
  endif

  " cright: Grab a copy of the character to the right of the cursor
  if virtcol(".") < virtcol("$")
   norm! lvyh
   let cright= @@
  else
   let cright= " "
  endif

  " cup: Grab a copy of the character above the cursor
  if line(".") > 1
   norm! kvyj
   let cup= @@
  else
   let cup= " "
  endif
  
  " cdown: Grab a copy of the character below the cursor
  if line(".") < line("$")
   norm! jvyk
   let cdown= @@
  else
   let cdown= " "
  endif
"  call Decho("ctr<".ctr."> cup<".cup."> cright<".cright."> cdown<".cdown."> cleft<".cleft.">")
  " - MIXED SINGLE-DOUBLE CORNERS ----------------------------------------
  "   ┼═   ╬═      ╒═
  "   │    │       │
  if  !s:IsDnS(cup)
 \ &&  s:IsLeftD(cright)
 \ &&  s:IsUpS(cdown)
 \ && !s:IsRightD(cleft)
   exe "norm! r".b:di_cSdDr

  "   ┼─   ╬─      ╓─
  "   ║    ║       ║
  elseif  !s:IsDnD(cup)
 \ &&      s:IsLeftS(cright)
 \ &&      s:IsUpD(cdown)
 \ &&     !s:IsRightS(cleft)
   exe "norm! r".b:di_cDdSr

  "  ═┼   ═╬      ═╕
  "   │    │       │
  elseif  !s:IsDnS(cup)
 \ &&     !s:IsLeftD(cright)
 \ &&      s:IsUpS(cdown)
 \ &&      s:IsRightD(cleft)
   exe "norm! r".b:di_cDlSd

  "  ─┼   ─╬      ─╖
  "   ║    ║       ║
  elseif  !s:IsDnD(cup)
 \ &&     !s:IsLeftS(cright)
 \ &&      s:IsUpD(cdown)
 \ &&      s:IsRightS(cleft)
   exe "norm! r".b:di_cSlDd

  "   │    │       │
  "   ┼═   ╬═      ╘═
  elseif   s:IsDnS(cup)
 \ &&      s:IsLeftD(cright)
 \ &&     !s:IsUpS(cdown)
 \ &&     !s:IsRightD(cleft)
   exe "norm! r".b:di_cDrSu

  "   ║    ║       ║
  "   ┼─   ╬─      ╙─
  elseif   s:IsDnD(cup)
 \ &&      s:IsLeftS(cright)
 \ &&     !s:IsUpD(cdown)
 \ &&     !s:IsRightS(cleft)
   exe "norm! r".b:di_cSrDu

  "   │    │       │
  "  ═┼   ═╬      ═╛
  elseif   s:IsDnS(cup)
 \ &&     !s:IsLeftD(cright)
 \ &&     !s:IsUpS(cdown)
 \ &&      s:IsRightD(cleft)
   exe "norm! r".b:di_cDlSu

  "   ║    ║       ║
  "  ─┼   ─╬      ─╜
  elseif   s:IsDnD(cup)
 \ &&     !s:IsLeftS(cright)
 \ &&     !s:IsUpD(cdown)
 \ &&      s:IsRightS(cleft)
   exe "norm! r".b:di_cSlDu

  " - SINGLE LINE --------------------------------------------------------
 elseif ctr == b:di_Splus
   "   ─┼  ─┐
   "    │   │
   if  !s:IsDnS(cup)
  \ && !s:IsLeftS(cright)
  \ &&  s:IsUpS(cdown)
  \ &&  s:IsRightS(cleft)
    exe "norm! r".b:di_Surcorn

   "    ┼─  ┌─
   "    │   │
   elseif !s:IsDnS(cup)
  \    &&  s:IsLeftS(cright)
  \    &&  s:IsUpS(cdown)
  \    && !s:IsRightS(cleft)
    exe "norm! r".b:di_Sulcorn

   "    │   │
   "   ─┼  ─┘
   elseif  s:IsDnS(cup)
  \    && !s:IsLeftS(cright)
  \    && !s:IsUpS(cdown)
  \    &&  s:IsRightS(cleft)
    exe "norm! r".b:di_Slrcorn

   "   │   │
   "   ┼─  └─
   elseif  s:IsDnS(cup)
  \    &&  s:IsLeftS(cright)
  \    && !s:IsUpS(cdown)
  \    && !s:IsRightS(cleft)
    exe "norm! r".b:di_Sllcorn

   "   │   │
   "   ┼─  ├─
   "   │   │
   elseif  s:IsDnS(cup)
  \    &&  s:IsLeftS(cright)
  \    &&  s:IsUpS(cdown)
  \    && !s:IsRightS(cleft)
    exe "norm! r".b:di_Srplus

   "   │   │
   "  ─┼  ─┤
   "   │   │
   elseif  s:IsDnS(cup)
  \    && !s:IsLeftS(cright)
  \    &&  s:IsUpS(cdown)
  \    &&  s:IsRightS(cleft)
    exe "norm! r".b:di_Slplus

   "  ─┼─   ─┬─
   "   │     │ 
   elseif !s:IsDnS(cup)
  \    &&  s:IsLeftS(cright)
  \    &&  s:IsUpS(cdown)
  \    &&  s:IsRightS(cleft)
	exe "norm! r".b:di_Sdnplus

   "  ─┼─   ─╥─
   "   ║     ║ 
   elseif !s:IsDnD(cup)
  \    &&  s:IsLeftS(cright)
  \    &&  s:IsUpD(cdown)
  \    &&  s:IsRightS(cleft)
	exe "norm! r".b:di_ShDd

   "   ║     ║ 
   "  ─┼─   ─╨─
   elseif  s:IsDnD(cup)
  \    &&  s:IsLeftS(cright)
  \    && !s:IsUpD(cdown)
  \    &&  s:IsRightS(cleft)
	exe "norm! r".b:di_ShDu

   "   │     │ 
   "  ─┼─   ─┴─
   elseif  s:IsDnS(cup)
  \    &&  s:IsLeftS(cright)
  \    && !s:IsUpS(cdown)
  \    &&  s:IsRightS(cleft)
	exe "norm! r".b:di_Supplus

   "   ║     ║ 
   "   ┼─    ╟─
   "   ║     ║ 
   elseif  s:IsDnD(cup)
  \    &&  s:IsLeftS(cright)
  \    &&  s:IsUpD(cdown)
  \    && !s:IsRightS(cleft)
	exe "norm! r".b:di_DuSr

   "   ║     ║ 
   "  ─┼    ─╢
   "   ║     ║ 
   elseif  s:IsDnD(cup)
  \    && !s:IsLeftS(cright)
  \    &&  s:IsUpD(cdown)
  \    &&  s:IsRightS(cleft)
	exe "norm! r".b:di_DuSl

   "   │   │
   "   ┼═  ╞═
   "   │   │
   elseif  s:IsDnS(cup)
  \    &&  s:IsLeftD(cright)
  \    &&  s:IsUpS(cdown)
  \    && !s:IsRightD(cleft)
    exe "norm! r".b:di_SuDr

   "   │   │
   "  ═┼  ═╡
   "   │   │
   elseif  s:IsDnS(cup)
  \    && !s:IsLeftD(cright)
  \    &&  s:IsUpS(cdown)
  \    &&  s:IsRightD(cleft)
    exe "norm! r".b:di_SuDl

   "  ═┼═   ═╤═
   "   │     │ 
   elseif !s:IsDnS(cup)
  \    &&  s:IsLeftD(cright)
  \    &&  s:IsUpS(cdown)
  \    &&  s:IsRightD(cleft)
	exe "norm! r".b:di_DhSd

   "   │     │ 
   "  ═┼═   ═╧═
   elseif  s:IsDnS(cup)
  \    &&  s:IsLeftD(cright)
  \    && !s:IsUpS(cdown)
  \    &&  s:IsRightD(cleft)
	exe "norm! r".b:di_DhSu

   "   ║     ║ 
   "  ─┼─   ─╫─
   "   ║     ║ 
   elseif  s:IsDnD(cup)
  \    &&  s:IsLeftS(cright)
  \    &&  s:IsUpD(cdown)
  \    &&  s:IsRightS(cleft)
	exe "norm! r".b:di_DuSlr

   "   │     │ 
   "  ═┼═   ═╪═
   "   │     │ 
   elseif  s:IsDnS(cup)
  \    &&  s:IsLeftD(cright)
  \    &&  s:IsUpS(cdown)
  \    &&  s:IsRightD(cleft)
	exe "norm! r".b:di_SuDlr
   endif

  " - DOUBLE LINE --------------------------------------------------------
  elseif ctr == b:di_Dplus
   "   ═╬  ═╗
   "    ║   ║
   if  !s:IsDnD(cup)
  \ && !s:IsLeftD(cright)
  \ &&  s:IsUpD(cdown)
  \ &&  s:IsRightD(cleft)
    exe "norm! r".b:di_Durcorn

   "    ╬═  ╔═
   "    ║   ║
   elseif !s:IsDnD(cup)
  \    &&  s:IsLeftD(cright)
  \    &&  s:IsUpD(cdown)
  \    && !s:IsRightD(cleft)
    exe "norm! r".b:di_Dulcorn

   "    ║   ║
   "   ═╬  ═╝
   elseif  s:IsDnD(cup)
  \    && !s:IsLeftD(cright)
  \    && !s:IsUpD(cdown)
  \    &&  s:IsRightD(cleft)
    exe "norm! r".b:di_Dlrcorn

   "   ║   ║
   "   ╬═  ╚═
   elseif  s:IsDnD(cup)
  \    &&  s:IsLeftD(cright)
  \    && !s:IsUpD(cdown)
  \    && !s:IsRightD(cleft)
    exe "norm! r".b:di_Dllcorn

   "   ║   ║
   "   ╬═  ╠═
   "   ║   ║
   elseif  s:IsDnD(cup)
  \    &&  s:IsLeftD(cright)
  \    &&  s:IsUpD(cdown)
  \    && !s:IsRightD(cleft)
    exe "norm! r".b:di_Drplus

   "   ║   ║
   "  ═╬  ═╣
   "   ║   ║
   elseif  s:IsDnD(cup)
  \    && !s:IsLeftD(cright)
  \    &&  s:IsUpD(cdown)
  \    &&  s:IsRightD(cleft)
    exe "norm! r".b:di_Dlplus

   "   ║   ║
   "  ─╬  ─╢
   "   ║   ║
   elseif  s:IsDnD(cup)
  \    && !s:IsLeftD(cright)
  \    &&  s:IsUpD(cdown)
  \    &&  s:IsRightS(cleft)
    exe "norm! r".b:di_DuSl

   "   ║   ║
   "   ╬─  ╟─
   "   ║   ║
   elseif  s:IsDnD(cup)
  \    &&  s:IsLeftS(cright)
  \    &&  s:IsUpD(cdown)
  \    && !s:IsRightD(cleft)
    exe "norm! r".b:di_DuSr

   "  ═╬═   ═╦═
   "   ║     ║ 
   elseif !s:IsDnD(cup)
  \    &&  s:IsLeftD(cright)
  \    &&  s:IsUpD(cdown)
  \    &&  s:IsRightD(cleft)
	exe "norm! r".b:di_Ddnplus

   "   ║     ║ 
   "  ═╬═   ═╩═
   elseif  s:IsDnD(cup)
  \    &&  s:IsLeftD(cright)
  \    && !s:IsUpD(cdown)
  \    &&  s:IsRightD(cleft)
	exe "norm! r".b:di_Dupplus

   "   │     │ 
   "   ╬═    ╞═
   "   │     │ 
   elseif  s:IsDnS(cup)
  \    &&  s:IsLeftD(cright)
  \    &&  s:IsUpS(cdown)
  \    && !s:IsRightD(cleft)
	exe "norm! r".b:di_SuDr

   "   │     │ 
   "  ═╬    ═╡
   "   │     │ 
   elseif  s:IsDnS(cup)
  \    && !s:IsLeftD(cright)
  \    &&  s:IsUpS(cdown)
  \    &&  s:IsRightD(cleft)
	exe "norm! r".b:di_SuDl

   "  ─╬─   ─╥─
   "   ║     ║ 
   elseif !s:IsDnD(cup)
  \    &&  s:IsLeftS(cright)
  \    &&  s:IsUpD(cdown)
  \    &&  s:IsRightS(cleft)
	exe "norm! r".b:di_ShDd

   "   ║     ║ 
   "  ─╬─   ─╨─
   elseif  s:IsDnD(cup)
  \    &&  s:IsLeftS(cright)
  \    && !s:IsUpD(cdown)
  \    &&  s:IsRightS(cleft)
	exe "norm! r".b:di_ShDu

   "   │     │ 
   "  ═╬═   ═╪═
   "   │     │ 
   elseif  s:IsDnS(cup)
  \    &&  s:IsLeftD(cright)
  \    &&  s:IsUpS(cdown)
  \    &&  s:IsRightD(cleft)
	exe "norm! r".b:di_SuDlr

   "   │     │ 
   "  ═╬═   ═╨═
   elseif  s:IsDnS(cup)
  \    &&  s:IsLeftD(cright)
  \    && !s:IsUpS(cdown)
  \    &&  s:IsRightD(cleft)
    exe "norm! r".b:di_SuDh

   "  ═╬═   ═╤═
   "   │     │ 
   elseif !s:IsDnS(cup)
  \    &&  s:IsLeftD(cright)
  \    &&  s:IsUpS(cdown)
  \    &&  s:IsRightD(cleft)
    exe "norm! r".b:di_SdDh

   "   ║     ║ 
   "  ─╬─   ─╫─
   "   ║     ║ 
   elseif  s:IsDnD(cup)
  \    &&  s:IsLeftS(cright)
  \    &&  s:IsUpD(cdown)
  \    &&  s:IsRightS(cleft)
	exe "norm! r".b:di_DuSlr
   endif

  endif

  norm! vy
  let newctr= @@
  let @@= keepatat
"  call Dret("s:DrawCorner : ".((newctr != ctr)? "newctr<".newctr.">" : "unchanged"))
endfun

" ---------------------------------------------------------------------
" s:IsDrawItH: moving horizontally {{{2
fun! s:IsDrawItH(chr)
"  call Dfunc("s:IsDrawItH(chr<".a:chr.">)")
   if a:chr == b:di_vert     || a:chr == b:di_plus
"    call Dret("s:IsDrawItH 1")
    return 1
   endif
   if b:di_gfxchr == 0
"    call Dret("s:IsDrawItH 0")
    return 0
   endif
   if  a:chr == b:di_Svert   || a:chr == b:di_Dvert
  \ || a:chr == b:di_Splus   || a:chr == b:di_Dplus
  \ || a:chr == b:di_Surcorn || a:chr == b:di_Durcorn
  \ || a:chr == b:di_Slrcorn || a:chr == b:di_Dlrcorn
  \ || a:chr == b:di_Sllcorn || a:chr == b:di_Dllcorn
  \ || a:chr == b:di_Sulcorn || a:chr == b:di_Dulcorn
  \ || a:chr == b:di_Sdnplus || a:chr == b:di_Ddnplus
  \ || a:chr == b:di_Supplus || a:chr == b:di_Dupplus
  \ || a:chr == b:di_Srplus  || a:chr == b:di_Drplus
  \ || a:chr == b:di_Slplus  || a:chr == b:di_Dlplus
  \ || a:chr == b:di_DhSd    || a:chr == b:di_DhSu
  \ || a:chr == b:di_DuSl    || a:chr == b:di_DuSr
  \ || a:chr == b:di_ShDd    || a:chr == b:di_ShDu
  \ || a:chr == b:di_SuDl    || a:chr == b:di_SuDr
  \ || a:chr == b:di_DuSlr   || a:chr == b:di_SuDlr
  \ || a:chr == b:di_cSdDr   || a:chr == b:di_cSdDr
  \ || a:chr == b:di_cDdSr   || a:chr == b:di_cDdSr
  \ || a:chr == b:di_cDlSd   || a:chr == b:di_cDlSd
  \ || a:chr == b:di_cSlDd   || a:chr == b:di_cSlDd
  \ || a:chr == b:di_cDrSu   || a:chr == b:di_cDrSu
  \ || a:chr == b:di_cSrDu   || a:chr == b:di_cSrDu
  \ || a:chr == b:di_cDlSu   || a:chr == b:di_cDlSu
  \ || a:chr == b:di_cSlDu   || a:chr == b:di_cSlDu
"   call Dret("s:IsDrawItH 1")
   return 1
  endif
"  call Dret("s:IsDrawItH 0")
  return 0
endfun

" ---------------------------------------------------------------------
" s:IsDrawItV: moving vertically  {{{2
fun! s:IsDrawItV(chr)
"  call Dfunc("s:IsDrawItV(chr<".a:chr.">)")
   if a:chr == b:di_horiz   || a:chr == b:di_plus
"    call Dret("s:IsDrawItH 1")
    return 1
   endif
   if b:di_gfxchr == 0
"    call Dret("s:IsDrawItH 0")
    return 0
   endif
   if  a:chr == b:di_Shoriz  || a:chr == b:di_Dhoriz
  \ || a:chr == b:di_Splus   || a:chr == b:di_Dplus
  \ || a:chr == b:di_Surcorn || a:chr == b:di_Durcorn
  \ || a:chr == b:di_Slrcorn || a:chr == b:di_Dlrcorn
  \ || a:chr == b:di_Sllcorn || a:chr == b:di_Dllcorn
  \ || a:chr == b:di_Sulcorn || a:chr == b:di_Dulcorn
  \ || a:chr == b:di_Sdnplus || a:chr == b:di_Ddnplus
  \ || a:chr == b:di_Supplus || a:chr == b:di_Dupplus
  \ || a:chr == b:di_Srplus  || a:chr == b:di_Drplus
  \ || a:chr == b:di_Slplus  || a:chr == b:di_Dlplus
  \ || a:chr == b:di_DhSd    || a:chr == b:di_DhSu
  \ || a:chr == b:di_DuSl    || a:chr == b:di_DuSr
  \ || a:chr == b:di_ShDd    || a:chr == b:di_ShDu
  \ || a:chr == b:di_SuDl    || a:chr == b:di_SuDr
  \ || a:chr == b:di_DuSlr   || a:chr == b:di_SuDlr
  \ || a:chr == b:di_cSdDr   || a:chr == b:di_cSdDr
  \ || a:chr == b:di_cDdSr   || a:chr == b:di_cDdSr
  \ || a:chr == b:di_cDlSd   || a:chr == b:di_cDlSd
  \ || a:chr == b:di_cSlDd   || a:chr == b:di_cSlDd
  \ || a:chr == b:di_cDrSu   || a:chr == b:di_cDrSu
  \ || a:chr == b:di_cSrDu   || a:chr == b:di_cSrDu
  \ || a:chr == b:di_cDlSu   || a:chr == b:di_cDlSu
  \ || a:chr == b:di_cSlDu   || a:chr == b:di_cSlDu
"   call Dret("s:IsDrawItV 1")
   return 1
  endif
"  call Dret("s:IsDrawItV 0")
  return 0
endfun

" ---------------------------------------------------------------------
" s:IsDnS: does the character "chr" have a single-line vertical-down? {{{2
fun! s:IsDnS(chr)
"  call Dfunc("s:IsDnS(chr<".a:chr.">)")
  let ret= 0
  if b:di_gfxchr
   if     a:chr == b:di_Svert  |let ret= 1
   elseif a:chr == b:di_Sulcorn|let ret= 1
   elseif a:chr == b:di_Surcorn|let ret= 1
   elseif a:chr == b:di_Splus  |let ret= 1
   elseif a:chr == b:di_Sdnplus|let ret= 1
   elseif a:chr == b:di_Slplus |let ret= 1
   elseif a:chr == b:di_Srplus |let ret= 1
   elseif a:chr == b:di_SdDh   |let ret= 1
   elseif a:chr == b:di_cDlSd  |let ret= 1
   elseif a:chr == b:di_cSdDr  |let ret= 1
   endif
  endif
"  call Dret("s:IsDnS ".ret)
  return ret
endfun

" ---------------------------------------------------------------------
" s:IsDnD: does the character "chr" have a double-line vertical-down? {{{2
fun! s:IsDnD(chr)
"  call Dfunc("s:IsDnD(chr<".a:chr.">)")
  let ret= 0
  if b:di_gfxchr
   if     a:chr == b:di_Dvert  |let ret= 1
   elseif a:chr == b:di_Dulcorn|let ret= 1
   elseif a:chr == b:di_Durcorn|let ret= 1
   elseif a:chr == b:di_Dplus  |let ret= 1
   elseif a:chr == b:di_Ddnplus|let ret= 1
   elseif a:chr == b:di_Dlplus |let ret= 1
   elseif a:chr == b:di_Drplus |let ret= 1
   elseif a:chr == b:di_cDdSr  |let ret= 1
   elseif a:chr == b:di_cSlDd  |let ret= 1
   endif
  endif
"   call Dret("s:IsDnD ".ret)
  return ret
endfun

" ---------------------------------------------------------------------
" s:IsUpS: does the character "chr" have a single-line vertical-up? {{{2
fun! s:IsUpS(chr)
"  call Dfunc("s:IsUpS(chr<".a:chr.">)")
  let ret= 0
  if b:di_gfxchr
   if     a:chr == b:di_Svert  |let ret= 1
   elseif a:chr == b:di_Sllcorn|let ret= 1
   elseif a:chr == b:di_Slrcorn|let ret= 1
   elseif a:chr == b:di_Splus  |let ret= 1
   elseif a:chr == b:di_Supplus|let ret= 1
   elseif a:chr == b:di_Slplus |let ret= 1
   elseif a:chr == b:di_Srplus |let ret= 1
   elseif a:chr == b:di_SuDh   |let ret= 1
   elseif a:chr == b:di_cDrSu  |let ret= 1
   elseif a:chr == b:di_cDlSu  |let ret= 1
   endif
  endif
"   call Dret("s:IsUpS ".ret)
  return ret
endfun

" ---------------------------------------------------------------------
" s:IsUpD: does the character "chr" have a double-line vertical-up? {{{2
fun! s:IsUpD(chr)
"  call Dfunc("s:IsUpD(chr<".a:chr.">)")
  let ret= 0
  if b:di_gfxchr
   if     a:chr == b:di_Dvert  |let ret= 1
   elseif a:chr == b:di_Dllcorn|let ret= 1
   elseif a:chr == b:di_Dlrcorn|let ret= 1
   elseif a:chr == b:di_Dplus  |let ret= 1
   elseif a:chr == b:di_Dupplus|let ret= 1
   elseif a:chr == b:di_Dlplus |let ret= 1
   elseif a:chr == b:di_Drplus |let ret= 1
   elseif a:chr == b:di_cSrDu  |let ret= 1
   elseif a:chr == b:di_cSlDu  |let ret= 1
   endif
  endif
"  call Dret("s:IsUpD ".ret)
  return ret
endfun

" ---------------------------------------------------------------------
" s:IsLeftS: does the character "chr" have a single-line horizontal-left? {{{2
fun! s:IsLeftS(chr)
"  call Dfunc("s:IsLeftS(chr<".a:chr.">)")
  let ret= 0
  if b:di_gfxchr
   if     a:chr == b:di_Shoriz  |let ret= 1
   elseif a:chr == b:di_Surcorn |let ret= 1
   elseif a:chr == b:di_Slrcorn |let ret= 1
   elseif a:chr == b:di_Splus   |let ret= 1
   elseif a:chr == b:di_Sdnplus |let ret= 1
   elseif a:chr == b:di_Supplus |let ret= 1
   elseif a:chr == b:di_Slplus  |let ret= 1
   elseif a:chr == b:di_cSlDd   |let ret= 1
   elseif a:chr == b:di_cSlDu   |let ret= 1
   endif
  endif
"  call Dret("s:IsLeftS ".ret)
  return ret
endfun

" ---------------------------------------------------------------------
" s:IsLeftD: does the character "chr" have a double-line horizontal-left? {{{2
fun! s:IsLeftD(chr)
"  call Dfunc("s:IsLeftD(chr<".a:chr.">)")
  let ret= 0
  if b:di_gfxchr
   if     a:chr == b:di_Dhoriz  |let ret= 1
   elseif a:chr == b:di_Durcorn |let ret= 1
   elseif a:chr == b:di_Dlrcorn |let ret= 1
   elseif a:chr == b:di_Dplus   |let ret= 1
   elseif a:chr == b:di_Ddnplus |let ret= 1
   elseif a:chr == b:di_Dupplus |let ret= 1
   elseif a:chr == b:di_Dlplus  |let ret= 1
   elseif a:chr == b:di_cDlSd   |let ret= 1
   elseif a:chr == b:di_cDlSu   |let ret= 1
   endif
  endif
"  call Dret("s:IsLeftD ".ret)
  return ret
endfun

" ---------------------------------------------------------------------
" s:IsRightS: does the character "chr" have a single-line horizontal-right? {{{2
fun! s:IsRightS(chr)
"  call Dfunc("s:IsRightS(chr<".a:chr.">)")
  let ret= 0
  if b:di_gfxchr
   if     a:chr == b:di_Shoriz  |let ret= 1
   elseif a:chr == b:di_Sulcorn |let ret= 1
   elseif a:chr == b:di_Sllcorn |let ret= 1
   elseif a:chr == b:di_Splus   |let ret= 1
   elseif a:chr == b:di_Sdnplus |let ret= 1
   elseif a:chr == b:di_Supplus |let ret= 1
   elseif a:chr == b:di_Srplus  |let ret= 1
   elseif a:chr == b:di_cDdSr   |let ret= 1
   elseif a:chr == b:di_cSrDu   |let ret= 1
   endif
  endif
"  call Dret("s:IsRightS ".ret)
  return ret
endfun

" ---------------------------------------------------------------------
" s:IsRightD: does the character "chr" have a double-line horizontal-right? {{{2
fun! s:IsRightD(chr)
"  call Dfunc("s:IsRightD(chr<".a:chr.">)")
  let ret= 0
  if b:di_gfxchr
   if     a:chr == b:di_Dhoriz  |let ret= 1
   elseif a:chr == b:di_Dulcorn |let ret= 1
   elseif a:chr == b:di_Dllcorn |let ret= 1
   elseif a:chr == b:di_Dplus   |let ret= 1
   elseif a:chr == b:di_Ddnplus |let ret= 1
   elseif a:chr == b:di_Dupplus |let ret= 1
   elseif a:chr == b:di_Drplus  |let ret= 1
   elseif a:chr == b:di_cSdDr   |let ret= 1
   elseif a:chr == b:di_cDrSu   |let ret= 1
   endif
  endif
"  call Dret("s:IsRightD ".ret)
  return ret
endfun

" ---------------------------------------------------------------------
" s:DrawErase: toggle [DrawIt on] and [DrawIt erase] modes {{{2
fun! s:DrawErase()
"  call Dfunc("s:DrawErase() b:di_erase=".b:di_erase)
  if b:di_erase == 0
   let b:di_erase= 1
   echo "[DrawIt erase]"
   let b:di_vert_save    = b:di_vert
   let b:di_horiz_save   = b:di_horiz
   let b:di_plus_save    = b:di_plus
   let b:di_upright_save = b:di_upright
   let b:di_upleft_save  = b:di_upleft
   let b:di_cross_save   = b:di_cross
   let b:di_ellipse_save = b:di_ellipse
   call SetDrawIt(' ',' ',' ',' ',' ',' ',' ')
  else
   let b:di_erase= 0
   echo "[DrawIt]"
   call SetDrawIt(b:di_vert_save,b:di_horiz_save,b:di_plus_save,b:di_upleft_save,b:di_upright_save,b:di_cross_save,b:di_ellipse_save)
  endif
"  call Dret("s:DrawErase")
endfun

" ---------------------------------------------------------------------
" s:DrawSpace: clear character and move right {{{2
fun! s:DrawSpace(chr,dir)
"  call Dfunc("s:DrawSpace(chr<".a:chr."> dir<".a:dir.">)")
  let curcol= virtcol(".")

  " replace current location with arrowhead/space
  if curcol == virtcol("$")-1
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
"  call Dret("s:DrawSpace")
endfun

" ---------------------------------------------------------------------
" s:DrawSlantDownLeft: / {{{2
fun! s:DrawSlantDownLeft()
"  call Dfunc("s:DrawSlantDownLeft()")
  call s:ReplaceDownLeft()		" replace
  call s:MoveDown()				" move
  call s:MoveLeft()				" move
  call s:ReplaceDownLeft()		" replace
"  call Dret("s:DrawSlantDownLeft")
endfun

" ---------------------------------------------------------------------
" s:DrawSlantDownRight: \ {{{2
fun! s:DrawSlantDownRight()
"  call Dfunc("s:DrawSlantDownRight()")
  call s:ReplaceDownRight()	" replace
  call s:MoveDown()			" move
  call s:MoveRight()		" move
  call s:ReplaceDownRight()	" replace
"  call Dret("s:DrawSlantDownRight")
endfun

" ---------------------------------------------------------------------
" s:DrawSlantUpLeft: \ {{{2
fun! s:DrawSlantUpLeft()
"  call Dfunc("s:DrawSlantUpLeft()")
  call s:ReplaceDownRight()	" replace
  call s:MoveUp()			" move
  call s:MoveLeft()			" move
  call s:ReplaceDownRight()	" replace
"  call Dret("s:DrawSlantUpLeft")
endfun

" ---------------------------------------------------------------------
" s:DrawSlantUpRight: / {{{2
fun! s:DrawSlantUpRight()
"  call Dfunc("s:DrawSlantUpRight()")
  call s:ReplaceDownLeft()	" replace
  call s:MoveUp()			" move
  call s:MoveRight()		" replace
  call s:ReplaceDownLeft()	" replace
"  call Dret("s:DrawSlantUpRight")
endfun

" ---------------------------------------------------------------------
" s:MoveLeft: {{{2
fun! s:MoveLeft()
"  call Dfunc("s:MoveLeft()")
  norm! h
  let b:lastdir= 2
"  call Dret("s:MoveLeft : b:lastdir=".b:lastdir)
endfun

" ---------------------------------------------------------------------
" s:MoveRight: {{{2
fun! s:MoveRight()
"  call Dfunc("s:MoveRight()")
  if virtcol(".") >= virtcol("$") - 1
   exe "norm! A \<Esc>"
  else
   norm! l
  endif
  let b:lastdir= 1
"  call Dret("s:MoveRight : b:lastdir=".b:lastdir)
endfun

" ---------------------------------------------------------------------
" s:MoveUp: {{{2
fun! s:MoveUp()
"  call Dfunc("s:MoveUp()")
  if line(".") == 1
   let curcol= virtcol(".") - 1
   if curcol == 0 && virtcol("$") == 1
     exe "norm! i \<Esc>"
   elseif curcol == 0
     exe "norm! YP:s/./ /ge\<CR>0r "
   else
     exe "norm! YP:s/./ /ge\<CR>0".curcol."lr "
   endif
  else
   let curcol= virtcol(".")
   norm! k
   while virtcol("$") <= curcol
     exe "norm! A \<Esc>"
   endwhile
  endif
  let b:lastdir= 3
"  call Dret("s:MoveUp : b:lastdir=".b:lastdir)
endfun

" ---------------------------------------------------------------------
" s:MoveDown: {{{2
fun! s:MoveDown()
"  call Dfunc("s:MoveDown()")
  if line(".") == line("$")
   let curcol= virtcol(".") - 1
   if curcol == 0 && virtcol("$") == 1
    exe "norm! i \<Esc>"
   elseif curcol == 0
    exe "norm! Yp:s/./ /ge\<CR>0r "
   else
    exe "norm! Yp:s/./ /ge\<CR>0".curcol."lr "
   endif
  else
   let curcol= virtcol(".")
   norm! j
   while virtcol("$") <= curcol
    exe "norm! A \<Esc>"
   endwhile
  endif
  let b:lastdir= 4
"  call Dret("s:MoveDown : b:lastdir=".b:lastdir)
endfun

" ---------------------------------------------------------------------
" s:ReplaceDownLeft: / X  (upright) {{{2
fun! s:ReplaceDownLeft()
"  call Dfunc("s:ReplaceDownLeft()")
  let curcol   = virtcol(".")
  let keepatat = @@
  if curcol != virtcol("$")
   norm! vy
   let curchar= @@

   " determine if curchr needs to be changed to an "X"
   let chg2cross = 0
   if curchar == b:di_upleft   || curchar == b:di_cross
    let chg2cross = 1
   elseif b:di_gfxchr
	" performing following test only if gfx drawing characters exist
    if curchar == b:di_Supleft || curchar == b:di_Scross
     let chg2cross = 1
    endif
   endif

   if chg2cross
    if g:drawit_mode == 'S'
     exe "norm! r".b:di_Scross
    else
     exe "norm! r".b:di_cross
    endif
   else
    if g:drawit_mode == 'S'
     exe "norm! r".b:di_Supright
    else
     exe "norm! r".b:di_upright
    endif
   endif
  else
    if g:drawit_mode == 'S'
     exe "norm! i".b:di_Supright."\<Esc>"
    else
     exe "norm! i".b:di_upright."\<Esc>"
    endif
  endif
  let @@= keepatat
"  call Dret("s:ReplaceDownLeft")
endfun

" ---------------------------------------------------------------------
" s:ReplaceDownRight: \ X  (upleft) {{{2
fun! s:ReplaceDownRight()
"  call Dfunc("s:ReplaceDownRight()")
  let curcol   = virtcol(".")
  let keepatat = @@
  if curcol != virtcol("$")
   norm! vy
   let curchar= @@
"   call Decho("case curcol#".curcol." == virtcol($)  drawit_mode<".g:drawit_mode.">  curchar<".curchar.">")

   " determine if curchr needs to be changed to an "X"
   let chg2cross = 0
   if curchar == b:di_upright   || curchar == b:di_cross
    let chg2cross = 1
   elseif b:di_gfxchr
	" performing following test only if gfx drawing characters exist
    if curchar == b:di_Supright || curchar == b:di_Scross
     let chg2cross = 1
    endif
   endif

   if chg2cross
    if g:drawit_mode == 'S'
     exe "norm! r".b:di_Scross
    else
     exe "norm! r".b:di_cross
    endif
   else
    if g:drawit_mode == 'S'
     exe "norm! r".b:di_Supleft
    else
     exe "norm! r".b:di_upleft
    endif
   endif
  else
"   call Decho("case curcol#".curcol." != virtcol($)  drawit_mode<".g:drawit_mode.">")
   if g:drawit_mode == 'S'
    exe "norm! i".b:di_Supleft."\<Esc>"
   else
    exe "norm! i".b:di_upleft."\<Esc>"
   endif
  endif
  let @@= keepatat
"  call Dret("s:ReplaceDownRight")
endfun

" ---------------------------------------------------------------------
" s:DrawFatRArrow: ----|> {{{2
fun! s:DrawFatRArrow()
"  call Dfunc("s:DrawFatRArrow()")
  if g:drawit_mode == 'N' || !b:di_gfxchr
   call s:MoveRight()
   norm! r|
   call s:MoveRight()
   norm! r>
  else
   call s:MoveRight()
   norm! r▶
  endif
"  call Dret("s:DrawFatRArrow")
endfun

" ---------------------------------------------------------------------
" s:DrawFatLArrow: <|---- {{{2
fun! s:DrawFatLArrow()
"  call Dfunc("s:DrawFatLArrow()")
  if g:drawit_mode == 'N' || !b:di_gfxchr
   call s:MoveLeft()
   norm! r|
   call s:MoveLeft()
   norm! r<
  else
   call s:MoveLeft()
   norm! r◀
  endif
"  call Dret("s:DrawFatLArrow")
endfun

" ---------------------------------------------------------------------
"                 .
" s:DrawFatUArrow: /_\ {{{2
"                 |
fun! s:DrawFatUArrow()
"  call Dfunc("s:DrawFatUArrow()")
  if g:drawit_mode == 'N' || !b:di_bfxchr
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
  else
   call s:MoveUp()
   norm! r▲
  endif
"  call Dret("s:DrawFatUArrow")
endfun

" ---------------------------------------------------------------------
" s:DrawFatDArrow: _|_ {{{2
"                  \ /
"                   '
fun! s:DrawFatDArrow()
"  call Dfunc("s:DrawFatDArrow()")
  if g:drawit_mode == 'N' || !b:di_gfxchr
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
  else
   call s:MoveDown()
   norm! r▼
  endif
"  call Dret("s:DrawFatDArrow")
endfun

" ---------------------------------------------------------------------
" s:DrawEllipse: Bresenham-like ellipse drawing algorithm {{{2
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
fun! s:DrawEllipse(x0,y0,x1,y1)
"  call Dfunc("s:DrawEllipse(x0=".a:x0." y0=".a:y0." x1=".a:x1." y1=".a:y1.")")
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
"  call Dret("s:DrawEllipse")
endf

" ---------------------------------------------------------------------
" s:DrawFour: reflect a point to four quadrants {{{2
fun! s:DrawFour(x,y,xoff,yoff,a,b)
"  call Dfunc("s:DrawFour(xy[".a:x.",".a:y."] off[".a:xoff.",".a:yoff."] a=".a:a." b=".a:b.")")
  let x  = a:xoff + a:x
  let y  = a:yoff + a:y
  let lx = a:xoff - a:x
  let by = a:yoff - a:y
  call s:SetCharAt(b:di_ellipse,  x, y)
  call s:SetCharAt(b:di_ellipse, lx, y)
  call s:SetCharAt(b:di_ellipse, lx,by)
  call s:SetCharAt(b:di_ellipse,  x,by)
"  call Dret("s:DrawFour")
endf

" ---------------------------------------------------------------------
" s:SavePosn: saves position of cursor on screen so NetWrite can restore it {{{2
fun! s:SavePosn()
"  call Dfunc("s:SavePosn() saveposn_count=".s:saveposn_count.' ['.line('.').','.virtcol('.').']')
  let s:saveposn_count= s:saveposn_count + 1

  " Save current line and column
  let b:drawit_line_{s:saveposn_count} = line(".")
  let b:drawit_col_{s:saveposn_count}  = virtcol(".") - 1

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
"  call Dret("s:SavePosn : saveposn_count=".s:saveposn_count)
endfun

" ------------------------------------------------------------------------
" s:RestorePosn: {{{2
fun! s:RestorePosn()
"  call Dfunc("s:RestorePosn() saveposn_count=".s:saveposn_count)
  if s:saveposn_count <= 0
"  	call Dret("s:RestorePosn : s:saveposn_count<=0")
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
"  call Dret("s:RestorePosn : saveposn_count=".s:saveposn_count)
endfun

" ------------------------------------------------------------------------
" s:Flood: this function begins a flood of a region {{{2
"        based on b:di... characters as boundaries
"        and starting at the current cursor location.
fun! s:Flood()
"  call Dfunc("s:Flood()")

  let s:bndry  = b:di_vert.b:di_horiz.b:di_plus.b:di_upright.b:di_upleft.b:di_cross.b:di_ellipse
  if b:di_gfxchr
   let s:bndry= s:bndry.b:di_Svert.b:di_Dvert.b:di_Shoriz.b:di_Dhoriz.b:di_Sulcorn.b:di_Dulcorn.b:di_Surcorn.b:di_Durcorn.b:di_Sllcorn.b:di_Dllcorn.b:di_Slrcorn.b:di_Dlrcorn.b:di_Splus.b:di_Dplus.b:di_Sdnplus.b:di_Ddnplus.b:di_Supplus.b:di_Dupplus.b:di_Slplus.b:di_Dlplus.b:di_Srplus.b:di_Drplus.b:di_Supright.b:di_Supleft.b:di_Scross
   let s:bndry= s:bndry.b:di_DhSd.b:di_DhSu.b:di_DuSl.b:di_DuSlr.b:di_DuSr.b:di_ShDd.b:di_ShDu.b:di_SuDl.b:di_SuDlr.b:di_SdDh.b:di_SuDh.b:di_SuDr.b:di_cSdDr.b:di_cDdSr.b:di_cDlSd.b:di_cSlDd.b:di_cDrSu.b:di_cSrDu.b:di_cDlSu.b:di_cSlDu
  endif
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
"  call Decho("s:bndry<".s:bndry.">")
  if s:Strlen(s:fillchar) > 1
   let s:fillchar= strpart(s:fillchar,0,1)
  endif

  " flood the region
  call s:DI_Flood(row,col)

  " restore
  call s:RestorePosn()
  let @0= athold
  unlet s:DIrows s:bndry s:fillchar

"  call Dret("s:Flood")
endfun

" ------------------------------------------------------------------------
" s:DI_Flood: fill up to the boundaries all characters to the left and right. {{{2
"           Then, based on the left/right column extents reached, check
"           adjacent rows to see if any characters there need filling.
fun! s:DI_Flood(frow,fcol)
"  call Dfunc("s:DI_Flood(frow=".a:frow." fcol=".a:fcol.")")
  if a:frow <= 0 || a:fcol <= 0 || s:SetPosn(a:frow,a:fcol) || s:IsBoundary(a:frow,a:fcol)
"   call Dret("s:DI_Flood")
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

"  call Dret("s:DI_Flood")
endfun

" ------------------------------------------------------------------------
"  s:DI_FillLeft: Starting at (frow,fcol), non-boundary locations are {{{2
"               filled with the fillchar.  The leftmost extent reached
"               is returned.
fun! s:DI_FillLeft(frow,fcol)
"  call Dfunc("s:DI_FillLeft(frow=".a:frow." fcol=".a:fcol.")")
  if s:SetPosn(a:frow,a:fcol)
"   call Dret("s:DI_FillLeft ".a:fcol)
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

" call Dret("s:DI_FillLeft ".Lcol)
 return Lcol
endfun

" ---------------------------------------------------------------------
"  s:DI_FillRight: Starting at (frow,fcol), non-boundary locations are {{{2
"                filled with the fillchar.  The rightmost extent reached
"                is returned.
fun! s:DI_FillRight(frow,fcol)
"  call Dfunc("s:DI_FillRight(frow=".a:frow." fcol=".a:fcol.")")
  if s:SetPosn(a:frow,a:fcol)
"   call Dret("s:DI_FillRight ".a:fcol)
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

"  call Dret("s:DI_FillRight ".Rcol)
  return Rcol
endfun

" ---------------------------------------------------------------------
"  s:DI_FillAdjacent: {{{2
"     DI_Flood does FillLeft and FillRight, so the run from left to right
"    (fcolL to fcolR) is known to have been filled.  FillAdjacent is called
"    from (fcolL to fcolR) on the lines one row up and down; if any character
"    on the run is not a boundary character, then a flood is needed on that
"    location.
fun! s:DI_FillAdjacent(frow,fcolL,fcolR)
"  call Dfunc("s:DI_FillAdjacent(frow=".a:frow." fcolL=".a:fcolL." fcolR=".a:fcolR.")")

  let icol  = a:fcolL
  while icol <= a:fcolR
	if !s:IsBoundary(a:frow,icol)
	 call s:DI_Flood(a:frow,icol)
	endif
   let icol= icol + 1
  endwhile

"  call Dret("s:DI_FillAdjacent")
endfun

" ---------------------------------------------------------------------
" s:SetPosn: set cursor to given position on screen {{{2
"    srow,scol: -s-creen    row and column
"   Returns  1 : failed sanity check
"            0 : otherwise
fun! s:SetPosn(row,col)
"  call Dfunc("s:SetPosn(row=".a:row." col=".a:col.")")
  " sanity checks
  if a:row < 1
"   call Dret("s:SetPosn 1")
   return 1
  endif
  if a:col < 1
"   call Dret("s:SetPosn 1")
   return 1
  endif

  exe "norm! ".a:row."G".a:col."\<Bar>"

"  call Dret("s:SetPosn 0")
  return 0
endfun

" ---------------------------------------------------------------------
" s:IsBoundary: returns 0 if not on boundary, 1 if on boundary {{{2
"             The "boundary" also includes the fill character.
fun! s:IsBoundary(row,col)
"  call Dfunc("s:IsBoundary(row=".a:row." col=".a:col.")")

  let orow= line(".")
  let ocol= virtcol(".")
  exe "norm! ".a:row."G".a:col."\<Bar>"
  norm! vy
  let ret= @0 =~ s:bndry
  if a:row != orow || a:col != ocol
   exe "norm! ".orow."G".ocol."\<Bar>"
  endif

"  call Dret("s:IsBoundary ".ret." : @0<".@0.">")
  return ret
endfun

" ---------------------------------------------------------------------
" s:PutBlock: puts a register's contents into the text at the current {{{2
"           cursor location
"              replace= 0: Blanks are transparent
"                     = 1: Blanks copy over
"                     = 2: Erase all drawing characters
"
fun! s:PutBlock(block,replace)
"  call Dfunc("s:PutBlock(block<".a:block."> replace=".a:replace.") g:drawit_xstrlen=".g:drawit_xstrlen)
  call s:SavePosn()
  exe "let block  = @".a:block
  let blocklen    = strlen(block)
  let drawit_line = line('.')
  let drawchars   = '['.escape(b:di_vert.b:di_horiz.b:di_plus.b:di_upright.b:di_upleft.b:di_cross,'\-').']'
"  call Decho("blocklen=".blocklen." block<".string(block).">")

  " insure that putting a block will do so in a region containing spaces out to textwidth
  exe "let blockrows= s:Strlen(substitute(@".a:block.",'[^[:cntrl:]]','','g'))"
  exe 'let blockcols= s:Strlen(substitute(@'.a:block.",'^\\(.\\{-}\\)\\n\\_.*$','\\1',''))"
  let curline= line('.')
  let curcol = virtcol('.')
"  call Decho("blockrows=".blockrows." blockcols=".blockcols." curline=".curline." curcol=".curcol)
  call s:AutoCanvas(curline-1,curline + blockrows+1,curcol + blockcols)

  let iblock= 0
  while iblock < blocklen
   " the following logic should permit 1, 2, or 4 byte glyphs (I've only tested it with 1 and 2)
  	let chr= strpart(block,iblock,4)
	if char2nr(chr) <= 255
  	 let chr= strpart(block,iblock,1)
	elseif char2nr(chr) <= 65536
  	 let chr= strpart(block,iblock,2)
	 let iblock= iblock + 1
	else
	 let iblock= iblock + 3
	endif
"	call Decho("iblock=".iblock." chr#".char2nr(chr)."<".string(chr).">")

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

"  call Dret("s:PutBlock")
endfun

" ---------------------------------------------------------------------
" s:AutoCanvas: automatic "Canvas" routine {{{2
fun! s:AutoCanvas(linestart,linestop,cols)
"  call Dfunc("s:AutoCanvas(linestart=".a:linestart." linestop=".a:linestop." cols=".a:cols.")  line($)=".line("$"))

  " insure there's enough blank lines at end-of-file
  if line("$") < a:linestop
"   call Decho("append ".(a:linestop - line("$"))." empty lines")
   call s:SavePosn()
   exe "norm! G".(a:linestop - line("$"))."o\<esc>"
   call s:RestorePosn()
  endif

  " insure that any tabs contained within the selected region are converted to blanks
  let etkeep= &l:et
  set et
"  call Decho("exe ".a:linestart.",".a:linestop."retab")
  exe a:linestart.",".a:linestop."retab"
  let &l:et= etkeep

  " insure that there's whitespace to textwidth/screenwidth/a:cols
  if a:cols <= 0
   let tw= &tw
   if tw <= 0
    let tw= &columns
   endif
  else
   let tw= a:cols
  endif
"  Decho("tw=".tw)
  if search('^$\|.\%<'.(tw+1).'v$',"cn",(a:linestop+1)) > 0
"   call Decho("append trailing whitespace")
   call s:Spacer(a:linestart,a:linestop,tw)
  endif

"  call Dret("s:AutoCanvas : tw=".tw)
endfun

" ---------------------------------------------------------------------
" s:Strlen: this function returns the length of a string, even if its {{{2
"           using two-byte etc characters.
"           Currently, its only used if g:Align_xstrlen is set to a
"           nonzero value.  Solution from Nicolai Weibull, vim docs
"           (:help strlen()), Tony Mechelynck, and my own invention.
fun! s:Strlen(x)
"  call Dfunc("s:Strlen(x<".a:x.">")
  
  if v:version >= 703 && exists("*strdisplaywidth")
   let ret= strdisplaywidth(a:x)
 
  elseif g:drawit_xstrlen == 1
   " number of codepoints (Latin a + combining circumflex is two codepoints)
   " (comment from TM, solution from NW)
   let ret= strlen(substitute(a:x,'.','c','g'))

  elseif g:drawit_xstrlen == 2
   " number of spacing codepoints (Latin a + combining circumflex is one spacing 
   " codepoint; a hard tab is one; wide and narrow CJK are one each; etc.)
   " (comment from TM, solution from TM)
   let ret= strlen(substitute(a:x, '.\Z', 'x', 'g')) 

  elseif g:drawit_xstrlen == 3
   " virtual length (counting, for instance, tabs as anything between 1 and 
   " 'tabstop', wide CJK as 2 rather than 1, Arabic alif as zero when immediately 
   " preceded by lam, one otherwise, etc.)
   " (comment from TM, solution from me)
   let modkeep= &l:mod
   exe "norm! o\<esc>"
   call setline(line("."),a:x)
   let ret= virtcol("$") - 1
   d
   keepj norm! k
   let &l:mod= modkeep

  else
   " at least give a decent default
   let ret= strlen(a:x)
  endif

"  call Dret("s:Strlen ".ret)
  return ret
endfun

" =====================================================================
"  DrawIt Functions: (by Sylvain Viart) {{{1
" =====================================================================

" ---------------------------------------------------------------------
" s:Canvas: {{{2
fun! s:Canvas()
"  call Dfunc("s:Canvas()")

  let lines  = input("how many lines under the cursor? ")
  let curline= line('.')
  if curline < line('$')
   exe "norm! ".lines."o\<esc>"
  endif
  call s:Spacer(curline+1,curline+lines,0)
  let b:drawit_canvas_used= 1

"  call Dret("s:Canvas")
endf

" ---------------------------------------------------------------------
" s:Spacer: fill end of line with space {{{2
"         if a:cols >0: to the virtual column specified by a:cols
"                  <=0: to textwidth (if nonzero), otherwise
"                       to display width (&columns)
fun! s:Spacer(debut, fin, cols) range
"  call Dfunc("s:Spacer(debut=".a:debut." fin=".a:fin." cols=".a:cols.") textwidth=".&textwidth)
  call s:SavePosn()

  if a:cols <= 0
   let width = &textwidth
   if width <= 0
    let width= &columns
   endif
  else
   let width= a:cols
  endif

  let l= a:debut
  while l <= a:fin
   call setline(l,printf('%-'.width.'s',getline(l)))
   let l = l + 1
  endwhile

  call s:RestorePosn()

"  call Dret("s:Spacer")
endf

" ---------------------------------------------------------------------
" s:CallBox: call the specified function using the current visual selection box {{{2
fun! s:CallBox(func_name)
"  call Dfunc("s:CallBox(func_name<".a:func_name.">)")

  if exists("b:xmouse_start")
   let xdep = b:xmouse_start
  else
   let xdep= 0
  endif
  if exists("b:ymouse_start")
   let ydep = b:ymouse_start
  else
   let ydep= 0
  endif
  let col0   = virtcol("'<")
  let row0   = line("'<")
  let col1   = virtcol("'>")
  let row1   = line("'>")
"  call Decho("TL corner[".row0.",".col0."] original")
"  call Decho("BR corner[".row1.",".col1."] original")
"  call Decho("xydep     [".ydep.",".xdep."]")

  if col1 == xdep && row1 == ydep
     let col1 = col0
     let row1 = row0
     let col0 = xdep
     let row0 = ydep
  endif
"  call Decho("TL corner[".row0.",".col0."]")
"  call Decho("BR corner[".row1.",".col1."]")

  " insure that the selected region has blanks to that specified by col1
  call s:AutoCanvas((row0 < row1)? row0 : row1,(row1 > row0)? row1 : row0,(col1 > col0)? col1 : col0)

"  call Decho("exe call s:".a:func_name."(".col0.','.row0.','.col1.','.row1.")")
  exe "call s:".a:func_name."(".col0.','.row0.','.col1.','.row1.")"
  let b:xmouse_start= 0
  let b:ymouse_start= 0

"  call Dret("s:CallBox")
endf

" ---------------------------------------------------------------------
" s:DrawBox: {{{2
fun! s:DrawBox(x0, y0, x1, y1)
"  call Dfunc("s:DrawBox(xy0[".a:x0.",".a:y0." xy1[".a:x1.",".a:y1."]) g:drawit_mode=".g:drawit_mode)
  " loop each line
  let x0= (a:x1 > a:x0)? a:x0 : a:x1
  let x1= (a:x1 > a:x0)? a:x1 : a:x0
  let y0= (a:y1 > a:y0)? a:y0 : a:y1
  let y1= (a:y1 > a:y0)? a:y1 : a:y0
"  call Decho('x0='.x0.' y0='.y0)
"  call Decho('x1='.x1.' y1='.y1)
  let l = y0
  while l <= y1
   let c = x0
   while c <= x1
	let remp= '.'
    if l == y0 || l == y1
	 if     g:drawit_mode == 's' || g:drawit_mode == 'S'
	  let remp = b:di_Shoriz
	 elseif g:drawit_mode == 'd' || g:drawit_mode == 'D'
	  let remp = b:di_Dhoriz
	 else
	  let remp = b:di_horiz
	 endif
	 if g:drawit_mode =~ '[sSdD]'
	  if     c == x0 && l == y0
	   let remp= (g:drawit_mode == 's' || g:drawit_mode == 'S')? b:di_Sulcorn : b:di_Dulcorn
"	   call Decho('x0,y0: ulcorn<'.remp.'>')
	  elseif c == x1 && l == y0
	   let remp= (g:drawit_mode == 's' || g:drawit_mode == 'S')? b:di_Surcorn : b:di_Durcorn
"	   call Decho('x0,y1: ulcorn<'.remp.'>')
	  elseif c == x0 && l == y1
	   let remp= (g:drawit_mode == 's' || g:drawit_mode == 'S')? b:di_Sllcorn : b:di_Dllcorn
"	   call Decho('x1,y0: ulcorn<'.remp.'>')
	  elseif c == x1 && l == y1
	   let remp= (g:drawit_mode == 's' || g:drawit_mode == 'S')? b:di_Slrcorn : b:di_Dlrcorn
"	   call Decho('x1,y1: ulcorn<'.remp.'>')
	  endif
	 else
      if c == x0 || c == x1
	    let remp = b:di_plus
      endif
	 endif
    else
	 if     g:drawit_mode == 's' || g:drawit_mode == 'S'
	  let remp = b:di_Svert
	 elseif g:drawit_mode == 'd' || g:drawit_mode == 'D'
	  let remp = b:di_Dvert
	 else
	  let remp = b:di_vert
	 endif
     if c != x0 && c != x1
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

"  call Dret("s:DrawBox")
endf

" ---------------------------------------------------------------------
" s:SetCharAt: set the character at the specified position (something must pre-exist at the pos'n) {{{2
fun! s:SetCharAt(chr, x, y)
"  call Dfunc("s:SetCharAt(chr<".a:chr."> xy[".a:x.",".a:y."])")

  exe a:y
  if a:x <= 1
   exe "norm! 0r".a:chr
  else
   exe "norm! 0".(a:x-1)."lr".a:chr
  endif

"  call Dret("s:SetCharAt")
endf

" ---------------------------------------------------------------------
" s:DrawLine: Bresenham line-drawing algorithm {{{2
" taken from :
" http://www.graphics.lcs.mit.edu/~mcmillan/comp136/Lecture6/Lines.html
fun! s:DrawLine(x0, y0, x1, y1, horiz)
"  call Dfunc("s:DrawLine(xy0[".a:x0.",".a:y0."] xy1[".a:x1.",".a:y1."] horiz=".a:horiz.")")

  if ( a:x0 < a:x1 && a:y0 > a:y1 ) || ( a:x0 > a:x1 && a:y0 > a:y1 )
    " swap direction
    let x0   = a:x1
    let y0   = a:y1
    let x1   = a:x0
    let y1   = a:y0
"	call Decho("swap points: p0(".x0.",".y0.")  p1(".x1.",".y1.")")
  else
    let x0 = a:x0
    let y0 = a:y0
    let x1 = a:x1
    let y1 = a:y1
"	call Decho("points: p0(".x0.",".y0.")  p1(".x1.",".y1.")")
  endif
  let dy = y1 - y0
  let dx = x1 - x0
"  call Decho("[dx=x1-x0]=".dx." [dy=y1-y0]=".dy)

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
  if a:horiz == '_'
   let horiz= a:horiz
  else
   let horiz = (g:drawit_mode == 'N')? b:di_horiz : ((g:drawit_mode == 'S')? b:di_Shoriz : b:di_Dhoriz)
  endif
  if a:horiz == '|'
   let vertline= a:vert
  else
   let vertline = (g:drawit_mode == 'N')? b:di_vert : ((g:drawit_mode == 'S')? b:di_Svert : b:di_Dvert)
  endif

  if dx > dy
"     call Decho("case dx>dy : Δ=".dx.",".dy." step=".stepx.",".stepy)
     let char = horiz
     call s:SetCharAt(char, x0, y0)
     let fraction = dy - (dx / 2)  " same as 2*Δy - Δx
     while x0 != x1
	   let char = horiz
        if fraction >= 0
           if stepx > 0
"			call Decho("..case [fraction=".fraction."]≥0 and [stepx=".stepx."]>0: go upleft")
			let char = (g:drawit_mode == 'N')? b:di_upleft : b:di_Supleft
           else
"			call Decho("..case [fraction=".fraction."]≥0 and [stepx=".stepx."]≤0: go upright")
			let char = (g:drawit_mode == 'N')? b:di_upright : b:di_Supright
           endif
           let y0       = y0 + stepy
           let fraction = fraction - dx    " same as fraction -= 2*Δx
"		   call Decho("....[y0+=stepy]=".y0." [fraction-=dx]=".fraction)
        endif
        let x0       = x0 + stepx
        let fraction = fraction + dy	" same as fraction = fraction - 2*Δy
"		call Decho("..[x0+=stepx]=".x0." [fraction-=dy]=".fraction)
        call s:SetCharAt(char, x0, y0)
     endw
  else
"     call Decho("case dx≤dy : Δ=".dx.",".dy." step=".stepx.",".stepy)
	 let char = vertline
     call s:SetCharAt(char, x0, y0)
     let fraction = dx - (dy / 2)
     while y0 != y1
		let char = (g:drawit_mode == 'N')? b:di_vert : ((g:drawit_mode == 'S')? b:di_Svert : b:di_Dvert)
        if fraction >= 0
           if stepx > 0
"			call Decho("..case [fraction=".fraction."]≥0 and [stepx=".stepx."]>0: go upleft")
			let char = (g:drawit_mode == 'N')? b:di_upleft : b:di_Supleft
           else
"			call Decho("..case [fraction=".fraction."]≥0 and [stepx=".stepy."]≤0: go upright")
			let char = (g:drawit_mode == 'N')? b:di_upright : b:di_Supright
           endif
           let x0       = x0 + stepx
           let fraction = fraction - dy
"		   call Decho("....[x0+=stepx]=".x0." [fraction-=dy]=".fraction)
        endif
        let y0       = y0 + stepy
        let fraction = fraction + dx
"		call Decho("..[y0+=stepy]=".y0." [fraction-=dy]=".fraction)
        call s:SetCharAt(char, x0, y0)
     endw
  endif

"  call Dret("s:DrawLine")
endf

" ---------------------------------------------------------------------
" s:Arrow: {{{2
fun! s:Arrow(x0, y0, x1, y1)
"  call Dfunc("s:Arrow(xy0[".a:x0.",".a:y0."] xy1[".a:x1.",".a:y1."])")

  let horiz = (g:drawit_mode == 'N')? b:di_horiz : ((g:drawit_mode == 'S')? b:di_Shoriz : b:di_Dhoriz)
  call s:DrawLine(a:x0, a:y0, a:x1, a:y1,horiz)
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

"  call Dret("s:Arrow")
endf

" ---------------------------------------------------------------------
" s:Abs: return absolute value {{{2
fun! s:Abs(val)
  if a:val < 0
   return - a:val
  else
   return a:val
  endif
endf

" ---------------------------------------------------------------------
" s:DrawPlainLine: {{{2
fun! s:DrawPlainLine(x0,y0,x1,y1)
"  call Dfunc("s:DrawPlainLine(xy0[".a:x0.",".a:y0."] xy1[".a:x1.",".a:y1."])")

"   call Decho("exe call s:DrawLine(".a:x0.','.a:y0.','.a:x1.','.a:y1.',"_")')
   exe "call s:DrawLine(".a:x0.','.a:y0.','.a:x1.','.a:y1.',"_")'

"  call Dret("s:DrawPlainLine")
endf

" =====================================================================
"  Mouse Functions: {{{1
" =====================================================================

" ---------------------------------------------------------------------
" s:LeftStart: Read visual drag mapping {{{2
" The visual start point is saved in b:xmouse_start and b:ymouse_start
fun! s:LeftStart()
"  call Dfunc("s:LeftStart()")
  let b:xmouse_start = virtcol('.')
  let b:ymouse_start = line('.')
  vnoremap <silent> <buffer> <script> <leftrelease> <leftrelease>:<c-u>call <SID>LeftRelease()<cr>gv
"  call Dret("s:LeftStart : [".b:ymouse_start.",".b:xmouse_start."]")
endf!

" ---------------------------------------------------------------------
" s:LeftRelease: {{{2
fun! s:LeftRelease()
"  call Dfunc("s:LeftRelease()")
  vunmap <buffer> <leftrelease>
"  call Dret("s:LeftRelease : [".line('.').','.virtcol('.').']')
endf

" ---------------------------------------------------------------------
" s:SLeftStart: begin drawing with a brush {{{2
fun! s:SLeftStart()
  if !exists("b:drawit_brush")
   let b:drawit_brush= "a"
  endif
"  call Dfunc("s:SLeftStart() brush=".b:drawit_brush.' ['.line('.').','.virtcol('.').']')
  noremap <silent> <buffer> <script> <s-leftdrag>    <leftmouse>:<c-u>call <SID>SLeftDrag()<cr>
  noremap <silent> <buffer> <script> <s-leftrelease> <leftmouse>:<c-u>call <SID>SLeftRelease()<cr>
"  call Dret("s:SLeftStart")
endfun

" ---------------------------------------------------------------------
" s:SLeftDrag: {{{2
fun! s:SLeftDrag()
"  call Dfunc("s:SLeftDrag() brush=".b:drawit_brush.' ['.line('.').','.virtcol('.').']')
  call s:SavePosn()
  call s:PutBlock(b:drawit_brush,0)
  call s:RestorePosn()
"  call Dret("s:SLeftDrag")
endfun

" ---------------------------------------------------------------------
" s:SLeftRelease: {{{2
fun! s:SLeftRelease()
"  call Dfunc("s:SLeftRelease() brush=".b:drawit_brush.' ['.line('.').','.virtcol('.').']')
  call s:SLeftDrag()
  nunmap <buffer> <s-leftdrag>
  nunmap <buffer> <s-leftrelease>
"  call Dret("s:SLeftRelease")
endfun

" ---------------------------------------------------------------------
" s:CLeftStart: begin moving a block of text {{{2
fun! s:CLeftStart()
  if !exists("b:drawit_brush")
   let b:drawit_brush= "a"
  endif
"  call Dfunc("s:CLeftStart() brush=".b:drawit_brush)
  if !line("'<") || !line("'>")
   redraw!
   echohl Error
   echo "must visual-block select a region first"
"   call Dret("s:CLeftStart : must visual-block select a region first")
   return
  endif
  '<,'>call DrawIt#SetBrush(b:drawit_brush)
  norm! gvr 
  let s:cleft_width= virtcol("'>") - virtcol("'<")
  if s:cleft_width < 0
   let s:cleft_width= -s:cleft_width
  endif
  let s:cleft_height= line("'>") - line("'<")
  if s:cleft_height < 0
   let s:cleft_height= -s:cleft_height
  endif
  if exists("s:cleft_oldblock")
   unlet s:cleft_oldblock
  endif
"  call Decho("blocksize: ".s:cleft_height."x".s:cleft_width)
  noremap <silent> <buffer> <script> <c-leftdrag>    :<c-u>call <SID>CLeftDrag()<cr>
  noremap <silent> <buffer> <script> <c-leftrelease> <leftmouse>:<c-u>call <SID>CLeftRelease()<cr>
"  call Dret("s:CLeftStart")
endfun

" ---------------------------------------------------------------------
" s:CLeftDrag: {{{2
fun! s:CLeftDrag()
"  call Dfunc("s:CLeftDrag() cleft_width=".s:cleft_width." cleft_height=".s:cleft_height)
  exe 'let keepbrush= @'.b:drawit_brush
"  call Decho("keepbrush<".keepbrush.">")

  " restore prior contents of block zone
  if exists("s:cleft_oldblock")
"   call Decho("draw prior contents: [".line(".").",".virtcol(".")."] line($)=".line("$"))
"   call Decho("draw prior contents<".s:cleft_oldblock.">")
   exe 'let @'.b:drawit_brush.'=s:cleft_oldblock'
   call s:PutBlock(b:drawit_brush,1)
  endif

  " move cursor to <leftmouse> position
  exe "norm! \<leftmouse>"

  " save new block zone contents
"  call Decho("save contents: [".line(".").",".virtcol(".")."] - [".(line(".")+s:cleft_height).",".(virtcol(".")+s:cleft_width)."]")
  let curline= line(".")
  call s:AutoCanvas(curline,curline + s:cleft_height,virtcol(".")+s:cleft_width)
  if s:cleft_width > 0 && s:cleft_height > 0
   exe "silent! norm! \<c-v>".s:cleft_width."l".s:cleft_height.'j"'.b:drawit_brush.'y'
  elseif s:cleft_width > 0
   exe "silent! norm! \<c-v>".s:cleft_width.'l"'.b:drawit_brush.'y'
  else
   exe "silent! norm! \<c-v>".s:cleft_height.'j"'.b:drawit_brush.'y'
  endif
  exe "let s:cleft_oldblock= @".b:drawit_brush
"  call Decho("s:cleft_oldblock=@".b:drawit_brush)
"  call Decho("cleft_height=".s:cleft_height." cleft_width=".s:cleft_width)
"  call Decho("save contents<".s:cleft_oldblock.">")

  " draw the brush
"  call Decho("draw brush")
"  call Decho("draw brush ".b:drawit_brush.": [".line(".").",".virtcol(".")."] line($)=".line("$"))
  exe 'let @'.b:drawit_brush.'=keepbrush'
  call s:PutBlock(b:drawit_brush,1)

"  call Dret("s:CLeftDrag")
endfun

" ---------------------------------------------------------------------
" s:CLeftRelease: {{{2
fun! s:CLeftRelease()
"  call Dfunc("s:CLeftRelease()")
  call s:CLeftDrag()
  nunmap <buffer> <c-leftdrag>
  nunmap <buffer> <c-leftrelease>
  unlet s:cleft_oldblock s:cleft_height s:cleft_width
"  call Dret("s:CLeftRelease")
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
