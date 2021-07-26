# AGK-CL-DnD-Plugin
Small plugin that provides commandline access and system wide drag and drop file access on the AppGameKit window


#Example:

#Import_Plugin CL as cl

SetErrorMode(2)
SetWindowTitle( "CL - Example" )
SetWindowSize( 1024, 768, 0 )
SetWindowAllowResize( 1 )
SetVirtualResolution( 1024, 768 )
SetOrientationAllowed( 1, 1, 1, 1 )
SetSyncRate( 30, 0 )
SetScissor( 0,0,0,0 )
UseNewDefaultFonts( 1 )
SetClearColor(255,255,255)

// Enable file drop on window
cl.SetDropEnable("CL - Example", 1)

// Command Line
if cl.Count()>0
	for i=0 to cl.Count()-1
		LoadSpriteFromImage( "raw:"+cl.Get(i), 10*i, 10*i)
    next
endif
	
drag_sprite = -1
drag_enable = 0
drag_offset_x=0
drag_offset_y=0

do
	mouse_x = GetRawMouseX()
	mouse_y = GetRawMouseY()
	
	// File Drop
	if cl.DropCount()>0
		
		for i=0 to cl.DropCount()-1
			//message(cl.DropGet(i))
			LoadSpriteFromImage( "raw:"+cl.DropGet(i) , mouse_x, mouse_y)
		next
		cl.DropClear() // important, clear the list or this will repeat
	endif
	
	for i=0 to aSprite.length
		id = aSprite[i].spriteID
		if GetSpriteExists(id)
			if GetSpriteHit(ScreenToWorldX(mouse_x), ScreenToWorldY(mouse_y)) = id
				SetSpriteColor(id, 255,0,0,255)
				if GetRawMouseLeftPressed()
					drag_sprite=id
					drag_enable=1
					drag_offset_x = mouse_x-GetSpriteX(id)
					drag_offset_y = mouse_y-GetSpriteY(id)
				endif
			else
				SetSpriteColor(id, 255,255,255,255)
			endif
		endif
	next
	
	if GetSpriteExists(drag_sprite)
		if GetRawMouseLeftState()
			SetSpritePosition(drag_sprite, mouse_x-drag_offset_x, mouse_y-drag_offset_y)
		endif
		x=GetSpriteX(drag_sprite)
		y=GetSpriteY(drag_sprite)		
		DrawBox(x, y, x+GetSpriteWidth(drag_sprite), y+GetSpriteHeight(drag_sprite), 255,255,255,255,0)
	endif
	
	if GetRawMouseLeftReleased()
		drag_enable=0
	endif	

    Sync()
loop

Type tSpriteInfo
	imagePath as string 
	imageID as integer
	spriteID as integer
EndType

Global aSprite as tSpriteInfo[-1]

Function IsImage(filePath as string)
	
	Result as integer
	if GetFileExists(filePath)
		Select cl.GetMIMEType(cl.GetExtPart(filePath, 0))
			Case "image/jpeg":
				Result=1
			EndCase
			Case "image/png":
				Result=1
			EndCase
		EndSelect
	endif
	
EndFunction Result

Function LoadSpriteFromImage(image as string, x, y)
	
	if IsImage(image)
		spr as tSpriteInfo
		spr.imagePath=image
		spr.imageID = LoadImage(spr.imagePath)
		spr.spriteID = CreateSprite(spr.imageID)
		SetSpritePosition(spr.spriteID, x, y)
		aSprite.insert(spr)
	endif
	
EndFunction
