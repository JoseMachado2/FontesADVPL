#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'totvs.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "FILEIO.CH"

#DEFINE D_LEITURA 164  //tamanho da linha

#DEFINE	X_FILIAL    1
#DEFINE	X_DATA      2
#DEFINE	X_DC        3
#DEFINE	X_DEBITO    4
#DEFINE	X_CREDIT    5
#DEFINE	X_CCD       6
#DEFINE	X_CCC       7
#DEFINE	X_CLVLDB    8
#DEFINE	X_CLVLCR    9
#DEFINE	X_VALOR    10
#DEFINE	X_HIST     11
#DEFINE	X_RECNO    12

/*/{Protheus.doc} UNI34M02
description
Importação da contabilização Sênior
@type function
@version
@author raul.santos
@since 20/03/2023
@return variant, return_description
/*/
User Function UNI34M02()
	Private cPerg  := "UNI34M02"

	Pergunte(cPerg,.T.)

	@ 136,77 To 328,650 Dialog recdlg Title OemToAnsi("Importação da contabilização Sênior")

	@ 9,6 To 57,275 Title OemToAnsi("Objetivo")
	@ 22,14 Say     OemToAnsi("Esta rotina tem por objetivo realizar a importação") Size 240,8
	@ 33,14 Say     OemToAnsi("da contabilização Sênior via arquivo TXT." ) Size 240,8

	@ 71,74  Button  OemToAnsi("_Executar")  Size 36,16 Action FWMsgRun(, {|lSched,oSay|  U_U34M02Run(oSay, lSched ) },"Aguarde... ","Processando")  //Processa( {|| U34M02Run()  } )
	@ 71,134 Button OemToAnsi("_Parâmetros") Size 36,16 Action  pergunte(cPerg,.T.)
	@ 71,194 Button OemToAnsi("_Sair")       Size 36,16 Action  Close( recdlg )
	Activate Dialog  recdlg CENTERED

Return


/*/{Protheus.doc} U34M02Run
description
@type function
@version
@author raul.santos
@since 20/03/2023
@param oSay, object, param_description
@param cArqTxt, character, param_description
@return variant, return_description
/*/
User function U34M02Run(lSched,oSay)

	Local cError 		:= ""
	Local cTime 		:= ""
	Local cSemaphore	:=	ProcName()+Strzero(SM0->(RECNO()),3)
	Local nThreadIPC
	Local nRegistros
	Local nMvThreads
	Local nThreads //número de threads

	// Para contabilização
	Local cDC
	Local cData
	Local cValor
	Local cDebito
	Local cCredit
	Local cFilx

	// Para leitura do arquivo

	Local cEOL    := "CHR(13)+CHR(10)"
	Local nlinhas
	Local nTamCC
	Local nTamFile
	Local cBuffer
	Local lFim
	Local nHdl
	Local cArqTxt
	//Local nOpc
	Local nIx
	Local nTotFil

	Local aLanca   //todos lançamentos 
	Local aLancaM  //lançamentos de uma filial 
	Local nTotDeb 
	Local nTotCre 
	Local aErro := {}
	Local lErro
