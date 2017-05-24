SuperStrict



' Imports

	Framework BRL.GLMax2D
	Import BRL.RamStream
	Import BRL.Timer
	Import BRL.Random
	Import BRL.PNGLoader
	Import BRL.Retro
	Import BRL.StandardIO


	AppTitle = "SlideMe_v1.03  by M.Frank"


	
' Grafik

	Incbin "tile1.png"
	Global Tile1:TImage = LoadImage("Incbin::tile1.png")
	Incbin "tile2.png"
	Global Tile2:TImage = LoadImage("Incbin::tile2.png")
	Incbin "tile3.png"
	Global Tile3:TImage = LoadImage("Incbin::tile3.png")
	Incbin "tile4.png"
	Global Tile4:TImage = LoadImage("Incbin::tile4.png")
	Incbin "tile5.png"
	Global Tile5:TImage = LoadImage("Incbin::tile5.png")
	Incbin "tile6.png"
	Global Tile6:TImage = LoadImage("Incbin::tile6.png")


	SetGraphicsDriver GLMax2DDriver()
	Global GW:Int = 256, GH:Int = 320
	Graphics GW, GH
	MoveMouse(GW/2, GH/2)


	
	
	
' Globals
	Global Moves:Int = 0
	Global Minutes:Int = 0
	Global Seconds:Int = 0
	Global GameStartTime:Int = MilliSecs()
	Global Color:Byte = 1
	Global RandomLevel:Int = 1000
	Global LastFreeX:Int, LastFreeY:Int
	Global LastMovedX:Int, LastMovedY:Int
	Global LastMovedVal:Int
	
' Locals
	Local timer:TTimer = CreateTimer(60)
	Local mh:Int, mh2:Int
	Local ms:Int = MilliSecs()

' Map
	Local map:Byte[4,4]
	MakeMap(map)
	RandMap(map, RandomLevel, ms)



' Mainloop
	Repeat
	Cls
	ms = MilliSecs()
	mh = MouseHit(1)
	mh2 = MouseHit(2)
	
		DrawMap(map)
		UpdateMap(map, mh, mh2, ms)
		UpdateTime(ms)
		DrawTime(10, 272)
		ColorChange(mh)
		
	Flip
	WaitTimer timer
	Until AppTerminate() Or KeyHit (KEY_ESCAPE)








