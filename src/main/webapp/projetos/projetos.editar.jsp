<%@ include file="/commons/taglibs.jsp"%>
<html>
	<head>
		<title>Cadastro de Projetos</title>

        <link rel="stylesheet" type="text/css" media="all" href="projetos.css" />

	</head>
	<body>
		<form action="${raiz}projetos/" id="formProjeto" method="post">

			<ul class="info">
				<h1>Cadastro de Projetos </h1>
			</ul>
			<div class="group">
				<form:hidden path="projeto.projetoKey"/>
				<c:if test="${projeto.projetoKey gt 0}">
					<div>
						<b>${projeto.projetoKey}</b>
						<p>C�digo</p>
					</div>
				</c:if>
				
				<div>
					<form:input path="projeto.nome" cssClass="required" size="40"/>
					<p>Nome</p>

                    <button type="button" class="btn btn-default btn-lg">
                        <span class="glyphicon glyphicon-star"></span> Star
                    </button>

                        <div class="col-md-2">
                            <select type="text" class="form-control multiselect multiselect-icon" role="multiselect">
                                <option value="0" data-icon="glyphicon-camera" selected="selected">Photos</option>
                                <option value="1" data-icon="glyphicon-link">Link</option>
                                <option value="2" data-icon="glyphicon-pencil">Edit</option>
                                <option value="3" data-icon="glyphicon-shopping-cart">Cart</option>
                            </select>
                        </div>

					<input type="hidden" name="paraEvitarProblemaDoSubmitNoEnter" value="Nada"/>
				</div>
				
				<c:if test="${projeto.projetoKey gt 0}">
					<div>
						<form:select path="projeto.etapaDeInicioDoCiclo.kanbanStatusKey" cssClass="required" items="${projeto.etapasDoKanban}" itemLabel="descricao" itemValue="kanbanStatusKey"/>

						<p>Etapa de In�cio</p>
					</div>
					
					<div>
						<form:select path="projeto.etapaDeTerminoDoCiclo.kanbanStatusKey" cssClass="required" items="${projeto.etapasDoKanban}"  itemLabel="descricao" itemValue="kanbanStatusKey"/>
						<p>Etapa de T�rmino</p>
					</div>
				</c:if>
			</div>

			<c:if test="${projeto.projetoKey gt 0}">
				<br/>
				<h3>
					Sprints
					<pronto:icons name="adicionar.png" title="Incluir Sprint" onclick="goTo('${raiz}sprints/novo?projetoKey=${projeto.projetoKey}')"/>
				
				</h3>
				<ul id="sprints">
					<c:forEach items="${projeto.sprints}" var="sprint">
						<li class="sprint">
							<a href="${raiz}sprints/${sprint.sprintKey}">${sprint.nome}</a> 
							- De <fmt:formatDate value="${sprint.dataInicial}"/> 
							� <fmt:formatDate value="${sprint.dataFinal}"/>
						</li>
					</c:forEach>
				</ul>
			
				<br/>
				<div>
					<h3>Etapas do Kanban
						<pronto:icons name="adicionar.png" title="Incluir Etapa no Kanban" clazz="icon-adicionar" onclick="incluirEtapa()"/>
					</h3>	
					<ul id="kanban">
						<c:forEach items="${projeto.etapasDoKanban}" var="etapa" varStatus="status">
							<li class="${status.first ? 'first' : (status.last ? 'last' : 'middle')} etapa" key="${etapa.kanbanStatusKey}">
								<span class="etapa-descricao">${etapa.descricao}</span>
							</li>
						</c:forEach>
					</ul>
				</div>
				
				<br/>
				<div>
					<h3>Milestones
						<pronto:icons name="adicionar.png" title="Incluir Milestone" clazz="icon-adicionar" onclick="incluirMilestone()"/>
					</h3>	
					<ul id="milestones">
						<c:forEach items="${projeto.milestones}" var="milestone" varStatus="status">
							<li class="milestone" key="${milestone.milestoneKey}">
								<span class="descricao">${milestone.nome}</span>
							</li>
						</c:forEach>
					</ul>
				</div>
			</c:if>
		
		<div align="center" class="buttons">
				<br />
				<button type="button" onclick="window.location.href='${raiz}projetos'">Cancelar</button>
				<button type="submit">Salvar</button><br/>
			</div>
		</form>

		<script>
		var projetoKey = "${projeto.projetoKey}";
		</script>
        <script src="projetos.js"></script>
    </body>
</html>