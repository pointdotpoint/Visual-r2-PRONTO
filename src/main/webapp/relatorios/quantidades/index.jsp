<%@ include file="/commons/taglibs.jsp"%>
<html>
	<head>
		<title>Relat�rio de Tickets</title>
	</head>
	<body>
		<h1>
			Relat�rio de Tickets
		</h1>
		
		<div id="topo" align="center">
			Tipo de Gr�fico:
			<select id="tipoDeRelatorio" name="tipoDeRelatorio">
				<option value="semana" chart="FCF_Line">Por Semana</option>
				<option value="mes" chart="FCF_Line">Por M�s</option>
				<option value="ano" chart="FCF_Line">Por Ano</option>
				<option value="categoria" chart="FCF_Bar2D">Por Categoria</option>
				<option value="cliente" chart="FCF_Bar2D">Por Cliente</option>
				<option value="modulo" chart="FCF_Bar2D">Por M�dulo</option>
				<option value="sprint" chart="FCF_Bar2D">Por Sprint</option>
				<option value="release" chart="FCF_Bar2D">Por Release</option>
				<option value="esforco" chart="FCF_Bar2D">Por Esfor�o</option>
				<option value="valor" chart="FCF_Bar2D">Por Valor de Neg�cio</option>
			</select>
			
			Valor:
			<select id="valor" name="valor">
				<option value="quantidade">Quantidade</option>
				<option value="lead">Lead Time (M�dio)</option>
				<option value="cycle">Cycle Time (M�dio)</option>
				<option value="esforco">Esfor�o (Total)</option>
				<option value="negocio">Valor de Neg�cio (Total)</option>
			</select>
			
			Tipo de Ticket:
			<select id="tipoDeTicketKey" name="tipoDeTicketKey">
				<option value="-1">Tudo</option>
				<option value="2">Est�rias</option>
				<option value="3">Defeitos</option>
			</select>
			
			<br/> 
			<br/>
			 
			Refer�ncia:
			<select id="referencia" name="referencia">
				<option value="data_de_criacao">Data de Cria��o</option>
				<option value="data_de_pronto">Data de Pronto</option>
			</select>
			
			
			<fmt:formatDate var="strDataInicial" value="${dataInicial}"/>
			Data Inicial: <input type="text" id="dataInicial" class="required dateBr" value="${strDataInicial}" size="12"/>
			<fmt:formatDate var="strDataFinal" value="${dataFinal}"/>
			Data Final: <input type="text" id="dataFinal" class="required dateBr" value="${strDataFinal}" size="12"/>
			
			&nbsp; &nbsp;
			
			<button type="button" onclick="gerar()">Gerar</button>
		</div>
		
		<div id="chartdiv" align="center" style="height: 510px;">
		</div>
		<script type="text/javascript">
			function gerar() {
				var di = $('#dataInicial').val();
				var df = $('#dataFinal').val();
				var tipoDeRelatorio = $("#tipoDeRelatorio").val();
				var tipoDeTicketKey = $("#tipoDeTicketKey").val();
				var referencia = $("#referencia").val();
				var valor = $("#valor").val();
				var parametros = "?dataInicial=" + di + "&dataFinal=" + df +"&tipoDeRelatorio=" + tipoDeRelatorio + "&tipoDeTicketKey=" + tipoDeTicketKey + "&referencia=" + referencia + "&valor=" + valor;
				var url = encodeURIComponent("${raiz}relatorios/tickets/gerar.xml" + parametros);
				var chartType = $('#tipoDeRelatorio').find('option:selected').attr('chart');
				var chart = new FusionCharts("${raiz}commons/charts/"+chartType+".swf", "chart", "920", "500");
				chart.setDataURL(url);
				chart.render("chartdiv");	
			}

			$(function(){
				$('#formSprint').validate();
				$('.dateBr').datepicker();
			});
		</script> 
	</body>
</html>