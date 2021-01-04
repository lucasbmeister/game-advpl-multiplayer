#include "totvs.ch"
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Class SquareMulti From BaseGameObjectMulti

    Method New() Constructor
    Method Update()
    Method HideGameObject() 

EndClass
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method New(oWindow, nTop, nLeft, nHeight, nWidth, cName) Class SquareMulti
    Local cStyle as char 
    Static oInstance as object

    _Super:New(oWindow)

    oInstance := Self
    //cStyle := "TPanel { background-color: black }"
    cStyle := "TPanel { border: 1 solid black }"

    ::oGameObject := TPanel():New(nTop, nLeft, cName, oInstance:oWindow,,,,,, nWidth, nHeight)
    ::oGameObject:SetCss(cStyle)

Return Self

/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method Update() Class SquareMulti
Return
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method HideGameObject() Class SquareMulti

   ::oGameObject:Hide()
    FreeObj(::oGameObject)

Return