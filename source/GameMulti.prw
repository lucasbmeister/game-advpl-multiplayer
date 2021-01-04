#include 'totvs.ch'
#include "gameadvpl.ch"
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
Main Function GameMulti()

    Local oWindow as object
    Local oGame as object
    Local oMenu as object
    Local oLevel1 as object
    Local aDimensions as array

// instância gerenciador do jogo
    oGame := GameManagerMulti():New("Game Multi", 50, 50, 650, 1330)

    // obtém janela princial onde as cenas serão adicionadas
    oWindow := oGame:GetMainWindow()

    // retorna dimensões de tela do jogo
    aDimensions := oGame:GetDimensions()

    // instância uma cena (deverá ser atribuida para janela do jogo)
    oMenu := SceneMulti():New(oWindow, "menu", aDimensions[TOP], aDimensions[LEFT], aDimensions[HEIGHT], aDimensions[WIDTH])
    oMenu:SetInitCodeBlock({|oLevel| LoadMenu(oLevel, oGame)})

    oLevel1 := SceneMulti():New(oWindow, "level_1", aDimensions[TOP], aDimensions[LEFT], aDimensions[HEIGHT], aDimensions[WIDTH], .T.)
    oLevel1:SetInitCodeBlock({|oLevel| LoadLvl1(oLevel, oGame)})
    oLevel1:SetDescription('Nível 1')

    oGame:AddScene(oMenu)
    oGame:AddScene(oLevel1)

    oGame:Start(oMenu:GetSceneID())

Return
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
Static Function LoadMenu(oMenu, oGame)

    Local aDimensions as array
    Local oWindow as object
    Local cServer as char
    Local cPort as char
    Local cClientName as char

    cServer := Space(30)
    cClientName := Space(30)
    cPort := Space(5)

    aDimensions := oMenu:GetDimensions()
    oWindow := oMenu:GetSceneWindow()

    oServer := TGet():New( 10,01,{|u|if(PCount() > 0, cServer := u, cServer)  },oWindow,096,010, "",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cServer,,,,,,,'Servidor', 1  )
    oPort :=TGet():New( 30,01,{|u| if(PCount() > 0, cPort := u, cPort) },oWindow,096,010, "",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cPort,,,,,,,'Porta',1 )
    oClientName :=TGet():New( 50,01,{|u| if(PCount() > 0, cClientName := u, cClientName) },oWindow,096,010, "",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cPort,,,,,,,'Usuario',1 )

    oButton := TButton():New(75,01,"Confirmar", oWindow,{|| oGame:SetServerInfo(cServer, cPort, cClientName), oGame:LoadScene('level_1') },096,15,,,,.T.)

    oMenu:AddObject(oButton)
    oMenu:AddObject(oServer)
    oMenu:AddObject(oPort)
    oMenu:AddObject(oClientName)

Return
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
Static Function LoadLvl1(oLevel, oGame)

    Local aDimensions as array
    Local oWindow as object
    Local oPlayer as object
    Local oGround1 as object
    
    aDimensions := oLevel:GetDimensions()
    oWindow := oLevel:GetSceneWindow()

    oPlayer := PlayerMulti():New(oWindow, "", 50, 005, 50, 80)
    oPlayer:SetTag('player')
    oPlayer:SetColliderMargin(25, 50, 0, -50)
    oPlayer:SetNetObject(.T.)

    oGround1 := GroundMulti():New(oWindow, 260, 0, 42, 110)
    oGround1:SetTag('ground')
    oGround1:SetColliderMargin(25, 0, 0, 0)

    oLevel:AddObject(oGround1)
    oLevel:AddObject(oPlayer)

Return