#Include 'Totvs.ch'
  
/*/{Protheus.doc} zViaCep
  
[API.VIACEP] [GET] Conecta na Api gratuita da ViaCep para retornar dados de um Endereço
a partir do CEP.
Documentação: https://viacep.com.br/
Campos Disponiveis na API:  
BAIRRO, CEP, COMPLEMENTO, GIA, IBGE, LOCALIDADE, LOGRADOURO, UF, UNIDADE
  
@type function
@author Thiago.Andrrade (autor da funcionalidade original)
@author Súlivan (resposável por adaptar o fonte)
@since 24/07/2020 [data da criação da rotina]
  
@example
    u_zViaCep('37600000')
    u_zViaCep('31015-104')
    u_zViaCep('31015.025')
    u_zViaCep('31010 514')
    u_zViaCep(FwFldGet('A1_CEP'))
  
    Exemplo para chamar em gatilhos do Protheus para preencher o código do municipio por exemplo
    Regra:   u_zViaCep(FwFldGet('A1_CEP'))['ibge']
  
      @obs : MANUTENÇÕES FEITAS NO CÓDIGO:
     --------------------------------------------------------------------------------------------                         
     Data: 26/01/2021
     Responsável: Súlivan
     Log: * Retirado o uso da função FWJsonDeserialize que está em deprecate
          * Rotina adaptada para receber parametros
          * Adicionado return para retornar as informações concedidas pela API               
          * Incluso mais logs na rotina.     
     --------------------------------------------------------------------------------------------
/*/
User Function zViaCep(cCep)
  
    Local aArea         := GetArea()
    Local aHeader       := {}    
    Local oRestClient   := FWRest():New("https://app.solides.com/pt-BR/api/v1/colaboradores") //lendo a API
    Local oJson         := JsonObject():New()
      


  // Cabeçalho da requisição

  
    aadd(aHeader,'Authorization: Token')
    aAdd(aHeader,'token=pca3e478144a2bf2a05c1fb1fe98asdk53247secfb55c1709e669')
    aAdd(aHeader,'Accept: application/json')
    aAdd(aHeader,'Content-Type: application/json')
    
  
    //[GET] Consulta Dados na Api
    oRestClient:setPath("/"+cCep+"/json/")
    If oRestClient:Get(aHeader)
           
        oJson:FromJson(oRestClient:CRESULT)          
  
        //Se as keys não existirem, cria elas com conteudo vazio.
        oJson['cep']        := Iif( ValType(oJson['cep'])         != "U", oJson['cep']        , "")
        oJson['logradouro'] := Iif( ValType(oJson['logradouro'])  != "U", oJson['logradouro'] , "")
        oJson['complemento']:= Iif( ValType(oJson['complemento']) != "U", oJson['complemento'], "")
        oJson['bairro']     := Iif( ValType(oJson['bairro'])      != "U", oJson['bairro']     , "")
        oJson['localidade'] := Iif( ValType(oJson['localidade'])  != "U", oJson['localidade'] , "")
        oJson['uf']         := Iif( ValType(oJson['uf'])          != "U", oJson['uf']         , "")
        oJson['ibge']       := Iif( ValType(oJson['ibge'])        != "U", SubStr(oJson['ibge'],3,5), "")
        oJson['gia']        := Iif( ValType(oJson['gia'])         != "U", oJson['gia']        , "") 
        oJson['ddd']        := Iif( ValType(oJson['ddd'])         != "U", oJson['ddd']        , "")
        oJson['siafi']      := Iif( ValType(oJson['siafi'])       != "U", oJson['siafi']      , "")
  
        VarInfo("[U_zViaCep] - Resultado da consulta ->",oJson)
    Else
        fConOut("[U_zViaCep] - ** Erro Api ViaCep: "+oRestClient:GetLastError())
    Endif  
  
   oJson['erro']:=  Iif( ValType(oJson['cep']) == "U", "Api não retornou dados do cep: "+cValTochar(cCep) ,"")      
  
    fConOut("[U_zViaCep] - Finalizou na função que consulta as informações do endereco pelo CEP") 
  
    FreeObj(oRestClient)
    RestArea(aArea)
Return oJson
  
Static Function fConOut(cLog)
      
    Default cLog := "Log empty"
          
    FwLogMsg("INFO", /*cTransactionId*/, "fConOut", FunName(), "", "01", cLog, 0, 0, {})
               
Return