' TileMap

	Function MakeMap(map:Byte[,])	
		Local i:Byte = 1
		For Local y:Byte = 0 To 3
			For Local x:Byte = 0 To 3
				If i = 16
					map[x,y] = 0
					Exit
				End If
				map[x,y] = i
				i:+1	
			Next
		Next
	End Function
	
	Function RandMap(map:Byte[,], level:Int, ms:Int)
		SeedRnd ms
		Local direction:Byte = 0 ' 1 Oben, 2 Unten, 3 Links, 4 Rechts
		Local buffer:Byte = 0
		
		Local emptyX:Int = 3, emptyY:Int = 3
		
		Local swaped:Byte = False
		
		For Local i:Int = 0 To level - 1
			Repeat
				direction = Rand(1, 4)
				
				Select direction
					' Oben
					Case 1
						If CheckDirection(map, emptyX, emptyY, 1) = True
							buffer = map[emptyX,emptyY]
							map[emptyX,emptyY] = map[emptyX,emptyY-1]
							map[emptyX,emptyY-1] = buffer
							emptyY:-1
							swaped = True
						End If
						
					' Unten
					Case 2
						If CheckDirection(map, emptyX, emptyY, 2) = True
							buffer = map[emptyX,emptyY]
							map[emptyX,emptyY] = map[emptyX,emptyY+1]
							map[emptyX,emptyY+1] = buffer
							emptyY:+1
							swaped = True
						End If
					
					' Links
					Case 3
						If CheckDirection(map, emptyX, emptyY, 3) = True
							buffer = map[emptyX,emptyY]
							map[emptyX,emptyY] = map[emptyX-1,emptyY]
							map[emptyX-1,emptyY] = buffer
							emptyX:-1
							swaped = True
						End If
					
					' Rechts
					Case 4
						If CheckDirection(map, emptyX, emptyY, 4) = True
							buffer = map[emptyX,emptyY]
							map[emptyX,emptyY] = map[emptyX+1,emptyY]
							map[emptyX+1,emptyY] = buffer
							emptyX:+1
							swaped = True
						End If
					
				End Select
			Until swaped = True
			swaped = False
		Next
		
	End Function
	
	Function CheckDirection:Byte(map:Byte[,], x:Byte, y:Byte, dir:Int)
		If map[x,y] = 0
			Select dir
				' Oben
				Case 1
					If y - 1 >= 0 Return True
				' Unten
				Case 2
					If y + 1 <= 3 Return True
				' Links
				Case 3
					If x - 1 >= 0 Return True
				' Rechts
				Case 4
					If x + 1 <= 3 Return True
			End Select
			Return False
		End If
	End Function
	
	
	Function DrawMap(map:Byte[,])
		For Local y:Byte = 0 To 3
			For Local x:Byte = 0 To 3
				If map[x,y] <> 0
					Select Color
						Case 1
							DrawImage Tile1, x*64, y*64
						Case 2
							DrawImage Tile2, x*64, y*64
						Case 3
							DrawImage Tile3, x*64, y*64
						Case 4
							DrawImage Tile4, x*64, y*64
						Case 5
							DrawImage Tile5, x*64, y*64
						Case 6
							DrawImage Tile6, x*64, y*64
						Default
							DrawImage Tile1, x*64, y*64
					End Select
					If map[x,y] > 9
						SetColor 0, 0, 0
						DrawText Int(map[x,y]), x*64+23, y*64+26
						SetColor 255, 255, 255
					Else
						SetColor 0, 0, 0
						DrawText Int(map[x,y]), x*64+27, y*64+26
						SetColor 255, 255, 255
					End If
				End If
			Next
		Next
	End Function
	
	
	Function UpdateMap(map:Byte[,], mh:Int, mh2:Int, ms:Int)
		Local buffer:Byte
		
		' Undo last move
		If mh2
			If LastMovedVal <> 0
				map[LastFreeX, LastFreeY] = LastMovedVal
				map[LastMovedX, LastMovedY] = 0
				LastMovedVal = 0
			End If
		End If
		
		If mh
			If (MouseX()/64 <= 3 And MouseY()/64 <= 3) And (MouseX()/64 >= 0 And MouseY()/64 >= 0)
				If map[MouseX()/64, MouseY()/64] <> 0
					buffer = map[MouseX()/64, MouseY()/64]
					' Oben
					If MouseY()/64 - 1 >= 0
						If map[MouseX()/64, MouseY()/64 - 1] = 0
							map[MouseX()/64, MouseY()/64 - 1] = buffer
							map[MouseX()/64, MouseY()/64] = 0
							LastFreeX = MouseX()/64
							LastFreeY = MouseY()/64
							LastMovedX = MouseX()/64
							LastMovedY = MouseY()/64 - 1
							LastMovedVal = buffer
							Moves:+1
						End If
					End If
					' Unten
					If MouseY()/64 + 1 <= 3
						If map[MouseX()/64, MouseY()/64 + 1] = 0
							map[MouseX()/64, MouseY()/64 + 1] = buffer
							map[MouseX()/64, MouseY()/64] = 0
							LastFreeX = MouseX()/64
							LastFreeY = MouseY()/64
							LastMovedX = MouseX()/64
							LastMovedY = MouseY()/64 + 1
							LastMovedVal = buffer
							Moves:+1
						End If
					End If
					' Rechts
					If MouseX()/64 + 1 <= 3
						If map[MouseX()/64 + 1, MouseY()/64] = 0
							map[MouseX()/64 + 1, MouseY()/64] = buffer
							map[MouseX()/64, MouseY()/64] = 0
							LastFreeX = MouseX()/64
							LastFreeY = MouseY()/64
							LastMovedX = MouseX()/64 + 1
							LastMovedY = MouseY()/64
							LastMovedVal = buffer
							Moves:+1
						End If
					End If
					' Links
					If MouseX()/64 - 1 >= 0
						If map[MouseX()/64 - 1, MouseY()/64] = 0
							map[MouseX()/64 - 1, MouseY()/64] = buffer
							map[MouseX()/64, MouseY()/64] = 0
							LastFreeX = MouseX()/64
							LastFreeY = MouseY()/64
							LastMovedX = MouseX()/64 - 1
							LastMovedY = MouseY()/64
							LastMovedVal = buffer
							Moves:+1
						End If
					End If
				End If
			End If
		End If
		
		
		' Überprüfen ob Spiel gewonnen ( Puzzle richtig sortiert)
		Local i:Int = 1
		Local completed:Byte = False
		For Local y:Byte = 0 To 3
			For Local x:Byte = 0 To 3
				If i <> 16
					If map[x,y] = i
						completed = True
					Else
						completed = False
						Exit
					End If
				End If
				i:+1
			Next
		Next
		
		If completed = True
			Cls
			DrawText "Puzzle complete!", 67, 40
			Drawtime(90, 120)
			DrawText "Press Mouse for New Game!", 28, 250
			FlushMouse()
			Flip
			Repeat
				If MouseHit(1) Or MouseHit(2) Or MouseHit(3) Then Exit
				If AppTerminate() Then End
			Forever
			MakeMap(map)
			RandMap(map, RandomLevel, ms)
			Minutes = 0
			Seconds = 0
			Moves = 0
			GameStartTime = ms
		End If
	End Function
	
	
	
	
