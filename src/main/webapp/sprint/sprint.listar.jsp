<%@ include file="/commons/taglibs.jsp"%>
<html>
	<head>
		<title>Sprints</title>
		<script>
			function fechar(sprintKey) {
				var msg = "Tem certeza que desejar fechar o Sprint? As est�rias ou defeitos em aberto ser�o movidas para o Sprint Atual.";
				if (confirm(msg)) {
					goTo('${raiz}sprints/'+sprintKey+'/fechar');
				}
			}

			function reabrir(sprintKey) {
				var msg = "Tem certeza que desejar reabrir o Sprint?";
				if (confirm(msg)) {
					goTo('${raiz}sprints/'+sprintKey+'/reabrir');
				}
			}		

			function recarregar(comboDeStatus) {
				goTo(pronto.raiz + 'sprints/' + $(comboDeStatus).val());
			}
			
		</script>
	</head>
	<body>
		<h1>Sprints</h1>
		
		<div align="right">
			Exibir: 
			<select name="status" id="status" onchange="recarregar(this)">
				<option ${status eq 'pendentes' ? 'selected="selected"' : ''} value="pendentes">Pendentes</option>
				<option ${status eq 'fechados' ? 'selected="selected"' : ''} value="fechados">Fechados</option>
				<option ${status eq 'todos' ? 'selected="selected"' : ''} value="todos">Todos</option>
			</select>
		</div>
		
		
		<table style="width: 100%">
			<thead>
			<tr>
				<th style="width: 18px"></th>
				<th>Nome</th>
				<th>Projeto</th>
				<th>Per�odo</th>
				<th>Valor de Neg�cio</th>
				<th>Esfor�o</th>
				<th style="width: 88px" colspan="7"></th>
			</tr>
			</thead>
			<tbody>
			<c:set var="cor" value="${false}"/>
			<c:forEach items="${sprints}" var="s">
				<c:set var="cor" value="${!cor}"/>
				<tr style="${s.atual ? 'background-color:ebf5fc;' : ''}" class="${cor ? 'even' : 'odd'}">
					<td>
						<c:choose>
							<c:when test="${s.atual}">
								<pronto:icons name="sprint_atual.png" title="Sprint Atual" />
							</c:when>
							<c:otherwise>
								<c:choose>
									<c:when test="${s.fechado}">
										<pronto:icons name="fechado.png" title="Sprint Fechado" />
									</c:when>
									<c:otherwise>
										<pronto:icons name="definir_sprint_atual.png" title="Definir Sprint como Atual" onclick="pronto.doPost('${raiz}sprints/${s.sprintKey}/mudarParaAtual')"/>
									</c:otherwise>
								</c:choose>
							</c:otherwise>
						</c:choose>
					</td>
					<td><a onclick="goTo('${raiz}sprints/${s.sprintKey}')" href="#" title="Clique para editar">${s.nome}</a></td>
					<td><a onclick="goTo('${raiz}projetos/${s.projeto.projetoKey}')" href="#" title="Clique para editar">${s.projeto.nome}</a></td>
					<td><fmt:formatDate value="${s.dataInicial}"/> � <fmt:formatDate value="${s.dataFinal}"/></td>
					<td>${s.valorDeNegocioTotal}</td>
					<td>${s.esforcoTotal}</td>
					<td><pronto:icons name="editar_sprint.png" title="Editar Sprint" onclick="goTo('${raiz}sprints/${s.sprintKey}')"/></td>
					<td>
						<c:if test="${!s.atual}">
							<c:choose>
								<c:when test="${s.fechado}">
									<pronto:icons name="reabrir.gif" title="Reabrir Sprint" onclick="reabrir(${s.sprintKey})"/>
								</c:when>
								<c:otherwise>
									<pronto:icons name="fechar.png" title="Fechar Sprint" onclick="fechar(${s.sprintKey})"/>
								</c:otherwise>
							</c:choose>
						</c:if>
					</td>
					<td><pronto:icons name="ver_estorias.gif" title="Ver Est�rias" onclick="goTo('${raiz}backlogs/sprints/${s.sprintKey}')"/></td>
					<td><pronto:icons name="kanban.png" title="Kanban do Sprint" onclick="goTo('${raiz}kanban/${s.sprintKey}')"/></td>
					<td><pronto:icons name="burndown_chart.png" title="Burndown Chart do Sprint" onclick="goTo('${raiz}burndown/${s.sprintKey}')"/></td>
					<td><pronto:icons name="retrospectiva.png" title="Retrospectiva" onclick="goTo('${raiz}retrospectivas/sprints/${s.sprintKey}')"/></td>
				</tr>
			</c:forEach>
			</tbody>
		</table>	
		<div align="center" class="buttons">
			<button type="button" onclick="window.location.href='${raiz}sprints/novo'">Incluir Sprint</button>
		</div>
	</body>
</html>