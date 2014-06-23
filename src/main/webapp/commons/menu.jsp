<%@ include file="/commons/taglibs.jsp"%>

<c:if test="${usuarioLogado ne null}">

    <!-- """""""MENU BOOTSTRAP""""""" -->
    <div class="navbar navbar-default" style="font-size: 1.3rem;">
        <div class="navbar-header">
            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-responsive-collapse">
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
        <a class="navbar-brand" href="${raiz}">&nbsp;PRONTO</a>
        </div>
        <div class="navbar-collapse collapse navbar-responsive-collapse">
            <ul class="nav navbar-nav">
                <li class="active dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">Cadastros <b class="caret"></b></a>
                    <ul class="dropdown-menu">
                        <li><a href="${raiz}categorias"><span class="glyphicon glyphicon-tags"></span>&nbsp;&nbsp;Categorias</a></li>
                        <li><a href="${raiz}causasDeDefeito"><span class="glyphicon glyphicon-warning-sign"></span>&nbsp;&nbsp;Causas de Defeito</a></li>

                        <c:if test="${usuarioLogado.administrador or usuarioLogado.scrumMaster or usuarioLogado.productOwner}">
                            <li><a href="${raiz}clientes"><span class="glyphicon glyphicon-shopping-cart"></span>&nbsp;&nbsp;Clientes</a></li>
                        </c:if>

                        <c:if test="${usuarioLogado.administrador or usuarioLogado.productOwner}">
                            <li><a href="${raiz}projetos"><span class="glyphicon glyphicon-tasks"></span>&nbsp;&nbsp;Projetos</a></li>
                            <li><a href="${raiz}modulos"><span class="glyphicon glyphicon-new-window"></span>&nbsp;&nbsp;Módulos</a></li>
                        </c:if>
                        
                        <c:if test="${usuarioLogado.administrador or usuarioLogado.equipe}">
                            <li><a href="${raiz}motivosReprovacao"><span class="glyphicon glyphicon-thumbs-down"></span>&nbsp;&nbsp;Motivos de Reprovação</a></li>
                        </c:if>

                        <c:if test="${usuarioLogado.administrador or usuarioLogado.equipe}">
                            <li><a href="${raiz}checklists"><span class="glyphicon glyphicon-th-list"></span>&nbsp;&nbsp;Checklists</a></li>
                        </c:if>
                        <li><a href="${raiz}usuarios"><span class="glyphicon glyphicon-user"></span>&nbsp;&nbsp;Usuários</a></li>
                    </ul>
                </li>
                <li class="dropdown"><a href="#" class="dropdown-toggle" data-toggle="dropdown">Backlogs <b class="caret"></b></a>
                    <ul class="dropdown-menu">
                        <c:if test="${usuarioLogado.administrador or usuarioLogado.scrumMaster or usuarioLogado.productOwner or usuarioLogado.equipe}">
                            <li><a href="${raiz}backlogs/sprints/atual"><span class="glyphicon glyphicon-play-circle"></span>&nbsp;&nbsp;Sprint Atual</a></li>
                            <li><a href="${raiz}backlogs/inbox"><span class="glyphicon glyphicon-envelope"></span>&nbsp;&nbsp;Inbox</a></li>
                            <li><a href="${raiz}backlogs/productBacklog"><span class="glyphicon glyphicon-book"></span>&nbsp;&nbsp;Product Backlog</a></li>
                            <li><a href="${raiz}backlogs/futuro"><span class="glyphicon glyphicon-time"></span>&nbsp;&nbsp;Futuro</a></li>
                            <li><a href="${raiz}backlogs/impedimentos"><span class="glyphicon glyphicon-pause"></span>&nbsp;&nbsp;Impedimentos</a></li>
                            <li><a href="${raiz}backlogs/lixeira"><span class="glyphicon glyphicon-trash"></span>&nbsp;&nbsp;Lixeira</a></li>
                            <li><a href="${raiz}backlogs/clientes"><span class="glyphicon glyphicon-list-alt"></span>&nbsp;&nbsp;Pendentes</a></li>
                            <c:if test="${usuarioLogado.clientePapel}">
                                <li><a href="${raiz}clientes/backlog">Cliente</a></li>
                            </c:if>
                            <li><a href="${raiz}buscar"><span class="glyphicon glyphicon-search"></span>&nbsp;&nbsp;Buscar Tickets</a></li>
                        </c:if>
                    </ul>
                </li>
                <c:if test="${usuarioLogado.administrador or usuarioLogado.scrumMaster or usuarioLogado.productOwner or usuarioLogado.equipe}">
                    <li><a href='${raiz}dashboard'><span>Dashboard</span></a></li>
                    <li><a href='${raiz}kanban'><span>Kanban</span></a></li>
                    <li><a href='${raiz}sprints'><span>Sprints</span></a></li>
                </c:if>
                <li class="dropdown"><a href="#" class="dropdown-toggle" data-toggle="dropdown">Ferramentas <b class="caret"></b></a>
                    <ul class="dropdown-menu">
                        <c:if test="${usuarioLogado.administrador or usuarioLogado.equipe}">
                            <li><a href="${raiz}tickets/branches"><span class="glyphicon glyphicon-random"></span>&nbsp;&nbsp;Branches</a></li>
                            <li><a href="${raiz}bancosDeDados"><span class="glyphicon glyphicon-hdd"></span>&nbsp;&nbsp;Bancos de dados</a></li>
                            <li><a href="${raiz}scripts"><span class="glyphicon glyphicon-pushpin"></span>&nbsp;&nbsp;Scripts</a></li>
                            <li><a href="${raiz}execucoes/pendentes"><span class="glyphicon glyphicon-play-circle"></span>&nbsp;&nbsp;Execuções de Scripts</a></li>
                        </c:if>
                        <c:if test="${usuarioLogado.administrador}">    
                            <li><a href="${raiz}configuracoes"><span class="glyphicon glyphicon-cog"></span>&nbsp;&nbsp;Configurações</a></li>
                        </c:if>    
                    </ul>
                </li>
                <li class="dropdown"><a href="#" class="dropdown-toggle" data-toggle="dropdown">Relatórios <b class="caret"></b></a>
                    <ul class="dropdown-menu">
                        <li><a href="${raiz}stream"><span class="glyphicon glyphicon-align-left"></span>&nbsp;&nbsp;Stream</a></li>
                        <li><a href="${raiz}burndown"><span class="glyphicon glyphicon-signal"></span>&nbsp;&nbsp;Burndown Chart</a></li>
                        <li><a href="${raiz}relatorios/tickets"><span class="glyphicon glyphicon-tag"></span>&nbsp;&nbsp;Gráfico de Tickets</a></li>
                        <li><a href="${raiz}relatorios/releaseNotes"><span class="glyphicon glyphicon-edit"></span>&nbsp;&nbsp;Notas de Release</a></li>
                    </ul>
                </li>
            </ul>

            <ul class="nav navbar-nav navbar-right">
                <li>
                    <form class="navbar-form" role="search">
                        <div class="input-group">
                            <input type="text" class="form-control" placeholder="Busca" name="busca" id="busca" accesskey="b">
                         <span class="input-group-btn">
                             <button class="btn btn-primary" type="button" onclick="pronto.buscar();">
                                 <span class="glyphicon glyphicon-search"></span>
                             </button>
                         </span>
                        </div>
                    </form>
                </li>
                <li><a href="${raiz}logout">Sair&nbsp;&nbsp;&nbsp;</a></li>
            </ul>
        </div>
    </div>

</c:if>