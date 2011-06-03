#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.6.1
 Author:         Matwachich

 Script Function:


#ce ----------------------------------------------------------------------------

#Region ### Functions ###
#cs
- Main Functions
	_GEng_ImageLoad($sPath, $width = Default, $height = Default, $x = 0, $y = 0, $w = Default, $h = Default)
	__GEng_Image_IsImage($hImage)
	__GEng_Image_hImg($hImage)
	__GEng_Image_DisposeAll()
#ce
#EndRegion ###

Global $__GEng_Images[1] = [0]

; # FUNCTION # ==============================================================================================
; Name...........:	_GEng_ImageLoad
; Description....:	Charge un fichier image pour �tre utiliser par GEngin
; Parameters.....:	$sPath
;					- Optionels
;					$width, $height = Taille de l'image (non sp�cifi� => Taille du fichier)
;					- Optionels: prendre une partie de l'objet Image (id�al pour les SpriteSheets)
;						Doivent TOUS �tre sp�cifi�s pour �tre pris en concid�ration
;					$x, $y = coordonn�es du point sup�rieur gauche du rectangle � prendre
;					$w, $h = largeur et hauteur du rectangle � prendre
; Return values..:	Succes - Objet Image
;					Echec - 0 et @error = 1
; Author.........:	Matwachich
; Remarks........:	
; ===========================================================================================================
Func _GEng_ImageLoad($sPath, $imgW = Default, $imgH = Default, $x = Default, $y = Default, $w = Default, $h = Default)
	Local $hImg = _GDIPlus_ImageLoadFromFile($sPath)
	If $hImg = -1 Then Return SetError(1, 0, 0)
	; ---
	Local $width, $height
	If $x <> Default And $y <> Default And $w <> Default And $h <> Default Then
		$width = $w
		$height = $h
	Else
		$x = 0
		$y = 0
		$width = _GDIPlus_ImageGetWidth($hImg)
		$height = _GDIPlus_ImageGetHeight($hImg)
		$w = $width
		$h = $height
	EndIf
	; ---
	Local $gContext, $newBmp, $gNewContext
	$gContext = _GDIPlus_ImageGetGraphicsContext($hImg)
	$newBmp = _GDIPlus_BitmapCreateFromGraphics($width, $height, $gContext)
	$gNewContext = _GDIPlus_ImageGetGraphicsContext($newBmp)
	_GDIPlus_GraphicsDrawImageRectRect($gNewContext, $hImg, $x, $y, $w, $h, 0, 0, $width, $height)
	; ---
	_GDIPlus_GraphicsDispose($gNewContext)
	_GDIPlus_GraphicsDispose($gContext)
	_GDIPlus_ImageDispose($hImg)
	; ---
	If $imgW <> Default And $imgH <> Default Then
		$hImg = __GDIPlus_ImageGetThumbnail($newBmp, $imgW, $imgH)
		_ArrayAdd($__GEng_Images, $hImg)
		_GDIPlus_BitmapDispose($newBmp)
		$width = $imgW
		$height = $imgH
	Else
		_ArrayAdd($__GEng_Images, $newBmp)
	EndIf
	; ---
	$__GEng_Images[0] += 1
	; ---
	Local $ret[3]
	$ret[0] = $__GEng_Images[0]
	$ret[1] = $width
	$ret[2] = $height
	; ---
	Return $ret
EndFunc


; ==============================================================
; ### Internals
; ==============================================================
Func __GEng_Image_IsImage($hImage)
	If Not IsArray($hImage) Then Return SetError(1, 0, 0)
	If UBound($hImage) <> 3 Then Return SetError(1, 0, 0)
	If $hImage[0] > $__GEng_Images[0] Then Return SetError(1, 0, 0)
	If $hImage[1] = -1 Or $hImage[2] = -1 Then Return SetError(1, 0, 0)
	; ---
	Return 1
EndFunc

Func __GEng_Image_hImg($hImage)
	If Not __GEng_Image_IsImage($hImage) Then Return SetError(1, 0, 0)
	; ---
	Return $__GEng_Images[$hImage[0]]
EndFunc

Func __GEng_Image_DisposeAll()
	For $i = 1 To $__GEng_Images[0]
		_GDIPlus_ImageDispose($__GEng_Images[$i])
		_GDIPlus_BitmapDispose($__GEng_Images[$i])
	Next
EndFunc

Func __GDIPlus_ImageGetThumbnail($hImg, $iW, $iH)
	Local $ret = DllCall($ghGDIPDll, "int", "GdipGetImageThumbnail", _
                                        "hwnd", $hImg, _
                                        "int", $iW, _
                                        "int", $iH, _
                                        "int*", 0, _
                                        "ptr", 0, _
                                        "ptr", 0)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	; ---
	Return SetError(0, 0, $ret[4])
EndFunc