MV_PAR02 := 1
MV_PAR03 := 2
MV_PAR04 := 1

	pergunte(cPerg,.F.)

	//cArqTxt    := AllTrim(MV_PAR01)
	cArqTxt    := cGetFile( "Files CSV|*.csv", "Select csv File", 0, , .F., GETF_LOCALHARD, .T., .T.)
	nOpcRel    := MV_PAR02        //Imprime relatório erros 1-Sim, 2-Nao
	lProcParc  := MV_PAR03 == 2   //Integra mesmo com erros 1-Não, 2-Sim
	lMulti     := MV_PAR04 == 1   //Usa Multi-thread 1-sim, 2-Não
	

	nHdl    := FOPEN(cArqTxt,0)

	CT2->(dbSetOrder(1))

	//Tabela de trabalha que recebe dados do arquivo txt baseado na CT2
	cAlias := "TRB"
	aCmp := {}
	oTempTable := FWTemporaryTable():New( cAlias )


	// CT2_FILIAL  = POSICAO 001 A 012 (012) = FILIAL DO PROTHEUS (4 DIGITOS EX. 0101, 0154, 0168, 2901), DEMAIS ESPAÇOS EM BRANCO
	// LP          = POSICAO 013 A 019 (006) = LANCAMENTO PADRAO, ENVIAR CONFORME REGRA ABAIXO
	// CT2_DATA    = POSICAO 020 A 026 (008) = DATA DA CONTABILIZACAO DDMMAAAA
	// CT2_DEBITO  = POSICAO 027 A 046 (020) = CONTA DEBITO
	// CT2_CREDITO = POSICAO 047 A 066 (020) = CONTA CREDITO
	// CT2_CCD     = POSICAO 067 A 076 (010) = CENTRO DE CUSTO DEBITO
	// CT2_CCC     = POSICAO 077 A 086 (010) = CENTRO DE CUSTO CREDITO
	// CT2_CLASSED = POSICAO 087 A 096 (010) = CLASSE DE VALOR DEBITO
	// CT2_CLASSEC = POSICAO 097 A 106 (010) = CLASSE DE VALOR CREDITO
	// CT2_VALOR   = POSICAO 107 A 122 (016) = VALOR A SER CONTABILIZADO (Valor não pode ter . ou , e iniciar na esquerda. Ex. Valor 547,84 - Enviar 54784 / Valor 1254,00 - Enviar 125400)
	// CT2_HIST    = POSICAO 123 A 222 (100) = HISTORIO  ENVIAR: "SENIOR + ' ' + No. Evento + ' ' + Desc. Evento + ' ' + MM/AAAA"

	// SE CT2_DEBITO <> BRANCO AND CT2_CREDITO = BRANCO
	// LP = 201001
	// ENVIAR CT2_CREDITO COM 20 ESPAÇOS EM BRANCO

	// SE CT2_DEBITO = BRANCO AND CT2_CREDITO <> BRANCO
	// LP = 202001
	// ENVIAR CT2_DEBITO COM 20 ESPAÇOS EM BRANCO

	// SE CT2_DEBITO <> BRANCO AND CT2_CREDITO <> BRANCO
	// LP = 203001

	aAdd(aCmp,{"CT2_FILIAL"		  ,"C",TamSx3("CT2_FILIAL")[1]  ,TamSx3("CT2_FILIAL")[2]}   )
	aAdd(aCmp,{"CT2_DATA"         ,"D",TamSx3("CT2_DATA")[1]    ,TamSx3("CT2_DATA")[2]}     )
	aAdd(aCmp,{"CT2_DC"           ,"C",TamSx3("CT2_DATA")[1]    ,TamSx3("CT2_DATA")[2]}     )
	aAdd(aCmp,{"CT2_DEBITO"       ,"C",TamSx3("CT2_DEBITO")[1]  ,TamSx3("CT2_DEBITO")[2]}   )
	aAdd(aCmp,{"CT2_CREDIT"       ,"C",TamSx3("CT2_CREDIT")[1]  ,TamSx3("CT2_CREDIT")[2]}   )
	aAdd(aCmp,{"CT2_CCC"          ,"C",TamSx3("CT2_CCC")[1]     ,TamSx3("CT2_CCC")[2]}      )
	aAdd(aCmp,{"CT2_CCD"          ,"C",TamSx3("CT2_CCD")[1]     ,TamSx3("CT2_CCD")[2]}      )
	aAdd(aCmp,{"CT2_CLVLDB"       ,"C",TamSx3("CT2_CLVLDB")[1]  ,TamSx3("CT2_CLVLDB")[2]}   )
	aAdd(aCmp,{"CT2_CLVLCR"       ,"C",TamSx3("CT2_CLVLCR")[1]  ,TamSx3("CT2_CLVLCR")[2]}   )
	aAdd(aCmp,{"CT2_VALOR"        ,"N",TamSx3("CT2_VALOR")[1]   ,TamSx3("CT2_VALOR")[2]}    )
	aAdd(aCmp,{"CT2_HIST"         ,"C",TamSx3("CT2_HIST")[1]    ,TamSx3("CT2_HIST")[2]}     )
	aAdd(aCmp,{"CT2_ITEMD"        ,"C",TamSx3("CT2_ITEMD")[1]   ,TamSx3("CT2_ITEMD")[2]}    )
	aAdd(aCmp,{"CT2_ITEMC"        ,"C",TamSx3("CT2_ITEMC")[1]   ,TamSx3("CT2_ITEMC")[2]}    )
	//aAdd(aCmp,{"CT2_TPSALD"     ,"C",TamSx3("CT2_HIST")[1]    ,TamSx3("CT2_HIST")[2]}     )
	aAdd(aCmp,{"CT2_EC05CR"       ,"C",TamSx3("CT2_EC05CR")[1]  ,TamSx3("CT2_EC05CR")[2]}   )
	aAdd(aCmp,{"CT2_EC05DB"       ,"C",TamSx3("CT2_EC05DB")[1]  ,TamSx3("CT2_EC05DB")[2]}   )
	aAdd(aCmp,{"CT2_EC06CR"       ,"C",TamSx3("CT2_EC06CR")[1]  ,TamSx3("CT2_EC06CR")[2]}   )
	aAdd(aCmp,{"CT2_EC06DB"       ,"C",TamSx3("CT2_EC06DB")[1]  ,TamSx3("CT2_EC06DB")[2]}   )

	/* CT2_ITEMD
	CT2_ITEMC
	CT2_EC05CR
	CT2_EC05DB
	CT2_EC06CR
	CT2_EC06DB */
	** Verificar se os dois últimos campos estão preenchidos, se não, não levar para o arquivo **

	aAdd(aCmp,{"RECNO"            ,"N",12  , 0} )
	oTemptable:SetFields( aCmp )
	oTemptable::AddIndex( 'FILIAL', {'CT2_FILIAL'} ) 	
	oTempTable:Create()

	//Carga do arquivo TXT com os lançamentos contábeis gerados na Senior
	//em HCM/Calculos/contabilização/Calcular/Listar

	//AQUI SERÁ FEITA A LEITURA DO ARQUIVO CSV

	IF EMPTY(cEOL)
		cEOL := CHR(13)+CHR(10)
	ELSE
		cEOL := TRIM(cEOL)
		cEOL := &cEOL
	ENDIF

	//VE SE O ARQUIVO ESTA VAZIO
	IF nHdl == -1
		MsgAlert('Arquivo TXT está vazio!')
		TRB->(dbCloseArea())
		oTempTable:Delete()
		RETURN
	ENDIF

	nLidos   := 1
	FSEEK(nHdl,0,0)
	nTamFile := FSEEK(nHdl,0,2)
	cLido    := ""   // irá ler D_LEITURA  caraceres de cada vez
	cBuffer  := ""   // armazenagem de uma linha completa
	FSEEK(nHdl,0,0)

	ProcRegua( INT( nTamFile / D_LEITURA) )

	lFim := .F.
	nlinhas := 0
	While ! lFim

		While .T.
			FREAD(nHdl, @cLido, D_LEITURA )  //Linha de Texto detalhe
			cBuffer  := @cLido
			If !Empty(FwCutOff(cBuffer))
				IncProc()
				cData  := SubStr(cBuffer,19,8)
				cData  := Substr(cData,1,2)+'/'+Substr(cData,3,2)+'/'+Substr(cData,5,4)
				cValor := AllTrim(Substr(cBuffer, 107,16))
				cValor := Substr(cValor,1, Len(cValor)-2)+'.'+Right(cValor,2)
				cDebito := Alltrim(Substr(cBuffer, 27, 20))
				cCredit := Alltrim(Substr(cBuffer, 47, 20))

				IF !Empty(cDebito) .AND. Empty(cCredit)
					cDC := '1' //debito
				ElseIf Empty(cDebito) .AND. !Empty(cCredit)
					cDC := '2' //credito
				ElseIf !Empty(cDebito) .AND. !Empty(cCredit)
					cDC := '3' //Partida dobrada
				Else
					cDC := '4' //Erro será gerados posteriormente
				Endif

				oSay:SetText("Lendo Registros: "+cValToCHAR(nTamFile/D_LEITURA)+" Atual: "+cValToCHAR(nLidos ))
				ProcessMessages()

				Reclock("TRB ", .T.)
				TRB->CT2_FILIAL   := Substr(cBuffer,1,6)
				TRB->CT2_DATA     := Ctod(cData)
				TRB->CT2_DC       := cDC

				TRB->CT2_DEBITO   := Alltrim(Substr(cBuffer, 27, 20))
				TRB->CT2_CREDIT   := Alltrim(Substr(cBuffer, 47, 20))
		    	IF cDC == '1'
					TRB->CT2_CCD      := Alltrim(Substr(cBuffer, 67, 10))
				Endif

				IF cDC == '2'
					TRB->CT2_CCC      := Rtrim(Substr(cBuffer, 67, 10)) //Rtrim(Substr(cBuffer, 77, 10))
					
				else
				TRB->CT2_CCD := Alltrim(Substr(cBuffer, 67, 10))
				Endif

				TRB->CT2_CLVLDB   := Rtrim(Substr(cBuffer, 87, 10))
				TRB->CT2_CLVLCR   := Rtrim(Substr(cBuffer, 97, 10))
				TRB->CT2_VALOR    := Val(cValor)
				TRB->CT2_HIST     := Alltrim(Substr(cBuffer,123, 100))

				TRB->CT2_ITEMD  := "teste"
				TRB->CT2_ITEMC  := "teste"
				TRB->CT2_EC05CR := "teste" 
				TRB->CT2_EC05DB := "teste"
				TRB->CT2_EC06CR := "teste"
				TRB->CT2_EC06DB := "teste"

				TRB->RECNO        := nLidos
				MsUnlock()
			

				IF Empty( TRB->CT2_CCD) .AND. Empty(TRB->CT2_CCC)
					x1 := 1
				Endif
				nLidos++
			Else
				lFim := .T.
				Exit   //Nada mais a ser lido
			Endif
		End
	ENDDO
	TRB->(dbgotop())
	Copy to TESTETRB
	FClose(nHdl)/// Fecha o arquivo de text

	//Validação preliminar
	//Carga de filiais
	CT1->(dbSetOrder(1))
	CTT->(dbSetOrder(1))
	nTamCC := TamSx3("CTT_FILIAL")[1]

	TRB->(dbgotop())

	nTotFil := 0
	aLanca := {}
	While !TRB->(Eof())

		cFilx := TRB->CT2_FILIAL
		nTotFil++
		nTotDeb := 0
		nTotCre := 0

		While !TRB->(Eof()) .AND. cFilx == TRB->CT2_FILIAL

			lErro := .F.
			//Testa contas contábeis
			If Empty( TRB->CT2_DEBITO) .AND. Empty(TRB->CT2_CREDIT)
				AADD( aErro, {TRB->CT2_FILIAL, 'Lançam. sem conta crédito ou débito.', Strzer(TRB->RECNO,9),;
					TRB->CT2_DATA, TRB->CT2_HIST, TRB->CT2_VALOR })
				lErro := .T.
			Endif
			If !Empty(TRB->CT2_DEBITO)
				If ! CT1->( dbSeek(xFilial('CT1')+Rtrim(TRB->CT2_DEBITO)))
					AADD( aErro, {TRB->CT2_FILIAL, 'Conta débito '+TRB->CT2_DEBITO+ ' não existe.', Strzer(TRB->RECNO,9),;
						TRB->CT2_DATA, TRB->CT2_HIST, TRB->CT2_VALOR })
					lErro := .T.
				Endif
				nTotDeb += TRB->CT2_VALOR 
			Endif
			If !Empty(TRB->CT2_CREDIT)
				If ! CT1->( dbSeek(xFilial('CT1')+Rtrim(TRB->CT2_CREDIT)))
					AADD( aErro, {TRB->CT2_FILIAL, 'Conta crédito '+TRB->CT2_CREDIT+ ' não existe.', Strzer(TRB->RECNO,9),;
						TRB->CT2_DATA, TRB->CT2_HIST, TRB->CT2_VALOR })
					lErro := .T.
				Endif
				nTotCre += TRB->CT2_VALOR 
			Endif
			//TO DO - testar contas bloqueadas

			//Testa centros de custo
			If Empty( TRB->CT2_CCD) .AND. Empty(TRB->CT2_CCC)
				AADD( aErro, {TRB->CT2_FILIAL, 'Lançamento sem c.custo crédito ou débito', Strzer(TRB->RECNO,9),;
					TRB->CT2_DATA, TRB->CT2_HIST, TRB->CT2_VALOR })
				lErro := .T.
			Endif
			
			/* If !Empty(TRB->CT2_CCD)
				If ! CTT->( dbSeek(PadR(Left(Alltrim(TRB->CT2_FILIAL),6), 6)+Alltrim(TRB->CT2_CCD)))
					AADD( aErro, {TRB->CT2_FILIAL, 'C.Custo débito '+TRB->CT2_CCD+ ' não existe.', Strzer(TRB->RECNO,9),;
						TRB->CT2_DATA, TRB->CT2_HIST, TRB->CT2_VALOR })
					lErro := .T.
				Endif
			Endif */
			
			If !Empty(TRB->CT2_CCD)
				If ! CTT->(  dbSeek(xFilial('CTT')+Rtrim(TRB->CT2_CCD)))
					AADD( aErro, {TRB->CT2_FILIAL, 'C.Custo débito '+TRB->CT2_CCD+ ' não existe.', Strzer(TRB->RECNO,9),;
						TRB->CT2_DATA, TRB->CT2_HIST, TRB->CT2_VALOR })
					lErro := .T.
				Endif
			Endif


			If !Empty(TRB->CT2_CCC)
				If ! CTT->( dbSeek(PadR(Left(TRB->CT2_FILIAL,2), nTamCC)+Rtrim(TRB->CT2_CCC)))
					AADD( aErro, {TRB->CT2_FILIAL, 'C.Custo crédito '+TRB->CT2_CCC+ ' não existe.', Strzer(TRB->RECNO,9),;
						TRB->CT2_DATA, TRB->CT2_HIST, TRB->CT2_VALOR })
					lErro := .T.
				Endif
			Endif

			//Testa valor
			If Empty( CT2->CT2_VALOR)
				AADD( aErro, {TRB->CT2_FILIAL, 'Valor do lançamento zerado.', Strzer(TRB->RECNO,9),;
					TRB->CT2_DATA, TRB->CT2_HIST, TRB->CT2_VALOR })
				lErro := .T.
			Endif

			//Testa histórico
			If Empty( CT2->CT2_HIST)
				AADD( aErro, {TRB->CT2_FILIAL, 'Histório vazio.', Strzer(TRB->RECNO,9),;
					TRB->CT2_DATA, TRB->CT2_HIST, TRB->CT2_VALOR })
				lErro := .T.
			Endif

			IF lErro  //Apaga os erros da tabela temporária
				RecLock('TRB',.F.)
				TRB->(DBDelete())
				MsUnlock()
			Endif
			
			AADD(aLanca, ;
				{ TRB->CT2_FILIAL,;
				TRB->CT2_DATA,;
				TRB->CT2_DC,;
				TRB->CT2_DEBITO,;
				TRB->CT2_CREDIT,;
				TRB->CT2_CCD,;
				TRB->CT2_CCC,;
				TRB->CT2_CLVLDB,;
				TRB->CT2_CLVLCR,;
				TRB->CT2_VALOR ,;
				TRB->CT2_HIST,;
				TRB->CT2_ITEMD,;
				TRB->CT2_ITEMC,;
				TRB->CT2_EC05CR,;
				TRB->CT2_EC05DB,;
				TRB->CT2_EC06CR,;
				TRB->CT2_EC06DB,;
				TRB->RECNO;
				} )

			TRB->(DbSkip())

		EndDo
		If nTotCre <> nTotDeb
           lErro := .T.
		   AADD( aErro, {cFilx , 'Total de Deb. e crédito diferem', Strzer(Len(aerro)+1,9),;
					aLanca[1,X_DATA], 'Diferença DEB-CRE = ', nTotDeb-nTotCre})

		Endif 

	EndDo

	If !Empty(aErro)
		IF nOpcRel == 1
			Rep34M02(aErro)
		Endif

		If !lProcParc
			MsgAlert('Integração não executada, os erros devem ser corrigidos!')
			TRB->(DBCloseArea())
			oTempTable:Delete()
			Return
		Else
			MsgAlert('Integração será executada, mas os erros serão descartados!')
		Endif
	Endif



	nMvThreads := SuperGetMV("UN_CPDDTHR",.F.,2)
	If lMulti
		//Quantidade Máxima de threads a serem usadas na contab.

		nRegistros :=  (TRB->(RecCount()))

		nRegThread :=  INT(nRegistros/nMvThreads)

		If nRegThread >= 30
			nThreads := nMvThreads  //seta para o máximo de threads
		Else
			//Caso contrário proporcionalizo o número de threas para 30 registros por thread
			nThreads := INT(  nRegistros / 30 )
			nThreads := If(nThreads <= 0, 2, nThreads )  //Caso não hajam registros
		Endif

		nThreadIPC	:= nThreads
		oIPC := FWIPCWait():New(cSemaphore,10000)
		oIPC:SetThreads(nThreadIPC)
		oIPC:Start("U_U34M02Exe")
		oIPC:StopProcessOnError(.T.)
		oIPC:SetNoErrorStop(.T.) //Se der erro em alguma thread sai imediatamente

	Endif

	TRB->(DbGotoP())

	nIx := 1

	Do While nIx  <= Len(aLanca)

		aLancaM := {}
		cFilx := aLanca[nIX, X_FILIAL]

		Do While nIx  <= Len(aLanca) .AND. aLanca[nIX,X_FILIAL] == cFilx
			AADD(aLancaM, aLanca[nIX])
			nIx++
		EndDo

		//Processo a filial
		//Aqui vou trocar de filial
		U_ALTEMP(Substr(cFilx,1,2), cFilx)

		If lMulti  //Multi-thread

			cTime := Time()

			U_xMPad(procname(),"INFO","************** UNI34M02 - Contabilizando Filial:"+aLancaM[1,X_FILIAL],,"U_UNI34M02")

			oSay:SetText("Processando "+cValToCHAR(nTotFil)+" filiais. Atual: "+aLancaM[1,X_FILIAL] )
			ProcessMessages()

			oIPC:Go( { aLancaM, lMulti } )

			U_xMPad(procname(),"INFO","************** UNI34M02 - Tempo Total:"+elaptime(cTime,Time()),,"U_UNI34M02")
		Else
			oSay:SetText("Processando "+cValToCHAR(nTotFil)+" filiais. Atual: "+aLancaM[1,X_FILIAL] )
			ProcessMessages()
			U_U34M02Thr(aLancaM , lMulti )
		Endif


	EndDo

	If lMulti

		If oIPC <> nil
			oIPC:Stop()
			cError:= oIPC:GetError()
			oIPC	:=	NIL
			If !Empty(cError)
				MsgAlert(cError)
			EndIfTUKUTH
		EndIf

	Endif

	oTempTable:Delete()
	MsgAlert('Processo concluído!')

