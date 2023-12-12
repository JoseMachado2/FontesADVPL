
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
 

User Function GeraPublicKey()
//preciso dar um post nisso: https://cieloecommerce.cielo.com.br/api/public/v2/token
	Local oJson     := JSonObject():New()
	Local cResultado := ""
	Local cErro := ""

	Private cURL := "https://sandbox.api.pagseguro.com" //alterar depois pra usar como parametro
	Private oRest := FWRest():New(cURL)
	Private cTkType := ""
	Private cAcessTk := ""
	Private cClient_Type := ""
	Private cClient_Secret := ""
	Private cClient_Id := ""
	Private aHeader1 := {}
    Private cTokenSandBox := "B799A31A4D8447C8BAFFDACC33714AD3"

    cJson1 := '{ '
    cJson1 += ' "type": "card" '
    cJson1 += '}'

    AADD(aHeader1, "Authorization: Bearer "+cTokenSandBox)
    AADD(aHeader1, "accept: application/json")
    AADD(aHeader1, "content-type: application/json")
	


	oRest:setPath("/public-keys")
	oRest:SetPostParams(cJson1)
    oRest:Post(aHeader1)
    
	

	cResultado := oRest:GetResult()
	cErro := oJSon:FromJson(cResultado)

	iF  oRest:GetHTTPCode() == "200"
		alert(cResultado)
		cPublicKey := oJson["public_key"]
		

		u_CriaAplicacao()
	else
		alert(cErro)
	endif

Return

User Function CriaAplicacao()
	Local oJson     := JSonObject():New()
	Local cResultado := ""
	Local cErro := ""
	Local aHeader := {}
	Private oRest := FWRest():New(cURL)
	oRest:setPath("/oauth2/application")
    AADD(aHeader , "Authorization: Bearer "+cTokenSandBox)
    AADD(aHeader, "accept:  application/json")
    AADD(aHeader, "content-type: application/json")
	


 	cJson := '{'
  	cJson += '"name": "LP Pharmapele",'
  	cJson += '"description": "teste description",'
  	cJson += '"site": "https://www.pharmapele.com.br/"'
    cJson += '}'

 oRest:SetPostParams(cJson)
	oRest:Post(aHeader)
	cResultado := oRest:GetResult()
	cErro := oJSon:FromJson(cResultado)

	iF  oRest:GetHTTPCode() == "201"
		alert(cResultado)
		cClient_Type := oJson["client_type"]
		cClient_Secret := oJson["client_secret"]
		cClient_Id := oJson["client_id"]

		/* u_POSTCRIARLINK(cAcessTk) */
	else
		alert(cErro)
		alert(cResultado)
	endif


Return


User Function GETCONSULTLINK2
 
Return
