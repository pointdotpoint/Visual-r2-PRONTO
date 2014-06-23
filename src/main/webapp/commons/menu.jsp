<%@ include file="/commons/taglibs.jsp"%>

<c:if test="${usuarioLogado ne null}">
    <!--
<span id="prontoMenu">
<table class="rootVoices" cellspacing='0' cellpadding='0' border='0'>
	<tr>
	    <td class="rootVoice {menu: 'menuCadastros'}" >Cadastros</td>
	    <td class="rootVoice {menu: 'menuBacklogs'}" >Demandas</td>
    -->

		<c:if test="${usuarioLogado.administrador or usuarioLogado.scrumMaster or usuarioLogado.productOwner or usuarioLogado.equipe}">
            <!--
					<td class="rootVoice {menu: 'empty'}" onclick="goTo('${raiz}dashboard');">Dashboard</td>
	   		<td class="rootVoice {menu: 'empty'}" onclick="goTo('${raiz}kanban');">Kanban</td>
			<td class="rootVoice {menu: 'empty'}" onclick="goTo('${raiz}sprints');">Sprints</td>
	        -->
			</c:if>
    <!--
	    <td class="rootVoice {menu: 'menuFerramentas'}" >Ferramentas</td>
	    <td class="rootVoice {menu: 'menuRelatorios'}">Relatórios</td>
	    <td class="rootVoice {menu: 'empty'}" onclick="goTo('${raiz}logout');">Sair</td>
	</tr>
</table>
</span>
-->

    <!-- """""""MENU BOOTSTRAP""""""" -->
    <div class="navbar navbar-default" style="font-size: 1.3rem;">
        <div class="navbar-header">
            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-responsive-collapse">
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
        <a class="navbar-brand" href="#">&nbsp;PRONTO</a>
        </div>
        <div class="navbar-collapse collapse navbar-responsive-collapse">
            <ul class="nav navbar-nav">
                <li class="active dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">Cadastros <b class="caret"></b></a>
                    <ul class="dropdown-menu">
                        <li><a href="#"><span class="glyphicon glyphicon-tags"></span>&nbsp;&nbsp;Categorias</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-warning-sign"></span>&nbsp;&nbsp;Causas de Defeito</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-shopping-cart"></span>&nbsp;&nbsp;Clientes</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-tasks"></span>&nbsp;&nbsp;Projetos</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-new-window"></span>&nbsp;&nbsp;Módulos</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-thumbs-down"></span>&nbsp;&nbsp;Motivos de Reprovação</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-th-list"></span>&nbsp;&nbsp;Checklists</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-user"></span>&nbsp;&nbsp;Usuários</a></li>
                    </ul>
                </li>
                <li class="dropdown"><a href="#" class="dropdown-toggle" data-toggle="dropdown">Backlogs <b class="caret"></b></a>
                    <ul class="dropdown-menu">
                        <li><a href="#"><span class="glyphicon glyphicon-play-circle"></span>&nbsp;&nbsp;Sprint Atual</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-envelope"></span>&nbsp;&nbsp;Inbox</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-book"></span>&nbsp;&nbsp;Product Backlog</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-time"></span>&nbsp;&nbsp;Futuro</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-pause"></span>&nbsp;&nbsp;Impedimentos</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-trash"></span>&nbsp;&nbsp;Lixeira</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-list-alt"></span>&nbsp;&nbsp;Pendentes</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-search"></span>&nbsp;&nbsp;Buscar Tickets</a></li>
                    </ul>
                </li>
                <li><a href='#'><span>Dashboard</span></a></li>
                <li><a href='#'><span>Sprints</span></a></li>
                <li class="dropdown"><a href="#" class="dropdown-toggle" data-toggle="dropdown">Ferramentas <b class="caret"></b></a>
                    <ul class="dropdown-menu">
                        <li><a href="#"><span class="glyphicon glyphicon-random"></span>&nbsp;&nbsp;Branches</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-hdd"></span>&nbsp;&nbsp;Bancos de dados</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-pushpin"></span>&nbsp;&nbsp;Scripts</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-play-circle"></span>&nbsp;&nbsp;Execuções de Scripts</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-cog"></span>&nbsp;&nbsp;Configurações</a></li>
                    </ul>
                </li>
                <li class="dropdown"><a href="#" class="dropdown-toggle" data-toggle="dropdown">Relatórios <b class="caret"></b></a>
                    <ul class="dropdown-menu">
                        <li><a href="#"><span class="glyphicon glyphicon-align-left"></span>&nbsp;&nbsp;Stream</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-signal"></span>&nbsp;&nbsp;Burndown Chart</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-tag"></span>&nbsp;&nbsp;Gráfico de Tickets</a></li>
                        <li><a href="#"><span class="glyphicon glyphicon-edit"></span>&nbsp;&nbsp;Notas de Release</a></li>
                    </ul>
                </li>
            </ul>

            <ul class="nav navbar-nav navbar-right">
                <li>
                    <!--    <div class="col-sm-3 col-md-3"> -->
                    <form class="navbar-form" role="search">
                        <div class="input-group">
                            <input type="text" class="form-control" name="x" placeholder="Busca">
                         <span class="input-group-btn">
                             <button class="btn btn-primary" type="button" >
                                 <span class="glyphicon glyphicon-search"></span>
                             </button>
                         </span>
                        </div>
                    </form>
                    <!--   </div> -->
                </li>
                <li><a href="#">Sair&nbsp;&nbsp;&nbsp;</a></li>
            </ul>
        </div>
    </div>


