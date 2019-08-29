#include <IE.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <SliderConstants.au3>

; TODO:
; Change volume
; Do not include channels

Local $oIE = _IECreate("https://www.youtube.com/", 0, 1, 1, 1)
Local $oIE2 = _IECreate("https://www.youtube.com/", 0, 1, 1, 1)
Global $results

GUICreate("YT Music Player", 320, 430)
Local $search_bar = GUICtrlCreateInput("", 10, 10, 200, 20)
Local $search_button = GUICtrlCreateButton("Search", 220, 10, 50, 20)
Local $idMylist = GUICtrlCreateListView("Title", 10, 40, 300, 300, BitOR($WS_BORDER, $WS_VSCROLL))
_GUICtrlListView_SetColumnWidth($idMylist, 0, 300)
Local $play_button = GUICtrlCreateButton("Pause", 10, 350, 40, 30)
Local $skip_button = GUICtrlCreateButton("Skip add", 260, 350, 50, 30)
Local $song_label = GUICtrlCreateLabel("Song: ", 10, 390, 400, 40)

GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
GUISetState(@SW_SHOW)

While 1
   Switch GUIGetMsg()
   Case $GUI_EVENT_CLOSE
	  CloseProgram()
   Case $search_button
	  Search(GUICtrlRead($search_bar))
   Case $play_button
	  _IEAction(GetPlayButton(), "click")
	  If GUICtrlRead($play_button) = "Play" Then
		 GUICtrlSetData($play_button, "Pause")
	  Else
		 GUICtrlSetData($play_button, "Play")
	  EndIf
   Case $skip_button
	  _IEAction($oIE, "refresh")
   EndSwitch
WEnd

Func CloseProgram()
   _IEQuit($oIE)
   _IEQuit($oIE2)
   Exit
EndFunc

Func WM_NOTIFY($hWnd, $MsgID, $wParam, $lParam)
   Local $tagNMHDR, $event, $hwndFrom, $code
   $tagNMHDR = DllStructCreate("int;int;int", $lParam)
   If @error Then Return 0
   $code = DllStructGetData($tagNMHDR, 3)
   If $wParam = $idMylist And $code = -3 Then
	  _IENavigate($oIE, $results[_GUICtrlListView_GetSelectedIndices($idMylist)])
	  _IELoadWait($oIE)
	  $title = _IEGetObjById($oIE, "eow-title")
	  GUICtrlSetData($song_label, "Song: " & $title.innerText)
   EndIf
   Return $GUI_RUNDEFMSG
EndFunc

; Skip add --> reload page

Func Search($str)
   _IENavigate($oIE2, "https://www.youtube.com/results?search_query=" & $str)
   _IELoadWait($oIE2)
   GetSearchResults()
EndFunc

Func GetSearchResults()
   _GUICtrlListView_DeleteAllItems($idMylist)
   $temp = _IEGetObjById($oIE2, "results").getElementsByClassName("yt-uix-tile-link yt-ui-ellipsis yt-ui-ellipsis-2 yt-uix-sessionlink spf-link ")
   Local $temp2[$temp.length]
   $results = $temp2
   Local $i = 0
   For $t in $temp
	  Local $idItem = GUICtrlCreateListViewItem($i, $idMylist)
	  GUICtrlSetData($idItem, StringReplace($t.innerText, "|", " "))
	  $results[$i] = $t.href
	  $i = $i + 1
   Next
EndFunc

Func GetPlayButton()
   Local $buttons = $oIE.document.GetElementsByTagName("button")
   Local $play_btn
   For $btn in $buttons
	  $class = $btn.GetAttribute("class")
	  If $class = "ytp-play-button ytp-button" Then
		 $play_btn = $btn
	  EndIf
   Next
   Return $play_btn
EndFunc