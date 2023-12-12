#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'TbIconn.CH'

#Define cAppKey "38de51d750ac6595597300fea893b646"
#Define cChavePIX "hmtestes2@bb.com.br"
#Define cClientID "eyJpZCI6IjQyOTljMjctMTkxIiwiY29kaWdvUHVibGljYWRvciI6MCwiY29kaWdvU29mdHdhcmUiOjcwNzUwLCJzZXF1ZW5jaWFsSW5zdGFsYWNhbyI6MX0"
#Define cClientSecret "eyJpZCI6ImM5MWVjZGUtZjQyIiwiY29kaWdvUHVibGljYWRvciI6MCwiY29kaWdvU29mdHdhcmUiOjcwNzUwLCJzZXF1ZW5jaWFsSW5zdGFsYWNhbyI6MSwic2VxdWVuY2lhbENyZWRlbmNpYWwiOjEsImFtYmllbnRlIjoiaG9tb2xvZ2FjYW8iLCJpYXQiOjE2OTE2Nzc3MzI2NjJ9"

User Function BBpix(nAcao, cUUID, cValor, cTxID)
	Local aRet     := {}
	DEFAULT nAcao  := 1
	DEFAULT cUUID  := cAppKey
	DEFAULT cValor := "0.01"
	//DEFAULT cNome  := "Francisco da Silva"
	//DEFAULT cCpf   := "12345678909"
	DEFAULT cChave := cChavePIX
	DEFAULT cSolic := "Cobranca dos servicos prestados."
	DEFAULT cTxID  := ""

	If nAcao == 1
		aRet := GeraPIX(1, cUUID, cValor, cChave, cSolic, cTxID)
	ElseIf nAcao == 2
		aRet := GetPIX(cUUID, cTxID)
	Endif
Return aRet
/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | RetAuth  | Autor |    Walter Rodrigo                             |*
*+------------+------------------------------------------------------------------+*
*|Data        | 24.09.2021                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao de autenticação para o Bradesco                           |*
**********************************************************************************/

Static Function RetAuth()
	Local cURL       := "https://oauth.hm.bb.com.br"
	Local cBase64    := Encode64(cClientID+":"+cClientSecret)
	Local cAuth      := "Authorization: Basic "+cBase64
	Local cContent   := "Content-Type: application/x-www-form-urlencoded"
	Local aHeader   := {}
	Local oRest     := FWRest():New(cURL)
	Local cJson     := "grant_type=client_credentials"
    Local oJson     := JSonObject():New()
    Private cTkType := ""

   	Aadd(aHeader, cAuth)
	Aadd(aHeader, cContent)

	oRest:setPath("/oauth/token")
	oRest:SetPostParams(cJson)
	oRest:Post(aHeader)
	cErro := oJSon:fromJson(oRest:GetResult())

	If !empty(cErro)
  	MsgStop(cErro,"JSON PARSE ERROR")
 	 Return ""
	Endif

	cAcessTk  := oJson:GetJSonObject('access_token')
	cTkType   := oJson:GetJSonObject('token_type')
	cExpireIn := oJson:GetJSonObject('expires_in')

	// Valida o retorno
	If Type("cAcessTk")=="U" .or. Empty(cAcessTk)
	Return ""
	Endif
Return "Authorization: "+cTkType+" "+cAcessTk


Static Function GeraPIX(nVal, cUUID, cValor, cChave, cSolic, cTxID)

Local cAuth     := RetAuth()
Local cContent  := "Content-Type: application/json "
Local aHeader   := {}
Local oRest     := FWRest():New("https://api.hm.bb.com.br")
Local oJson     := JSonObject():New()
Local cJson     := ""
Local aRet      := {}

// Valida a autorização
If Empty(cAuth)
	Return ""
Endif

cJson +=  '{ '
cJson +=  '"chave": "'+cChave+'",'
cJson +=  '"solicitacaoPagador" : "'+cSolic+'", '
cJson +=  '"valor":'
cJson +=  '{ '
cJson +=  '"original":'+cValor
cJson +=  '},'
cJson +=  ' "calendario": {'
cJson +=  '"expiracao": 36000'
cJson +=  ' }'
cJson +=  '}'
/*
cJson +='"devedor": {'
If Len(cCpf) > 11
	cJson +='"cnpj": "'+cCpf+'",'
Else
	cJson +='"cpf": "'+cCpf+'",'
EndIf
cJson +='"nome": "'+cNome+'"'
cJson +='}'*/

Aadd(aHeader, cAuth)
Aadd(aHeader, cContent)

oRest:setPath("/pix/v2/cob"+cTxID+"?gw-dev-app-key="+cUUID)
oRest:SetPostParams(cJson)
oRest:POST(aHeader)
oJSon:fromJson(oRest:GetResult())

