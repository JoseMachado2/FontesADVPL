#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"

// Exemplo de relatorio usando tReport com uma Section
// cod aluno/nome aluno/ media/ nome prof/situacion
// campo de media tem que tar centralizado e codigo do aluno tbm
User Function ROP01()

	local oReport
	local cPerg := 'ROP01'
	local cAlias := getNextAlias()
	Pergunte(cPerg, .f.)
	oReport := reportDef(cAlias, cPerg)
	oReport:printDialog()

return

//+-----------------------------------------------------------------------------------------------+
//! Rotina para montagem dos dados do relatório. !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportPrint(oReport,cAlias)

	local oSecao1 := oReport:Section(1)

	oSecao1:BeginQuery()

   BeginSQL Alias cAlias

      SELECT C2_NUM, C2_EMISSAO, C2_QUANT FROM %table:SC2% SC2,


	EndSQL

	oSecao1:EndQuery()
	oReport:SetMeter((cAlias)->(RecCount()))
	oSecao1:Print()

return

//+-----------------------------------------------------------------------------------------------+
//! FunÃ§Ã£o para criação da estrutura do relatório. !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportDef(cAlias, cPerg)

	local cTitle := "Ordem de produ��o"
	
	local oReport
	local oSection1


	Pergunte(cPerg, .f.)

	oReport := TReport():New('RCOMR02',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},)

//Primeira sessao
	oSection1 := TRSection():New(oReport,"Ordens de Produ��o",{cAlias})

	ocell:= TRCell():New(oSection1,"C2_NUM", cAlias, "NUMERO DA OP")
	ocell:= TRCell():New(oSection1,"C2_EMISSAO", cAlias, "DATA")
	ocell:= TRCell():New(oSection1,"C2_QUANT", cAlias, "QUANTIDADE")

Return(oReport)
