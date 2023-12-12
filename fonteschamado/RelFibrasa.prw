//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#Include "PRTOPDEF.ch"
 
//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
 
//Cores
#Define COR_CINZA   RGB(217, 217, 217)
#Define COR_PRETO   RGB(000, 000, 000)
#Define COR_AMARELO  RGB(255, 255, 000)
#Define COR_CINZA2   RGB(242, 242, 242)
#Define COR_BRANCO  RGB(255, 255, 255)
 
//Colunas
#Define COL_GRUPO   0015
#Define COL_DESCR   0095
 
/*/{Protheus.doc} zTstRel
Exemplos de FWMSPrinter
@author Atilio
@since 27/01/2019
@version 1.0
@type function
/*/
 
User Function zTstRel2()
    Local aArea := GetArea()
     
    //Se a pergunta for confirmada
    If MsgYesNo("Deseja gerar o relatório de grupos de produtos?", "Atenção")
        Processa({|| fMontaRel()}, "Processando...")
    EndIf
     
    RestArea(aArea)
Return
 
/*---------------------------------------------------------------------*
 | Func:  fMontaRel                                                    |
 | Desc:  Função que monta o relatório                                 |
 *---------------------------------------------------------------------*/
 
Static Function fMontaRel()
    Local cCaminho    := ""
    Local cArquivo    := ""
    Local cQryAux     := ""
    Local nAtual      := 0
    Local nTotal      := 0
    //Linhas e colunas
    Private nLinAtu   := 000
    Private nTamLin   := 010
    Private nLinFin   := 820
    Private nColIni   := 010
    Private nColFin   := 550
    Private nColMeio  := (nColFin-nColIni)/2
    //Objeto de Impressão
    Private oPrintPvt
    //Variáveis auxiliares
    Private dDataGer  := Date()
    Private cHoraGer  := Time()
    Private nPagAtu   := 1
    Private cNomeUsr  := 'Administrator' /* UsrRetName(RetCodUsr()) */
    //Fontes
    Private cNomeFont := "Arial"
    Private oFontDet  := TFont():New(cNomeFont, 9, -14, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDetN := TFont():New(cNomeFont, 9, -10, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontDetN2 := TFont():New(cNomeFont, 9, -8, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontDetS := TFont():New(cNomeFont, 9, -10, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontCab  := TFont():New(cNomeFont, 9, 15, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontRod  := TFont():New(cNomeFont, 9, -08, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontTit  := TFont():New(cNomeFont, 9, 13, .T., .T., 5, .T., 5, .T., .F.)
     
    //Definindo o diretório como a temporária do S.O. e o nome do arquivo com a data e hora (sem dois pontos)
    cCaminho  := GetTempPath()
    cArquivo  := "zTstRel_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-')
     
    //Criando o objeto do FMSPrinter
    oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., "", .T., , @oPrintPvt, "", , , , .T.)
     
    //Setando os atributos necessários do relatório
    oPrintPvt:SetResolution(72)
    oPrintPvt:SetPortrait()
    oPrintPvt:SetPaperSize(DMPAPER_A4)
    oPrintPvt:SetMargin(60, 60, 60, 60)
     
    //Imprime o cabeçalho
    fImpCab()
     
    //Montando a consulta
    cQryAux := " SELECT "                                       + CRLF
    cQryAux += "     A1_NOME, "                                + CRLF
    cQryAux += "     A1_COD,"                                  + CRLF
    cQryAux += "     A1_END"                                  + CRLF
    cQryAux += " FROM "                                         + CRLF
    cQryAux += "     " + RetSQLName('SA1') + " SA1 "            + CRLF
    cQryAux += " WHERE "                                        + CRLF
    cQryAux += "     A1_FILIAL = '" + FWxFilial('SA1') + "' "   + CRLF
    cQryAux += "     AND SA1.D_E_L_E_T_ = ' ' "                 + CRLF
    cQryAux += " ORDER BY "                                     + CRLF
    cQryAux += "     A1_COD "                                 + CRLF
    TCQuery cQryAux New Alias "QRY_SA1"
     
    //Conta o total de registros, seta o tamanho da régua, e volta pro topo
    Count To nTotal
    ProcRegua(nTotal)
    QRY_SA1->(DbGoTop())
    nAtual := 0
     
    //Enquanto houver registros
    While ! QRY_SA1->(EoF())
        nAtual++
        IncProc("Imprimindo grupo " + QRY_SA1->A1_COD + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")
         
        //Se a linha atual mais o espaço que será utilizado forem maior que a linha final, imprime rodapé e cabeçalho
        If nLinAtu + nTamLin > nLinFin
            fImpRod()
            fImpCab()
        EndIf
         
        //Imprimindo a linha atual
        /* oPrintPvt:Box( 100, 90, 60, 100, "-4")
        oPrintPvt:SayAlign(nLinAtu, COL_GRUPO, QRY_SA1->A1_COD, oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu, COL_DESCR, QRY_SA1->A1_NOME,  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu-10, COL_DESCR, "Descriçãoadm", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0) */
       //tabela
       /*  oPrintPvt:Box( 240,     COL_GRUPO,       385,        305,             "-4")
        oPrintPvt:Box( 240,     COL_GRUPO+350,   385,        540,             "-4")
        oPrintPvt:Box( 550,     COL_GRUPO,       395,        540,             "-4")
        oPrintPvt:Box( 550,     COL_GRUPO,       395,        540,             "-4")
        oPrintPvt:Box( 560,     COL_GRUPO,      740,        305,             "-4")
        oPrintPvt:Box( 560,    COL_GRUPO+350,   740,        540,             "-4") */

    /* oPrintPvt:Box(PONTO INI VERTICAL,   PONTO INI HORIZONTAL,    DISTANCIA AO CHÃO,  DISTANCIA À DIREITA ,    "-4") */

   //POTE TERMOFORMAGEM
    oPrintPvt:Box(248,  COL_GRUPO-20,    340,  273,  "-4") 
    oPrintPvt:Line(249, COL_GRUPO-20,249 ,273, COR_CINZA, "-9") // Linha horizontal
    oPrintPvt:Line(250, COL_GRUPO-20,250 ,273, COR_CINZA, "-9") // Linha horizontal
    oPrintPvt:Line(251, COL_GRUPO-20,251 ,273, COR_CINZA, "-9") // Linha horizontal
    oPrintPvt:Line(252, COL_GRUPO-20,252 ,273, COR_CINZA, "-9") // Linha horizontal
    oPrintPvt:Line(253, COL_GRUPO-20,253 ,273, COR_CINZA, "-9") // Linha horizontal
    oPrintPvt:Line(254, COL_GRUPO-20,254 ,273, COR_CINZA, "-9") // Linha horizontal
    oPrintPvt:Line(255, COL_GRUPO-20,255 ,273, COR_CINZA, "-9") // Linha horizontal
    oPrintPvt:Line(256, COL_GRUPO-20,256 ,273, COR_CINZA, "-9") // Linha horizontal
    oPrintPvt:Line(257, COL_GRUPO-20,257 ,273, COR_CINZA, "-9") // Linha horizontal
    oPrintPvt:Line(258, COL_GRUPO-20,258 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(259, COL_GRUPO-20,259 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(260, COL_GRUPO-20,260 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(261, COL_GRUPO-20,261 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(262, COL_GRUPO-20,262 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(263, COL_GRUPO-20,263 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(264, COL_GRUPO-20,264 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(265, COL_GRUPO-20,265 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(266, COL_GRUPO-20,266 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(267, COL_GRUPO-20,267 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(258, COL_GRUPO+155,340 ,COL_GRUPO+155, COR_PRETO, "-4") // Linha vertical
    oPrintPvt:Line(258, COL_GRUPO-20,258 ,273, COR_PRETO, "-4")
    oPrintPvt:Line(268, COL_GRUPO-20,268 ,273, COR_PRETO, "-4")
    oPrintPvt:Line(278, COL_GRUPO-20,278 ,273, COR_PRETO, "-4")
    oPrintPvt:Line(288, COL_GRUPO-20,288 ,273, COR_PRETO, "-4")
    oPrintPvt:Line(298, COL_GRUPO-20,298 ,273, COR_PRETO, "-4")
    oPrintPvt:Line(308, COL_GRUPO-20,308 ,273, COR_PRETO, "-4")
    oPrintPvt:Line(318, COL_GRUPO-20,318 ,273, COR_PRETO, "-4")
    oPrintPvt:Line(328, COL_GRUPO-20,328 ,273, COR_PRETO, "-4")
    oPrintPvt:Line(328, COL_GRUPO-20,328 ,273, COR_PRETO, "-4")

    // POTE IMPRESSÃO 
    oPrintPvt:Box(248,  COL_GRUPO+335, 340,  560,    "-4") 
    oPrintPvt:Line(249, COL_GRUPO+335,249 ,560, COR_CINZA, "-9") // Linha horizontal
    oPrintPvt:Line(250, COL_GRUPO+335,250 ,560, COR_CINZA, "-9") // Linha horizontal
    oPrintPvt:Line(251, COL_GRUPO+335,251 ,560, COR_CINZA, "-9") // Linha horizontal
    oPrintPvt:Line(252, COL_GRUPO+335,252 ,560, COR_CINZA, "-9") // Linha horizontal
    oPrintPvt:Line(253, COL_GRUPO+335,253 ,560, COR_CINZA, "-9") // Linha horizontal
    oPrintPvt:Line(254, COL_GRUPO+335,254 ,560, COR_CINZA, "-9") // Linha horizontal
    oPrintPvt:Line(255, COL_GRUPO+335,255 ,560, COR_CINZA, "-9") // Linha horizontal
    oPrintPvt:Line(256, COL_GRUPO+335,256 ,560, COR_CINZA, "-9") // Linha horizontal
    oPrintPvt:Line(257, COL_GRUPO+335,257 ,560, COR_CINZA, "-9") // Linha horizontal
    oPrintPvt:Line(258, COL_GRUPO+335,258 ,560, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(259, COL_GRUPO+335,259 ,560, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(260, COL_GRUPO+335,260 ,560, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(261, COL_GRUPO+335,261 ,560, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(262, COL_GRUPO+335,262 ,560, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(263, COL_GRUPO+335,263 ,560, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(264, COL_GRUPO+335,264 ,560, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(265, COL_GRUPO+335,265 ,560, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(266, COL_GRUPO+335,266 ,560, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(267, COL_GRUPO+335,267 ,560, COR_PRETO, "-9") // Linha horizontal PRETA
    oPrintPvt:Line(258, COL_GRUPO+470,340 ,COL_GRUPO+470, COR_PRETO, "-4") // Linha vertical
    oPrintPvt:Line(268, COL_GRUPO+335,268 ,560, COR_PRETO, "-4")
    oPrintPvt:Line(278, COL_GRUPO+335,278 ,560, COR_PRETO, "-4")
    oPrintPvt:Line(288, COL_GRUPO+335,288 ,560, COR_PRETO, "-4")
    oPrintPvt:Line(298, COL_GRUPO+335,298 ,560, COR_PRETO, "-4")
    oPrintPvt:Line(308, COL_GRUPO+335,308 ,560, COR_PRETO, "-4")
    oPrintPvt:Line(318, COL_GRUPO+335,318 ,560, COR_PRETO, "-4")
    oPrintPvt:Line(328, COL_GRUPO+335,328 ,560, COR_PRETO, "-4")
    
    // PARÂMETROS
    oPrintPvt:Box(350,       COL_GRUPO-20,    480,  560,    "-4") 
    oPrintPvt:Box(350,       COL_GRUPO-20,    380,  COL_GRUPO+190,   "-4") // Cabeçalho do parâmetro
    oPrintPvt:Box(350,       COL_GRUPO+190,    380,  560,   "-4") //Cabeçalho espec/resul

oPrintPvt:Line(351, COL_GRUPO-20,351 , 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(352, COL_GRUPO-20,352 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(353, COL_GRUPO-20,353 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(354, COL_GRUPO-20,354 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(355, COL_GRUPO-20,355 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(356, COL_GRUPO-20,356 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(357, COL_GRUPO-20,357 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(358, COL_GRUPO-20,358 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(359, COL_GRUPO-20,359 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(360, COL_GRUPO-20,360 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(361, COL_GRUPO-20,361 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(362, COL_GRUPO-20,362 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(363, COL_GRUPO-20,363 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(364, COL_GRUPO-20,364 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(365, COL_GRUPO-20,365 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(366, COL_GRUPO-20,366 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(367, COL_GRUPO-20,367 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(368, COL_GRUPO-20,368 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(369, COL_GRUPO-20,369 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(370, COL_GRUPO-20,370 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(371, COL_GRUPO-20,371 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(372, COL_GRUPO-20,372 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(373, COL_GRUPO-20,373 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(374, COL_GRUPO-20,374 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(375, COL_GRUPO-20,375 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(376, COL_GRUPO-20,376 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(377, COL_GRUPO-20,377 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(378, COL_GRUPO-20,378 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(379, COL_GRUPO-20,379 ,560, COR_CINZA, "-9") // Linha horizontal cor cinza
//oPrintPvt:Line(380, COL_GRUPO-20,380 ,COL_GRUPO+190, COR_CINZA, "-9") // Linha horizontal cor cinza



    oPrintPvt:Line(350, COL_GRUPO+190, 480 ,COL_GRUPO+190, COR_PRETO, "-4") // Linha vertical 1
    oPrintPvt:Line(365, COL_GRUPO+250, 480 ,COL_GRUPO+250, COR_PRETO, "-4") // Linha vertical 2
    oPrintPvt:Line(365, COL_GRUPO+310, 480 ,COL_GRUPO+310, COR_PRETO, "-4") // Linha vertical 3
    oPrintPvt:Line(350, COL_GRUPO+370, 480 ,COL_GRUPO+370, COR_PRETO, "-4") // Linha vertical 4
    oPrintPvt:Line(365, COL_GRUPO+430, 480 ,COL_GRUPO+430, COR_PRETO, "-4") // Linha vertical 5
    oPrintPvt:Line(365, COL_GRUPO+475, 480 ,COL_GRUPO+475, COR_PRETO, "-4") // Linha vertical 6
    oPrintPvt:Line(365, COL_GRUPO+190, 365 ,560, COR_PRETO, "-4") // Linha horizontal esp/min;pad;max;med
    oPrintPvt:Line(390, COL_GRUPO-20, 390 ,560, COR_PRETO, "-4") // Linha horizontal
    oPrintPvt:Line(400, COL_GRUPO-20, 400 ,560, COR_PRETO, "-4") // Linha horizontal
    oPrintPvt:Line(410, COL_GRUPO-20, 410 ,560, COR_PRETO, "-4") // Linha horizontal
    oPrintPvt:Line(420, COL_GRUPO-20, 420 ,560, COR_PRETO, "-4") // Linha horizontal
    oPrintPvt:Line(430, COL_GRUPO-20, 430 ,560, COR_PRETO, "-4") // Linha horizontal
    oPrintPvt:Line(440, COL_GRUPO+190, 440 ,560, COR_PRETO, "-4") // Linha de compensação
    oPrintPvt:Line(450, COL_GRUPO-20, 450 ,560, COR_PRETO, "-4") // Linha horizontal
    oPrintPvt:Line(460, COL_GRUPO-20, 460 ,560, COR_PRETO, "-4") // Linha de compensação
    oPrintPvt:Line(470, COL_GRUPO-20, 470 ,560, COR_PRETO, "-4") // Linha horizontal
    oPrintPvt:Line(480, COL_GRUPO-20, 480 ,560, COR_PRETO, "-4") // Linha horizontal
    


    //TAMPAS TERMOFORMAGEM
    oPrintPvt:Box(490,       COL_GRUPO-20,    580,  273,    "-4")
oPrintPvt:Line(491, COL_GRUPO-20,491 ,273, COR_CINZA, "-9") // Linha horizontal
oPrintPvt:Line(492, COL_GRUPO-20,492 ,273, COR_CINZA, "-9") // Linha horizontal
oPrintPvt:Line(493, COL_GRUPO-20,493 ,273, COR_CINZA, "-9") // Linha horizontal
oPrintPvt:Line(494, COL_GRUPO-20,494 ,273, COR_CINZA, "-9") // Linha horizontal
oPrintPvt:Line(495, COL_GRUPO-20,495 ,273, COR_CINZA, "-9") // Linha horizontal
oPrintPvt:Line(496, COL_GRUPO-20,496 ,273, COR_CINZA, "-9") // Linha horizontal
oPrintPvt:Line(497, COL_GRUPO-20,497 ,273, COR_CINZA, "-9") // Linha horizontal
oPrintPvt:Line(498, COL_GRUPO-20,498 ,273, COR_CINZA, "-9") // Linha horizontal
oPrintPvt:Line(499, COL_GRUPO-20,499 ,273, COR_CINZA, "-9") // Linha horizontal
oPrintPvt:Line(500, COL_GRUPO-20,500 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(501, COL_GRUPO-20,501 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(502, COL_GRUPO-20,502 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(503, COL_GRUPO-20,503 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(504, COL_GRUPO-20,504 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(505, COL_GRUPO-20,505 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(506, COL_GRUPO-20,506 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(507, COL_GRUPO-20,507 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(508, COL_GRUPO-20,508 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(509, COL_GRUPO-20,509 ,273, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(500, COL_GRUPO+155,580 ,COL_GRUPO+155, COR_PRETO, "-4") // Linha vertical
oPrintPvt:Line(500, COL_GRUPO-20,500 ,273, COR_PRETO, "-4")
oPrintPvt:Line(508, COL_GRUPO-20,508 ,273, COR_PRETO, "-4")
oPrintPvt:Line(518, COL_GRUPO-20,518 ,273, COR_PRETO, "-4")
oPrintPvt:Line(528, COL_GRUPO-20,528 ,273, COR_PRETO, "-4")
oPrintPvt:Line(538, COL_GRUPO-20,538 ,273, COR_PRETO, "-4")
oPrintPvt:Line(548, COL_GRUPO-20,548 ,273, COR_PRETO, "-4")
oPrintPvt:Line(558, COL_GRUPO-20,558 ,273, COR_PRETO, "-4")
oPrintPvt:Line(568, COL_GRUPO-20,568 ,273, COR_PRETO, "-4")
oPrintPvt:Line(568, COL_GRUPO-20,568 ,273, COR_PRETO,"-4")
    //TAMPAS IMPRESSÃO
   oPrintPvt:Box(490, COL_GRUPO+335, 580, 560, "-4")
oPrintPvt:Line(491, COL_GRUPO+335, 491, 560, COR_CINZA, "-9") // Linha horizontal
oPrintPvt:Line(492, COL_GRUPO+335, 492, 560, COR_CINZA, "-9") // Linha horizontal
oPrintPvt:Line(493, COL_GRUPO+335, 493, 560, COR_CINZA, "-9") // Linha horizontal
oPrintPvt:Line(494, COL_GRUPO+335, 494, 560, COR_CINZA, "-9") // Linha horizontal
oPrintPvt:Line(495, COL_GRUPO+335, 495, 560, COR_CINZA, "-9") // Linha horizontal
oPrintPvt:Line(496, COL_GRUPO+335, 496, 560, COR_CINZA, "-9") // Linha horizontal
oPrintPvt:Line(497, COL_GRUPO+335, 497, 560, COR_CINZA, "-9") // Linha horizontal
oPrintPvt:Line(498, COL_GRUPO+335, 498, 560, COR_CINZA, "-9") // Linha horizontal
oPrintPvt:Line(499, COL_GRUPO+335, 499, 560, COR_CINZA, "-9") // Linha horizontal
oPrintPvt:Line(500, COL_GRUPO+335, 500, 560, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(501, COL_GRUPO+335, 501, 560, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(502, COL_GRUPO+335, 502, 560, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(503, COL_GRUPO+335, 503, 560, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(504, COL_GRUPO+335, 504, 560, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(505, COL_GRUPO+335, 505, 560, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(506, COL_GRUPO+335, 506, 560, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(507, COL_GRUPO+335, 507, 560, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(508, COL_GRUPO+335, 508, 560, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(509, COL_GRUPO+335, 509, 560, COR_PRETO, "-9") // Linha horizontal PRETA
oPrintPvt:Line(500, COL_GRUPO+470, 580, COL_GRUPO+470, COR_PRETO, "-4") // Linha vertical
oPrintPvt:Line(510, COL_GRUPO+335, 508, 560, COR_PRETO, "-4")
oPrintPvt:Line(520, COL_GRUPO+335, 520, 560, COR_PRETO, "-4")
oPrintPvt:Line(530, COL_GRUPO+335, 530, 560, COR_PRETO, "-4")
oPrintPvt:Line(540, COL_GRUPO+335, 540, 560, COR_PRETO, "-4")
oPrintPvt:Line(550, COL_GRUPO+335, 550, 560, COR_PRETO, "-4")
oPrintPvt:Line(560, COL_GRUPO+335, 560, 560, COR_PRETO, "-4")
oPrintPvt:Line(570, COL_GRUPO+335, 570, 560, COR_PRETO, "-4")




  //PARÂMETROS 2
oPrintPvt:Box(590,       COL_GRUPO-20 , 670,  560,    "-4")
oPrintPvt:Box(590,       COL_GRUPO-20,    620,  COL_GRUPO+190,   "-4") // Cabeçalho do parâmetro
oPrintPvt:Box(590,       COL_GRUPO+190,    620,  560,   "-4") // Cabeçalho espec/resul

//oPrintPvt:Line(590, COL_GRUPO-20,590, COL_GRUPO+190, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(591, COL_GRUPO-20,591, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(592, COL_GRUPO-20,592, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(593, COL_GRUPO-20,593, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(594, COL_GRUPO-20,594, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(595, COL_GRUPO-20,595, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(596, COL_GRUPO-20,596, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(597, COL_GRUPO-20,597, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(598, COL_GRUPO-20,598, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(599, COL_GRUPO-20,599, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(600, COL_GRUPO-20,600, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(601, COL_GRUPO-20,601, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(602, COL_GRUPO-20,602, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(603, COL_GRUPO-20,603, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(604, COL_GRUPO-20,604, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(605, COL_GRUPO-20,605, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(606, COL_GRUPO-20,606, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(607, COL_GRUPO-20,607, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(608, COL_GRUPO-20,608, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(609, COL_GRUPO-20,609, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(610, COL_GRUPO-20,610, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(611, COL_GRUPO-20,611, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(612, COL_GRUPO-20,612, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(613, COL_GRUPO-20,613, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(614, COL_GRUPO-20,614, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(615, COL_GRUPO-20,615, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(616, COL_GRUPO-20,616, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(617, COL_GRUPO-20,617, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(618, COL_GRUPO-20,618, 560, COR_CINZA, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(619, COL_GRUPO-20,619, 560, COR_CINZA, "-9") // Linha horizontal cor cinza


oPrintPvt:Line(620, COL_GRUPO+190, 670 ,COL_GRUPO+190, COR_PRETO, "-4") // Linha vertical 1
oPrintPvt:Line(605, COL_GRUPO+250, 670 ,COL_GRUPO+250, COR_PRETO, "-4") // Linha vertical 2
oPrintPvt:Line(605, COL_GRUPO+310, 670 ,COL_GRUPO+310, COR_PRETO, "-4") // Linha vertical 3
oPrintPvt:Line(590, COL_GRUPO+370, 670 ,COL_GRUPO+370, COR_PRETO, "-4") // Linha vertical 4
oPrintPvt:Line(605, COL_GRUPO+430, 670 ,COL_GRUPO+430, COR_PRETO, "-4") // Linha vertical 5
oPrintPvt:Line(605, COL_GRUPO+490, 670 ,COL_GRUPO+490, COR_PRETO, "-4") // Linha vertical 6

oPrintPvt:Line(605, COL_GRUPO+190, 605 ,560, COR_PRETO, "-4") // Linha horizontal esp/min;pad;max;med
oPrintPvt:Line(590, COL_GRUPO+190, 620 ,COL_GRUPO+190, COR_PRETO, "-4") // Linha horizontal 1
oPrintPvt:Line(620, COL_GRUPO-20, 620, 560, COR_PRETO, "-4") // Linha horizontal 2
oPrintPvt:Line(630, COL_GRUPO-20, 630, 560, COR_PRETO, "-4") // Linha horizontal 3
oPrintPvt:Line(640, COL_GRUPO+190, 640, 560, COR_PRETO, "-4") // Linha de compensaçao
oPrintPvt:Line(650, COL_GRUPO-20, 650, 560, COR_PRETO, "-4") // Linha horizontal 4
oPrintPvt:Line(660, COL_GRUPO-20, 660, 560, COR_PRETO, "-4") // Linha horizontal 5



// TESTE DE ABERTURA MANUAL
oPrintPvt:Box(680,       COL_GRUPO-20 , 690,  560,     "-4")
oPrintPvt:Line(681, COL_GRUPO-20,681, 560, COR_CINZA2, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(682, COL_GRUPO-20,682, 560, COR_CINZA2, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(683, COL_GRUPO-20,683, 560, COR_CINZA2, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(684, COL_GRUPO-20,684, 560, COR_CINZA2, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(685, COL_GRUPO-20,685, 560, COR_CINZA2, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(686, COL_GRUPO-20,686, 560, COR_CINZA2, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(687, COL_GRUPO-20,687, 560, COR_CINZA2, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(688, COL_GRUPO-20,688, 560, COR_CINZA2, "-9") // Linha horizontal cor cinza
oPrintPvt:Line(689, COL_GRUPO-20,689, 560, COR_CINZA2, "-9") // Linha horizontal cor cinza


oPrintPvt:Line(680, COL_GRUPO+190, 690 ,COL_GRUPO+190, COR_PRETO, "-4") // Linha vertical 1
        //tabela
        


        //textos de titulo
      //oPrintPvt:SayAlign( < nRow>, < nCol>, < cText>, [ oFont], [ nWidth], [ nHeigth], [ nClrText], [ nAlignHorz], [ nAlignVert ] )    
        oPrintPvt:SayAlign(nLinAtu+5, COL_GRUPO+220, "UNIDADE DE FABRICAÇÃO:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+25, COL_GRUPO-20, "AT,:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+25, COL_GRUPO+100, "SEÇÃO DE QUALIDADE", oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+40, COL_GRUPO-20, "CLIENTE:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+50, COL_GRUPO+320, "REVISÃO:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+50, COL_GRUPO-20, "CÓDIGO ARTE/CONJUNTO:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        //espaço
        oPrintPvt:SayAlign(nLinAtu+80, COL_GRUPO-20, "PRODUTO:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+90, COL_GRUPO-20, "CÓDIGO PRODUTO:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        //espaço
        oPrintPvt:SayAlign(nLinAtu+110, COL_GRUPO-20, "NOTA FISCAL:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+120, COL_GRUPO-20, "DATA DE EMBARQUE:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+130, COL_GRUPO-20, "DATA E HORA DE EMISSAO DO LAUDO:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        //espaço
        oPrintPvt:SayAlign(nLinAtu+150, COL_GRUPO-20, "QUANTIDADE DE POTES:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+160, COL_GRUPO-20, "QUANTIDADE DE TAMPAS:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+175, COL_GRUPO+80, "POTE TERMOFORMAGEM:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
         oPrintPvt:SayAlign(nLinAtu+185, COL_GRUPO+70, "LOTE", oFontDetN, 0200, nTamLin, COR_BRANCO, PAD_LEFT, 0)
         oPrintPvt:SayAlign(nLinAtu+185, COL_GRUPO+165, "DATA DE PRODUÇÃO", oFontDetN, 0200, nTamLin, COR_BRANCO, PAD_LEFT, 0)
         oPrintPvt:SayAlign(nLinAtu+185, COL_GRUPO+400, "LOTE", oFontDetN, 0200, nTamLin, COR_BRANCO, PAD_LEFT, 0)
         oPrintPvt:SayAlign(nLinAtu+185, COL_GRUPO+475, "DATA DE PROD.", oFontDetN, 0200, nTamLin, COR_BRANCO, PAD_LEFT, 0)

        oPrintPvt:SayAlign(nLinAtu+284, COL_GRUPO+60, "PARÂMETROS", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+279, COL_GRUPO+250, "ESPECIFICAÇÕES", oFontDetN2, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+279, COL_GRUPO+430, "RESULTADO", oFontDetN2, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+294, COL_GRUPO+206, "MÍNIMO", oFontDetN2, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+294, COL_GRUPO+263, "PADRÃO", oFontDetN2, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+294, COL_GRUPO+325, "MÁXIMO", oFontDetN2, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+294, COL_GRUPO+387, "MÍNIMO", oFontDetN2, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+294, COL_GRUPO+440, "MÁXIMO", oFontDetN2, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+294, COL_GRUPO+500, "MÉDIA", oFontDetN2, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+307, COL_GRUPO+65, "Peso(g)", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+317, COL_GRUPO+60, "Altura Total(mm)", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+327, COL_GRUPO+60, "Volume útil(ml)", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+337, COL_GRUPO+60, "Crush de Esmagamento(Kgf)", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+347, COL_GRUPO+60, "Volume Total(ml)", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+362, COL_GRUPO+60, "Medidas ext. do topo (mm)", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+377, COL_GRUPO+60, "Medidas da Base (mm)", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+387, COL_GRUPO+60, "Altura do Colarinho (mm)", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+397, COL_GRUPO+60, "Medidas ext. do colarinho (mm)", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)

        oPrintPvt:SayAlign(nLinAtu+175, COL_GRUPO+400, "POTE IMPRESSÃO:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+416, COL_GRUPO+75, "TAMPA TERMOFORMAGEM:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+426, COL_GRUPO+70, "LOTE", oFontDetN, 0200, nTamLin, COR_BRANCO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+426, COL_GRUPO+165, "DATA DE PRODUÇÃO", oFontDetN, 0200, nTamLin, COR_BRANCO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+426, COL_GRUPO+400, "LOTE", oFontDetN, 0200, nTamLin, COR_BRANCO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+426, COL_GRUPO+475, "DATA DE PROD.", oFontDetN, 0200, nTamLin, COR_BRANCO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+416, COL_GRUPO+400, "TAMPAS IMPRESSÃO:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)

        oPrintPvt:SayAlign(nLinAtu+525, COL_GRUPO+60, "PARÂMETROS", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+520, COL_GRUPO+250, "ESPECIFICAÇÕES", oFontDetN2, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+520, COL_GRUPO+430, "RESULTADO", oFontDetN2, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+535, COL_GRUPO+206, "MÍNIMO", oFontDetN2, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+535, COL_GRUPO+263, "PADRÃO", oFontDetN2, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+535, COL_GRUPO+325, "MÁXIMO", oFontDetN2, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+535, COL_GRUPO+387, "MÍNIMO", oFontDetN2, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+535, COL_GRUPO+440, "MÁXIMO", oFontDetN2, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+535, COL_GRUPO+500, "MÉDIA", oFontDetN2, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+547, COL_GRUPO+60, "   Peso(g)", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+562, COL_GRUPO+45, "Medida total - Com abas (mm)", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+577, COL_GRUPO+45, "Altura Total(mm)", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+587, COL_GRUPO+45, "Crush de Fechamento(KgF.)", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)


oPrintPvt:SayAlign(680, COL_GRUPO+60, "Teste de abertura manual", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
oPrintPvt:SayAlign(680, COL_GRUPO+226, "( )     Aprovado            ( )    Reprovado", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)

        // parte de baixo
        oPrintPvt:SayAlign(695, COL_GRUPO-20, "ESPECIFICAÇÕES GERAIS DO PRODUTO", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        //Espaço
        oPrintPvt:SayAlign(705, COL_GRUPO-20, "Substrato:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign( 705, COL_GRUPO+240, "PP(Polipropileno)", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        //Espaço
        oPrintPvt:SayAlign( 725, COL_GRUPO-20, "Prazo de Validade:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign( 725, COL_GRUPO+240, "01 ano a partir da data de fabricação, desde que mantido o acondicionamento original e seguidos as", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(733, COL_GRUPO+240, "orientações da embalagem", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        //Espaço
        oPrintPvt:SayAlign(745, COL_GRUPO-20, "Categoria da Reciclagem:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(745, COL_GRUPO+240, "05", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(755, COL_GRUPO-20, "Tipo de Impressão:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(755, COL_GRUPO+240, "Dry off-set ou sleeve (conforme especificação do cliente)", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(765, COL_GRUPO-20, "Dizeres Legais e Informações Nutricionais", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(765, COL_GRUPO+240, "Conformes aprovação de arte do cliente", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(775, COL_GRUPO-20, "Texto e Layout", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(775, COL_GRUPO+240, "Conformes aprovação de arte do cliente", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(785, COL_GRUPO-20, "Padrão de Cor:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(785, COL_GRUPO+240, "Conformes aprovação de arte do cliente", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(795, COL_GRUPO-20, "Odores:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(795, COL_GRUPO+240, "Isento", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(805, COL_GRUPO-20, "Umidade:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(805, COL_GRUPO+240, "Isento", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(815, COL_GRUPO-20, "Contaminação:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(815, COL_GRUPO+240, "Isento", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(825, COL_GRUPO-20, "Rebarbas:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(825, COL_GRUPO+240, "Isento", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(835, COL_GRUPO-20, "Crush de Fechamento e Esmagamento:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(835, COL_GRUPO+240, "Conforme", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(845, COL_GRUPO-20, "Registro da Arte:", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(845, COL_GRUPO+240, "Conformes aprovação de arte do cliente", oFontDetS, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)

       nLinAtu += nTamLin
        QRY_SA1->(DbSkip())
    EndDo
        QRY_SA1->(DbCloseArea())
     
    //Se ainda tiver linhas sobrando na página, imprime o rodapé final
    If nLinAtu <= nLinFin
        fImpRod()
    EndIf
     
    //Mostrando o relatório
    oPrintPvt:Preview()
Return
 
/*---------------------------------------------------------------------*
 | Func:  fImpCab                                                      |
 | Desc:  Função que imprime o cabeçalho                               |
 *---------------------------------------------------------------------*/
 
Static Function fImpCab()
    Local cTexto   := ""
    Local nLinCab  := 030
     
    //Iniciando Página
    oPrintPvt:StartPage()
     
    //Cabeçalho
    cTexto := "LAUDO TÉCNICO"
    oPrintPvt:SayAlign(nLinCab+5, nColMeio - 50, cTexto + "*Lugar de colocar a query*", oFontTit, 240, 20, COR_PRETO, PAD_CENTER, 0)
    oPrintPvt:SayBitmap( nLinCab-8, COL_GRUPO, "C:\semaforo\fibrasa.bmp", 70, 40)
    //Linha Separatória
    nLinCab += (nTamLin * 2)
    oPrintPvt:Line(nLinCab-30, nColIni-500, nLinCab-30, nColFin+500, COR_PRETO)
    oPrintPvt:Line(nLinCab+15, nColIni-500, nLinCab+15, nColFin+500, COR_PRETO)
     
    //Cabeçalho das colunas
    nLinCab += nTamLin
   /*  oPrintPvt:SayAlign(nLinCab, COL_GRUPO, "Grupo",     oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0) */
    /* oPrintPvt:SayAlign(nLinCab, COL_DESCR, "Descrição", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0) */
    nLinCab += nTamLin
     
    //Atualizando a linha inicial do relatório
    nLinAtu := nLinCab + 3
Return
 
/*---------------------------------------------------------------------*
 | Func:  fImpRod                                                      |
 | Desc:  Função que imprime o rodapé                                  |
 *---------------------------------------------------------------------*/
 
Static Function fImpRod()
    Local nLinRod   := nLinFin + nTamLin
    //Local cTextoEsq := ''
   // Local cTextoDir := ''
 
    //Linha Separatória
    //oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin, COR_PRETO)
 
    nLinRod += 3
     
    //Dados da Esquerda e Direita
    //cTextoEsq := dToC(dDataGer) + "    " + cHoraGer + "    " + FunName() + "    " + cNomeUsr
   // cTextoDir := "Página " + cValToChar(nPagAtu)
     
    //Imprimindo os textos
    //oPrintPvt:SayAlign(nLinRod, nColIni,    cTextoEsq, oFontRod, 200, 05, COR_CINZA, PAD_LEFT,  0)
    //oPrintPvt:SayAlign(nLinRod, nColFin-40, cTextoDir, oFontRod, 040, 05, COR_CINZA, PAD_RIGHT, 0)
     
    //Finalizando a página e somando mais um
    oPrintPvt:EndPage()
    nPagAtu++
Return
