//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'


#DEFINE  CABECALHO  "ZLP_FILIAL/ZLP_CODLP/ZLP_CODORC/ZLP_CODTB/ZLP_CODVEN/ZLP_NOMEVE/ZLP_CONTCL/ZLP_VALOR/ZLP_LINKPG/ZLP_DATAHR"
#DEFINE  ITENS      "ZLK_FILIAL/ZLK_CODLP/ZLK_CODORC/ZLK_CODPRD/ZLK_DESC/ZLK_QUANT/ZLK_UNIT/ZLK_TOTAL"
Static 	 cTitle :=  "Tela MVC"

*-------------------------------------------------------------------------------------
************************************************************************************ X
/*@nomeFunction: 	  					U_TelPag()						   		  */ *
/*--------------------------------------------------------------------------------*/ *
/*							  FunÁ„o de Montagem da Tela MVC	 				  */ *
/*					 	  Gravando os Dados nas Tabelas ZLP e ZLK				  */ *
/*					  Tela de Vinculo dos Produtos para TransformaÁ„o			  */ *
/*--------------------------------------------------------------------------------*/ *
/*@author: 						Jose.Machado - CodERP							  */ *
/*@since: 				    	  	   21/09/2022								  */ *
************************************************************************************ X
*-------------------------------------------------------------------------------------
User Function TelPag()
	Local oBrowse := NIL

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZLP')                               // Alias da tabela utilizada
	oBrowse:SetDescription(cTitle)
	oBrowse:DisableDetails()

	oBrowse:AddLegend( "ZLP->ZLP_STATUS == '1' ", "BLUE",    "Link Criado" )
    oBrowse:AddLegend( "ZLP->ZLP_STATUS == '2' ", "RED",    "Link Expirado" )
    oBrowse:AddLegend( "ZLP->ZLP_STATUS == '3' ", "GREEN",    "Link Pago" )
    oBrowse:Activate()

Return

User Function MVCLeg()
	Local aLegenda := {}

	//Monta as cores
	AADD(aLegenda,{"BR_VERDE",     "Link Pago"		 })
	AADD(aLegenda,{"BR_AZUL",	   "Link Criado"	 })
	AADD(aLegenda,{"BR_VERMELHO",  "Link Expirado"	 })
	BrwLegenda("Grupo de Produtos", "Procedencia", aLegenda)
Return

	*-------------------------------------------------------------------------------------
	*************************************************************************************X
/*////////////////////////////////////////////////////////////////////////////////*/ *
/*@nomeFunction: 	  					MenuDef()							   	  */ *
/*--------------------------------------------------------------------------------*/ *
/*									Menu do Browser					  			  */ *
/*--------------------------------------------------------------------------------*/ *
/*@author: 						Rivaldo.J˙nior - CodERP							  */ *
/*@since: 				    	  	   20/09/2022								  */ *
/*////////////////////////////////////////////////////////////////////////////////*/ *
	*************************************************************************************X
	*-------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.TelPag' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.TelPag' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.TelPag' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.TelPag' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Legenda'    ACTION 'U_MVCLeg' OPERATION 6 ACCESS 0 

	//ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.TelPag' OPERATION 8 ACCESS 0
	//ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.TelPag' OPERATION 9 ACCESS 0

Return aRotina



	*-------------------------------------------------------------------------------------
	*************************************************************************************X
/*////////////////////////////////////////////////////////////////////////////////*/ *
/*@nomeFunction: 	  					ModelDef()							   	  */ *
/*--------------------------------------------------------------------------------*/ *
/*							   Modelo do cabecalho e grid		  				  */ *
/*--------------------------------------------------------------------------------*/ *
/*@author: 						Rivaldo.J˙nior - CodERP							  */ *
/*@since: 				    	  	   20/09/2022								  */ *
/*////////////////////////////////////////////////////////////////////////////////*/ *
	*************************************************************************************X
	*-------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel   := Nil
	Local oStPai   := FWFormStruct( 1, 'ZLP', { |cCampo|  AllTrim( cCampo ) + '/' $ CABECALHO } )
	Local oStFilho := FWFormStruct( 1, 'ZLK', { |cCampo|  AllTrim( cCampo ) + '/' $ ITENS }  )
	//Local bCamValid:= {|oCab, cAction, cIDField, xValue|  ValidEx(oCab, cAction, cIDField, xValue)}
	Local aRelacFNL:= {}
	oStFilho:AddTrigger("ZR3_QTORI","ZR3_QTDES",,{|oModel| Conv(oModel)})
	oModel := MPFormModel():New("MTelPag", /*{|oModel| MDMVlPre( oModel ) }bPre*/, /*{|oModel| MDMVlPos( oModel ) }/*bPos*/,/*{||ComplZZ3( Self ) }bCommit*/,/*bCancel*/)

	oModel:SetDescription(OemtoAnsi("Produtos") )

	oModel:AddFields('ZLPMASTER',/*cOwner*/,oStPai/* , bCamValid *//*bPreValidacao*/, /*bPosValidacao*/, /*{ || AN001(oModel)}*/)

	oModel:AddGrid('ZLKDETAIL','ZLPMASTER',oStFilho, /*{|oModel,nLine,cAction| linePreGrid(oModel,nLine, cAction)}*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/)//, {|oModel|AN002( oModel ) } )

	oModel:SetPrimaryKey( { "ZLP_FILIAL" , "ZLK_CODLP" })

	//Relacionamento da tabela Etapa com Projeto
	aAdd(aRelacFNL,{ 'ZLK_CODLP'	, 'ZLP_CODLP' 	})
	oModel:SetRelation('ZLKDETAIL', aRelacFNL, ZLK->( IndexKey( 1 ) ))

	//Setando as descriùùes
	oModel:SetDescription("Produtos")

Return oModel



	*-------------------------------------------------------------------------------------
	*************************************************************************************X
/*////////////////////////////////////////////////////////////////////////////////*/ *
/*@nomeFunction: 	  					ViewDef()							   	  */ *
/*--------------------------------------------------------------------------------*/ *
/*							  ExibiÁao do cabecalho e grid		  				  */ *
/*--------------------------------------------------------------------------------*/ *
/*@author: 						Rivaldo.J˙nior - CodERP							  */ *
/*@since: 				    	  	   20/09/2022								  */ *
/*////////////////////////////////////////////////////////////////////////////////*/ *
	*************************************************************************************X
	*-------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oView     := Nil
	Local oModel    := FWLoadModel('TelPag')
	Local oStPai 	:= FWFormStruct( 2, 'ZLP' ,{ |cCampo|  AllTrim( cCampo ) + '/' $ CABECALHO } )
	Local oStFilho 	:= FWFormStruct( 2, 'ZLK' ,{ |cCampo|  AllTrim( cCampo ) + '/' $ ITENS } )

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Adicionando os campos do cabeùalho e o grid dos filhos
	oView:AddField('VIEW_CAB',oStPai,'ZLPMASTER')
	oView:AddGrid('VIEW_DET',oStFilho,'ZLKDETAIL')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',40)
	oView:CreateHorizontalBox('GRID',60)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:SetOwnerView('VIEW_DET','GRID')

Return oView
