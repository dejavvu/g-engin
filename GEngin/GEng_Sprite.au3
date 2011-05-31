#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.6.1
 Author:         Matwachich

 Script Function:


#ce ----------------------------------------------------------------------------

#Region ### Functions ###
#cs
- Main Functions
	_GEng_Sprite_Create($hImage = Default)
	_GEng_Sprite_ImageSet(ByRef $hSprite, ByRef $hImage, $x = Default, $y = Default, $w = Default, $h = Default)
	_GEng_Sprite_ImageSetRect(ByRef $hSprite, $x, $y, $w, $h, $InitSize = 0)
	_GEng_Sprite_Draw(ByRef $hSprite, $iCalculateMovements = 1)
	_GEng_Sprite_Del(ByRef $hSprite)
	__GEng_Sprite_IsSprite($hSprite)
	__GEng_Sprite_ContainsImage($hSprite)
	__GEng_Sprite_InitArray(ByRef $a)
#ce
#EndRegion ###


Global Const $__GEng_SpritesArrayUB = 36
Global Enum $GEng_Origin_Mid, $GEng_Origin_TL, $GEng_Origin_TR, $GEng_Origin_BL, $GEng_Origin_BR

Global Enum _
	$_gSpr_hBuffer, $_gSpr_iImg, $_gSpr_ImgX, $_gSpr_ImgY, $_gSpr_ImgW, $_gSpr_ImgH, _
	$_gSpr_PosX, $_gSpr_PosY, $_gSpr_Width, $_gSpr_Height, $_gSpr_OriX, $_gSpr_OriY, _
	$_gSpr_SpeedX, $_gSpr_SpeedY, $_gSpr_AccelX, $_gSpr_AccelY, $_gSpr_SpeedMax, _
	$_gSpr_InnertieX, $_gSpr_InnertieY, _
	$_gSpr_AngleDeg, $_gSpr_AngleRad, _
	$_gSpr_AngleSpeed, $_gSpr_AngleAccel, $_gSpr_AngleSpeedMax, $_gSpr_AngleInnertie, _
	$_gSpr_AngleOriDeg, $_gSpr_AngleOriRad, _
	$_gSpr_AnimFrame, $_gSpr_AnimDelayMulti, _
	$_gSpr_CollX, $_gSpr_CollY, $_gSpr_CollW, $_gSpr_CollH, $_gSpr_CollType, _
	$_gSpr_MoveTimer, $_gSpr_AnimTimer


; # FUNCTION # ==============================================================================================
; Name...........:	_GEng_Sprite_Create
; Description....:	Cr�er un Objet Sprite
; Parameters.....:	$hImage = Objet Image � assigner au sprite (Optionel)
;						Si Defaut, Objet Sprite vide
; Return values..:	Objet Sprite
; Author.........:	Matwachich
; Remarks........:	
; ===========================================================================================================
Func _GEng_Sprite_Create($hImage = Default)
	Local $hSprite[$__GEng_SpritesArrayUB]
	__GEng_Sprite_InitArray($hSprite)
	; ---
	If $hImage <> Default Then _GEng_Sprite_ImageSet($hSprite, $hImage)
	_GEng_Sprite_AnimRewind($hSprite)
	; ---
	Return $hSprite
EndFunc

