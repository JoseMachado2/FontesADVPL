#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#include "TopConn.ch"
#include "Color.ch"
#include "COLORS.ch"

#DEFINE SM0_FILIAL	02
#DEFINE SM0_NREDUZ 07

#define CLR_SILVER rgb(192,192,192)
#define CLR_LIGHTGRAY rgb(220,220,220)

User Function RELFAL00
	Local oReport
	Private _Enter    := chr(13) + Chr(10)
	Private aOrdem    := {}
	Private cAliasTop := GetNextAlias()
	Private oRelBCO
	Private _lBold := .F. //Controle de IMpressão em NEgrito
	Private _nSize := TamSX3("E5_VALOR")[1]
	Private _lPixel := .F.
	Private lAutoSize := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= fRunBco()
	oReport:PrintDialog()
Return

Static Function fRunBco
	Local oReport
	/* cPerg     := "MFINR001" */
	_cTitulo  := "Relatorio de Apontamentos"
//	Pergunte( cPerg , .T. , "Informe os parametros")

Local aPergs   := {}
Local cFilialDe  := Space(TamSX3('PC_FILIAL')[01])
Local cFilialAt  := Space(TamSX3('PC_FILIAL')[01])
Local cMatDe  := Space(TamSX3('PC_MAT')[01])
Local cMatAt  := Space(TamSX3('PC_MAT')[01])
Local dDataDe  := FirstDate(Date())
Local dDataAt  := LastDate(Date())

 

aAdd(aPergs, {1, "Filial De",  cFilialDe,  "",             ".T.",        "SPC", ".T.", 80,  .F.})
aAdd(aPergs, {1, "Filial Até", cFilialAt,  "",             ".T.",        "SPC", ".T.", 80,  .T.})
aAdd(aPergs, {1, "Matricula De",  cMatDe,  "",             ".T.",        "SPC", ".T.", 80,  .F.})
aAdd(aPergs, {1, "Matricula Até", cMatAt,  "",             ".T.",        "SPC", ".T.", 80,  .T.})
aAdd(aPergs, {1, "Data De",  dDataDe,  "",             ".T.",        "",    ".T.", 80,  .F.})
aAdd(aPergs, {1, "Data Até", dDataAt,  "",             ".T.",        "",    ".T.", 80,  .T.})


 
If ParamBox(aPergs, "Informe os parâmetros")
    /* Alert(MV_PAR01)
    Alert(MV_PAR02)
    Alert(MV_PAR03)
    Alert(MV_PAR04)
    Alert(MV_PAR05)
    Alert(MV_PAR06)
    Alert(MV_PAR07)
    Alert(MV_PAR08)
    Alert(MV_PAR09) */
