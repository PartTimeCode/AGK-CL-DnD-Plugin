
IncludeFile "AGKPluginWrapper.pbi"

Global agkHWND.i

Macro S(str)
  PeekS(@str, StringByteLength(str), #PB_Ascii)
EndMacro

Structure DROP_INFO
  file.s
EndStructure

Global NewList drop.DROP_INFO()

Procedure agkWndProc(hwnd, uMsg, wParam, lParam)
  
  Define *oldProc=GetProp_(hwnd, "oldProc")
  
  Select uMsg 
      
    ; Select window message
    Case #WM_CLOSE
      
      RemoveProp_(hwnd, "oldProc")
 
    Case #WM_DROPFILES                                                                        ; Files were dropped
      
      *DroppedFilesArea = wParam                                                              ; Pointer to the structure that contains the dropped files
      NumberOfCharactersDropped.i = DragQueryFile_(*DroppedFilesArea , $FFFFFFFF, #Null$, 0)  ; Return value is a count of the characters copied
      ClearList(drop())
      
      For index.i = 0 To NumberOfCharactersDropped.i - 1                                      ; Iterate through the character size returned
        
        file_path.s = Space(#MAX_PATH)                                                        ; Build a buffer big enough for the characters to be copied
        DragQueryFile_(*DroppedFilesArea , index, @file_path, #MAX_PATH)                       ; Get next filename character
        
        GetCursorPos_(p.POINT) 
        GetClientRect_(hwnd, rc.RECT)

        AddElement( drop() )
        drop()\file=file_path
        
      Next
      
      DragFinish_(*DroppedFilesArea)                                                                      ; Clear the filename buffer area
  EndSelect                                                                                              ; No more selections
  
  ProcedureReturn CallWindowProc_(*oldProc, hwnd, uMsg, wParam, lParam)
  
EndProcedure

ProcedureCDLL CL_SetDrop(name.s, state)
  
  agkHWND = FindWindow_(#Null, S(name))
  If IsWindow_(agkHWND)
    
    oldProc = GetWindowLongPtr_(agkHWND, #GWLP_WNDPROC)
    SetProp_(agkHWND, "oldProc", oldProc)
    SetWindowLongPtr_(agkHWND, #GWLP_WNDPROC, @agkWndProc())
    
    DragAcceptFiles_(agkHWND, state)
  Else
    MessageRequester("CL", "Could not find window with name "+S(name))
  EndIf
  ProcedureReturn 0
  
EndProcedure

ProcedureCDLL CL_DropCount()
  
  Protected Result.i
  Result = ListSize(drop())
  ProcedureReturn Result
  
EndProcedure

ProcedureCDLL CL_DropGet(Index.l)
  
  Protected Result.s=""
  If Index>=0 And Index < ListSize(drop())
    
    If SelectElement(drop(), Index)
      Result = drop()\file
      *StringPtr = agkMakeString(Result)
      ProcedureReturn *StringPtr    
    Else
      MessageRequester("", "Nothing at index")
    EndIf
    
  Else
    MessageRequester("", "Index ("+Str(Index)+")out of range")
  EndIf

  
EndProcedure

ProcedureCDLL CL_DropClear()
  If ListSize(drop()) > 0
    ClearList(drop())
  EndIf
EndProcedure



ProcedureCDLL CL_Count()
  
  Protected Result.i
  Result = CountProgramParameters()
  ProcedureReturn Result
  
EndProcedure

ProcedureCDLL CL_Get(Index.l)
  
  Protected Result.s
  Result = ProgramParameter(Index)
  *StringPtr = agkMakeString(Result)
  ProcedureReturn *StringPtr
  
EndProcedure

ProcedureCDLL CL_GetPathPart(file.s)
  
  Protected Result.s
  Result = GetPathPart(S(file))
  *StringPtr = agkMakeString(Result)
  ProcedureReturn *StringPtr
  
EndProcedure

ProcedureCDLL CL_GetFilePart(file.s, ext.b)
  
  Protected Result.s
  If ext
    Result = GetFilePart(S(file))
  Else
    Result = GetFilePart(S(file), #PB_FileSystem_NoExtension)
  EndIf
  
  *StringPtr = agkMakeString(Result)
  ProcedureReturn *StringPtr
  
EndProcedure

ProcedureCDLL CL_GetExtPart(file.s, dot.b)
  
  Protected Result.s
  If dot
    Result = "."+GetExtensionPart(S(file))
  Else
    Result = GetExtensionPart(S(file))
  EndIf
  *StringPtr = agkMakeString(Result)
  ProcedureReturn *StringPtr
  
EndProcedure

ProcedureCDLL CL_GetMIMEType(Extension.s)
  Extension = "." + S(Extension)
  hKey.l = 0
  KeyValue.s = Space(255)
  datasize.l = 255
  If RegOpenKeyEx_(#HKEY_CLASSES_ROOT, Extension, 0, #KEY_READ, @hKey)
      KeyValue = "application/octet-stream"
  Else
      If RegQueryValueEx_(hKey, "Content Type", 0, 0, @KeyValue, @datasize)
          KeyValue = "application/octet-stream"
      Else
          KeyValue = Left(KeyValue, datasize-1)
      EndIf
    RegCloseKey_(hKey)
  EndIf
  *StringPtr = agkMakeString(KeyValue)
  ProcedureReturn *StringPtr
EndProcedure
 

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 87
; FirstLine = 46
; Folding = 4+-
; EnableXP
; EnableUnicode