Return


/*/{Protheus.doc} U34M02Exe
description
Função  que 'Retorna o resultado' da função que realmente é executada em
Multi-thread , dando início ao processo.
@type function
@version 12.1.2210
@author raul.santos
@since 16/03/2022
@param aExecuta, aArray, sim
Função que executa - registro a ser processado
@return variant, nil
Resultado da função que executa a Thread
/*/
User Function U34M02Exe(aExecuta)
Return( U_U34M02Thr(aExecuta[1] , aExecuta[2] ) )

/*/{Protheus.doc} U34M02Thr
description
Função que é executada pelas threads
Grava o lançamento contábil PDD
@type function
@version
@author raul.santos
@since 16/03/2023
@param reg, variant, param_description
registro a ser processado
@return variant, return_description
/*/
User Function U34M02Thr(aLanca, lMulti)

	Local _cDoc
	Local _lOk   := .T.
	Local aItens := {}
	Local aCab
	Local cLin
	Local nIx
	Local nAux

	Local cArqErro
	Local cLogTxt

	If lMulti
		RpcSetEnv('01', aLanca[1,X_FILIAL])
	Endif


	_cDoc := ''
	//O número do documento não é passado, para que ele seja gerado automaticamente
	//isto irá prevenir o erro relacionado a tabela CTF (MV_CTFQTD)

	cLin := '000'
	aCab := { {'DDATALANC' , aLanca[1,X_DATA] ,NIL},;
		{'CLOTE' ,'000001' ,NIL},;  //Lote da folha
		{'CSUBLOTE' ,'001' ,NIL},;
		{'CFILIAL' ,aLanca[1,X_FILIAL],NIL};
		}

	For nIx := 1 To Len(aLanca) 

		cLin := Soma1(cLin)

		aAdd(aItens,{ {'CT2_FILIAL' ,aLanca[nIx,X_FILIAL] , NIL},;
			{'CT2_LINHA'  ,cLin , NIL},;   //---> Como será o controle das linhas?
			{'CT2_MOEDLC' ,'01' , NIL},;
			{'CT2_DC'     ,Rtrim(aLanca[nIx,X_DC]), NIL},;
			{'CT2_DEBITO' ,Rtrim(aLanca[nIx,X_DEBITO]), NIL},;
			{'CT2_CREDIT' ,Rtrim(aLanca[nIx,X_CREDIT]), NIL},;
			{'CT2_VALOR'  ,aLanca[nIx,X_VALOR], NIL},;
			{'CT2_CCD'    ,Rtrim(aLanca[nIx,X_CCD]), NIL},;
			{'CT2_CCC'    ,Rtrim(aLanca[nIx,X_CCC]), NIL},;
			{'CT2_CLVLDB' ,aLanca[nIx,X_CLVLDB], NIL},;
			{'CT2_CLVLCR' ,aLanca[nIx,X_CLVLCR], NIL},;
			{'CT2_ORIGEM' ,'UNI34M02', NIL},;
			{'CT2_HP'     ,'', NIL},;
			{'CT2_HIST'   ,Rtrim(aLanca[nIx,X_HIST]), NIL},;
			{'CT2_ITEMD'     ,'TST', NIL},;
			{'CT2_ITEMC'     ,'TST', NIL},;
			{'CT2_EC05CR'     ,'TST', NIL},;
			{'CT2_EC05DB'     ,'TST', NIL},;
			{'CT2_EC06CR'     ,'TST', NIL},;
			{'CT2_EC06DB'     ,'TST', NIL} } )

	Next nIx


	BEGIN TRANSACTION


		If lMulti
			lMsErroAuto     := .T.
			lAutoErrNoFile  := .T.
			lMsHelpAuto     := .F.
		Else

			lMsErroAuto := .F.
			lMsHelpAuto := .F.
		Endif

		MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)

		If lMsErroAuto
			DisarmTransaction()

			cArqErro := 'E34'+aLanca[1,X_FILIAL]+cLin+'.TXT'
			cLogTxt  := ''
			//Pegando log do ExecAuto
			aLogAuto := GetAutoGRLog()

			//Percorrendo o Log e incrementando o texto (para usar o CRLF você deve usar a include "Protheus.ch")
			For nAux := 1 To Len(aLogAuto)
				cLogTxt += aLogAuto[nAux] + CRLF
			Next

			MemoWrite(cArqErro , cLogTxt)
			_lOk := .F.

			If !lMulti
				MostraErro()
			Endif
		Else
			_lOk := .T.
			// Se gerou lançamento na contabilidade,
			// Gerar algum log, marcar a tabela TRB
		endif

	END TRANSACTION

