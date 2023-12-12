#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

User Function POSTAUTENT()
//preciso dar um post nisso: https://cieloecommerce.cielo.com.br/api/public/v2/token
	Local oJson     := JSonObject():New()
	Local cResultado := ""
	Local cErro := ""

	local cURL := "https://cieloecommerce.cielo.com.br" //alterar depois pra usar como parametro
	Private oRest := FWRest():New(cURL)
	Private cTkType := ""
	Private cAcessTk := ""
	Private aHeader := {"Authorization: Basic ZjcyZmY5NGQtZGEyYi00OGE1LWJkYjgtNWVmOTJmNGVkMzU0OmlPU2JRT0tpSHpFeEF2dHdmS3JXaG9mQlErWXB5RGtCV0xITzVVVGE2RUU9"}
	
	oRest:setPath("/api/public/v2/token")
	oRest:SetPostParams("")
	oRest:Post(aHeader)
	

	cResultado := oRest:GetResult()
	cErro := oJSon:FromJson(cResultado)

	iF  oRest:GetHTTPCode() == "201"
		alert(cResultado)
		cAcessTk := oJson["access_token"]
		cTkType := oJson["token_type"]

		u_POSTCRIARLINK(cAcessTk)
	else
		alert(cErro)
	endif

Return

User Function POSTCRIARLINK(cAcessTk)
	Local oJson     := JSonObject():New()
	Local cResultado := ""
	Local cErro := ""
	Local aHeader := {"Authorization: Bearer " +cAcessTk}
	Private oRest := FWRest():New(cURL)
	oRest:setPath("/api/public/v1/products/")



/* 	If oRest:Post(aHeader)
		ConOut("GET", oRest:GetResult())
	else
		ConOut("GET", oRest:GetLastError())
	ENDIF

	private resultado := oRest:GetResult()
	private erro := oRest:GetLastError()
	alert(resultado)
	alert(erro)
	ConOut("FIM")
 */
 	cJson := '{'
	cJson += '  "type": "Digital",'
  	cJson += '"name": "Pedido",'
  	cJson += '"description": "teste description",'
  	cJson += '"price": "500",'
  	cJson += '"weight": 100,'
   	cJson += '"expirationDate": "2023-10-13",'
   	cJson += '"maxNumberOfInstallments": "2",'
   	cJson += '"quantity": 3,'
   	cJson += '"sku": "LinkPagamento",'
   	cJson += '"shipping": {'
	cJson += '"type": "WithoutShipping",'
    cJson += '"name": "teste",'
    cJson += '"price": "1000"'
   	cJson += '},'
   	cJson += '"softDescriptor": "Pharmapele"'
 	cJson += '}'

oRest:SetPostParams(cJson)
	oRest:Post(aHeader)
	cResultado := oRest:GetResult()
	cErro := oJSon:FromJson(cResultado)

	iF  oRest:GetHTTPCode() == "201"
		alert(cResultado)
	/* 	cAcessTk := oJson["access_token"]
		cTkType := oJson["token_type"]
 */
		/* u_POSTCRIARLINK(cAcessTk) */
	else
		alert(cErro)
		alert(cResultado)
	endif


Return


User Function GETCONSULTLINK

Return