' Time
	Function UpdateTime(ms:Int)
		If Moves = 0 Then GameStartTime = ms
		If Moves > 0
			Seconds = (ms - GameStartTime) * 1000
			If Len(String(Seconds)) >= 8
				If Int(Mid(String(Seconds), 1, 2)) >= 60
					Minutes:+ 1
					GameStartTime = ms
				End If
			End If
		End If
	End Function
	
	Function DrawTime(x:Int, y:Int)
		DrawText "Moves: " + Moves, x, y
		Local strLen:Int = Len(String(Seconds))
		If strLen = 6
			DrawText "Time: " + Minutes + ":00" , x,y+20
		ElseIf strLen = 7
			Local strSeconds:String = Mid(String(Seconds), 1, 1)
			DrawText "Time: " + Minutes + ":0" + strSeconds , x,y+20
		Else
			Local strSeconds:String = Mid(String(Seconds), 1, 2)
			DrawText "Time: " + Minutes + ":" + strSeconds , x,y+20
		End If
	End Function
	
	
' Farben ändern
	Function ColorChange(mh:Int)
		If RectsOverlap(MouseX(), MouseY(), 1, 1, 190, 300, 70, 15)
			SetColor 200, 200, 150
			DrawText "Color: " + Color, 180, 300
			DrawLine 178, 312, 244, 312
			If mh
				Color:+1
				If Color > 6 Then Color = 1
			End If
		Else
			SetColor 180, 180, 180
			DrawText "Color: " + Color, 185, 300
			DrawLine 183, 312, 249, 312
		End If
		SetColor 255, 255, 255
	End Function
	Function RectsOverlap:Byte(x1:Int, y1:Int, w1:Int, h1:Int, x2:Int, y2:Int, w2:Int, h2:Int)
		If x1 <= (x2 + w2) And y1 <= y2 + h2 And (x1 + w1) >= x2 And (y1 + h1) >= y2 Then Return True
		Return False
	End Function
