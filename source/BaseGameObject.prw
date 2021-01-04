#include "totvs.ch"

Class BaseGameObjectMulti From LongNameClass

    Data cAssetsPath
    Data oWindow
    Data cTag
    Data oGameObject
    Data cInternalId
    Data lDestroy

    Data oAnimations

    //fisica
    Data lHasCollider

    Data nTopMargin
    Data nLeftMargin
    Data nBottomMargin
    Data nRightMargin

    Data nHalfHeight
    Data nHalfWidth

    Data nDY
    Data nDX

    Data nMass

    Data lIsNet

    Method New() Constructor
    Method SetWindow()
    Method SetTag()
    Method GetTag()
    Method GetAssetsPath()
    Method LoadFrames()
    Method SetSize()
    Method GetInternalId()
    Method SetInternalId()
    Method GetHeight()
    Method GetWidth()

    //fisica
    Method SetColliderMargin()
    Method HasCollider()
    Method GetMidX()
    Method GetMidY()
    Method GetTop()
    Method GetLeft()
    Method GetRight()
    Method GetBottom()
    Method GetMass()
    Method Destroy()
    Method ShouldDestroy()

    //network
    Method FromJson()
    Method ToJson()
    Method SetNetObject()
    Method IsNetObject()
    Method UpdateCoords()

EndClass

/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method New(oWindow) Class BaseGameObjectMulti
    Local cTempPath as char

    cTempPath := GetTempPath()
    ::cAssetsPath := cTempPath + "gameadvpl\assets\

    if !Empty(oWindow)
        ::SetWindow(oWindow)
    EndIf

    ::cInternalId := UUIDRandom()
    ::lHasCollider := .F.
    ::lDestroy := .F.
    ::nDY := 0
    ::nDX := 0

Return Self

/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method SetWindow(oWindow) Class BaseGameObjectMulti
    ::oWindow := oWindow
Return 

/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetAssetsPath(cAsset) Class BaseGameObjectMulti
Return ::cAssetsPath + cAsset

