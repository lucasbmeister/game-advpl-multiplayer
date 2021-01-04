#include "totvs.ch"
#include "gameadvpl.ch"

/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Class SceneMulti

    Data aObjects
    Data oParent
    Data lActive
    Data cId
    Data nLeft
    Data nTop
    Data nHeight
    Data nWidth
    Data bLoadObjects
    Data cDescription
    Data lUpdateNet

    Method New() Constructor
    Method GetSceneID()
    Method AddObject()
    Method GetSceneWindow()
    Method Update()
    Method Start()
    Method EndScene()
    Method SetInitCodeBlock()
    Method GetDimensions()
    Method SetActive()
    Method IsActive()
    Method ClearScene()
    Method GetObjectsWithColliders()
    Method SetDescription()
    Method GetDescription()
    Method GetNetObjects()
    Method UpdateActiveObjects()

EndClass
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method New(oWindow, cId, nTop, nLeft, nHeight, nWidth, lUpdateNet) Class SceneMulti

    Static oInstance as object

    Default nLeft := 180
    Default nTop := 180
    Default nHeight := 550
    Default nWidth := 700
    Default lUpdateNet := .F.

    oInstance := Self
    ::oParent := oWindow

    ::nLeft := nLeft
    ::nTop := nTop
    ::nHeight := nHeight
    ::nWidth := nWidth
    ::cId := cId
    ::cDescription := cId
    ::lUpdateNet := lUpdateNet

    ::aObjects := {}

    ::SetActive(.F.)

Return
/*
{Protheus.doc} function
descriptiondd
@author  author
@since   date
@version version
*/
Method GetSceneID() Class SceneMulti
Return ::cId
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method Update(oGameManager) Class SceneMulti

    Local nX as numeric

    If ::lUpdateNet
        ::UpdateActiveObjects(oGameManager)
    EndIf

    For nX := Len(::aObjects)  To 1 STEP -1
        If ::IsActive()
            If MethIsMemberOf(::aObjects[nX], 'Update')
                ::aObjects[nX]:Update(oGameManager)
            EndIf
            If MethIsMemberOf(::aObjects[nX], 'ShouldDestroy') .and. ::aObjects[nX]:ShouldDestroy()
                FreeObj(::aObjects[nX])
                ADel(::aObjects, nX)
                ASize(::aObjects, Len(::aObjects) - 1)
            EndIf
        Else
            Exit
        EndIf
    Next nX

Return
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method AddObject(oObject) Class SceneMulti
    Aadd(::aObjects, oObject)
Return
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method Start() Class SceneMulti
    ::ClearScene()
    ::SetActive(.T.)
    Eval(::bLoadObjects, Self)
Return
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method EndScene() Class SceneMulti
    ::SetActive(.F.)
    ::ClearScene()
Return
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetSceneWindow() Class SceneMulti
Return ::oParent

/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method SetInitCodeBlock(bBlock) Class SceneMulti
    ::bLoadObjects := bBlock
Return

/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetDimensions() Class SceneMulti
Return { ::nTop, ::nLeft, ::nHeight, ::nWidth}

/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method SetActive(lActive) Class SceneMulti
    ::lActive := lActive
Return

/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method IsActive() Class SceneMulti
Return ::lActive

/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method ClearScene() Class SceneMulti
    AEval(::aObjects,{|x| IIF(MethIsMemberOf(x, 'HideGameObject'),x:HideGameObject(), x:Hide()), FreeObj(x) })
    ASize(::aObjects , 0)
Return
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetObjectsWithColliders() Class SceneMulti
    Local aObjColl as array
    aObjColl := {}

    AEval(::aObjects,{|x| IIF(x:HasCollider(), AAdd(aObjColl, x), nil)})

Return aObjColl
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method SetDescription(cDesc) Class SceneMulti
    ::cDescription := cDesc
Return
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetDescription() Class SceneMulti
Return ::cDescription
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetNetObjects(cClientName, oClients) Class SceneMulti

    Local nX as numeric
    Local oObjects as object
    Local nPos as numeric

    oObjects := JsonObject():New()

    If ValType(oClients) == 'J' .and. !Empty(oClients['clients'])
        nPos := AScan(oClients['clients'], {|x| x['client'] == cClientName})
    EndIf

    oObjects['client'] := cClientName
    oObjects['objects'] := {}

    For nX := Len(::aObjects)  To 1 STEP -1
        If ::IsActive() .and. MethIsMemberOf(::aObjects[nX], 'IsNetObject', .T.) .and. ::aObjects[nX]:IsNetObject()
            Aadd(oObjects['objects'], ::aObjects[nX]:ToJson(cClientName))
        EndIf
    Next nX

    If !Empty(nPos)
        oClients['clients'][nPos] := oObjects
    Else
        oClients := JsonObject():New()
        oClients['clients'] := {oObjects}
    EndIf

Return oClients:ToJson()
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method UpdateActiveObjects(oGameManager) Class SceneMulti

    Local aNetObjects as array
    Local nX as numeric
    Local nPos as numeric
    Local oObject as object

    aNetObjects := oGameManager:GetQueueObjects()

    If !Empty(aNetObjects)
        For nX := 1 To Len(aNetObjects)

            oObject := aNetObjects[nX]
            nPos := AScan(::aObjects, {|x| x:GetInternalId() == oObject['objectId']})

            If nPos == 0

                aNetObjects[nX] :=;
                    SquareMulti():New(::GetSceneWindow(), oObject['top'], oObject['left'], oObject['height'], oObject['width'], SubStr(oObject['objectId'],1,At('_',oObject['objectId']) - 1))

                aNetObjects[nX]:SetColliderMargin(0, 0, 0, 0)
                aNetObjects[nX]:SetTag('enemy')
                aNetObjects[nX]:SetInternalId(oObject['objectId'])

                AAdd(::aObjects, aNetObjects[nX])
            Else
                ::aObjects[nPos]:UpdateCoords(aNetObjects[nX])
            EndIf
        Next
    EndIf

Return