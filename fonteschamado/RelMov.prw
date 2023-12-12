#INCLUDE "Totvs.ch"
/*/{Protheus.doc} RelMov
RelatÃƒÂ³rio RelMov
@type function
@version 12.1.33
@author Michel Rocha CodERP
@since 13/10/2022 
@return variant, Nill
/*/                                                                                                                                                                                                
User Function RelMov()  
	PRIVATE cTitulo     := 'Relatorio de Consumo/Requisicao' 
	PRIVATE cDescri     := "Estoque"
	PRIVATE cFunName    := FunName()
	PRIVATE oRelatorio
	PRIVATE aPergs      := {}

	aAdd(aPergs, {1, "Filial"      ,space(TamSX3("D3_FILIAL")[1]),PesqPict("SD3","D3_FILIAL"),,,,40, .F.}) //MV_PAR01
	aAdd(aPergs, {1, "Ate Filial"  ,space(TamSX3("D3_FILIAL")[1]),PesqPict("SD3","D3_FILIAL"),,,,40, .T.}) //MV_PAR02
	aAdd(aPergs, {1, "Codigo de"   ,space(TamSX3("D3_COD")[1]) , "",    , ,    , 80, .F.}) //MV_Par01
	aAdd(aPergs, {1, "Codigo  ate" ,space(TamSX3("D3_COD")[1]) , "",   , ,    , 80, .T.}) //MV_Par02
	aAdd(aPergs, {1, "Data"        ,Date()   , "", ".T.", "", ".T.", 80 , .F.}) //MV_PAR05
	aAdd(aPergs, {1, "Ate Data"    ,Date()   , "", ".T.", "", ".T.", 80 , .T.}) //MV_PAR06
	aAdd(aPergs, {1, "Armazem"     ,space(TamSX3("D3_LOCAL")[1]),PesqPict("SD3","D3_LOCAL"),,,,TamSX3("D3_LOCAL")[1], .F.}) //MV_PAR07
	aAdd(aPergs, {1, "Ate Armazem" ,space(TamSX3("D3_LOCAL")[1]),PesqPict("SD3","D3_LOCAL"),,,,TamSX3("D3_LOCAL")[1], .T.}) //MV_PAR08
	aAdd(aPergs, {2, "Selecione o tipo de relatorio ","analitico" , {"analitico" , "sintetico"}  , 60 ,".T.",.F.})//MV_PAR09
	aAdd(aPergs, {2, "Selecione o tipo de relatorio ","MP" , {"MP" , "EM"}  , 60 ,".T.",.F.})//MV_PAR10

	If !parambox(aPergs,"Informe os parametros")
		Return
	EndIf

	oRelatorio  := TReport():New(cFunName, cTitulo,, {|oRelatorio| PrintReport(oRelatorio)}, cDescri)
	oRelatorio:SetCustomText({||CriaCab(oRelatorio)})

	oSection1   := TRSection():New(oRelatorio, 'Consumo/Requisicao'+" da data "+Dtoc(MV_PAR05)+" Até "+Dtoc(MV_PAR06), {'SD3'})
	If MV_PAR09 == "sintetico"
		TRCell():New(oSection1, "D3_COD"    , "SD3" ,"Codigo"           ,PesqPict( "SD3", "D3_COD"  )     ,TamSX3("D3_COD")[1],/*lPixel*/,{|| QERY->D3_COD   },"LEFT",,"LEFT",,,,,,,)
		TRCell():New(oSection1, "B1_DESC"   , "SB1" ,"Desc."   ,PesqPict( "SB1", "B1_DESC"  )    ,TamSX3("B1_DESC")[1],/*lPixel*/,{|| QERY->B1_DESC   },"LEFT",,"LEFT",,,,,,,)
		TRCell():New(oSection1, "D3_UM"     , "SD3" ,"Und"          ,PesqPict( "SD3", "D3_UM" )       ,TamSX3("D3_UM")[1],/*lPixel*/,{|| QERY->D3_UM  },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D3_LOCAL"  , "SD3" ,"Arm"          ,PesqPict( "SD3", "D3_LOCAL" )    ,TamSX3("D3_LOCAL")[1],/*lPixel*/,{|| QERY->D3_LOCAL  },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D3_CONTA"  , "SD3" ,"Conta contabil"          ,PesqPict( "SD3", "D3_CONTA" )    ,TamSX3("D3_CONTA")[1],/*lPixel*/,{|| QERY->D3_CONTA  },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D3_Quant"  , "SD3" ,"Quant."       ,PesqPict( "SD3", "D3_QUANT" )    ,TamSX3("D3_QUANT")[1],/*lPixel*/,{|| QERY->QUANT  },"RIGHT",,"RIGHT",,,,,,,)
		TRCell():New(oSection1, "D3_CUSTO1" , "SD3" ,"Custo"      ,PesqPict( "SD3", "D3_CUSTO1"   ) ,TamSX3("D3_CUSTO1")[1],/*lPixel*/,{|| QERY->CUSTO    },"RIGHT",,"RIGHT",,,,,,,)
	Else
		TRCell():New(oSection1, "D3_COD"    , "SD3" ,"Codigo"           ,PesqPict( "SD3", "D3_COD"  )     ,TamSX3("D3_COD")[1],/*lPixel*/,{|| QERY->D3_COD   },"LEFT",,"LEFT",,,,,,,)
		TRCell():New(oSection1, "B1_DESC"   , "SB1" ,"Desc."   ,PesqPict( "SB1", "B1_DESC"  )    ,TamSX3("B1_DESC")[1],/*lPixel*/,{|| QERY->B1_DESC   },"LEFT",,"LEFT",,,,,,,)
		TRCell():New(oSection1, "D3_UM"     , "SD3" ,"Und"          ,PesqPict( "SD3", "D3_UM" )       ,TamSX3("D3_UM")[1],/*lPixel*/,{|| QERY->D3_UM  },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D3_LOCAL"  , "SD3" ,"Arm"          ,PesqPict( "SD3", "D3_LOCAL" )    ,TamSX3("D3_LOCAL")[1],/*lPixel*/,{|| QERY->D3_LOCAL },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D3_CONTA"  , "SD3" ,"Conta contabil"          ,PesqPict( "SD3", "D3_CONTA" )    ,TamSX3("D3_CONTA")[1],/*lPixel*/,{|| QERY->D3_CONTA  },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D3_TM"     , "SD3" ,"Mov."     ,PesqPict( "SD3", "D3_TM")        ,TamSX3("D3_TM")[1],/*lPixel*/,{|| QERY->D3_TM },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D3_CF"     , "SD3" ,"Tipo de Req."          ,PesqPict( "SD3", "D3_CF")        ,TamSX3("D3_CF")[1],/*lPixel*/,{|| QERY->D3_CF },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D3_DOC"    , "SD3" ,"Doc"     ,PesqPict( "SD3", "D3_DOC")        ,TamSX3("D3_DOC")[1],/*lPixel*/,{|| QERY->D3_DOC },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D3_EMISSAO", "SD3" ,"Data"     ,PesqPict( "SD3", "D3_EMISSAO")   ,12,/*lPixel*/,{|| StoD(QERY->EMISSAO) },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D3_Quant"  , "SD3" ,"Quant."       ,PesqPict( "SD3", "D3_QUANT" )    ,TamSX3("D3_QUANT")[1],/*lPixel*/,{|| QERY->QUANT  },"RIGHT",,"RIGHT",,,,,,,)
		TRCell():New(oSection1, "D3_CUSTO1" , "SD3" ,"Custo"      ,PesqPict( "SD3", "D3_CUSTO1"   ) ,TamSX3("D3_CUSTO1")[1],/*lPixel*/,{|| QERY->CUSTO    },"RIGHT",,"RIGHT",,,,,,,)
		TRCell():New(oSection1, "D3_OP" , "SD3" ,"O.P"      ,PesqPict( "SD3", "D3_OP"   ) ,TamSX3("D3_OP")[1],/*lPixel*/,{|| QERY->numop    },"RIGHT",,"RIGHT",,,,,,,)
	EndIf
	oRelatorio:PrintDialog()

Return

Static Function PrintReport(oRelatorio)
	Local oSection1 := oRelatorio:section(1)
	oSection1:BeginQuery()
	If MV_PAR09 == "sintetico"
		BEGINSQL ALIAS 'QERY'
    		Select B1_DESC, sum(D3_QUANT) quant ,D3_COD, Sum(D3_CUSTO1) Custo, D3_CONTA ,D3_LOCAL , D3_UM   from %Table:SD3% D3
    		Inner Join %Table:SB1% ON B1_COD = D3_COD
    		Where D3_TM BETWEEN '500' and '999'
			AND B1_TIPO = %Exp:MV_PAR10%
    		AND D3_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
    		AND D3_COD BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
    		AND D3_EMISSAO BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
    		AND D3_LOCAL BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
    		Group by B1_DESC ,D3_COD , D3_UM , D3_LOCAL , D3_CONTA
		ENDSQL
	Else
		BEGINSQL ALIAS 'QERY'
    		Select B1_DESC, D3_QUANT as quant ,D3_COD, D3_CUSTO1 as Custo ,D3_LOCAL, D3_CONTA ,D3_TM, D3_UM, D3_CF, D3_EMISSAO as emissao,D3_DOC, D3_OP as numop from %Table:SD3% D3
    		Inner Join %Table:SB1% ON B1_COD = D3_COD
    		Where D3_TM BETWEEN '500' and '999'
			AND B1_TIPO = %Exp:MV_PAR10%
    		AND D3_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
    		AND D3_COD BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
    		AND D3_EMISSAO BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
    		AND D3_LOCAL BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
		ENDSQL
	EndIf
	oSection1:EndQuery()
	oSection1:Print()

Return

Static Function CriaCab( oRelatorio )
	Local aArea		:= GetArea()
	Local aCabec	:= {}
	Local cChar		:= chr(160)
	local _cEmp 	:= FWCodEmp()

	_DataDe := DToC(MV_PAR05)
	_DataAte:= DToC(MV_PAR06)

	aCabec := {TRANSFORM(oRelatorio:Page(),'999999');
		, Padc(UPPER("Relatorio de Consumo/Requisicao - ") + FWFilialName(_cEmp),132);
		, Padc("",132);
		, Padc(UPPER('Período de '+_DataDe+' até '+_DataAte),132);
		, "Hora: " + time() ;
		+ cChar + "          Emissão: " + Dtoc(dDataBase)}

	RestArea( aArea )

Return aCabec