Return _lOk


/*/{Protheus.doc} Rep34M02
description
Gerar o relatório de erros da rotina
@type function
@version
@author raul.santos
@since 20/03/2023
@param aErro, array, param_description
@return variant, return_description
/*/
Static  Function Rep34M02(aErro)
	Local oReport
	oReport := ReportDef(aErro)
	oReport:PRINTDIALOG()
Return


/*/{Protheus.doc} ReportDef
description
Executa o relatório de erros da rotina
@type function
@version
@author raul.santos
@since 20/03/2023
@param aErro, array, param_description
@return variant, return_description
/*/ 
Static Function ReportDef(aErro)

	Local oReport
	Local cPerg := ""
	oReport := TReport():New(cPerg,"Relatorio de Erros de Integracao" ,cPerg, {|oReport| ReportPrint(oReport,aErro)},"Apresenta os Erros na Integracao Senior")

	oReport:SetPortrait()
	oReport:ShowHeader()
	oReport:LPARAMPAGE := .F.

	oPRD   := TRSection():New(oReport,"Analise",{"TRB"})
	oPRD:SetTotalInLine(.F.)

	TRCell():New(oPRD,"cFilial"	 ,, "Filial"				    ,"",10)
	TRCell():New(oPRD,"cErro"	 ,, "Erro de Integracao"		,"",60)

	TRCell():New(oPRD,"nLinha"	 ,, "Linha do erro"	    		,"",20)
	TRCell():New(oPRD,"dEmissao" ,, "Dt. Lançamento"      		,"",15)
	TRCell():New(oPRD,"cHist"	 ,, "Histórico"	         		,"",90)
	TRCell():New(oPRD,"nValor"	 ,, "Vl.Lançamento"	           	,"@E 999,999,999.99",15)

	oPRD:Cell("cFilial"):SetBlock(  {|| cFilial  })
	oPRD:Cell("cErro"):SetBlock(    {|| cErro    })
	oPRD:Cell("nLinha"):SetBlock(   {|| nLinha   })
	oPRD:Cell("dEmissao"):SetBlock( {|| dEmissao })
	oPRD:Cell("cHist"):SetBlock(    {|| cHist    })
	oPRD:Cell("nValor"):SetBlock(   {|| nValor   })

