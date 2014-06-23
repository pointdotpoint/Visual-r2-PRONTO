<%@ include file="/commons/taglibs.jsp"%>
<html>
	<head>
		<title>M�dulos</title>
	</head>
	<body>
		<h1>M�dulos</h1>
		<table style="width: 100%" id="modulos">
			<thead>
			<tr>
				<th>Nome</th>
				<th style="width: 16px"></th>
				<th style="width: 16px"></th>
			</tr>
			</thead>
			<tbody>
				<c:forEach items="${modulos}" var="c">
					<tr>
						<td>
							${c.descricao}
						</td>
						<c:if test="${usuarioLogado.administrador or usuarioLogado.productOwner}">
							<td>
								<pronto:icons name="editar.png" title="Editar M�dulo" onclick="goTo('${raiz}modulos/${c.moduloKey}')"/>
							</td>
							<td>
								<pronto:icons name="excluir.png" title="Excluir M�dulo" onclick="pronto.doDelete('${raiz}modulos/${c.moduloKey}')"/>
							</td>
						</c:if>
					</tr>
				</c:forEach>
			</tbody>
		</table>	
		
		<c:if test="${usuarioLogado.administrador or usuarioLogado.productOwner}">
			<div align="center" class="buttons">
				<button type="button" onclick="window.location.href='${raiz}modulos/novo'">Incluir M�dulo</button>
			</div>
		</c:if>
		
		<script>
			$(function(){
				$('#modulos tbody tr:odd').addClass('odd');
				$('#modulos tbody tr:even').addClass('even');
			});
		</script>
		
	</body>
</html>