<!--
<div id="menuCadastros" class="mbmenu">
    <c:if test="${usuarioLogado.administrador or usuarioLogado.productOwner}">
		<a img="categorias.png" href="${raiz}categorias">Categorias</a>
	</c:if>
	<c:if test="${usuarioLogado.administrador or usuarioLogado.equipe}">
		<a img="defeito.png" href="${raiz}causasDeDefeito">Causas de Defeito</a>
	</c:if>
	<c:if test="${usuarioLogado.administrador or usuarioLogado.scrumMaster or usuarioLogado.productOwner}">
		<a img="clientes.png" href="${raiz}clientes">Clientes</a>
	</c:if>
	<c:if test="${usuarioLogado.administrador or usuarioLogado.productOwner}">
		<li><a img="projetos.png" href="${raiz}projetos">Projetos</a></li>
		<li><a img="modulos.png" href="${raiz}modulos">Mï¿½dulos</a></li>
	</c:if>
	<c:if test="${usuarioLogado.administrador or usuarioLogado.equipe}">
		<li><a img="reprovacao.png" href="${raiz}motivosReprovacao">Motivos De Reprovaï¿½ï¿½o</a></li>
	</c:if>
	<c:if test="${usuarioLogado.administrador or usuarioLogado.equipe}">
		<a img="checklist.png" href="${raiz}checklists">Checklists</a>
	</c:if>
	<a img="usuarios.png" href="${raiz}usuarios">Usuï¿½rios</a>
    <a rel="separator"></a>
</div>

<div id="menuBacklogs" class="mbmenu">
	<c:if test="${usuarioLogado.administrador or usuarioLogado.scrumMaster or usuarioLogado.productOwner or usuarioLogado.equipe}">
		<a href="${raiz}backlogs/sprints/atual" img="sprint_atual.png">Sprint Atual</a>
		<a href="${raiz}backlogs/inbox" img="inbox.png">Inbox</a>
		<a href="${raiz}backlogs/productBacklog" img="estorias.gif">Product Backlog</a>
		<a href="${raiz}backlogs/futuro" img="futuro.png">Futuro</a>
		<a href="${raiz}backlogs/impedimentos" img="impedimentos.png">Impedimentos</a>
		<a href="${raiz}backlogs/lixeira" img="lixeira.png">Lixeira</a>
		<a href="${raiz}backlogs/clientes" img="pendentes.png">Pendentes</a>
		<c:if test="${usuarioLogado.clientePapel}">
			<li><a href="${raiz}clientes/backlog" img="estorias.gif">Cliente</a></li>
		</c:if>
		<a href="${raiz}buscar" img="buscar.png">Buscar Tickets</a>
	</c:if>
</div>

<div id="menuFerramentas" class="mbmenu">
	<c:if test="${usuarioLogado.administrador or usuarioLogado.equipe}">
		<a img="branches.png" href="${raiz}tickets/branches">Branches</a>
		<a img="banco_de_dados.png" href="${raiz}bancosDeDados">Bancos de Dados</a>
		<a img="script.png" href="${raiz}scripts">Scripts</a>
		<a img="execucoes.png" href="${raiz}execucoes/pendentes">Execuï¿½ï¿½es de Scripts</a>
	</c:if>
	<c:if test="${usuarioLogado.administrador}">
		<a img="configuracoes.png" href="${raiz}configuracoes">Configuraï¿½ï¿½es</a>
	</c:if>
</div>

<div id="menuRelatorios" class="mbmenu">
	<a img="stream.png" href="${raiz}stream">Stream</a>
	<a img="burndown_chart.png" href="${raiz}burndown">Burndown Chart</a>
	<a img="grafico.png" href="${raiz}relatorios/tickets">Grï¿½fico de Tickets</a>
	<a img="nota.gif" href="${raiz}relatorios/releaseNotes">Notas de Release</a>
</div>
-->
</c:if>