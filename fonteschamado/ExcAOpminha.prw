#INCLUDE "TOTVS.CH"

*******************************************************************************
// Função : GeraOp - Função Automática para gerar uma Ordem de produção       |
// Modulo : ""                                                                |
// Fonte  : ExcAOp.prw                                                       |
// ---------+--------------------------+--------------------------------------+
// Data     | Autor             	   | Descricao                            |
// ---------+--------------------------+--------------------------------------+
// 05/10/23 | Pedro Almeida - Cod.ERP  | Rotina Automática			          |
*******************************************************************************

User Function GeraOp(cProduto,cLocal,nQuant,cTipoProd,cTipoOp)

    //campos obrigatórios C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,C2_LOCAL,C2_QUANT,C2_UM,C2_DATPRI,C2_DATPRF,C2_EMISSAO,C2_TPPR,C2_TPOP
	Local aItens := {}
    Local cNumOp := ""
	Local aInfos := {}

	lMsErroAuto := .F.
	DBSelectArea("SC2")
    DBSetOrder(1)
 
    cCodFor := GetSXENum("SC2","C2_NUM")
	MSGINFO(cCodFor)
	aadd(aItens,{"C2_NUM"    ,   cCodFor                  ,    Nil})
	aadd(aItens,{"C2_FILIAL" ,   cFilAnt 	              ,    Nil})
	aadd(aItens,{"C2_PRODUTO",   cProduto				  ,    Nil})
	aadd(aItens,{"C2_LOCAL"  ,   cLocal				      ,    Nil})
	aadd(aItens,{"C2_QUANT"  ,   nQuant				      ,    Nil}) 
	aadd(aItens,{"C2_DATPRI" ,   dDataBase		          ,    Nil})
	aadd(aItens,{"C2_DATPRF" ,   dDataBase + 1	          ,    Nil})
	aadd(aItens,{"C2_TPPR"   ,   cTipoProd		              ,    Nil})
	aadd(aItens,{"C2_TPOP"   ,   cTipoOp	                  ,    Nil})
 

	MsExecAuto({|x,y| Mata650(x,y)},aItens,3)

	If  lMsErroAuto
		MSGINFO( "Erro na rotina automática", "Atenção" )
		Mostraerro()
        cNumOp := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN //retirar depois
		/* aadd(aInfos,  cProduto) 
		aadd(aInfos,   nQuant)
		aadd(aInfos, cNumOp )
		aadd(aInfos,  cLocal)  */
		SC2->(DBCLOSEAREA())
	else
		MsgInfo("Rotina Automática gerada com sucesso","Aviso")
        cNumOp := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN //retirar depois
		ConfirmSX8()		
        aadd(aInfos,  cProduto)
		aadd(aInfos,   nQuant)
		aadd(aInfos, cNumOp)
		aadd(aInfos,  cLocal)
		
		SC2->(DBCLOSEAREA())
	Endif
SC2->(DBCLOSEAREA())
return aInfos

*******************************************************************************
// Função : GeraMI - Função Automática para movimentar estoque interno para OP|
// Modulo : ""                                                                |
// Fonte  : ExcAOp.prw                                                        |
// ---------+--------------------------+--------------------------------------+
// Data     | Autor             	   | Descricao                            |
// ---------+--------------------------+--------------------------------------+
// 05/10/23 | Pedro Almeida - Cod.ERP  | Rotina Automática			          |
*******************************************************************************

User Function GeraMI(cCodProd,nQuant,cNumOp,cLocal,cLote,cCodigoTM,cCC,cNumSerie,cLocaliz)

	Local aItens := {}
	local aCab := {}
	Local aItem := {}

	lMsErroAuto := .F.
