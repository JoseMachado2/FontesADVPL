#INCLUDE "protheus.ch"
#INCLUDE "RWMAKE.ch"

User function TmsRel01()
    local i
    Private cTitulo         := "Relatorio exemplo"
    Private oRelatorio
    Private oFont1          := TFont():new("Courier New",,-18,.T.,.T.,,,,,/*lUnderline*/,/*italic*/)
    Private oFont2          := TFont():new("Tahoma",,-18,.T.,.T.,,,,,/*lUnderline*/,/*italic*/)
    Private oBrush1
    PRIVATE oBrush2
    Private oBrush3
                


    oRelatorio := TMSPrinter():new(cTitulo)
    oRelatorio:Setup()                  // Apresenta a tela de seleção de impressora
    oRelatorio:SetLandscape()           // Definir como paisagem
    
    // inicia a pagina
    oRelatorio:StartPage()

    // escrever uma linha 
    oRelatorio:SAY(200,040,"linha de teste de impressão [Courier New  -18]",oFont1 )
    oRelatorio:SAY(270,040,"linha de teste de impressão [Tahoma  -18]",oFont2,,CLR_HRED )
    
    // imprimo uma linha
    oRelatorio:Line(400, 040, 400, 800)
    
    // imprimir um retangulo
    oRelatorio:Box(430, 040, 800, 800)

    //imprimir rentangulo com cor 
    oBrush1 := TBrush():new(,CLR_BLUE)
    oBrush2 := TBrush():new(,CLR_BLACK)
    oBrush3 := TBrush():new(,CLR_GREEN)
    oRelatorio:FillRect({430, 040, 800, 240}, oBrush1)
    oRelatorio:FillRect({430, 240, 800, 440}, oBrush2)
    oRelatorio:FillRect({430, 440, 800, 640}, oBrush3)

    // Terminar a pagina
    oRelatorio:EndPage()

     // inicia a pagina
    oRelatorio:StartPage()
    nLinha := 100
        FOR i := 1 to 10
            oRelatorio:Say(nLinha,040,"impressão na linha "+CValToChar(nLinha),oFont1 )
            nLinha += 150
        NEXT

    // Terminar a pagina
    oRelatorio:EndPage()    


    // exibe preview
    oRelatorio:Preview()

RETURN 
