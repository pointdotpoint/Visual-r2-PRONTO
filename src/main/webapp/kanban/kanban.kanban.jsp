<%@ include file="/commons/taglibs.jsp"%>
<html>
	<head>
		<title>Kanban</title>
		<link rel="stylesheet" type="text/css" media="all" href="${raiz}kanban/kanban.css" />
		<script type="text/javascript" src="${raiz}kanban/kanban.js"  charset="UTF-8"></script>
		<script>
			var ordens = eval(${ordens});
		</script>
	</head>
	<body>
		<div align="left">
			<h1>
				Kanban do Sprint <a href="${raiz}sprints/${sprint.sprintKey}">${sprint.nome}</a> do Projeto <a href="${raiz}projetos/${sprint.projeto.projetoKey}">${sprint.projeto.nome}</a>
				<%@ include file="/commons/sprintLinks.jsp" %>
			</h1>
			<c:if test="${sprint.meta ne null and fn:length(sprint.meta) gt 0}">
				<span id="meta">Meta: ${sprint.meta}</span><br/>
			</c:if>
			<c:if test="${impedimentos gt 0}">
				<span id="impedidosDoUsuario">
					<c:url var="ticketImpedidosUrl" value="/buscar/?responsavel=${usuarioLogado.username}"/>
					<a href="${ticketImpedidosUrl}">
						H� ${impedimentos} ticket(s) impedido(s) em sua responsabilidade.
					</a>
				</span>
			</c:if>
		</div>
		
		<div align="right">
			Sprint: 
			<form:select path="sprint.sprintKey" onchange="pronto.kanban.recarregar(this.value)">
				<c:forEach items="${projetos}" var="projeto">
					<optgroup label="${projeto.nome}"></optgroup>
					<c:forEach items="${sprints[projeto]}" var="sp">
						<option ${sprint.sprintKey eq sp.sprintKey ? 'selected="selected"' : ''} value="${sp.sprintKey}">${sp.nome} ${sp.atual ? ' (atual)' : ''} </option>
					</c:forEach>
				</c:forEach>
			</form:select>
		</div>
		
		<table align="center" style="width: 100%;" id="kanbanTable">
			<tr>
                <c:set var="width" value="${100 / fn:length(status)}"/>
                <c:forEach items="${status}" var="s">
					<td style="width: ${width}%; height: 100%;">
                              <div class="ui-widget ui-helper-clearfix kanban-area" align="center">
                                  <h4 class="kanban-header ui-widget-header">
                                  	<span class="quantidade">${mapaDeQuantidades[s.kanbanStatusKey] != null ? mapaDeQuantidades[s.kanbanStatusKey] : 0}</span>
                                  	${s.descricao}
                                  </h4>
                                  <ul id="kanban-${s.kanbanStatusKey}" class="kanbanColumn ui-helper-reset ui-helper-clearfix drop" status="${s.kanbanStatusKey}">
                                      <c:forEach items="${mapaDeTickets[s.kanbanStatusKey]}" var="t">
											<c:choose>
												<c:when test="${t.impedido}">
													<c:set var="tipo" value="impedido"/>
												</c:when>
												<c:when test="${t.tipoDeTicket.tipoDeTicketKey eq 3}">
													<c:set var="tipo" value="bug"/>
												</c:when>
												<c:when test="${t.tipoDeTicket.tipoDeTicketKey eq 6}">
													<c:set var="tipo" value="task"/>
												</c:when>
												<c:otherwise>
													<c:set var="tipo" value="story"/>
												</c:otherwise>
											</c:choose>
                                              <li id="${t.ticketKey}" kanbanStatus="${t.kanbanStatus.kanbanStatusKey}" class="ticket ui-corner-tr  ${t.categoria ne null ? 'categoria-' : ''}${t.categoria ne null ? t.categoria.cor : tipo}" ondblclick="pronto.kanban.openTicket(${t.ticketKey});" title="${t.titulo}">
                                                  <p><span class="ticketKey">
                                                  	<c:if test="${t.impedido}">
														<pronto:icons name="impedimento.png" title="Impedido" clazz="ticket-icon"/>                                                  
                                                  	</c:if>
                                                  	#${t.ticketKey}
                                                  </span>
                                                  <br/>${t.tituloResumido}<br/>
													<span class="avatares">
	                                                  <c:forEach items="${t.envolvidos}" var="u" varStatus="s">
	                                                  	<c:if test="${s.index < 3}">
															<img alt="${u.username}" id="dev_img_${u.username}" align="bottom" title="${u.nome}" src="http://www.gravatar.com/avatar/${u.emailMd5}?s=25" style="padding: 1px;"/>
														</c:if>
													 </c:forEach>
												 	</span>                                                  
                                                  </p>
                                              </li>
                                      </c:forEach>
                                  </ul>
                              </div>
                          </td>
                </c:forEach>
			</tr>
		</table>
		
		<div align="center" id="texto-de-ajuda">
			<br/><br/>* Clique duas vezes sobre o cart�o para abr�-lo.
		</div>
		
		
		<div id="motivo">
			<select id="motivoReprovacaoKey" onchange="pronto.kanban.alterarMotivo(this)">
				<option value="-1">=== Selecione um Motivo ===</option>
				<c:forEach items="${motivos}" var="motivo">
					<option value="${motivo.motivoReprovacaoKey}">${motivo.descricao}</option>				
				</c:forEach>
			</select>
		</div>
	</body>
</html>