EndIf

	//oReport:= TReport():New("fRunBco",_cTitulo,{|oReport| ReportPrint(oReport,aOrdem,cAliasTop)},_cTitulo)
	oReport:= TReport():New("fRunBco",_cTitulo, , {|oReport| ReportPrint(oReport,aOrdem,cAliasTop)},_cTitulo)
	oReport:SetCustomText({||CriaCab(oReport)})
	oReport:SetLandscape()

	//Parametriza o TReport para alinhamento a direita
	oReport:SetRightAlignPrinter(.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criacao da Sessao 1                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oRelBCO:= TRSection():New(oReport,_cTitulo,{"SE5"} ,aOrdem)

	oRelBCO:SetTotalInLine(.F.)

	//New(oParent,cName           ,cAlias,cTitle,cPicture                       ,nSize                      ,lPixel    ,bBlock                           ,cAlign ,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize      ,nClrBack  ,nClrFore ,lBold)
	TRCell():New(oRelBCO,'Filial'  		,''    ,      ,PesqPict("SPC", "PC_FILIAL")   ,TamSX3("PC_FILIAL")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelBCO,'Codigo'    	,' '   ,      ,PesqPict("SRA", "RA_CC")    ,TamSX3("RA_CC")[1]+30 ,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT",          ,"LEFT"      ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelBCO,'Descrição'    		,''    ,      ,PesqPict("CTT", "CTT_DESC01")    ,TamSX3("CTT_DESC01")[1]    ,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT",          ,"LEFT"      ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelBCO,'Matricula'  		,''    ,      ,PesqPict("SRA", "RA_MAT")  ,TamSX3("RA_MAT")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT",          ,"LEFT"      ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelBCO,'Nome'    		,''    ,      ,PesqPict("SRA", "RA_NOME")    ,TamSX3("RA_NOME")[1]   	,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT",          ,"LEFT"      ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelBCO,'Tipo Evento'    	,' '   ,      ,PesqPict("SPC", "PC_PD")     ,TamSX3("PC_PD")[1]   	,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT",          ,"LEFT"      ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelBCO,'Justificativa' 	,''	   , 	  ,PesqPict("SPC", "PC_ABONO")    ,TamSX3("PC_ABONO")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelBCO,'Soma de Horas' 		,''    ,      ,PesqPict("SPC", "PC_QUANTC")    ,TamSX3("PC_QUANTC")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
   // TRCell():New(oRelBCO,'Despesas' 		,''    ,      ,PesqPict("SE5", "E5_VALOR")    ,TamSX3("E5_VALOR")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
   // TRCell():New(oRelBCO,'Saldo Atual   ' 	,''    ,      ,PesqPict("SE5", "E5_VALOR")    ,TamSX3("E5_VALOR")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	
Return(oReport)

Static Function ReportPrint(oReport,aOrdem,cAliasTop)

	Local nPrc, nMs, nX, nFil
	Local cOrderBy  := ''
	Local oRelBCO	:= oReport:Section(1)
	Local cIndexkey	:= ''
	Local nOrdem   	:= oRelBCO:GetOrder()
	Local cFilUser  := oReport:Section(1):GetAdvplExp()
    Local cQuery    := ""
    Local cFilialx    := ""
	Local nIni		:= 0
	Local nDuracao		:= 0
    Local nRec      := 0
    Local nDesp     := 0
	Local nIniAc	:= 0
	Local nSldAc 	:= 0
    Local nRecAc    := 0
    Local nDespAc   := 0
	Local nRegPrc

	//Pergunte(oReport:uParam,.F.)
	//MakeSqlExpr(oReport:uParam)
	//MakeSqlExpr(oReport:GetParam())

	oReport:cTitle := "Relatorio de Apontamentos"



	cQuery += "SELECT"
cQuery += "    PC_FILIAL AS Filial,"
cQuery += "    SRA.RA_CC AS Codigo,"
cQuery += "    CTT010.CTT_DESC01 AS Descricao,"
cQuery += "    PC_MAT AS Matricula,"
cQuery += "    SRA.RA_NOME AS Nome,"
cQuery += "    CASE PC_PD"
cQuery += "        WHEN '001' THEN 'HORAS NORMAIS       '"
cQuery += "        WHEN '002' THEN 'D.S.R               '"
cQuery += "        WHEN '003' THEN 'ADICIONAL NOTURNO   '"
cQuery += "        WHEN '004' THEN 'H.NOT               '"
cQuery += "        WHEN '005' THEN 'H.NORMAIS N/REALIZ  '"
cQuery += "        WHEN '006' THEN 'H.NOT N/REALIZADAS  '"
cQuery += "        WHEN '007' THEN 'FALTA 1/2 PER N/AUT '"
cQuery += "        WHEN '008' THEN 'FALTA 1/2 PERIODO   '"
cQuery += "        WHEN '009' THEN 'FALTA INTEG N/AUT   '"
cQuery += "        WHEN '010' THEN 'FALTA INTEGRAL      '"
cQuery += "        WHEN '011' THEN 'ATRASO N/AUT        '"
cQuery += "        WHEN '012' THEN 'ATRASO  '"
cQuery += "        WHEN '013' THEN 'SAIDA ANTECIP N/AUT '"
cQuery += "        WHEN '014' THEN 'SAIDA ANTECIPADA    '"
cQuery += "        WHEN '015' THEN 'REFEICAO EMPRESA    '"
cQuery += "        WHEN '016' THEN 'REFEICAO            '"
cQuery += "        WHEN '017' THEN 'DESCONTO DSR N/AUT  '"
cQuery += "        WHEN '018' THEN 'DESCONTO DO DSR     '"
cQuery += "        WHEN '019' THEN 'SAIDA EXPED N/AUT   '"
cQuery += "        WHEN '020' THEN 'SAIDA NO EXPEDIENTE '"
cQuery += "        WHEN '021' THEN 'ATRASO P.ANT N/AUT  '"
cQuery += "        WHEN '022' THEN 'ATRASO PERIODO ANT  '"
cQuery += "		WHEN '023' THEN 'BCO HORAS - PROVENTO'"
cQuery += "		WHEN '024' THEN 'BCO HORAS - DESCONTO'"
cQuery += "		WHEN '025' THEN 'NONA HORA           '"
cQuery += "		WHEN '026' THEN 'H.NORMAIS NOT       '"
cQuery += "		WHEN '027' THEN 'ADIC.HE N/AUT       '"
cQuery += "		WHEN '028' THEN 'ADIC NOT S/HE       '"
cQuery += "		WHEN '029' THEN 'HE INTER JORNADA    '"
cQuery += "		WHEN '030' THEN 'HORAS DE INTERVALO  '"
cQuery += "		WHEN '031' THEN 'H.INTERVALO NOT     '"
cQuery += "		WHEN '032' THEN 'FALTAS H.INTERVALO  '"
cQuery += "		WHEN '033' THEN 'FALTAS H.INT N/AUT  '"
cQuery += "		WHEN '034' THEN 'FALTAS H.INT NOT    '"
cQuery += "		WHEN '035' THEN 'FALTAS H.INT NOT N/A'"
cQuery += "		WHEN '036' THEN 'DSR AUT PERIODO ANT '"
cQuery += "		WHEN '037' THEN 'ACRESCIMO NOT       '"
cQuery += "		WHEN '038' THEN 'HE INTER JORN N/AUT '"
cQuery += "		WHEN '039' THEN 'FALTAS H.INT NOT    '"
cQuery += "		WHEN '040' THEN 'descanso laborado'"
cQuery += "		WHEN '041' THEN 'teste'"
cQuery += "		WHEN '042' THEN 'TOT MESES BCO HORAS '"
cQuery += "		WHEN '043' THEN 'HE 50% NORMAL N/AUT '"
cQuery += "		WHEN '044' THEN 'HE 50% NORMAL       '"
cQuery += "		WHEN '045' THEN 'HE DSR N/AUT        '"
cQuery += "		WHEN '046' THEN 'DSR H EXTRA         '"
cQuery += "		WHEN '047' THEN 'HE COMPENSADO N/AUT '"
cQuery += "		WHEN '048' THEN 'HE COMPENSADO 50%   '"
cQuery += "		WHEN '049' THEN 'HE FERIADO N/AUT    '"
cQuery += "		WHEN '050' THEN 'HE FERIADO 100%     '"
cQuery += "		WHEN '051' THEN 'HE NORMAL NOT N/AUT '"
cQuery += "		WHEN '052' THEN 'HE NORMAL NOT 50%   '"
cQuery += "		WHEN '053' THEN 'HE DSR NOT N/AUT    '"
cQuery += "		WHEN '054' THEN 'HE DSR NOT 100%     '"
cQuery += "		WHEN '055' THEN 'HE COMP NOT N/AUT   '"
cQuery += "		WHEN '056' THEN 'HE COMP NOT  50%    '"
cQuery += "		WHEN '057' THEN 'HE FERIADO NOT N/AUT'"
cQuery += "		WHEN '058' THEN 'HE FERIADO NOT 100% '"
cQuery += "		WHEN '059' THEN 'HE 60% N/AUT        '"
cQuery += "		WHEN '060' THEN 'HE 60%              '"
cQuery += "		WHEN '061' THEN 'HE 65% N/AUT                '"
cQuery += "		WHEN '062' THEN 'HE 65%                          '"
cQuery += "		WHEN '063' THEN 'HE 70% N/AUT               '"
cQuery += "		WHEN '064' THEN 'HE 70%              '"
cQuery += "		WHEN '065' THEN 'HE 75% N/AUT  '"
cQuery += "		WHEN '066' THEN 'HE 75%'"
cQuery += "		WHEN '067' THEN 'HE 80% N/AUT        '"
cQuery += "		WHEN '068' THEN 'HE 80%              '"
cQuery += "		WHEN '069' THEN 'HE 120% N/AUT       '"
cQuery += "		WHEN '070' THEN 'HE 120%             '"
cQuery += "		WHEN '071' THEN 'HE 200%N/AUT        '"
cQuery += "		WHEN '072' THEN 'HE 100% FERIADO     '"
cQuery += "		WHEN '073' THEN 'HE 50% FOL          '"
cQuery += "		WHEN '074' THEN 'HE 100% FOL         '"
cQuery += "		WHEN '075' THEN 'DESC. ATRASOS FOL   '"
cQuery += "		WHEN '076' THEN 'FALTA DESC FOLHA    '"
cQuery += "		WHEN '077' THEN 'H. EXTRA 80% FOL    '"
cQuery += "        ELSE PC_PD"
cQuery += "    END AS TIPO_EVENTO,"
cQuery += "    CASE PC_ABONO"
cQuery += "        WHEN '001' THEN 'ABONADO                              '"
cQuery += "        WHEN '002' THEN 'ADMITIDO                               '"
cQuery += "        WHEN '003' THEN 'ADICIONAL NOTURNO   '"
cQuery += "        WHEN '004' THEN 'ALISTAMENTO MILITAR                     '"
cQuery += "        WHEN '005' THEN 'AMAMENTACAO               '"
cQuery += "        WHEN '006' THEN 'ASSUNTOS JURIDICOS         '"
cQuery += "        WHEN '007' THEN 'ASSUNTOS PESSOAIS         '"
cQuery += "        WHEN '008' THEN 'ATESTADO                 '"
cQuery += "        WHEN '009' THEN 'AVISO PREVIO                   '"
cQuery += "        WHEN '010' THEN 'BATIDA DUPLICIDADE            '"
cQuery += "        WHEN '011' THEN 'BENEFICIO INSS                 '"
cQuery += "        WHEN '012' THEN 'CARTAO MANUAL              '"
cQuery += "        WHEN '013' THEN 'CARTORIO ELEITORAL        '"
cQuery += "        WHEN '014' THEN 'CASAMENTO                   '"
cQuery += "        WHEN '015' THEN 'CHUVA                        '"
cQuery += "        WHEN '016' THEN 'COMPENSACAO                             '"
cQuery += "        WHEN '017' THEN 'CURSO              '"
cQuery += "        WHEN '018' THEN 'DECLARACAO ABONADA           '"
cQuery += "        WHEN '019' THEN 'DECL DE ACOMPANHAMENTO  '"
cQuery += "		WHEN '020' THEN ' DECLARACAO COMPARECIMENTO '"
cQuery += "		WHEN '021' THEN 'DELEGACIA                 '"
cQuery += "		WHEN '022' THEN 'DEMISSAO       '"
cQuery += "		WHEN '023' THEN 'FALHA  DIGITAL           '"
cQuery += "		WHEN '024' THEN 'DOAR SANGUE              '"
cQuery += "		WHEN '025' THEN 'FOLGA DA ELEICAO                   '"
cQuery += "		WHEN '026' THEN 'ENEM                          '"
cQuery += "		WHEN '027' THEN 'ERRO DIGITAL                '"
cQuery += "		WHEN '028' THEN 'ESQUECEU BATIMENTO PONTO       '"
cQuery += "		WHEN '029' THEN 'FALECIMENTO                  '"
cQuery += "		WHEN '030' THEN 'FALTA DE ENERGIA           '"
cQuery += "		WHEN '031' THEN 'FERIADO                      '"
cQuery += "		WHEN '032' THEN 'FERIAS                    '"
cQuery += "		WHEN '033' THEN 'FOLGA                     '"
cQuery += "		WHEN '034' THEN 'FOLGA FERIADO                '"
cQuery += "		WHEN '035' THEN 'FOLGA FIXA'"
cQuery += "		WHEN '036' THEN 'GREVE DE ONIBUS           '"
cQuery += "		WHEN '037' THEN 'INICIO BATIDA DE PONTO          '"
cQuery += "		WHEN '038' THEN 'GREVE METRO     '"
cQuery += "		WHEN '039' THEN 'INTIMACAO JUDICIAL         '"
cQuery += "		WHEN '040' THEN 'LICENCA MATERNIDADE      '"
cQuery += "		WHEN '041' THEN 'LICENCA PATERNIDADE      '"
cQuery += "		WHEN '042' THEN 'MEDICO DO TRABALHO        '"
cQuery += "		WHEN '043' THEN 'MUDANCA DE HORARIO        '"
cQuery += "		WHEN '044' THEN 'PARALISACAO PROTESTO        '"
cQuery += "		WHEN '045' THEN 'PEDIDO DEMISSAO             '"
cQuery += "		WHEN '046' THEN 'PONTO CARTOGRAFICO           '"
cQuery += "		WHEN '047' THEN 'PONTO COM DEFEITO         '"
cQuery += "		WHEN '048' THEN 'PROBLEMA NO METRO         '"
cQuery += "		WHEN '049' THEN 'RECEBIMENTO PIS              '"
cQuery += "		WHEN '050' THEN 'REUNIAO                      '"
cQuery += "		WHEN '051' THEN 'SUSPENSAO                '"
cQuery += "		WHEN '052' THEN 'SERVICO EXTERNO           '"
cQuery += "		WHEN '053' THEN 'TRANFERENCIA                '"
cQuery += "		WHEN '054' THEN 'TRANSPORTE                   '"
cQuery += "		WHEN '055' THEN 'TREINAMENTO                '"
cQuery += "		WHEN '056' THEN 'TROCA                        '"
cQuery += "		WHEN '057' THEN 'HOME OFFICE              '"
cQuery += "		WHEN '058' THEN 'ATESTADO DE OBITO        '"
cQuery += "		WHEN '059' THEN 'ATESTADO DE OBITO   N  '"
cQuery += "        WHEN '060' THEN 'ABONADO PELA EMPRESA                   '"
cQuery += "        WHEN '061' THEN 'DESCONTO B. HORAS                    '"
cQuery += "        ELSE PC_ABONO"
cQuery += "    END AS JUSTIFICATIVA,"
cQuery += "    SUM(PC_QUANTC) AS Soma_Duracao"
cQuery += "  FROM "+RetSqlName('SPC')+" SPC"
cQuery += "    LEFT JOIN SRA010 SRA ON SRA.RA_MAT = SPC.PC_MAT AND SRA.RA_FILIAL = SPC.PC_FILIAL AND SRA.D_E_L_E_T_ <> '*'"
cQuery += "    LEFT JOIN CTT010 ON SRA.RA_CC = CTT010.CTT_CUSTO AND SUBSTRING(SRA.RA_FILIAL,1,2) = CTT010.CTT_FILIAL AND CTT010.D_E_L_E_T_ <> '*'"
cQuery += "WHERE"
cQuery += "    SPC.D_E_L_E_T_ <> '*' AND PC_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND PC_MAT BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND PC_DATA BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"'
cQuery += "GROUP BY  PC_FILIAL, SRA.RA_CC,  CTT010.CTT_DESC01,PC_MAT,  SRA.RA_NOME, PC_PD, PC_ABONO  "
cQuery += "ORDER BY"
cQuery += "    PC_FILIAL, SRA.RA_CC, CTT010.CTT_DESC01, PC_MAT, SRA.RA_NOME, PC_PD;"

    MpSysOpenQuery(cQuery, "TE5")

	oReport:SetMeter(100) //-> Indica quantos registros serao processados para a regua ³
	nCt := 1
	Do While !oReport:Cancel() .And. !TE5->(Eof())

		oReport:IncMeter()
		oRelBCO:Init()
		oReport:SetMsgPrint( "Calculando contas ... "+cValToChar(nCt)+" / "+cValToChar(nRegPrc) )

        cFilialx  := TE5->FILIAL
        nRec    := 0
        nDesp   := 0

        While !oReport:Cancel() .And. !TE5->(Eof()) .And. cFilialx == TE5->FILIAL


			oRelBCO:Cell('Filial'):SetValue(TE5->FILIAL)
			oRelBCO:Cell('Codigo'):SetValue(TE5->CODIGO)
			oRelBCO:Cell('Descrição'):SetValue(TE5->DESCRICAO)
			oRelBCO:Cell('Matricula'):SetValue(TE5->MATRICULA)
			oRelBCO:Cell('Nome'):SetValue(TE5->NOME)
            oRelBCO:Cell('Tipo Evento'):SetValue(TE5->TIPO_EVENTO)
			oRelBCO:Cell('Justificativa'):SetValue(TE5->JUSTIFICATIVA)
			oRelBCO:Cell('Soma de Horas'):SetValue(TE5->SOMA_DURACAO)
           


		    nDuracao := nDuracao + TE5->SOMA_DURACAO
        



            oRelBCO:Printline()
		    oReport:SkipLine() //-- Salta Linha		

            TE5->(DbSkip())
        EndDo

        oRelBCO:Cell('Filial'):SetValue(cFilialx)
		oRelBCO:Cell('Codigo'):SetValue(Space(TamSX3("RA_CC")[1]+30))
		oRelBCO:Cell('Descrição'):SetValue(Space(TamSX3("CTT_DESC01")[1]))
		oRelBCO:Cell('Matricula'):SetValue(Space(TamSX3("RA_MAT")[1]))
		oRelBCO:Cell('Nome'):SetValue(Space(TamSX3("RA_NOME")[1]))
		oRelBCO:Cell('Tipo Evento'):SetValue(Space(TamSX3("PC_PD")[1]))
	    oRelBCO:Cell('Justificativa'):SetValue(Space(TamSX3("PC_ABONO")[1]))
		oRelBCO:Cell('Soma de Horas'):SetValue(nDuracao)
		oRelBCO:Printline()
		oReport:SkipLine() //-- Salta Linha		

	EndDo

	TE5->(DbCloseArea())

    //Total acumulado
	/* oRelBCO:Cell('Filial'):nClrBack := CLR_LIGHTGRAY
	oRelBCO:Cell('Codigo'):nClrBack := CLR_LIGHTGRAY
    oRelBCO:Cell('Descrição'):nClrBack := CLR_LIGHTGRAY
	oRelBCO:Cell('Matricula'):nClrBack := CLR_LIGHTGRAY
	oRelBCO:Cell('Nome'):nClrBack := CLR_LIGHTGRAY
    oRelBCO:Cell('Tipo Evento'):nClrBack := CLR_LIGHTGRAY
	oRelBCO:Cell('Justificativa'):nClrBack := CLR_LIGHTGRAY
	oRelBCO:Cell('Soma de Horas'):nClrBack := CLR_LIGHTGRAY
   

	oRelBCO:Cell('Filial'):LBOLD := .T.
	oRelBCO:Cell('Codigo'):LBOLD := .T.
    oRelBCO:Cell('Descrição'):LBOLD := .T.
	oRelBCO:Cell('Matricula'):LBOLD := .T.
	oRelBCO:Cell('Nome'):LBOLD := .T.
	oRelBCO:Cell('Tipo Evento'):LBOLD := .T.
	oRelBCO:Cell('Justificativa'):LBOLD := .T.
	oRelBCO:Cell('Soma de Horas'):LBOLD := .T.


	oRelBCO:Cell('Filial'):SetValue(Space(TamSX3("PC_FILIAL")[1]))
	oRelBCO:Cell('Codigo'):SetValue(Space(TamSX3("RA_CC")[1]+30))
	oRelBCO:Cell('Banco'):SetValue("Geral -> ")
	oRelBCO:Cell('Agencia'):SetValue(Space(TamSX3("E5_AGENCIA")[1]))
	oRelBCO:Cell('Conta'):SetValue(Space(TamSX3("E5_CONTA")[1]))
	oRelBCO:Cell('Nome Conta'):SetValue(Spce(TamSX3("A6_NOME")[1]))
    oRelBCO:Cell('Saldo Inicial'):SetValue(nIniAc)
	oRelBCO:Cell('Receitas'):SetValue(nRecAc)
	oRelBCO:Cell('Despesas'):SetValue(nDespAc)
    oRelBCO:Cell('Saldo Atual'):SetValue('((nSldAc+nDespAc)-nRecAc+nDespAc)-nRecAc') */
    //oRelBCO:Cell('Saldo Atual'):SetValue(((nSldAc+nDespAc)-nRecAc+nDespAc)-nRecAc)

    oRelBCO:Printline()
	oReport:SkipLine() //-- Salta Linha		

	//Next nFil
	oRelBCO:Finish()

Return

Static Function CriaCab( oRelatorio )
	Local aArea		:= GetArea()
	Local aCabec	:= {}
	Local cChar		:= chr(160)
	local _cEmp 	:= FWCodEmp()

	_DataDe := DToC(MV_PAR05)
	_DataAte:= DToC(MV_PAR06)

	aCabec := {	"__LOGOEMP__" + "         " + cChar + "         " + RptFolha+TRANSFORM(oRelatorio:Page(),'999999');
		, Padc(UPPER("Relatórido de Contas - ") + FWFilialName(_cEmp),132);
		, Padc("",132);
		, Padc(UPPER('Período de '+_DataDe+' até '+_DataAte),132);
		, RptHora + " " + time() ;
		+ cChar + "         " + RptEmiss + " " + Dtoc(dDataBase)}

	RestArea( aArea )

Return aCabec
