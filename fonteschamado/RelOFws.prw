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
 
// Cores
#Define COR_CINZA   RGB(180, 180, 180)
#Define COR_PRETO   RGB(000, 000, 000)
 
//Colunas
#Define COL_NUM   0015
#Define COL_EMISSAO   0095
#Define COL_PRODUTO   0095
#Define COL_QUANT   0095
 
/*/{Protheus.doc} zTstRel 
Exemplos de FWMSPrinter
@author Atilio
@since 27/01/2019
@version 1.0
@type function
/*/
 
User Function zTstRel()
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
    Private cNomeUsr  := UsrRetName(RetCodUsr())
    //Fontes
    Private cNomeFont := "Arial"
    Private oFontDet  := TFont():New(cNomeFont, 9, 160, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontLeg  := TFont():New(cNomeFont, 9, 30, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDetN := TFont():New(cNomeFont, 9, 20, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontRod  := TFont():New(cNomeFont, 9, -08, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontTit  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
     
    //Definindo o diretório como a temporária do S.O. e o nome do arquivo com a data e hora (sem dois pontos)
    cCaminho  := GetTempPath()
    cArquivo  := "zTstRel_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-')
     
    //Criando o objeto do FMSPrinter
    oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., "", .T., , @oPrintPvt, "", , , , .T.)
     
    //Setando os atributos necessários do relatório
    oPrintPvt:SetResolution(72)
    oPrintPvt:SetLandScape()
  /*   oPrintPvt:SetPaperSize(1) */
    oPrintPvt:SetMargin(60, 60, 60, 60)
     
    //Imprime o cabeçalho
    fImpCab()
     
    //Montando a consulta
    cQryAux := " SELECT "                                       + CRLF
    cQryAux += "     C2_NUM, "                                  + CRLF
    cQryAux += "     C2_EMISSAO, "                              + CRLF
    cQryAux += "    C2_PRODUTO, "                               + CRLF
    cQryAux += "    C2_QUANT, "                                  + CRLF
    cQryAux += "    C2_UM"                                  + CRLF
    cQryAux += " FROM "                                         + CRLF
    cQryAux += "     " + RetSQLName('SC2') + " SC2 "            + CRLF
    cQryAux += " WHERE "                                        + CRLF 
    cQryAux += "     C2_FILIAL = '" + FWxFilial('SC2') + "' "   + CRLF
    cQryAux += "     AND SC2.D_E_L_E_T_ = ' ' "                 + CRLF
    cQryAux += " ORDER BY "                                     + CRLF
    cQryAux += "     C2_NUM "                                 + CRLF
    TCQuery cQryAux New Alias "QRY_SC2"
     
    //Conta o total de registros, seta o tamanho da régua, e volta pro topo
    Count To nTotal
    ProcRegua(nTotal)
    QRY_SC2->(DbGoTop())
    nAtual := 0
     
    //Enquanto houver registros
    While ! QRY_SC2->(EoF())
        nAtual++
        IncProc("Imprimindo grupo " + QRY_SC2->C2_NUM + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")
         
        //Se a linha atual mais o espaço que será utilizado forem maior que a linha final, imprime rodapé e cabeçalho
        If nLinAtu + nTamLin > nLinFin
            fImpRod()
            fImpCab()
        EndIf
         
        //Imprimindo a linha atual
        oPrintPvt:SayAlign(nLinAtu+180, 0200, QRY_SC2->C2_NUM, oFontDet, 0800, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+420, 0065, "Data: "+ dToC(dDataGer) , oFontLeg, 0200, nTamLin+10, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+420, 0345, "Hora: "+ cHoraGer , oFontLeg, 0200, nTamLin+10, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+420, 0625,  "Item: "+QRY_SC2->C2_PRODUTO, oFontLeg, 0200, nTamLin+10, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+480, 0345, "Qtd: "+ CVALTOCHAR(QRY_SC2->C2_QUANT)+ " "+QRY_SC2->C2_UM, oFontLeg, 0200, nTamLin+10, COR_PRETO, PAD_LEFT, 0)
       
 /*  oPrintPvt:SayAlign(nLinAtu, COL_EMISSAO, QRY_SC2->C2_EMISSAO,  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu, COL_PRODUTO, QRY_SC2->C2_PRODUTO,  oFontDet, 0300, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu, COL_QUANT, CVALTOCHAR(QRY_SC2->C2_QUANT),  oFontDet, 0400, nTamLin, COR_PRETO, PAD_LEFT, 0) */
        nLinAtu += nTamLin
         
        QRY_SC2->(DbSkip())
    EndDo
    QRY_SC2->(DbCloseArea())
      
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
    /* cTexto := "Relação de Grupos de Produtos"
    oPrintPvt:SayAlign(nLinCab, nColMeio - 120, cTexto, oFontTit, 240, 20, COR_CINZA, PAD_CENTER, 0) */
     
    //Linha Separatória
    /* nLinCab += (nTamLin * 2)
    oPrintPvt:Line(nLinCab+90, nColIni, nLinCab, nColFin, COR_CINZA) */
     
    //Cabeçalho das colunas
    nLinCab += nTamLin
    oPrintPvt:SayAlign(nLinCab+50, 0310, "OP",     oFontDet, 0800, nTamLin, COR_PRETO, PAD_LEFT, 0)
/*     oPrintPvt:SayAlign(nLinCab+20, COL_NUM, "OP",     oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0) */

   /*  oPrintPvt:SayAlign(nLinCab+10, COL_EMISSAO, "Data:", oFontDetN, 0200, nTamLin+10, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:SayAlign(nLinCab+50, COL_PRODUTO, "Item:", oFontDetN, 0300, nTamLin+30, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:SayAlign(nLinCab+10, COL_QUANT, "Qtd", oFontDetN, 0400, nTamLin+40, COR_PRETO, PAD_LEFT, 0) */
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
    Local cTextoEsq := ''
    Local cTextoDir := ''
 
    //Linha Separatória
    oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin, COR_CINZA)
    nLinRod += 3
     
    //Dados da Esquerda e Direita
    cTextoEsq := dToC(dDataGer) + "    " + cHoraGer + "    " + FunName() + "    " + cNomeUsr
    cTextoDir := "Página " + cValToChar(nPagAtu)
     
    //Imprimindo os textos
    oPrintPvt:SayAlign(nLinRod, nColIni,    cTextoEsq, oFontRod, 200, 05, COR_CINZA, PAD_LEFT,  0)
    oPrintPvt:SayAlign(nLinRod+10, nColFin-40, cTextoDir, oFontRod, 040, 15, COR_CINZA, PAD_RIGHT, 0)

     
    //Finalizando a página e somando mais um
    oPrintPvt:EndPage()
    nPagAtu++
Return
