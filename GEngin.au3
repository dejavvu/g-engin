#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.6.1
 Author:         Matwachich

 Script Function:
	G-Engin:
		G-Engin (GEng) est un UDF qui permet de g�rer un affichage 2D
		avec AutoIt simplement.
		Il est bas� sur GDI+.
		
	Version 2.0: (29/05/2011)
	- Lance une fen�tre de rendu
	- Chargement de fichiers images (BMP, ICON, GIF, JPEG, Exif, PNG, TIFF, WMF, EMF)
		avec gestion de la transparence (PNG, ICO ...)
	- Cr�ation d'objets Sprites, qui sont le coeur du moteur:
		+ Un objet sprite doit contenir une image, ou une portion d'image
		+ Il poss�de diff�rent attributs:
			Position (x, y)
			Taille (x, y)
			Point d'origin (x, y)
			Vitesse (x, y) et vitesse max (pixels/s)
			Accel�ration (x, y) (pixels/s�)
			Innertie (x, y) (pixels/s�)
			Angle (Degres)
			Vitesse de rotation (Deg/s)
			Acc�l�ration de rotation (Deg/s�)
			Innertie de rotation (Deg/s�)
		+ Il poss�de une zone de collision, qui peut �tre soir un point, un cercle, 
			ou un rectangle
		+ Enfin, il peut �tre anim� gr�ce � un objer Animation
		+ PS: On peut attacher des variables � un sprite (voir GEng_Sprite_Append.au3)
	- Fonctions de calcules g�om�triques
		+ Distance, Angle, Vecteur entre: point-point, sprite-point, sprite-sprite
		+ Convertion Vecteur->Angle, Angle->Vecteur (en sp�cifiant la grandeur du vecteur)
	- Gestion des collisions entre sprites, et avec les bords de l'�cran
	- Affichage de texte (couleur, police, taille, format ...)
	- Gestion rudimentaire des sons (bass.dll)
	
	Remarques:
	- L'unit� de distance est le pixel => vitesse = pixels/s, acc�l�ration = pixels/s�
	- L'unit� d'angle est le degr� => vitesse de rotation = Deg/s, acc�l�ration de rotation = Deg/s�
	- Le point 0, 0 est situ� au coin sup�rieur gauche de l'�cran
	- En ce qui concerne les angles:
		+ 0 correspond � la direction droite
		+ un angle (+) signifie 'sens horaire', et inversement.
		+ l'angle d'un sprite sera toujours stock� sous la forme d'une valeur entre 0 et 359
			jamais un _GEng_Sprite_AngleGet ne retournera un nombre sup�rieur � 359 ou inf�rieur � 0
			Par contre, vous pouvez sp�cifier n'IMPORTE quel valeur pour un angle et elle sera toujours
			r�duite � la valeur correspondante entre 0 et 359
		+ Concernant la vitesse et acc�l�ration de rotation: une valeur (+) signifie 'sens horaire'
			et inversement
	- L'innertie: est d�finie dans cet UDF comme 'une acc�l�ration qui fait tendre la vitesse vers 0'
		vous pouvez sp�cifier n'importe quelle valeur qu'elle soit + ou -, elle sera prise comme valeur
		absolue
	- Un objet Sprite tourne autour de sont point d'origine, et est positionn� pas rapport � ce point
	
	To do:
	- Effets sonors (bass_fx.dll)
	- Perm�tre la transmission de forces lors des collisions!
	- Meilleur gestion des erreurs

#ce ----------------------------------------------------------------------------

#include <GDIPlus.au3>
#include <Array.au3>
#include <WinApi.au3>
#include "GEngin\Bass\bass.au3"

; ##############################################################

Global $__GEng_hGui = -1
Global $__GEng_WinW = -1, $__GEng_WinH = -1
Global $__GEng_hGraphic = -1
Global $__GEng_hBitmap = -1
Global $__GEng_hBuffer = -1
Global $__GEng_ScreenDC = -1
Global $__GEng_CompatibleDC = -1
Global $__GEng_FrameTimer = 0
; ---
Global Const $__GEng_PI = 4 * ATan(1)


; ##############################################################

Global $__GEng_Debug = 0
Global $_Arrow, _
	$_dbg_Arrow0 = 0, $_dbg_Arrow1, $_dbg_Arrow2, $_dbg_Arrow3, $_dbg_Arrow4, _
	$_dbg_pen0 = 0, $_dbg_pen1, $_dbg_pen2, $_dbg_pen3, $_dbg_pen4

; ##############################################################

#include "GEngin\GEng_System.au3"
#include "GEngin\GEng_Image.au3"
#include "GEngin\GEng_Sprite.au3"
#include "GEngin\GEng_Sprite_Collision.au3"
#include "GEngin\GEng_Sprite_Animation.au3"
#include "GEngin\GEng_Sprite_Dynamics.au3"
#include "GEngin\GEng_Sprite_Get.au3"
#include "GEngin\GEng_Sprite_Set.au3"
#include "GEngin\GEng_Sprite_Append.au3"
#include "GEngin\GEng_Animation.au3"
#include "GEngin\GEng_Draw.au3"
#include "GEngin\GEng_Geometry.au3"
#include "GEngin\GEng_Text.au3"
#include "GEngin\GEng_Sound.au3"
; ---
#include "GEngin\GEng_Debug.au3"
