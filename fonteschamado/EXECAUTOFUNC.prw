#INCLUDE "Protheus.CH"
#Include "TOTVS.CH"
#Include "RESTFUL.CH"
#Include "tbiconn.ch"
#Include "topconn.ch"

//Esta rotina tem a finalidade de efetuar o lançamento automático de funcionários
//através do mecanismo de rotina automática.
//Nesse exemplo, a chamada da função U_GP010AUT deve ser realizada
//a partir do menu, como demonstrado no extrato de um arquivo (*.XNU) qualquer:
/*  ... Parte anterior do menu .... 
 Rotina Auto		Rotina Auto		Rotina Auto        U_GP010AUT		1		xxxxxxxxxx		07		0	 	... Continuacao do menu ...*/

WSRESTFUL INCFUNC DESCRIPTION "Serviço REST para geracao de Cadastro de Funcionario."
	WSMethod POST   Description "Inclusão de funcionario" WSSYNTAX  "/INCFUNC/"
END WSRESTFUL
  
WSMETHOD POST WSSERVICE INCFUNC

Local aCabec   := {}       
Local oParseJSON       As Object
Local cJson            := Self:GetContent()
Local oJson            := JsonObject():New()
PRIVATE lAtivAmb := .F.                                        		
PRIVATE lMsErroAuto := .F.


If Select("SX2") == 0
	//RPCClearEnv()
	RpcSetType( 3 )
	RpcSetEnv( "99",'01', , , "GPE")	

	lAtivAmb := .T. // Seta se precisou montar o ambiente
Endif

::SetContentType("application/json")
FwJsonDeserialize(cJson,@oParseJSON)
//### Primeiro Funcionario ######################################### //
//-- Inclusão de 1 funcionário da matricula '880001'

aCabec   := {}
aadd(aCabec,{"RA_FILIAL" 		,oParseJSON:funcionario:filial	                	,Nil		})
aadd(aCabec,{"RA_MAT" 			,oParseJSON:funcionario:matricula               	,Nil		})
aadd(aCabec,{'RA_NOME'			,oParseJSON:funcionario:nome 	                    ,Nil		})
aadd(aCabec,{'RA_SEXO'			,oParseJSON:funcionario:sexo						,Nil		})
aadd(aCabec,{'RA_ESTCIVI'		,oParseJSON:funcionario:estadocivil					,Nil		})
aadd(aCabec,{'RA_NATURAL'		,oParseJSON:funcionario:natural						,Nil		})
aadd(aCabec,{'RA_NACIONA'		,oParseJSON:funcionario:nacionalidade				,Nil		})
aadd(aCabec,{'RA_NASC'			,Stod(oParseJSON:funcionario:datanascimento)		,Nil		})
aadd(aCabec,{'RA_CC'			,oParseJSON:funcionario:centrodecusto	        	,Nil		})
aadd(aCabec,{'RA_ADMISSA'		,Stod(oParseJSON:funcionario:dataadmissao)			,Nil		})
aadd(aCabec,{'RA_PROCES'		,oParseJSON:funcionario:codigodeprocesso			,Nil		})
aadd(aCabec,{'RA_OPCAO'			,Stod(oParseJSON:funcionario:dataopcfgts)			,Nil		})
// aadd(aCabec,{'RA_BCDPFGT'		,'34100'			   							,Nil		})
// aadd(aCabec,{'RA_CTDPFGT'		,'222285'			     						,Nil		})
aadd(aCabec,{'RA_HRSMES'		,oParseJSON:funcionario:horasmens					,Nil		})
aadd(aCabec,{'RA_HRSEMAN'		,oParseJSON:funcionario:horassem				    ,Nil		})
aadd(aCabec,{'RA_CODFUNC'		,oParseJSON:funcionario:codfunc		    			,Nil		})
aadd(aCabec,{'RA_CATFUNC'		,oParseJSON:funcionario:categoriafunc	    		,Nil		})
aadd(aCabec,{'RA_TIPOPGT'		,oParseJSON:funcionario:tipopagamento				,Nil		})
aadd(aCabec,{'RA_TIPOADM'		,oParseJSON:funcionario:tipoadmissao			    ,Nil		})
aadd(aCabec,{'RA_VIEMRAI'		,oParseJSON:funcionario:vinculoempregaticio			,Nil		})
aadd(aCabec,{'RA_GRINRAI'		,oParseJSON:funcionario:codinstrais		     		,Nil		})
aadd(aCabec,{'RA_HOPARC'		,oParseJSON:funcionario:contratoatempoparcial	    ,Nil		})
aadd(aCabec,{'RA_COMPSAB'		,oParseJSON:funcionario:compenssab			    	,Nil		})
// aadd(aCabec,{'RA_NUMCP'			,'1234567'										,Nil		})
// aadd(aCabec,{'RA_SERCP'			,'150'											,Nil		})
aadd(aCabec,{'RA_TNOTRAB'		,oParseJSON:funcionario:tnotrab		  		        ,Nil		})
//aadd(aCabec,{'RA_ADTPOSE'		,'***N**'											,Nil		})

//-- Faz a chamada da rotina de cadastro de funcionários (opção 3) 

MSExecAuto({|x,y,k,w| GPEA010(x,y,k,w)},NIL,NIL,aCabec,3)  //-- Opcao 3 - Inclusao registro

//-- Retorno de erro na execução da rotina

If lMsErroAuto	
 SetRestFault(400,'erro no execauto') 
else
    SetRestFault(200,'deu certo')
EndIf 

If lAtivAmb
		RPCClearEnv()
	Endif

Return(.T.)


/* cJson += '{'

While .T.

	cJson += '{'
	cJson += '"teste": "teste"'
	cJson += '"teste2": "teste2"'
	cJson += '"teste3": "teste3"'
	cJson += '},'


End

cJson += '}' */
