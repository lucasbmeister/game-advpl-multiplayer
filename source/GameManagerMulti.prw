#include "totvs.ch"
#include "gameadvpl.ch"

#DEFINE NETWORK_QUEUE 'gameadvplmulti'
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Class GameManagerMulti From LongNameClass

    Data oKeys
    Data oActiveScene
    Data nDeltaTime
    Data aScenes
    Data oWindow
    Data cGameName
    Data oWebChannel
    Data oWebEngine
    Data nTop
    Data nLeft
    Data nHeight
    Data nWidth
    Data nPlayerScore
    Data nPlayerLife
    Data cServer
    Data nPort
    Data oServer
    Data cClientName
    Data oCacheObjects

    Method New() Constructor
    Method AddScene()
    Method SetActiveScene()
    Method GetActiveScene()
    Method LoadScene()
    Method Start()
    Method SetPressedKeys()
    Method GetPressedKeys()
    Method GetMainWindow()
    Method GetDimensions()
    Method StartEngine()
    Method Update()
    Method HandleEvent()
    Method ExportAssets()
    Method Processed()
    Method GetColliders()
    Method UpdateScore()
    Method GetScore()
    Method UpdateLife()
    Method GetLife()
    Method GameOver()
    Method SetServerInfo()
    Method GetQueueObjects()
    Method SendNetObjects()

EndClass

/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method New(cGameName, nTop, nLeft, nHeight, nWidth) Class GameManagerMulti

    Static oInstance as object
    Default cGameName := "Game 2D"
    Default nTop := 180
    Default nLeft := 180
    Default nHeight := 550
    Default nWidth := 700

    ::nPlayerScore := 0
    ::nPlayerLife := 0

    ::nTop := nTop
    ::nLeft := nLeft
    ::nHeight := nHeight
    ::nWidth := nWidth

    ::cGameName := cGameName
    ::aScenes := {}
    ::oKeys := {}

    ::nDeltaTime := 0

    oInstance := Self

    ::oServer := TRedisClient():New()

    ::oWindow := TDialog():New(::nTop ,::nLeft,::nHeight,::nWidth,::cGameName ,,,,,CLR_BLACK,CLR_HCYAN,,,.T.)

    ::ExportAssets()

Return Self

/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method AddScene(oScene) Class GameManagerMulti
    Aadd(::aScenes, oScene)
Return
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetMainWindow() Class GameManagerMulti
Return ::oWindow
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method Start(cFirstScene) Class GameManagerMulti

    Local nPos as numeric
    Static oInstance as object

    oInstance := Self

    nPos := AScan(::aScenes,{|x| x:GetSceneID() == cFirstScene })

    ::SetActiveScene(::aScenes[nPos])

    ::oWindow:bStart := {||::aScenes[nPos]:Start(),  oInstance:StartEngine() }
    ::oWindow:Activate()

Return

/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method StartEngine() Class GameManagerMulti

    Static oInstance as object
    Local cLink as char

    oInstance := Self

    cLink := GetTempPath() + "gameadvplmulti\gameadvplmulti.html"

    ::oWebChannel := TWebChannel():New()
    ::oWebChannel:Connect()

    If !::oWebChannel:lConnected
        UserException("Erro na conexao com o WebSocket")
        Return
    EndIf

    ::oWebChannel:bJsToAdvpl := {|self,codeType,codeContent| oInstance:HandleEvent(self, codeType, codeContent)}

    ::oWebEngine := TWebEngine():New(oInstance:oWindow, 0, 0, ::nWidth, 10,,::oWebChannel:nPort)
    ::oWebEngine:Navigate(cLink)

Return
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method HandleEvent(oWebChannel, codeType, codeContent) Class GameManagerMulti

    If codeType == "start"
        ::oWebChannel:advplToJs("started", "true")
    ElseIf codeType == "update"
        ::Update(oWebChannel, codeType, Upper(codeContent))
    EndIf

Return
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method SetPressedKeys(oKeys) Class GameManagerMulti
    ::oKeys := oKeys
REturn
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetPressedKeys() Class GameManagerMulti
Return ::oKeys
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method Update(oWebChannel, codeType, codeContent) Class GameManagerMulti

    Local oKeys as object
    Local oActiveScene as object

    oKeys := JsonObject():New()
    oActiveScene := ::GetActiveScene()

    oKeys:FromJson(Lower(codeContent))

    ::SetPressedKeys(oKeys)
    ::nDeltaTime := TimeCounter() - ::nDeltaTime

    oActiveScene:Update(Self)

    If oActiveScene:lUpdateNet
        ::SendNetObjects(oActiveScene:GetNetObjects(::cClientName, ::oCacheObjects))
    EndIf

    ::Processed()