DBSelectArea("SD3")
    DBSetOrder(1)
	aCab 	:= {{"D3_DOC" , GetSXENum("SC3","D3_DOC"), 	NIL},;
				{"D3_TM" ,			cCodigoTM 				, 	NIL},;
				{"D3_EMISSAO" ,		ddatabase		   	    , 	NIL}}

	aItens := { {"D3_COD"	  ,         cCodProd   ,    Nil},;
				{"D3_QUANT"   ,         nQuant     ,    Nil},;
				{"D3_OP"	  ,         cNumOp     ,    Nil},;
				{"D3_CC" ,			   cCC     			    , 	NIL},;
				{"D3_LOCAL"   ,       	cLocal     ,    Nil},;
				{"D3_NUMSERIE"   ,       	cNumSerie     ,    Nil},;
				{"D3_LOCALIZ"   ,       	cLocaliz    ,    Nil},;
				{"D3_LOTECTL" ,         cLote      ,    Nil}}
				
		
		aadd(aItem,aItens) 
		
		MsExecAuto({|x,y,z| Mata241(x,y,z)},aCab,aItem,3)

	If  lMsErroAuto
		MSGINFO( "Erro na rotina automática", "Atenção" )
		Mostraerro()
	else
		MsgInfo("Rotina Automática gerada com sucesso","Aviso")
	Endif
SD3->(DBCLOSEAREA())
return

*******************************************************************************
// Função : ApontaOp - Função Automática para apontar uma ordem de produção   |
// Modulo : ""                                                                |
// Fonte  : ExcAOp.prw                                                        |
// ---------+--------------------------+--------------------------------------+
// Data     | Autor             	   | Descricao                            |
// ---------+--------------------------+--------------------------------------+
// 05/10/23 | José Antônio Machado - Cod.ERP  | Rotina Automática			          |
*******************************************************************************

User Function ApontaOp(cNumOp,cTPMovime, cMaq, cLote, cCC,cNumSerie,cLocaliz)

    //campos obrigatórios D3_OP,D3_TM
	Local aItens := {}

	lMsErroAuto := .F.

	aadd(aItens,{"D3_OP"   ,       	cNumOp  ,    Nil})
	aadd(aItens,{"D3_TM"   ,       	cTPMovime     ,    Nil})
	aadd(aItens,{"D3_PERDA",     	  0 	,    Nil})
	//aadd(aItens,{"D3_XRECURS",     	  cMaq 	,    Nil}) DESCOMENTAR DEPOIS
	aadd(aItens,{"D3_LOTECTL",     	 cLote  	,    Nil})
	/* aadd(aItens,{"D3_NUMSERIE",     	 cNumSerie  	,    Nil})
	aadd(aItens,{"D3_LOCALIZ",     	 cLocaliz  	,    Nil}) */
	aadd(aItens,{"D3_CC",     	 cCC 	,    Nil})

	MsExecAuto({|x,y| Mata250(x,y)},aItens,3)

	If  lMsErroAuto
		MSGINFO( "Erro na rotina automática." , "Atenção"  )
		Mostraerro()
	else
		MsgInfo("Rotina Automática gerada com sucesso numero da op: "+cNumOp,"Aviso")
	Endif
 
return 


User Function  tstch() //rotina de teste p chamar

    Local aArray:= {}
    Local cTPMovime := "501"
	Local cMaq := "01"
	Local cLote := "FAN270723"    //Local cLote := "L223585"
	Local nQuant := 11
	Local cProduto := "11"//Local cProduto := "0201000003"
	Local cLocal := "01"
	Local cTipoProd := "1"
	Local cTipoOp := "F"
	Local cCodigoTM := "501"
	Local cCC := "DDDEDEE"
	//Local cNumSerie := "888"
	Local cLocaliz := 'ESTANTE L'


	//gera a op retornando as informações para os movimentos internos
/* 	aArray := u_GeraOp("0201000002","02",10,"1","F") 
 */	aArray := u_GeraOp(cProduto,cLocal,nQuant,cTipoProd,cTipoOp) 
		
	//u_GeraMI(cProCod,nQuant,cNumOp,cLocal,cLote,"501")
	//gera o movimento interno de requisição para a op, ainda para testar, necessário que o ambiente da petinho esteja como exclusivo(já solicitado)

	u_GeraMI(aArray[1],aArray[2],aArray[3],aArray[4],cLote,cCodigoTM,cCC,cNumSerie,cLocaliz)
	//Criar apontamento para a op
	u_ApontaOp(aArray[3],cTPMovime,cMaq,cLote,cCC,cNumSerie,cLocaliz)
	
return

//op->mov interna->apontamento de produção
