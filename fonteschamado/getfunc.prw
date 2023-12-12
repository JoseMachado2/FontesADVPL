#include "TOTVS.ch"
#include "RESTFUL.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FATF180
 WebService para disponibilização do cadastro de produto
@author  RDS Tecnologia
@since   03/02/2022
@version 1.0  
/*/
//-------------------------------------------------------------------

WsRestful Funcionario Description "WebService de Regiao"
	WSDATA Chave AS STRING OPTIONAL
	WsMethod GET Description "Disponibilização dos Regiao" WsSyntax "/GET"

End WsRestful

WSMETHOD GET WSRECEIVE Chave WSSERVICE Regiao


Local nPosChave := aScan(Self:AQueryString, {|x| AllTrim(Upper(x[1])) == "Chave"})
Local cChave
Local oBody
Local cJson
If nPosChave > 0
	cChave := Self:AQueryString[nPosChave][2]
EndIf
oBody       := u_GetRegiao(cChave)
cJson           := oBody:toJson()

::SetContentType( 'application/json' )
::SetResponse(cJson)

    /*
	SetRestFault(400,"Ops")
    Return .F.
    */
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRegiao
 WebService para disponibilização do cadastro de produto
@author  RDS Tecnologia
@since   03/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------

User Function GetRegiao(cChave)
	Local cQuery      := ""
	Local cCampos     := ""
	Local lAtivAmb    := .F.
	Local a           := 0
	Local oBody       := JsonObject():new()
	Local oLine       := Nil//JsonObject():new()
	Private xConteudo := ""
	Private aCampos   := {}
	Private aNomes   := {}
	Default cChave := ''

// Prepara o ambiente caso precise
	If Select("SX2") == 0
		RPCClearEnv()
		RpcSetType( 3 )
		RpcSetEnv( "01",'020101', , , "",,, , , ,  )
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif

	AADD(aCampos,"X5_CHAVE")//codigo_Regiao
	AADD(aCampos,"X5_DESCRI")//codigo_Regiao

	AADD(aNomes,"codigo_Regiao")
	AADD(aNomes,"Descricao_Regiao")


	For a := 1 To Len(aCampos)
		cCampos := cCampos + aCampos[a] + ", "
	Next

	cCampos := SubStr(cCampos, 1, Len(cCampos) - 2) + Space(1)

	cQuery += "SELECT "
	cQuery += cCampos
	cQuery += "FROM " + RetSqlName("SX5") + " SX5 "
	cQuery += "WHERE SX5.D_E_L_E_T_ <> '*' "
	cQuery += "AND X5_TABELA = 'A2' "
	If !Empty(cChave)
		cQuery += "AND X5_CHAVE = '"+cChave+"'
	EndIf

	cQuery := ChangeQuery(cQuery)

	MpSysOpenQuery(cQuery, "TMP")

	If TMP->(!EOF())
		TMP->(DBGOTOP())
		oBody["Regiao"] := {}
		While TMP->(!EOF())
			oLine       := JsonObject():new()
			For a := 1 To Len(aCampos)
				xConteudo := &("TMP->"+aCampos[a])
				&('oLine["'+aNomes[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + EncodeUtf8(Alltrim(xConteudo)) + '"') )
			Next
			AADD(oBody["Regiao"],oLine)
			TMP->(DbSkip())
		EndDo
	Else
		SetRestFault(404,'Regiao: "'+cChave+'",Status: Nao encontrado ',.T.)
	EndIf
// Se montou o ambiente, desmonta
	If lAtivAmb
		RPCClearEnv()
	Endif

Return oBody

