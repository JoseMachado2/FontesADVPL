#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'TbIconn.CH'

User Function GeraPIX(nVal, cUUID, cValor, cChave, cSolic, cTxID)

Local cAuth     := RetAuth()
Local cContent  := "Content-Type: application/json "
Local aHeader   := {}
Local oRest     := FWRest():New("https://mydns.mybeehome.com")
Local oJson     := JSonObject():New()
Local cJson     := ""
Local aRet      := {}

// Valida a autorização
If Empty(cAuth)
//msg de token vazio
	Return ""
Endif

While SRA->(!EoF())
cJson :=  '{ '
cJson +=  '"filial":"'+SRA->RA_FILIAL+'",'
cJson +=  '"nome":"'+SRA->RA_NOME+'", '
cJson +=  '"matricula":"  '+SRA->RA_MAT+'   "   , '
cJson +=  '"sexo":'+SRA->RA_SEXO+'", '
cJson +=  '"estadocivil":'+SRA->RA_ESTCIVI+'", '
cJson +=  '"natural":'+SRA->RA_NATURAL+'", '
cJson +=  '"nacionalidade":'+SRA->RA_NACIONA+'", '
cJson +=  '"datanascimento":'+SRA->RA_NASC+'", '
cJson +=  '"centrodecusto":'+SRA->RA_CC+'", '
cJson +=  '"dataadmissao":'+SRA->RA_ADMISSA+'", '
cJson +=  '"codigodeprocesso":'+SRA->RA_PROCES+'", '
cJson +=  '"dataopcfgts":'+SRA->RA_OPCAO+'", '
cJson +=  '"horassem":'+SRA->RA_HRSMES+'", '
cJson +=  '"horasmens":'+SRA->RA_HRSMES+'", '
cJson +=  '"codfunc":'+SRA->RA_CODFUNC+'", '
cJson +=  '"categoriafunc":'+SRA->RA_CATFUNC+'", '
cJson +=  '"tipopagamento":'+SRA->RA_TIPOPGT+'", '
cJson +=  '"tipoadmissao":'+SRA->RA_TIPOADM+'", '
cJson +=  '"vinculoempregaticio":'+SRA->RA_VIEMRAI+'", '
cJson +=  '"codinstrais":'+SRA->RA_GRINRAI+'", '
cJson +=  '"contratoatempoparcial":'+SRA->RA_HOPARC+'", '
cJson +=  '"compenssab":'+SRA->RA_COMPSAB+'", '
cJson +=  '"tnotrab":'+SRA->RA_TNOTRAB+'", '
cJson +=  '}'

SRA->(DbSkip())
End
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

STATIC function token

Local oRest     := FWRest():New("https://mydns.mybeehome.com/userdata/login")
cAuth := oParseJSON:token 

RETURN
