<%@ include file="/commons/taglibs.jsp"%>
<html>
	<head>
		<title>Branches</title>
		<script>

			function apagarLinha(ticketKey) {
				$('#'+ticketKey).add('tr[pai='+ticketKey+']').remove();
			}
		
			function moverParaBranchMaster(ticketKey){
				var url = '${raiz}tickets/' + ticketKey + '/moverParaBranchMaster'; 
				$.post(url, {
					success: function() {
						apagarLinha(ticketKey);
					}
				});
			}

			$(function() {
				$("#dialog").dialog({ 
						autoOpen: false, 
						height: $(document).height() - 50, 
						width: $(document).width() - 50, 
						modal: true 
				});
			});

			function verDescricao(ticketKey) {
				$.ajax({
					url: '${raiz}tickets/' + ticketKey + '/descricao',
					cache: false,
					success: function (data) {
						$("#dialog").dialog('option', 'title', '#' + ticketKey + ' - ' + $('#' + ticketKey + ' .titulo').text());
						$("#dialogDescricao").html(data);
						$("#dialog").dialog('open');
					}
				});
			}
		</script>
	</head>
	<body>
		<h1>Tickets em Branches</h1>
		<c:set var="cor" value="${true}"/>
		<table style="width: 100%">
			<tr>
				<th>#</th>
				<th>T�tulo</th>
				<th>Tipo</th>
				<th>Branch</th>
				<th>Status</th>
				<th colspan="3"></th>
			</tr>
			<c:forEach items="${tickets}" var="t">
				<c:set var="cor" value="${!cor}"/>
				
				<c:if test="${branch ne null and branch ne t.branch}">
					<tr style="height: 1px;">
						<td colspan="8" style="background-color:#b4c24b"></td>
					</tr>				
				</c:if>
				<c:set var="branch" value="${t.branch}"/>
				
				<tr id="${t.ticketKey}" class="${cor ? 'odd' : 'even'}">
					<td>${t.ticketKey}</td>
					<td class="titulo">${t.titulo}</td>
					<td>${t.tipoDeTicket.descricao}</td>
					<td style="color: #006600">${t.branch}</td>
					<td>${t.kanbanStatus.descricao}</td>
					<td>
					<c:if test="${usuarioLogado.administrador or usuarioLogado.equipe}">
						<pronto:icons name="mover_para_o_branch_master.png" title="Mover para o Branch Master" onclick="moverParaBranchMaster(${t.ticketKey})"></pronto:icons>
					</c:if>
					</td>
					<td>
						<pronto:icons name="ver_descricao.png" title="Ver Descri��o" onclick="verDescricao(${t.ticketKey});"/>
					</td>
					<td>
						<a href="${raiz}tickets/${t.ticketKey}"><pronto:icons name="editar.png" title="Editar" /></a>
					</td>
				</tr>
			</c:forEach>
		</table>	
		
		<div title="Descri��o" id="dialog" style="display: none; width: 500px;">
			<div align="left" id="dialogDescricao">Aguarde...</div>
		</div>
	</body>
</html>