/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method LoadFrames(cEntity) Class BaseGameObjectMulti

    Local cPath as char
    Local nX as numeric
    Local nY as numeric
    Local aDirectory as array
    Local aAnimations as array
    Local aFramesForward as array
    Local aFramesBackward as array
    Local cTempPath as char

    ::oAnimations := JsonObject():New()

    cPath := ::GetAssetsPath(cEntity + "\animation\")

    aDirectory := Directory(cPath + "*.*", "D",,.F.)
    cTempPath := StrTran(cPath, "\", "/")
    aAnimations := {}

    If !Empty(aDirectory)

        AEval(aDirectory, { |x| IIF(x[5] == 'D', Aadd(aAnimations, x[1]), nil)}, 3)

        For nX := 1 To Len(aAnimations)
            // tem que existir pelo menos um estado
            aFramesForward := Directory(cPath + aAnimations[nX] + "\forward\*.png", "A",,.F.)
            aFramesBackward := Directory(cPath + aAnimations[nX] + "\backward\*.png", "A",,.F.)
            // se for animação deve existir pelo menos a direção forward
            For nY := 1 To Len(aFramesForward)
                aFramesForward[nY] := cTempPath + aAnimations[nX] + "/forward/" + aFramesForward[nY][1]
                If !Empty(aFramesBackward)
                    aFramesBackward[nY] := cTempPath + aAnimations[nX] + "/backward/" + aFramesBackward[nY][1]
                EndIf
            Next nY

            ::oAnimations[aAnimations[nX]] := JsonObject():New()
            ::oAnimations[aAnimations[nX]]['forward'] := aFramesForward
            
            If !Empty(aFramesBackward)
                ::oAnimations[aAnimations[nX]]['backward'] := aFramesBackward
            EndIf

        Next nX

    EndIf

Return 
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method SetTag(cTag) Class BaseGameObjectMulti
    ::cTag := cTag
Return
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetTag() Class BaseGameObjectMulti
Return ::cTag

/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method SetColliderMargin(nTopMargin, nLeftMargin, nBottomMargin, nRightMargin) Class BaseGameObjectMulti

    If nTopMargin != Nil .and. nLeftMargin == Nil .and. nBottomMargin == Nil .and. nRightMargin == Nil

        ::nTopMargin := ::nLeftMargin := ::nBottomMargin := ::nRightMargin := nTopMargin

    ElseIf nTopMargin != Nil .and. nLeftMargin != Nil .and. nBottomMargin == Nil .and. nRightMargin == Nil

        ::nTopMargin := ::nBottomMargin := nTopMargin
        ::nLeftMargin := ::nRightMargin := nLeftMargin
        
    Else
        ::nTopMargin := nTopMargin
        ::nLeftMargin := nLeftMargin
        ::nBottomMargin := nBottomMargin
        ::nRightMargin := nRightMargin
    EndIf

    ::nHalfHeight := (::oGameObject:nHeight + ::nTopMargin + ::nBottomMargin) * 0.5
    ::nHalfWidth := (::oGameObject:nWidth + ::nLeftMargin + ::nRightMargin) * 0.5

    ::lHasCollider := .T.

Return

/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method HasCollider() Class BaseGameObjectMulti
Return ::lHasCollider

/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetMidX() Class BaseGameObjectMulti
Return ::nHalfWidth + ::oGameObject:nLeft
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetMidY() Class BaseGameObjectMulti
Return ::nHalfHeight + ::oGameObject:nTop
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetTop(lMargin) Class BaseGameObjectMulti
Return ::oGameObject:nTop + IIF(lMargin, ::nTopMargin, 0)
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetLeft(lMargin) Class BaseGameObjectMulti
Return ::oGameObject:nLeft + IIF(lMargin, ::nLeftMargin, 0)
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetRight(lMargin) Class BaseGameObjectMulti
Return ::oGameObject:nLeft + ::oGameObject:nWidth + IIF(lMargin, ::nRightMargin, 0)
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetBottom(lMargin) Class BaseGameObjectMulti
Return ::oGameObject:nTop + ::oGameObject:nHeight + IIF(lMargin, ::nBottomMargin, 0)
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetInternalId() Class BaseGameObjectMulti
Return ::cInternalId
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method Destroy() Class BaseGameObjectMulti
    ::lDestroy := .T.
Return 
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method ShouldDestroy() Class BaseGameObjectMulti
Return ::lDestroy

/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetHeight() Class BaseGameObjectMulti
Return ::oGameObject:nHeight
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetWidth() Class BaseGameObjectMulti
Return ::oGameObject:nWidth
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetMass() Class BaseGameObjectMulti
Return ::nMass
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method FromJson(cJson) Class BaseGameObjectMulti

    Local oJson as object

    oJson := JsonObject():New()

    oJson:FromJson(cJson)

    ::oGameObject:nWidth := oJson['width']
    ::oGameObject:nHeight := oJson['height']

    ::oGameObject:nTop := oJson['top']
    ::oGameObject:nLeft := oJson['left']

    ::nTopMargin := oJson['topMargin'] 
    ::nLeftMargin := oJson['leftMargin'] 
    ::nBottomMargin := oJson['bottomMargin'] 
    ::nRightMargin := oJson['rightMargin']

Return 
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method ToJson(cClientName) Class BaseGameObjectMulti

    Local oJson as object

    oJson := JsonObject():New()

    oJson['objectId'] := AllTrim(cClientName) +'_'+ ::GetInternalId()
    oJson['className'] := GetClassName(Self)

    oJson['width'] := ::oGameObject:nWidth
    oJson['height'] := ::oGameObject:nHeight

    oJson['top'] := ::oGameObject:nTop
    oJson['left'] := ::oGameObject:nLeft

    oJson['topMargin'] := ::nTopMargin
    oJson['leftMargin'] := ::nLeftMargin
    oJson['bottomMargin'] := ::nBottomMargin
    oJson['rightMargin'] := ::nRightMargin

Return oJson
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method SetNetObject(lIsNet) Class BaseGameObjectMulti
    ::lIsNet := lIsNet
Return
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method IsNetObject() Class BaseGameObjectMulti
Return ::lIsNet 
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method UpdateCoords(oOriginal) Class BaseGameObjectMulti

    ::oGameObject:nTop := oOriginal['top']
    ::oGameObject:nLeft := oOriginal['left']

    ::oGameObject:nHeight := oOriginal['height']
    ::oGameObject:nWidth := oOriginal['width']

    ::SetColliderMargin(oOriginal['topMargin'], oOriginal['leftMargin'], oOriginal['bottomMargin'], oOriginal['rightMargin'])

Return
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method SetInternalId(cId) Class BaseGameObjectMulti
    ::cInternalId := cId
Return