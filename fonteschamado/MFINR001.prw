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

User Function MFINR001
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
	cPerg     := "MFINR001"
	_cTitulo  := "Consolidação das contas"
	Pergunte( cPerg , .T. , "Informe os parametros" )
	oReport:= TReport():New("fRunBco",_cTitulo,cPerg, {|oReport| ReportPrint(oReport,aOrdem,cAliasTop)},_cTitulo)
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
	TRCell():New(oRelBCO,'Empresa'  		,''    ,      ,PesqPict("SE5", "E5_FILIAL")   ,TamSX3("E5_FILIAL")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelBCO,'Nome Empresa'    	,' '   ,      ,PesqPict("SE5", "E5_BANCO")    ,TamSX3("E5_BANCO")[1]+30 ,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT",          ,"LEFT"      ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelBCO,'Banco'    		,''    ,      ,PesqPict("SE5", "E5_BANCO")    ,TamSX3("E5_BANCO")[1]    ,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT",          ,"LEFT"      ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelBCO,'Agencia'  		,''    ,      ,PesqPict("SED", "E5_AGENCIA")  ,TamSX3("E5_AGENCIA")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT",          ,"LEFT"      ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelBCO,'Conta'    		,''    ,      ,PesqPict("SED", "E5_CONTA")    ,TamSX3("E5_CONTA")[1]   	,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT",          ,"LEFT"      ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelBCO,'Nome Conta'    	,' '   ,      ,PesqPict("SA6", "A6_NOME")     ,TamSX3("A6_NOME")[1]   	,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT",          ,"LEFT"      ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelBCO,'Saldo Inicial' 	,''	   , 	  ,PesqPict("SE5", "E5_VALOR")    ,TamSX3("E5_VALOR")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelBCO,'Receitas' 		,''    ,      ,PesqPict("SE5", "E5_VALOR")    ,TamSX3("E5_VALOR")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelBCO,'Despesas' 		,''    ,      ,PesqPict("SE5", "E5_VALOR")    ,TamSX3("E5_VALOR")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
    TRCell():New(oRelBCO,'Saldo Atual   ' 	,''    ,      ,PesqPict("SE5", "E5_VALOR")    ,TamSX3("E5_VALOR")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	
Return(oReport)

Static Function ReportPrint(oReport,aOrdem,cAliasTop)

	Local nPrc, nMs, nX, nFil
	Local cOrderBy  := ''
	Local oRelBCO	:= oReport:Section(1)
	Local cIndexkey	:= ''
	Local nOrdem   	:= oRelBCO:GetOrder()
	Local cFilUser  := oReport:Section(1):GetAdvplExp()
    Local cQuery    := ""
    Local cBanco    := ""
	Local nIni		:= 0
	Local nSld		:= 0
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

	oReport:cTitle := "Consolidação das contas "

    /*cQuery := "SELECT E5_BANCO Banco, E5_AGENCIA Agencia, E5_CONTA Conta, A6_NOME NomeConta, E5_FILIAL Empresa, SUM(RECEITAS) AS RECEITAS, SUM(DESPESAS) AS DESPESAS, "
	Query += " ( SELECT "
    cQuery += " E8_SALATUA "
    cQuery += " FROM "+RetSqlName('SE8')+" SE8 "
    cQuery += " WHERE E8_BANCO = A.E5_BANCO AND E8_AGENCIA = A.E5_AGENCIA AND E8_CONTA = A.E5_CONTA AND E8_FILIAL = A.E5_FILIAL "
    cQuery += " AND E8_DTSALAT < '"+DtoS(MV_PAR05)+"' "
  	cQuery += " ORDER BY E8_DTSALAT DESC "
  	cQuery += " LIMIT 1 "
	cQuery += " ) AS SALDOINI " "
	cQuery += " FROM ( "
    cQuery += "SELECT E5_BANCO, E5_AGENCIA, E5_CONTA, A6_NOME, E5_FILIAL, CASE WHEN E5_RECPAG = 'R' THEN SUM(E5_VALOR) ELSE 0 END AS RECEITAS, CASE WHEN E5_RECPAG = 'P' THEN SUM(E5_VALOR) ELSE 0 END AS DESPESAS "
    cQuery += "FROM " + RetSqlName("SE5") + " SE5 " 
	cQuery += "INNER JOIN " + RetSqlName("SA6") + " SA6 ON A6_FILIAL = SUBSTRING(E5_FILIAL,1,4) AND A6_COD = E5_BANCO AND A6_AGENCIA = E5_AGENCIA AND A6_NUMCON = E5_CONTA AND SA6.D_E_L_E_T_ <> '*'  AND A6_BLOCKED <> '1' "
    cQuery += "WHERE E5_BANCO <> ' ' AND SE5.D_E_L_E_T_ <> '*' AND E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','ES','BA') AND E5_SITUACA NOT IN ('C','E','X') "
    cQuery += "AND E5_BANCO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQuery += "AND E5_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	cQuery += "AND E5_DATA BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"' "
    cQuery += "GROUP BY E5_BANCO, E5_AGENCIA, E5_CONTA, A6_NOME, E5_FILIAL, E5_RECPAG "
    cQuery += ") AS A "
    cQuery += "GROUP BY A.E5_BANCO, A.E5_AGENCIA, A.E5_CONTA, A.A6_NOME, A.E5_FILIAL "
    cQuery += "ORDER BY E5_BANCO, E5_AGENCIA, E5_CONTA, A6_NOME, E5_FILIAL"*/

	cQuery := " SELECT A6_FILIAL EMPRESA, A6_COD BANCO, A6_AGENCIA AGENCIA, A6_NUMCON CONTA, A6_NOME NOMECONTA, "
	
	cQuery += " ( SELECT SUM(E5_VALOR) FROM "+RetSqlName('SE5')+" E5  "
	cQuery += " WHERE E5_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND E5_BANCO = A6.A6_COD AND E5_CONTA = A6.A6_NUMCON "
	cQuery += " AND E5_SITUACA NOT IN ('C','E','X') AND E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','ES','BA') "
	cQuery += " AND E5_DATA BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"' AND E5_RECPAG = 'R' "
	cQuery += " AND E5.D_E_L_E_T_ <> '*' ) AS RECEITAS, "

	cQuery += " ( SELECT SUM(E5_VALOR) FROM "+RetSqlName('SE5')+" E5  "
	cQuery += " WHERE E5_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND E5_BANCO = A6.A6_COD AND E5_CONTA = A6.A6_NUMCON "
	cQuery += " AND E5_SITUACA NOT IN ('C','E','X') AND E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','ES','BA') "
	cQuery += " AND E5_DATA BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"' AND E5_RECPAG = 'P' "
	cQuery += " AND E5.D_E_L_E_T_ <> '*' ) AS DESPESAS, "

	cQuery += " ( SELECT  E8_SALATUA  FROM "+RetSqlName('SE8')+" SE8   "
	cQuery += " WHERE E8_BANCO = A6.A6_COD  "
	cQuery += " AND E8_AGENCIA = A6.A6_AGENCIA  "
	cQuery += " AND E8_CONTA = A6.A6_NUMCON  "
	cQuery += " AND E8_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'  AND E8_DTSALAT = '"+DtoS(Lastday(MV_PAR06,1))+"'   "
	cQuery += " ORDER BY E8_DTSALAT DESC  LIMIT 1  )  "
	cQuery += " AS SALDOINI,    "

 	cQuery += " ( SELECT  E8_SALATUA  FROM "+RetSqlName('SE8')+" SE8   "
    cQuery += " WHERE E8_BANCO = A6.A6_COD     "
	cQuery += " AND E8_AGENCIA = A6.A6_AGENCIA  "
	cQuery += " AND E8_CONTA = A6.A6_NUMCON  "
	cQuery += " AND E8_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'  AND E8_DTSALAT < '"+(MV_PAR03)+"'   "
	cQuery += " AND E8_SALATUA <> 0 "
	cQuery += " ORDER BY E8_DTSALAT DESC  LIMIT 1  )  "
	cQuery += "AS SALDOATUAL"

	cQuery += " FROM "+RetSqlName('SA6')+" A6 "
	cQuery += " WHERE A6_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND A6_FILIAL BETWEEN SUBSTRING('"+MV_PAR03+"',1,4) AND SUBSTRING('"+MV_PAR04+"',1,4) "
	cQuery += " AND A6_BLOCKED <> '1' AND A6.D_E_L_E_T_ <> '*' "

    MpSysOpenQuery(cQuery, "TE5")

	oReport:SetMeter(100) //-> Indica quantos registros serao processados para a regua ³
	nCt := 1
	Do While !oReport:Cancel() .And. !TE5->(Eof())

		oReport:IncMeter()
		oRelBCO:Init()
		oReport:SetMsgPrint( "Calculando contas ... "+cValToChar(nCt)+" / "+cValToChar(nRegPrc) )

        cBanco  := TE5->BANCO
        nRec    := 0
        nDesp   := 0

        While !oReport:Cancel() .And. !TE5->(Eof()) .And. cBanco == TE5->BANCO


			oRelBCO:Cell('Empresa'):nClrBack := CLR_WHITE
			oRelBCO:Cell('Nome Empresa'):nClrBack := CLR_WHITE
            oRelBCO:Cell('Banco'):nClrBack := CLR_WHITE
			oRelBCO:Cell('Agencia'):nClrBack := CLR_WHITE
			oRelBCO:Cell('Conta'):nClrBack := CLR_WHITE
			oRelBCO:Cell('Nome Conta'):nClrBack := CLR_WHITE
            oRelBCO:Cell('Saldo Inicial'):nClrBack := CLR_WHITE
			oRelBCO:Cell('Receitas'):nClrBack := CLR_WHITE
			oRelBCO:Cell('Despesas'):nClrBack := CLR_WHITE
            oRelBCO:Cell('Saldo Atual'):nClrBack := CLR_WHITE

			oRelBCO:Cell('Empresa'):LBOLD := .F.
			oRelBCO:Cell('Nome Empresa'):LBOLD := .F.
			oRelBCO:Cell('Banco'):LBOLD := .F.
			oRelBCO:Cell('Agencia'):LBOLD := .F.
			oRelBCO:Cell('Conta'):LBOLD := .F.
			oRelBCO:Cell('Nome Conta'):LBOLD := .F.
            oRelBCO:Cell('Saldo Inicial'):LBOLD := .F.
			oRelBCO:Cell('Receitas'):LBOLD := .F.
			oRelBCO:Cell('Despesas'):LBOLD := .F.
            oRelBCO:Cell('Saldo Atual'):LBOLD := .F.

			oRelBCO:Cell('Empresa'):SetValue(TE5->EMPRESA)
			oRelBCO:Cell('Nome Empresa'):SetValue(FWFilialName(cEmpAnt, TE5->EMPRESA))
			oRelBCO:Cell('Banco'):SetValue(TE5->BANCO)
			oRelBCO:Cell('Agencia'):SetValue(TE5->AGENCIA)
			oRelBCO:Cell('Conta'):SetValue(TE5->CONTA)
			oRelBCO:Cell('Nome Conta'):SetValue(TE5->NOMECONTA)
            oRelBCO:Cell('Saldo Inicial'):SetValue(TE5->SALDOINI)
			oRelBCO:Cell('Receitas'):SetValue(TE5->RECEITAS)
			oRelBCO:Cell('Despesas'):SetValue(TE5->DESPESAS)
            oRelBCO:Cell('Saldo Atual'):SetValue('TE5->SALDOINI-TE5->DESPESAS+TE5->RECEITAS')

			nIni := nIni + TE5->SALDOINI
			nSld := nSld + TE5->SALDOINI-TE5->DESPESAS+TE5->RECEITAS
            nRec := nRec + TE5->RECEITAS 
            nDesp := nDesp + TE5->DESPESAS

			nIniAc := nIniAc + TE5->SALDOINI
			nSldAc := nSldAc + TE5->SALDOINI-TE5->DESPESAS+TE5->RECEITAS
            nRecAc := nRecAc + TE5->RECEITAS
            nDespAc := nDespAc + TE5->DESPESAS

            oRelBCO:Printline()
		    oReport:SkipLine() //-- Salta Linha		

            TE5->(DbSkip())
        EndDo

		oRelBCO:Cell('Empresa'):nClrBack := CLR_LIGHTGRAY
		oRelBCO:Cell('Nome Empresa'):nClrBack := CLR_LIGHTGRAY
		oRelBCO:Cell('Banco'):nClrBack := CLR_LIGHTGRAY
		oRelBCO:Cell('Agencia'):nClrBack := CLR_LIGHTGRAY
		oRelBCO:Cell('Conta'):nClrBack := CLR_LIGHTGRAY
		oRelBCO:Cell('Nome Conta'):nClrBack := CLR_LIGHTGRAY
		oRelBCO:Cell('Saldo Inicial'):nClrBack := CLR_LIGHTGRAY
		oRelBCO:Cell('Receitas'):nClrBack := CLR_LIGHTGRAY
		oRelBCO:Cell('Despesas'):nClrBack := CLR_LIGHTGRAY
        oRelBCO:Cell('Saldo Atual'):nClrBack := CLR_LIGHTGRAY

		oRelBCO:Cell('Empresa'):LBOLD := .T.
		oRelBCO:Cell('Nome Empresa'):LBOLD := .T.
		oRelBCO:Cell('Banco'):LBOLD := .T.
		oRelBCO:Cell('Agencia'):LBOLD := .T.
		oRelBCO:Cell('Conta'):LBOLD := .T.
		oRelBCO:Cell('Nome Conta'):LBOLD := .T.
        oRelBCO:Cell('Saldo Inicial'):LBOLD := .T.
		oRelBCO:Cell('Receitas'):LBOLD := .T.
		oRelBCO:Cell('Despesas'):LBOLD := .T.
        oRelBCO:Cell('Saldo Atual'):LBOLD := .T.

		oRelBCO:Cell('Empresa'):SetValue(Space(TamSX3("E5_FILIAL")[1]))
		oRelBCO:Cell('Nome Empresa'):SetValue(Space(TamSX3("E5_BANCO")[1]+30))
		oRelBCO:Cell('Banco'):SetValue(cBanco)
		oRelBCO:Cell('Agencia'):SetValue(Space(TamSX3("E5_AGENCIA")[1]))
		oRelBCO:Cell('Conta'):SetValue(Space(TamSX3("E5_CONTA")[1]))
		oRelBCO:Cell('Nome Conta'):SetValue(Space(TamSX3("A6_NOME")[1]))
        oRelBCO:Cell('Saldo Inicial'):SetValue(nIni)
		oRelBCO:Cell('Receitas'):SetValue(nRec)
		oRelBCO:Cell('Despesas'):SetValue(nDesp)
        oRelBCO:Cell('Saldo Atual'):SetValue('nIni-nDespAc+nRecAc')

		oRelBCO:Printline()
		oReport:SkipLine() //-- Salta Linha		

	EndDo

	TE5->(DbCloseArea())

    //Total acumulado
	oRelBCO:Cell('Empresa'):nClrBack := CLR_LIGHTGRAY
	oRelBCO:Cell('Nome Empresa'):nClrBack := CLR_LIGHTGRAY
    oRelBCO:Cell('Banco'):nClrBack := CLR_LIGHTGRAY
	oRelBCO:Cell('Agencia'):nClrBack := CLR_LIGHTGRAY
	oRelBCO:Cell('Conta'):nClrBack := CLR_LIGHTGRAY
	oRelBCO:Cell('Nome Conta'):nClrBack := CLR_LIGHTGRAY
    oRelBCO:Cell('Saldo Inicial'):nClrBack := CLR_LIGHTGRAY
	oRelBCO:Cell('Receitas'):nClrBack := CLR_LIGHTGRAY
	oRelBCO:Cell('Despesas'):nClrBack := CLR_LIGHTGRAY
    oRelBCO:Cell('Saldo Atual'):nClrBack := CLR_LIGHTGRAY

	oRelBCO:Cell('Empresa'):LBOLD := .T.
	oRelBCO:Cell('Nome Empresa'):LBOLD := .T.
	oRelBCO:Cell('Banco'):LBOLD := .T.
	oRelBCO:Cell('Agencia'):LBOLD := .T.
	oRelBCO:Cell('Conta'):LBOLD := .T.
	oRelBCO:Cell('Nome Conta'):LBOLD := .T.
    oRelBCO:Cell('Saldo Inicial'):LBOLD := .T.
	oRelBCO:Cell('Receitas'):LBOLD := .T.
	oRelBCO:Cell('Despesas'):LBOLD := .T.
    oRelBCO:Cell('Saldo Atual'):LBOLD := .T.

	oRelBCO:Cell('Empresa'):SetValue(Space(TamSX3("E5_FILIAL")[1]))
	oRelBCO:Cell('Nome Empresa'):SetValue(Space(TamSX3("E5_BANCO")[1]+30))
	oRelBCO:Cell('Banco'):SetValue("Geral -> ")
	oRelBCO:Cell('Agencia'):SetValue(Space(TamSX3("E5_AGENCIA")[1]))
	oRelBCO:Cell('Conta'):SetValue(Space(TamSX3("E5_CONTA")[1]))
	oRelBCO:Cell('Nome Conta'):SetValue(Space(TamSX3("A6_NOME")[1]))
    oRelBCO:Cell('Saldo Inicial'):SetValue(nIniAc)
	oRelBCO:Cell('Receitas'):SetValue(nRecAc)
	oRelBCO:Cell('Despesas'):SetValue(nDespAc)
    oRelBCO:Cell('Saldo Atual'):SetValue('((nSldAc+nDespAc)-nRecAc+nDespAc)-nRecAc')
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