Return
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method Processed()  Class GameManagerMulti
    ::oWebChannel:advplToJs("processed", "true")
Return
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetDimensions() Class GameManagerMulti
Return {::nTop, ::nLEft, ::nHeight, ::nWidth}
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method ExportAssets() Class GameManagerMulti

    Local cTempPath as char
    Local cFile as char

    cTempPath := GetTempPath()
    cFile := "gameadvplmulti.app"

    If !Resource2File(cFile,  cTempPath + cFile)
        UserException("Nao foi possivel copiar o arquivo "+cFile+" para o diretorio temporario")
        Return
    EndIf

    If !ExistDir(cTempPath + "gameadvplmulti\" )
        If MakeDir(cTempPath + "gameadvplmulti\" ) != 0
            UserException("Nao foi criar o diretorio" + cTempPath + "gameadvplmulti\")
            Return
        EndIf
    EndIf

    FUnzip(cTempPath + cFile, cTempPath + "gameadvplmulti\")

Return
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method SetActiveScene(oScene) Class GameManagerMulti
    ::oActiveScene := oScene
Return
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method GetActiveScene() Class GameManagerMulti
Return ::oActiveScene
/*
{Protheus.doc} function
description
@author  author
@since   date
@version version
*/
Method LoadScene(cSceneID) Class GameManagerMulti

    Local nPos as numeric

    nPos := AScan(::aScenes,{|x| x:GetSceneID() == cSceneID })

    If !Empty(::oActiveScene)
        ::oActiveScene:EndScene()
    EndIf

    ::SetActiveScene(::aScenes[nPos])
    ::oActiveScene:Start()
    ::oWebEngine:SetFocus()
    ProcessMessage()

Return
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
Method GetColliders() Class GameManagerMulti
Return ::GetActiveScene():GetObjectsWithColliders()

/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
Method GameOver() Class GameManagerMulti

    Local oSay as object
    Local cText as char

    cText := "<h1>GAME OVER</h1>"

    oSay := TSay():New(1, 1,{||cText}, ::oWindow,,,,,,.T.,,,100,100,,,,,,.T.)
    oSay:MoveToTop()
    oSay:SetCSS('QLabel { backgound-color: white }')

    Sleep(1000)

    oSay:Hide()
    FreeObj(oSay)

    ::LoadScene(::GetActiveScene():GetSceneID())

Return
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
Method UpdateScore(nValue) Class GameManagerMulti
    ::nPlayerScore += nValue
Return ::nPlayerScore
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
Method GetScore() Class GameManagerMulti
Return ::nPlayerScore
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
Method UpdateLife(nLife) Class GameManagerMulti
    ::nPlayerLife += nLife
Return ::nPlayerLife
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
Method GetLife() Class GameManagerMulti
Return ::nPlayerLife
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
Method SetServerInfo(cServer, cPort, cClientName) Class GameManagerMulti

    ::cServer := AllTrim(cServer)
    ::nPort := Val(cPort)
    ::cClientName := AllTrim(cClientName)

    ::oServer := ::oServer:Connect(::cServer, ::nPort)

    If !::oServer:lConnected
        MsgInfo("Falha de conexao com o Redis.")
        ::oServer:Disconnect()
    EndIf
Return
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
Method GetQueueObjects(aScnObjects) Class GameManagerMulti

    Local cIdMsg as char
    Local cMsg as char
    Local aObjects as numeric
    Local oClients as array
    Local nX as numeric

    cIdMsg := ''
    cMsg := ''
    oClients := JsonObject():New()
    aObjects := {}

    ::oServer:Exec('get ' + NETWORK_QUEUE, @cMsg)
    //por enquanto só quadrados para teste
    If !Empty(cMsg)
        oClients:FromJson(cMsg)

        ::oCacheObjects := JsonObject():New()
        ::oCacheObjects['clients'] := {}

        For nX := 1 To Len(oClients['clients'])
            If oClients['clients'][nX]['client'] != ::cClientName
                AAdd(::oCacheObjects['clients'], oClients['clients'][nX])
                AEval(oClients['clients'][nX]['objects'], {|x| AAdd(aObjects, x)})
            EndIf
        Next
    EndIf

Return aObjects
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
Method SendNetObjects(cObjects) Class GameManagerMulti

    Local cMsgId as char
    Local cReponse

    cMsgId := ''

    ::oServer:Exec("set " + NETWORK_QUEUE + " '" + cObjects + "'", @cReponse)

Return