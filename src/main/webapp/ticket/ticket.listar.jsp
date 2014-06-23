<%@ include file="/commons/taglibs.jsp"%>
<html>
	<head>
		<title>${backlog.descricao}${sprint.nome}</title>
		<script src="${raiz}ticket/ticket.listar.js" type="text/javascript"  charset="UTF-8"></script>
		<style type="text/css">
			#ticketsTable tr {
				height: 22px;
			}
		</style>
	</head>
	<body>
		<c:choose>
			<c:when test="${sprint.nome ne null}">
				<h1>
					Sprint ${sprint.nome}
					
					<c:if test="${usuarioLogado.administrador or usuarioLogado.productOwner}">
						<a href="${raiz}sprints/${sprint.sprintKey}">
							<pronto:icons name="editar.png" title="Editar Sprint" />
						</a>
					</c:if>
					
					<c:if test="${(usuarioLogado.administrador or usuarioLogado.equipe or usuarioLogado.productOwner)}">
						<a href="${raiz}sprints/${sprint.sprintKey}/estimar"><pronto:icons name="estimar.png" title="Estimar Sprint" /></a>
					</c:if>

					<c:if test="${usuarioLogado.administrador or usuarioLogado.productOwner}">
						<a href="${raiz}sprints/${sprint.sprintKey}/adicionarTarefas">
							<pronto:icons name="adicionar.png" title="Adicionar Est�rias ou Defeitos do Product Backlog ao Sprint" />
						</a>
					</c:if>
					
					<c:if test="${usuarioLogado.administrador or usuarioLogado.productOwner}">
						<a href="${raiz}sprints/${sprint.sprintKey}/priorizar">
							<pronto:icons name="priorizar.png" title="Priorizar" />
						</a>
					</c:if>
					
					<%@ include file="/commons/sprintLinks.jsp" %>
					
				</h1>	
			</c:when>
			<c:otherwise>
				<h1>
					${backlog.descricao} 
					<c:if test="${(usuarioLogado.administrador or usuarioLogado.equipe or usuarioLogado.productOwner) and (backlog.backlogKey le 3)}">
						<a href="${raiz}backlogs/${backlog.backlogKey}/estimar"><pronto:icons name="estimar.png" title="Estimar Backlog" /></a>  
					</c:if>
					
					<c:if test="${usuarioLogado.administrador or usuarioLogado.productOwner}">
						<a href="${raiz}backlogs/${backlog.backlogKey}/priorizar">
							<pronto:icons name="priorizar.png" title="Priorizar" />
						</a>
					</c:if>
				</h1>
			</c:otherwise>
		</c:choose>
		
		
		<div align="right">
			<c:if test="${sprint ne null}">
				Sprint: 
				<select name="sprintKey" onchange="recarregar(this.value)">
					<c:forEach items="${projetos}" var="projeto">
						<optgroup label="${projeto.nome}"></optgroup>
						<c:forEach items="${projeto.sprints}" var="sp">
							<option ${sprint.sprintKey eq sp.sprintKey ? 'selected="selected"' : ''} value="${sp.sprintKey}">${sp.nome} ${sp.atual ? ' (atual)' : ''} </option>
						</c:forEach>
					</c:forEach>
				</select>
			</c:if>
			
			Categoria:
			<select name="categoriaKey" id="categoriaKey" onchange="recarregarFiltros()">
				<option value="0" selected="selected">Todas</option>
				<optgroup label="---">
					<c:forEach items="${categorias}" var="categoria">
						<option value="${categoria.categoriaKey}">${categoria.descricao}</option>
					</c:forEach>
				</optgroup>
				<optgroup label="---"></optgroup>
				<option value="-1">Sem categoria</option>
			</select>

			Tipo:
			<select name="ticketDeTicketKey" id="tipoDeTicketKey" onchange="recarregarFiltros()">
				<option value="0" selected="selected">Todos</option>
				<optgroup label="---">
					<c:forEach items="${tiposDeTicket}" var="tipoDeTicket">
						<option value="${tipoDeTicket.tipoDeTicketKey}">${tipoDeTicket.descricao}</option>
					</c:forEach>
				</optgroup>
			</select>
			
			Status: 
			<select name="kanbanStatusKey" id="kanbanStatusKey" onchange="recarregarFiltros()">
				<option value="0" selected="selected">Todos</option>
				<option value="-1">Pendentes</option>
				<c:forEach items="${projetos}" var="projeto">
					<optgroup label="${projeto.nome}"></optgroup>
					<c:forEach items="${projeto.etapasDoKanban}" var="item">
						<option value="${item.kanbanStatusKey}">${item.descricao}</option>
					</c:forEach>
				</c:forEach>
			</select>
			
			Ordem:
			<select name="ordem" id="ordem" onchange="recarregarFiltros()">
				<option value="categoria" ${ordem eq 'categoria' ? 'selected' : ''}>Categoria</option>
				<option value="cliente" ${ordem eq 'cliente' ? 'selected' : ''}>Cliente</option>
				<option value="dias" ${ordem eq 'dias' ? 'selected' : ''}>Dias</option>
				<option value="esforco" ${ordem eq 'esforco' ? 'selected' : ''}>Esfor�o</option>
				<option value="modulo" ${ordem eq 'modulo' ? 'selected' : ''}>M�dulo</option>
				<option value="status" ${ordem eq 'status' ? 'selected' : ''}>Status</option>
				<option value="valor" ${ordem eq 'valor' or ordem eq null  ? 'selected' : ''}>Valor de Neg�cio</option>
			</select>
		</div>
		
		<c:set var="cor" value="${true}"/>
		<table id="ticketsTable" style="width: 100%">
			<thead>
			<tr>
				<th style="width: 30px;"></th>
				<th>#</th>
				<th>T�tulo</th>
				<c:if test="${backlog.impedimentos}"><th>Respons�vel</th></c:if>
				<th>Tipo</th>
				<th>Cliente</th>
				<th>M�dulo</th>
				<th>Valor</th>
				<th>Esfor�o</th>
				<th>Status</th>
				<th title="Tempo de Vida em Dias">Dias</th>
			</tr>
			</thead>
			<tbody>
			<c:forEach items="${tickets}" var="t">
					<c:set var="cor" value="${!cor}"/>
					<tr id="${t.ticketKey}" class="${cor ? 'odd' : 'even'}">
						
						<td ondblclick="trocarCategoria(this)" title="D� um duplo clique para alterar a categoria" categoriaKey="${t.categoria ne null ? t.categoria.categoriaKey : 0}">
							<c:if test="${t.categoria ne null}">
								<span class="categoria categoria-${t.categoria.cor}">
									${t.categoria.descricao}
								</span>
							</c:if>
						</td>
						<td>
							<a href="${raiz}tickets/${t.ticketKey}" title="Editar">
								${t.ticketKey}
							</a>
						</td>
						<td>
							<span class="titulo">${t.titulo}</span>
							<span class="opcao" style="display: none;">
								<pronto:icons name="ver_descricao.png" title="Ver Descri��o" onclick="verDescricao(${t.ticketKey});"/>
								<a href="${raiz}tickets/${t.ticketKey}"><pronto:icons name="editar.png" title="Editar" /></a>
								
								<c:if test="${usuarioLogado.administrador or usuarioLogado.productOwner}">
									<c:if test="${t.backlog.backlogKey eq 2 or t.backlog.backlogKey eq 6}">
											<pronto:icons name="mover_para_inbox.png" title="Mover para o Inbox" onclick="pronto.moverParaInbox(${t.ticketKey},true)"></pronto:icons>
									</c:if>
									<c:if test="${t.backlog.backlogKey le 3 or t.backlog.backlogKey eq 6}">
										<pronto:icons name="mover_para_o_sprint_atual.png" title="Mover para um Sprint" onclick="escolherSprintParaMover(${t.ticketKey})"></pronto:icons>
									</c:if>
									<c:if test="${t.backlog.backlogKey eq 1 or t.backlog.backlogKey eq 3 or t.backlog.backlogKey eq 6}">
										<pronto:icons name="mover_para_pb.png" title="Mover para o Product Backlog" onclick="pronto.moverParaProductBacklog(${t.ticketKey},true)"></pronto:icons>
									</c:if>
									<c:if test="${t.backlog.backlogKey eq 1 or t.backlog.backlogKey eq 2}">
										<pronto:icons name="mover_para_futuro.png" title="Mover para Futuro" onclick="pronto.moverParaFuturo(${t.ticketKey},true)"></pronto:icons>
									</c:if>
									<c:if test="${t.backlog.backlogKey ne 4 and t.backlog.backlogKey ne 5}">
										<pronto:icons name="mover_para_lixeira.png" title="Mover para a Lixeira" onclick="pronto.jogarNoLixo(${t.ticketKey},true)"></pronto:icons>
									</c:if>
								</c:if>

								<c:if test="${t.backlog.backlogKey eq 4 or t.backlog.backlogKey eq 5}">
									<pronto:icons name="restaurar.png" title="Restaurar para o Inbox" onclick="pronto.restaurar(${t.ticketKey},true)"></pronto:icons>
								</c:if>
							</span>
						</td>
						<td>
							${t.tipoDeTicket.descricao}
						</td>
						<c:if test="${backlog.impedimentos}"><td>${t.responsavel}</td></c:if>
						<td>${t.cliente}</td>
						<td>${t.modulo}</td>
						<td class="valorDeNegocio">${t.valorDeNegocio}</td>
						<td class="esforco">${t.esforco}</td>
						<td>${t.kanbanStatus.descricao}</td>
						<td>${t.tempoDeVidaEmDias}</td>
					</tr>
					<c:forEach items="${t.filhos}" var="f">
						<c:if test="${f.backlog.backlogKey eq t.backlog.backlogKey}">
							<c:set var="cor" value="${!cor}"/>	 
							<tr class="${cor ? 'odd' : 'even'}" id="${f.ticketKey}" pai="${t.ticketKey}">
								<td ondblclick="trocarCategoria(this)" title="D� um duplo clique para alterar a categoria" categoriaKey="${f.categoria ne null ? f.categoria.categoriaKey : 0}">
									<c:if test="${f.categoria ne null}">
										<span class="categoria categoria-${f.categoria.cor}">
											${f.categoria.descricao}
										</span>
									</c:if>
								</td>
								<td>
									<a href="${raiz}tickets/${f.ticketKey}" title="Editar">
										${f.ticketKey}
									</a>
								</td>
								<td>
									<span class="titulo">${f.titulo}</span>
									<span class="opcao" style="display: none">
										<pronto:icons name="ver_descricao.png" title="Ver Descri��o" onclick="verDescricao(${f.ticketKey});"/>
										<a href="${raiz}tickets/${f.ticketKey}"><pronto:icons name="editar.png" title="Editar" /></a>

										<c:if test="${usuarioLogado.administrador or usuarioLogado.productOwner}">
											<c:if test="${f.backlog.backlogKey ne 4 and f.backlog.backlogKey ne 5}">
												<pronto:icons name="mover_para_lixeira.png" title="Mover para a Lixeira" onclick="pronto.jogarNoLixo(${f.ticketKey},true)"></pronto:icons>
											</c:if>
										</c:if>
										
										<c:if test="${f.backlog.backlogKey eq 4 or f.backlog.backlogKey eq 5}">
											<c:if test="${f.pai.backlog.backlogKey ne 4 and f.pai.backlog.backlogKey ne 5}">
												<pronto:icons name="restaurar.png" title="Restaurar para o Inbox" onclick="pronto.restaurar(${f.ticketKey},true)"></pronto:icons>
											</c:if>
										</c:if>
									</span>
								</td>
								<td>${f.tipoDeTicket.descricao}</td>
								<c:if test="${backlog.impedimentos}"><td>${f.responsavel}</td></c:if>
								<td>${f.cliente}</td>
								<td style="color:gray;" class="valorDeNegocio"></td>
								<td style="color:gray;" class="esforco">${f.esforco}</td>
								<td>${f.kanbanStatus.descricao}</td>
								<td></td>
							</tr>
						</c:if>
					</c:forEach>
					<tr style="height: 1px;" class="divisor" ticket="${f.ticketKey}">
						<td colspan="16" style="background-color:#b4c24b"></td>
					</tr>
				</c:forEach>
			<!-- Tarefas Soltas -->
			<c:forEach items="${tarefasSoltas}" var="s">
					<c:set var="cor" value="${!cor}"/>	 
					<tr class="${cor ? 'odd' : 'even'}" id="${s.ticketKey}" pai="${s.pai.ticketKey}" categoriaKey="${s.categoria ne null ? s.categoria.categoriaKey : 0}">
						<td ondblclick="trocarCategoria(this)" title="D� um duplo clique para alterar a categoria">
							<c:if test="${s.categoria ne null}">
								<span class="categoria categoria-${s.categoria.cor}">
									${s.categoria.descricao}
								</span>
							</c:if>
						</td>
						<td>
							<a href="${raiz}tickets/${s.ticketKey}" title="Editar">
								${s.ticketKey}
							</a>
						</td>
						<td>
							<span class="titulo">${s.titulo}</span>
							<span class="opcao" style="display: none;">
								<pronto:icons name="ver_descricao.png" title="Ver Descri��o" onclick="verDescricao(${s.ticketKey});"/>
								<a href="${raiz}tickets/${s.ticketKey}"><pronto:icons name="editar.png" title="Editar" /></a>

								<c:if test="${usuarioLogado.administrador or usuarioLogado.productOwner}">
									<c:if test="${s.backlog.backlogKey ne 4 and s.backlog.backlogKey ne 5}">
										<pronto:icons name="mover_para_lixeira.png" title="Mover para a Lixeira" onclick="pronto.jogarNoLixo(${s.ticketKey},true)" />
									</c:if>
								</c:if>
								<c:if test="${s.backlog.backlogKey eq 4 or s.backlog.backlogKey eq 5}">
									<c:if test="${s.pai.backlog.backlogKey ne 4 and s.pai.backlog.backlogKey ne 5}">
										<pronto:icons name="restaurar.png" title="Restaurar para o Inbox" onclick="pronto.restaurar(${s.ticketKey},true)" />
									</c:if>
								</c:if>
							</span>
						</td>
						<td>${s.tipoDeTicket.descricao}</td>
						<c:if test="${backlog.impedimentos}"><td>${s.responsavel}</td></c:if>
						<td>${s.cliente}</td>
						<td style="color:gray;" class="valorDeNegocio">${s.valorDeNegocio}</td>
						<td style="color:gray;" class="esforco">${s.esforco}</td>
						<td>${s.kanbanStatus.descricao}</td>
						<td></td>
					</tr>
				</c:forEach>
			</tbody>
			<tfoot>
				<tr>
					<th colspan="6">Total</th>
					<c:if test="${backlog.impedimentos}"><th></th></c:if>
					<th id="somaValorDeNegocio">${valorDeNegocioTotal}</th>
					<th id="somaEsforco">${esforcoTotal}</th>
					<th></th>
					<th id="tempoDeVidaMedio">${tempoDeVidaMedioEmDias}</th>
				</tr>
				<tr>
					<td colspan="9"><i>* ${descricaoTotal}</i></td>
				</tr>
			</tfoot>
		</table>	
		
		<c:if test="${backlog ne null and backlog.backlogKey eq 1}">
			<div align="center" class="buttons">
				<button type="button" onclick="pronto.doGet('${raiz}tickets/novo?tipoDeTicketKey=2')">Nova Est�ria</button>&nbsp;&nbsp;
				<button type="button" onclick="pronto.doGet('${raiz}tickets/novo?tipoDeTicketKey=3')">Novo Defeito</button>
			</div>
		</c:if>
		
		<div title="Descri��o" id="dialog" style="display: none; width: 500px;">
			<div align="left" id="dialogDescricao">Aguarde...</div>
		</div>

		<div title="Escolha um Sprint" id="dialogSelecionarSprint" style="display: none; width: 500px;">
			<select id="selecionarSprint">
				<c:forEach items="${projetos}" var="projeto">
					<optgroup label="${projeto.nome}"></optgroup>
					<c:forEach items="${projeto.sprints}" var="sp">
						<option ${sprint.sprintKey eq sp.sprintKey ? 'selected="selected"' : ''} value="${sp.sprintKey}">${sp.nome} ${sp.atual ? ' (atual)' : ''} </option>
					</c:forEach>
				</c:forEach>			
			</select>
			<input type="hidden" id="ticketKey" value="" />
			<br/><br/>
			<button onclick="$('#dialogSelecionarSprint').dialog('close');">Cancelar</button>
			<button onclick="pronto.moverParaSprint($('#ticketKey').val(), $('#selecionarSprint').val(), true)">Mover</button>
		</div>
		
		<div id="divCategorias">
			<div style="display: none; width: 500px;">
				<select id="trocaCategoria" onchange="salvarCategoria(this);" >
					<option value="0" class="nenhuma">Nenhuma</option>
					<c:forEach items="${categorias}" var="c">
						<option value="${c.categoriaKey}" categoriaClass="categoria-${c.cor}">${c.descricao}</option>
					</c:forEach>			
				</select>
			</div>
		</div>
		
		<script type="text/javascript">
			$(function(){
				var categoria = "${param.categoriaKey}";
				var tipoDeTicket = "${param.tipoDeTicketKey}";
				var kanbanStatusKey = "${param.kanbanStatusKey}";
				
				if (categoria.length > 0) {
					$('#categoriaKey').val(categoria);	
				}
				
				if (tipoDeTicket.length > 0) {
					$('#tipoDeTicketKey').val(tipoDeTicket);	
				}
				
				if (kanbanStatusKey.length > 0) {
					$('#kanbanStatusKey').val(kanbanStatusKey);	
				}
			});
		</script>
	</body>
</html>