; # FUNCTION # ==============================================================================================
; Name...........:	_GEng_Sprite_ImageSet
; Description....:	Assigne un objet Image � un Objet Sprite
; Parameters.....:	$hSprite = Objet Sprite
;					$hImage = Objet Image � assigner
;					- Optionels: prendre une partie de l'objet Image (id�al pour les SpriteSheets)
;						Doivent TOUS �tre sp�cifi�s pour �tre pris en concid�ration
;					$x, $y = coordonn�es du point sup�rieur gauche du rectangle � prendre
;					$w, $h = largeur et hauteur du rectangle � prendre
; Return values..:	Succes - 1
;					Echec - 0 et @error = 1
; Author.........:	Matwachich
; Remarks........:	Si il n'y avait aucune image associ�e au sprite lors de l'appel � cette fonction,
;						alors la taille du sprite est initialis� � la taille de l'image assign�
;						(appel � _GEng_Sprite_SizeSet)
; ===========================================================================================================
Func _GEng_Sprite_ImageSet(ByRef $hSprite, ByRef $hImage, $x = Default, $y = Default, $w = Default, $h = Default) ; If Default => 0,0,ImgW,ImgH
	If Not __GEng_Sprite_IsSprite($hSprite) Then Return SetError(1, 0, 0)
	If Not __GEng_Image_IsImage($hImage) Then Return SetError(1, 0, 0)
	; ---
	$hSprite[$_gSpr_iImg] = $hImage[0] ; Image Index
	; ---
	If $x <> Default And $y <> Default And $w <> Default And $h <> Default Then
		$hSprite[$_gSpr_ImgX] = $x
		$hSprite[$_gSpr_ImgY] = $y
		$hSprite[$_gSpr_ImgW] = $w
		$hSprite[$_gSpr_ImgH] = $h
	Else
		$hSprite[$_gSpr_ImgX] = 0
		$hSprite[$_gSpr_ImgY] = 0
		$hSprite[$_gSpr_ImgW] = $hImage[1]
		$hSprite[$_gSpr_ImgH] = $hImage[2]
	EndIf
	; D�j� fait dans _GEng_SpriteSetSize()
	;$hSprite[9] = $hSprite[3]
	;$hSprite[10] = $hSprite[4]
	; ---
	If $hSprite[$_gSpr_Width] = 0 And $hSprite[$_gSpr_Height] = 0 Then _ ; Si il n'y avait aucune image dans le sprite
		_GEng_Sprite_SizeSet($hSprite, -1, -1) ; on initialiser la taille (Size) aux dimensions de l'image
	; ---
	Return 1
EndFunc

; # FUNCTION # ==============================================================================================
; Name...........:	_GEng_Sprite_ImageSetRect
; Description....:	Change le rectangle s�lection� de l'objet image actuellement assign� � l'objet sprite
; Parameters.....:	$hSprite = Objet Sprite
;					- Doivent TOUS �tre sp�cifi�s pour �tre pris en concid�ration
;					$x, $y = coordonn�es du point sup�rieur gauche du rectangle � prendre
;					$w, $h = largeur et hauteur du rectangle � prendre
;					$InitSize = Si 1, la taille du sprite est initialis� � la taille du rectangle
;						s�lection� de l'objet image
; Return values..:	Succes - 1
;					Echec - 0 et @error = 1
; Author.........:	Matwachich
; Remarks........:	
; ===========================================================================================================
Func _GEng_Sprite_ImageSetRect(ByRef $hSprite, $x, $y, $w, $h, $InitSize = 0)
	If Not __GEng_Sprite_IsSprite($hSprite) Then Return SetError(1, 0, 0)
	; ---
	$hSprite[$_gSpr_ImgX] = $x
	$hSprite[$_gSpr_ImgY] = $y
	$hSprite[$_gSpr_ImgW] = $w
	$hSprite[$_gSpr_ImgH] = $h
	; ---
	If $InitSize Then _
	_GEng_Sprite_SizeSet($hSprite, -1, -1) ; Pour initialiser la taille (Size) aux dimensions de l'image
	; ---
	Return 1
EndFunc