Return oReport


/*/{Protheus.doc} ReportPrint
description
@type function
@version
@author raul.santos
@since 20/03/2023
@param oReport, object, param_description
@param aErro, array, param_description
@return variant, return_description
/*/
Static Function ReportPrint(oReport,aErro)

	Local oPRD	 		:= oReport:Section(1)
	Local nPos := 0
	oPRD:Init()
	For nPos := 1 to len(aErro)

		oPRD:Cell("cFilial"):SetValue(aErro[nPos,1])
		oPRD:Cell("cErro"):SetValue(aErro[nPos,2])
		oPRD:Cell("nLinha"):SetValue(aErro[nPos,3])
		oPRD:Cell("dEmissao"):SetValue(aErro[nPos,4])
		oPRD:Cell("cHist"):SetValue(aErro[nPos,5])
		oPRD:Cell("nValor"):SetValue(aErro[nPos,6])

		oPRD:PrintLine()
	NEXT
	oPRD:Finish()
Return oReport


Static Function xGeraLog( aInfo, cDelimit, cArquivo )
	Local cLinha   := "",;
		cTipoVal := "",;
		cValor   := "",;
		lRetorno := .F.,;
		nHandle  := 0,;
		nLoop    := 0,;
		nTamMat  := Len( aInfo )

	nHandle := FCREATE( cArqLog, FC_NORMAL )

	If( nTamMat > 0 )
		FSeek( nHandle, 0, FS_END )
		For nLoop := 01 To nTamMat

			cTipoVal := ValType( aInfo[ nLoop ] )
			Do Case
				Case ( cTipoVal == "N" )   //tipo numerico
					cValor := LTrim( Str( aInfo[ nLoop ] ) )
				Case ( cTipoVal == "D" )   //tipo data
					cValor := DToS( aInfo[ nLoop ] )
				Case ( cTipoVal == "C" )   //tipo caracter
					cValor := AllTrim( aInfo[ nLoop ] )
				Otherwise
					cValor := ""
			End Case
			cLinha += If( !Empty( cLinha ), cDelimit, "" ) + cValor
		Next nLoop
		cLinha += CHR(013)

		If( FWrite( nHandle, cLinha ) == Len( cLinha ) )
			lRetorno := FClose( nHandle )
		EndIf

	EndIf

Return( lRetorno )


xGeralog( aInfoLog, ';', cArqLog )



/*/{Protheus.doc} ALTEMP
description
@type function
@version  
@author raul.santos
@since 28/03/2023
@param cEmp, character, param_description
@param cFil, character, param_description
@return variant, return_description
/*/
User Function ALTEMP(cEmp, cFil)

Local cemp := cEmp
Local cfil := cFil
	
	dbcloseall()
	cempant := cemp
	cfilant := cfil 
	cNumEmp := cemp+cfil
	Opensm0(cempant+cfil)
 	Openfile(cempant+cfil)
	lrefresh :=.T.
	       
Return