If oRest:GetHTTPCode() == "201"
	cImgQrCode := oJson:GetJSonObject('pixCopiaECola')
	cRetTxID   := oJson:GetJSonObject('txid')
	aRet := {cImgQrCode, cRetTxID}
Endif

Return aRet

Static Function GetPIX(cUUID, cTxID)

Local cAuth     := RetAuth()
Local cContent  := "Content-Type: application/json "
Local aHeader   := {}
Local oRest     := FWRest():New("https://api.hm.bb.com.br")
Local oJson     := JSonObject():New()
Local cJson     := ""
Local cStatus   := ""
Local aRet      := {""}

// Valida a autorização
If Empty(cAuth)
	Return ""
Endif

Aadd(aHeader, cAuth)
Aadd(aHeader, cContent)

oRest:setPath("/pix/v2/cob"+cTxID+"?gw-dev-app-key="+cUUID)
oRest:SetPostParams(cJson)
oRest:GET(aHeader)
oJSon:fromJson(oRest:GetResult())

If oRest:GetHTTPCode() $ "200/201"
	cStatus := oJson:GetJSonObject('status')
	aRet    := {cStatus}
Endif

Return aRet

/**********************************************************************************
+-------------------------------------------------------------------------------+
|Funcao      | GerRAPIX | Autor |    Walter Rodrigo                             |
+------------+------------------------------------------------------------------+
|Data        | 01.01.2021                                                       |
+------------+------------------------------------------------------------------+
|Descricao   | Geração do RA com retorno do PIX                                 |
********************************************************************************/

User Function GerRAPIX(cEmp, cFil, cCliente, cLoja, nValor, cVend, cHist)

	local cQUERY := GetNextAlias()
	Local cBanco   := ""
	Local cConta   := ""
	Local cAgencia := ""
	Local aTitRA := {}
	Local cNum   := ""
	Local nX 	 := 0
	Local aiErro := {}
	Local ciErro := ""
	//Local cCCusto := SUPERGETMV('MV_XCUST', .F., 'D06002')
	//Local cICTA   := SUPERGETMV('MV_XITCCLJ', .F., '')
	Local cNatureza := ""
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.
	
	PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil MODULO "FIN"
	cNatureza := SUPERGETMV('MV_XNATPIX', .F., 'PIX')

	BeginSql alias cQUERY
	SELECT A6_XPIXRA,A6_AGENCIA,A6_NUMCON,A6_COD
	FROM %Table:SA6% SA6
	WHERE 	SA6.%NotDel% AND
			SA6.A6_XPIXRA = "S" AND
			A6_FILIAL = %xFilial:SA6%
	EndSql

	cBanco := (cQUERY)->A6_COD
	cAgencia := (cQUERY)->A6_AGENCIA
	cConta := ALLTRIM((cQUERY)->A6_NUMCON)

	if Empty(cBanco) .or. Empty(cAgencia) .or. Empty(cConta)
	return {.f.}
	
	endif

	cNum := GetSXENum('SE1', 'E1_NUM')
	lMsErroAuto := .F.

	aTitRA := { { "E1_PREFIXO"  , "PIX"     						    , NIL },;
		{ "E1_NUM"      , cNum              		    			, NIL },;
		{ "E1_TIPO"     , "RA"              		    			, NIL },;
		{ "E1_NATUREZ"  , cNatureza            		    			  , NIL },;
		{ "E1_CLIENTE"  , cCliente  		              , NIL },;
		{ "E1_LOJA"     , cLoja                			, NIL },;
		{ "E1_EMISSAO"  , dDatabase								        , NIL },;
		{ "E1_VENCTO"   , dDatabase								        , NIL },;
		{ "E1_VENCREA"  , dDatabase									        , NIL },;
		{ "E1_VALOR"    , nValor   		  					        , NIL },;
		{ "E1_VEND1"    , cVend                      , NIL },;
		{ "E1_HIST"  	, cHist                         , NIL },;
		{ "CBCOAUTO"    , PADR(cBanco,3) 							    , NIL },;
		{ "CAGEAUTO"    , PADR(cAgencia,5) 							  , NIL },;
		{ "CCTAAUTO"    , PADR(cConta,10) 							  , NIL } }

		/*
		Antes esses dois campos também eram incluidos no aTitRA
		{ "E1_CCUSTO"   , cCCusto                        , NIL },;
		{ "E1_ITEMCTA"  , cICTA                         , NIL },;*/

	MsExecAuto( { |x,y| FINA040(x,y)} , aTitRA, 3)  // 3 - Inclusao, 4 - Alterao, 5 - Excluso

	If lMsErroAuto
		aiErro := GetAutoGRLog()
		For nX := 1 To Len(aiErro)
			ciErro += aiErro[nX] + Chr(13)+Chr(10)
		Next nX
		aiRet		:=	{.F.,"Erro na rotina automatica",ciErro}
	Else
		aiRet		:=	{.T.,"" + cNum,""}
		
	Endif

	RESET ENVIRONMENT

Return aiRet