; # FUNCTION # ==============================================================================================
; Name...........:	_GEng_Sprite_Draw
; Description....:	D�ssine un sprite � l'�cran selon ses attribut position
; Parameters.....:	$hSprite = Objet Sprite
;					$iCalculateMovements = Si 1, alors tous les mouvements du sprite sont calcul� selon ses
;						attribut vitesse, acc�l�ration, innertie. et Vitesse, acc�l�ration et innertie de rotation
; Return values..:	Succes - 1
;					Echec - 0 et @error = 1
; Author.........:	Matwachich
; Remarks........:	Un sprite fix (arri�re plan, objet de d�core immobile) devrai toujour avoir $iCalculateMovements = 0
; ===========================================================================================================
Func _GEng_Sprite_Draw(ByRef $hSprite, $iCalculateMovements = 1)
	If Not __GEng_Sprite_IsSprite($hSprite) Then Return SetError(1, 0, 0)
	If Not __GEng_Sprite_ContainsImage($hSprite) Then Return SetError(1, 0, 0)
	; ---
	If $iCalculateMovements Then _GEng_Sprite_Move($hSprite)
	; ---
	Local $hBuffer = $hSprite[$_gSpr_hBuffer]
	Local $imgIndex = $hSprite[$_gSpr_iImg]
	; ---
	Local $rotDeg = $hSprite[$_gSpr_AngleDeg]
	Local $rotRad = $hSprite[$_gSpr_AngleRad]
	; ---
	Local $posX = $hSprite[$_gSpr_PosX], $posY = $hSprite[$_gSpr_PosY]
	Local $oriX = $hSprite[$_gSpr_OriX], $oriY = $hSprite[$_gSpr_OriY]
	Local $sizeW = $hSprite[$_gSpr_Width], $sizeH = $hSprite[$_gSpr_Height]
	; ---
	Local $sheetX = $hSprite[$_gSpr_ImgX], $sheetY = $hSprite[$_gSpr_ImgY]
	Local $sheetW = $hSprite[$_gSpr_ImgW], $sheetH = $hSprite[$_gSpr_ImgH]
	; ---
	Local $ret
	If $rotDeg = 0 Then ; Si pas de rotation => Dessine sur le buffer principal
		$ret = _GDIPlus_GraphicsDrawImageRectRect($__GEng_hBuffer, $__GEng_Images[$imgIndex], _
		$sheetX, $sheetY, $sheetW, $sheetH, _ ; region de l'image d'origin
		$posX - $oriX, $posY - $oriY, _ ; position � l'�cran
		$sizeW, $sizeH) ; taille � l'�cran
		
		If $__GEng_Debug Then
			_GEng_Debug_DrawRect(0, $posX - $oriX, $posY - $oriY, $sizeW, $sizeH)
			_GEng_Debug_DrawCircle(1, $posX, $posY, 2)
			_GEng_Debug_DrawCircle(3, $posX - $oriX, $posY - $oriY, 2)
		EndIf
		
	Else ; Si rotation => Calcule la rotation et position et dessine sur le buffer personnel du sprite
		Local $matrix = _GDIPlus_MatrixCreate()
		_GDIPlus_MatrixRotate($matrix, $rotDeg)
		_GDIPlus_MatrixTranslate($matrix, $posX * Cos(-$rotRad) - $posY * Sin(-$rotRad), $posX * Sin(-$rotRad) + $posY * Cos(-$rotRad))
		_GDIPlus_GraphicsSetTransform($hBuffer, $matrix)
		; ---
		$ret = _GDIPlus_GraphicsDrawImageRectRect($hBuffer, $__GEng_Images[$imgIndex], _
		$sheetX, $sheetY, $sheetW, $sheetH, _
		-1 * $oriX, -1 * $oriY, _
		$sizeW, $sizeH)
		
		If $__GEng_Debug Then
			_GEng_Debug_DrawRect(0, -1 * $oriX, -1 * $oriY, $sizeW, $sizeH, $hBuffer)
			_GEng_Debug_DrawCircle(1, 0, 0, 2, $hBuffer)
			_GEng_Debug_DrawCircle(3, -1 * $oriX, -1 * $oriY, 2, $hBuffer)
			; ---
			_GEng_Debug_DrawVector(2, 0, 0, 50, 0, $hBuffer)
			_GEng_Debug_DrawVector(2, 0, 0, 0, 50, $hBuffer)
		EndIf
		
		; ---
		_GDIPlus_MatrixDispose($matrix)
	EndIf
	
	; ---
	Return $ret
EndFunc

; # FUNCTION # ==============================================================================================
; Name...........:	_GEng_Sprite_Del
; Description....:	Supprime un Objet Sprite
; Parameters.....:	$hSprite = Objet Sprite
; Return values..:	1
; Author.........:	Matwachich
; Remarks........:	
; ===========================================================================================================
Func _GEng_Sprite_Del(ByRef $hSprite)
	If Not __GEng_Sprite_IsSprite($hSprite) Then Return SetError(1, 0, 0)
	; ---
	$hSprite = 0
	; ---
	Return 1
EndFunc

; ==============================================================
; ### Internals
; ==============================================================
Func __GEng_Sprite_IsSprite($hSprite)
	If Not IsArray($hSprite) Then Return SetError(1, 0, 0)
	If UBound($hSprite) < $__GEng_SpritesArrayUB Then Return SetError(1, 0, 0)
	; ---
	Return 1
EndFunc

Func __GEng_Sprite_ContainsImage($hSprite)
	If Not __GEng_Sprite_IsSprite($hSprite) Then Return SetError(1, 0, 0)
	; ---
	If $hSprite[$_gSpr_iImg] = 0 Then Return SetError(1, 0, 0)
	; ---
	Return 1
EndFunc

Func __GEng_Sprite_InitArray(ByRef $a)
	For $i = 0 To $__GEng_SpritesArrayUB - 1
		$a[$i] = 0
	Next
	; ---
	$a[$_gSpr_AnimDelayMulti] = 1 ; AnimDelay Multiplier
	$a[$_gSpr_hBuffer] = __GEng_GetBuffer()
EndFunc
